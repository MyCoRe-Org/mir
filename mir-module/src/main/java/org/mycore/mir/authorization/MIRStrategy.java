/**
 * 
 */
package org.mycore.mir.authorization;

import java.text.MessageFormat;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.TimeUnit;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.log4j.Logger;
import org.hibernate.Criteria;
import org.hibernate.Session;
import org.hibernate.criterion.Projections;
import org.hibernate.criterion.Restrictions;
import org.mycore.access.MCRAccessInterface;
import org.mycore.access.MCRAccessManager;
import org.mycore.access.MCRAccessRule;
import org.mycore.access.strategies.MCRAccessCheckStrategy;
import org.mycore.access.strategies.MCRCreatorRuleStrategy;
import org.mycore.backend.hibernate.MCRHIBConnection;
import org.mycore.backend.hibernate.tables.MCRACCESS;
import org.mycore.common.MCRCache;
import org.mycore.datamodel.classifications2.MCRCategLinkReference;
import org.mycore.datamodel.classifications2.MCRCategLinkService;
import org.mycore.datamodel.classifications2.MCRCategLinkServiceFactory;
import org.mycore.datamodel.classifications2.MCRCategoryID;
import org.mycore.datamodel.metadata.MCRMetadataManager;
import org.mycore.datamodel.metadata.MCRObjectID;

/**
 * This is the standard access strategy used in the archive application. This is the queue of rule ID that is checked
 * every time checkPermission() is called:
 * <ul>
 * <li> <code>&lt;MCRObjectID&gt;</code></li>
 * <li>if <code>objectType != 'derivate'</code> check via {@link MCRCreatorRuleStrategy}</li>
 * <li>all categories of the owning object with the rule ID <code>derivate:&lt;MCRCategoryID&gt;</code> where
 * &lt;MCRCategoryID&gt; is a linked category</li>
 * <li>return of <code>checkPermission(&lt;objectID&gt;, permission)</code>, objectID is owning MCRObject
 * <li>fallback to {@link MCRCreatorRuleStrategy}</li>
 * </ul>
 * 
 * @author Thomas Scheffler (yagee)
 * @since 0.3
 */
public class MIRStrategy implements MCRAccessCheckStrategy {
    private static final Pattern TYPE_PATTERN = Pattern.compile("[^_]*_([^_]*)_*");

    private static final long CACHE_TIME = 1000 * 60 * 60;

    private static final Logger LOGGER = Logger.getLogger(MIRStrategy.class);

    private static final MCRCache<String, List<MCRCategoryID>> PERMISSION_CATEGORY_MAPPING_CACHE = new MCRCache<String, List<MCRCategoryID>>(
        20,
        "MIRStrategy");

    private static final String DERIVATE_RULE_PREFIX = "derivate:";

    private static final String FAV_CLASS = "mir_access"; //generateMCRCategoryIDList() filters this classification

    private final MCRAccessInterface ACCESS_IMPL;

    private final MCRCategLinkService LINK_SERVICE;

    private final MCRAccessCheckStrategy BASE_STRATEGY;

    public MIRStrategy() {
        ACCESS_IMPL = MCRAccessManager.getAccessImpl();
        LINK_SERVICE = MCRCategLinkServiceFactory.getInstance();
        BASE_STRATEGY = new MCRCreatorRuleStrategy();
    }

    public boolean checkPermission(String id, String permission) {
        String objectType = getObjectType(id);
        if (!"derivate".equals(objectType)) {
            return BASE_STRATEGY.checkPermission(id, permission);
        }
        LOGGER.debug("checking permission '" + permission + "' for id " + id);
        MCRAccessRule rule = ACCESS_IMPL.getAccessRule(id, permission);
        if (rule != null) {
            return rule.validate();
        }
        //get MCRObjectID from derivate
        MCRObjectID objectId = MCRMetadataManager
            .getObjectId(MCRObjectID.getInstance(id), CACHE_TIME, TimeUnit.SECONDS);
        if (objectId == null) {
            LOGGER.warn("Could not get MCRObject for derivate: " + id);
        } else {
            List<MCRCategoryID> accessMappedCategories = getAccessMappedCategories(permission);
            if (!accessMappedCategories.isEmpty()) {
                MCRCategLinkReference categLinkReference = new MCRCategLinkReference(objectId);
                for (MCRCategoryID category : accessMappedCategories) {
                    LOGGER.debug(MessageFormat.format("Checking if {0} is in category {1}.",
                        categLinkReference.getObjectID(), category));
                    if (LINK_SERVICE.isInCategory(categLinkReference, category)) {
                        LOGGER.debug("using access rule defined for category: " + category);
                        return ACCESS_IMPL.checkPermission(DERIVATE_RULE_PREFIX + category.toString(), permission);
                    }
                }
            }
            LOGGER.debug("try to find rule for derivate in object");
            return checkPermission(objectId.toString(), permission);
        }
        return BASE_STRATEGY.checkPermission(id, permission);
    }

    private static String getObjectType(String id) {
        Matcher m = TYPE_PATTERN.matcher(id);
        if (m.find() && (m.groupCount() == 1)) {
            return m.group(1);
        }
        return "";
    }

    @SuppressWarnings("unchecked")
    private static List<MCRCategoryID> getAccessMappedCategories(String permission) {
        List<MCRCategoryID> result = PERMISSION_CATEGORY_MAPPING_CACHE.getIfUpToDate(permission,
            System.currentTimeMillis() - CACHE_TIME);
        if (result != null) {
            return result;
        }
        Session session = MCRHIBConnection.instance().getSession();
        Criteria criteria = session.createCriteria(MCRACCESS.class);
        criteria.add(Restrictions.like("key.objid", DERIVATE_RULE_PREFIX + "%"));
        criteria.add(Restrictions.eq("key.acpool", permission));
        criteria.setProjection(Projections.property("key.objid"));
        result = generateMCRCategoryIDList(criteria.list());
        PERMISSION_CATEGORY_MAPPING_CACHE.put(permission, result);
        return result;
    }

    private static List<MCRCategoryID> generateMCRCategoryIDList(List<String> list) {
        ArrayList<MCRCategoryID> categIds = new ArrayList<MCRCategoryID>(list.size());
        for (String result : list) {
            String[] id = result.substring(DERIVATE_RULE_PREFIX.length()).split(":");
            if (id[0].equals(FAV_CLASS)) {
                categIds.add(new MCRCategoryID(id[0], id[1]));
            }
        }
        return categIds;
    }

}
