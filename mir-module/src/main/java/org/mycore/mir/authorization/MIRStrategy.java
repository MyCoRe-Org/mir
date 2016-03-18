/**
 * 
 */
package org.mycore.mir.authorization;

import java.util.Arrays;
import java.util.List;
import java.util.Optional;
import java.util.concurrent.TimeUnit;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.hibernate.Criteria;
import org.hibernate.Session;
import org.hibernate.criterion.Projections;
import org.hibernate.criterion.Restrictions;
import org.mycore.access.MCRAccessInterface;
import org.mycore.access.MCRAccessManager;
import org.mycore.access.strategies.MCRAccessCheckStrategy;
import org.mycore.access.strategies.MCRCreatorRuleStrategy;
import org.mycore.access.strategies.MCRObjectBaseStrategy;
import org.mycore.access.strategies.MCRObjectIDStrategy;
import org.mycore.backend.hibernate.MCRHIBConnection;
import org.mycore.backend.jpa.access.MCRACCESS;
import org.mycore.common.MCRCache;
import org.mycore.common.MCRException;
import org.mycore.common.MCRSessionMgr;
import org.mycore.common.config.MCRConfiguration;
import org.mycore.datamodel.classifications2.MCRCategLinkReference;
import org.mycore.datamodel.classifications2.MCRCategLinkService;
import org.mycore.datamodel.classifications2.MCRCategLinkServiceFactory;
import org.mycore.datamodel.classifications2.MCRCategoryID;
import org.mycore.datamodel.metadata.MCRMetadataManager;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.mir.authorization.accesskeys.MIRAccessKeyManager;
import org.mycore.mir.authorization.accesskeys.MIRAccessKeyPair;

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

    private static enum PermissionIDType {
        MCRObject, MCRDerivate, Other;
        public static PermissionIDType fromID(String id) {
            Matcher m = TYPE_PATTERN.matcher(id);
            if (m.find() && (m.groupCount() == 1)) {
                return "derivate".equals(m.group(1)) ? MCRDerivate : MCRObject;
            }
            return Other;

        }
    }

    private static final Pattern TYPE_PATTERN = Pattern.compile("[^_]+_([^_]+)_[0-9]+");

    private static final Logger LOGGER = LogManager.getLogger();

    private static final MCRObjectIDStrategy ID_STRATEGY = new MCRObjectIDStrategy();

    private static final MCRObjectBaseStrategy OBJECT_BASE_STRATEGY = new MCRObjectBaseStrategy();

    private static final MCRCreatorRuleStrategy CREATOR_STRATEGY = new MCRCreatorRuleStrategy();

    private static final long CACHE_TIME = 1000 * 60 * 60;

    private static final MCRCache<String, List<MCRCategoryID>> PERMISSION_CATEGORY_MAPPING_CACHE = new MCRCache<String, List<MCRCategoryID>>(
        20, "MIRStrategy");

    private final List<String> ACCESS_CLASSES;

    private final MCRCategLinkService LINK_SERVICE;

    private MCRAccessInterface ACCESS_IMPL;

    public MIRStrategy() {
        ACCESS_CLASSES = MCRConfiguration.instance().getStrings("MIR.Access.Strategy.Classifications",
            Arrays.asList("mir_access"));
        LINK_SERVICE = MCRCategLinkServiceFactory.getInstance();
        ACCESS_IMPL = MCRAccessManager.getAccessImpl();
    }

    /* (non-Javadoc)
     * @see org.mycore.access.strategies.MCRAccessCheckStrategy#checkPermission(java.lang.String, java.lang.String)
     */
    @Override
    public boolean checkPermission(String id, String permission) {
        LOGGER.debug("checkPermission({}, {})", id, permission);
        switch (PermissionIDType.fromID(id)) {
            case MCRObject:
                return checkObjectPermission(MCRObjectID.getInstance(id), permission);
            case MCRDerivate:
                return checkDerivatePermission(MCRObjectID.getInstance(id), permission);
            case Other:
                return checkOtherPermission(id, permission);
            default:
                throw new MCRException("Could not handle PermissionIDType: " + PermissionIDType.fromID(id));
        }
    }

    private boolean checkObjectPermission(MCRObjectID objectId, String permission) {
        LOGGER.debug("checkObjectPermission({}, {})", objectId, permission);
        boolean isWritePermission = MCRAccessManager.PERMISSION_WRITE.equals(permission);
        boolean isReadPermission = MCRAccessManager.PERMISSION_READ.equals(permission);
        // 1. check read or write key of current user
        if ((isWritePermission || isReadPermission)) {
            String userKey = getUserKey(objectId);
            if (userKey != null) {
                MIRAccessKeyPair keyPair = MIRAccessKeyManager.getKeyPair(objectId);
                if (keyPair != null && (userKey.equals(keyPair.getWriteKey())
                    || isReadPermission && userKey.equals(keyPair.getReadKey()))) {
                    LOGGER.debug("Access granted. User has a key to access the resource {}.", objectId);
                    return true;
                }
                LOGGER.warn("Neither read nor write key matches. Remove access key from user.");
                MIRAccessKeyManager.deleteAccessKey(objectId);
            }
        }
        // 2. check if access mapping for object id exists
        String permissionId = objectId.toString();
        if (ID_STRATEGY.hasRuleMapping(permissionId, permission)) {
            LOGGER.debug("Found match in ID strategy for {} on {}.", permission, objectId);
            return ID_STRATEGY.checkPermission(permissionId, permission);
        }
        // 3. check if creator rule applies
        if (CREATOR_STRATEGY.isCreatorRuleAvailable(permissionId, permission)) {
            LOGGER.debug("Found match in CREATOR strategy for {} on {}.", permission, objectId);
            return CREATOR_STRATEGY.checkPermission(permissionId, permission);
        }
        return getAccessCategory(objectId, permission)
            // 4. check if classification rule applies
            .map(c -> {
                LOGGER.debug("using access rule defined for category: " + c);
                return ACCESS_IMPL.checkPermission(objectId.getTypeId() + ":" + c.toString(), permission);
            })
            //5. fallback to MCRObjectBaseStrategy
            .orElseGet(() -> {
                LOGGER.debug("Using BASE strategy as fallback for {} on {}.", permission, objectId);
                return OBJECT_BASE_STRATEGY.checkPermission(permissionId, permission);
            });
    }

    private boolean checkDerivatePermission(MCRObjectID derivateId, String permission) {
        LOGGER.debug("checkDerivatePermission({}, {})", derivateId, permission);
        String permissionId = derivateId.toString();
        // 1. check if base strategy applies for derivate
        if (OBJECT_BASE_STRATEGY.hasRuleMapping(permissionId, permission)) {
            return OBJECT_BASE_STRATEGY.checkPermission(permissionId, permission);
        }
        // 2. go for object permission, if object link exists.
        MCRObjectID objectId = MCRMetadataManager.getObjectId(derivateId, 10, TimeUnit.MINUTES);
        if (objectId == null) {
            LOGGER.debug("Derivate {} is an orphan. Cannot apply rules for MCRObject.", derivateId);
            return ID_STRATEGY.checkPermission(permissionId, permission);
        }
        LOGGER.debug("No rule for base strategy found, check against object {}.", objectId);
        return checkObjectPermission(objectId, permission);
    }

    private boolean checkOtherPermission(String id, String permission) {
        return ID_STRATEGY.checkPermission(id, permission);
    }

    private static String getUserKey(MCRObjectID objectId) {
        return MCRSessionMgr.getCurrentSession().getUserInformation()
            .getUserAttribute(MIRAccessKeyManager.ACCESS_KEY_PREFIX + objectId.toString());
    }

    private Optional<MCRCategoryID> getAccessCategory(MCRObjectID objectId, String permission) {
        List<MCRCategoryID> accessMappedCategories = getAccessMappedCategories(objectId.getTypeId(), permission,
            ACCESS_CLASSES);
        MCRCategLinkReference categLinkReference = new MCRCategLinkReference(objectId);
        Optional<MCRCategoryID> accessCategory = accessMappedCategories
            .stream()
            .peek(c -> LOGGER.info("Checking if {} is in category {}.", objectId, c))
            .filter(c -> LINK_SERVICE.isInCategory(categLinkReference, c))
            .findFirst();
        return accessCategory;
    }

    @SuppressWarnings("unchecked")
    private static List<MCRCategoryID> getAccessMappedCategories(String objectType, String permission,
        List<String> accessClasses) {
        List<MCRCategoryID> result = PERMISSION_CATEGORY_MAPPING_CACHE.getIfUpToDate(objectType + "_" + permission,
            System.currentTimeMillis() - CACHE_TIME);
        if (result != null) {
            return result;
        }
        Session session = MCRHIBConnection.instance().getSession();
        Criteria criteria = session.createCriteria(MCRACCESS.class);
        criteria.add(Restrictions.like("key.objid", objectType + ":%"));
        criteria.add(Restrictions.eq("key.acpool", permission));
        criteria.setProjection(Projections.property("key.objid"));
        result = generateMCRCategoryIDList(objectType, criteria.list(), accessClasses);
        PERMISSION_CATEGORY_MAPPING_CACHE.put(objectType + "_" + permission, result);
        return result;
    }

    private static List<MCRCategoryID> generateMCRCategoryIDList(String objectType, List<String> accessKeys,
        List<String> accessClasses) {
        return accessKeys.stream()
            .map(s -> s.substring((objectType + ":").length()))
            .map(MCRCategoryID::fromString)
            .filter(c -> accessClasses.contains(c.getRootID()))
            .sorted((c1, c2) -> {
                return accessClasses.indexOf(c1.getRootID()) - accessClasses.indexOf(c1.getRootID());
            })
            .collect(Collectors.toList());
    }

}
