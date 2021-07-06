/**
 *
 */
package org.mycore.mir.authorization;

import java.util.List;
import java.util.Objects;
import java.util.Optional;
import java.util.concurrent.TimeUnit;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import javax.persistence.EntityManager;
import javax.persistence.TypedQuery;
import javax.persistence.criteria.CriteriaBuilder;
import javax.persistence.criteria.CriteriaQuery;
import javax.persistence.criteria.Root;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.mycore.access.MCRAccessInterface;
import org.mycore.access.MCRAccessManager;
import org.mycore.access.strategies.MCRAccessCheckStrategy;
import org.mycore.access.strategies.MCRCreatorRuleStrategy;
import org.mycore.access.strategies.MCRObjectBaseStrategy;
import org.mycore.access.strategies.MCRObjectIDStrategy;
import org.mycore.mcr.acl.accesskey.MCRAccessKeyManager;
import org.mycore.mcr.acl.accesskey.MCRAccessKeyUserUtils;
import org.mycore.mcr.acl.accesskey.backend.MCRAccessKey;
import org.mycore.mcr.acl.accesskey.strategy.MCRAccessKeyStrategy;
import org.mycore.backend.jpa.MCREntityManagerProvider;
import org.mycore.backend.jpa.access.MCRACCESS;
import org.mycore.backend.jpa.access.MCRACCESSPK_;
import org.mycore.backend.jpa.access.MCRACCESS_;
import org.mycore.common.MCRCache;
import org.mycore.common.MCRException;
import org.mycore.common.config.MCRConfiguration2;
import org.mycore.datamodel.classifications2.MCRCategLinkReference;
import org.mycore.datamodel.classifications2.MCRCategLinkService;
import org.mycore.datamodel.classifications2.MCRCategLinkServiceFactory;
import org.mycore.datamodel.classifications2.MCRCategoryID;
import org.mycore.datamodel.metadata.MCRMetadataManager;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.mods.MCRMODSEmbargoUtils;
import org.mycore.pi.MCRPIManager;
import org.mycore.pi.MCRPIRegistrationInfo;
import org.mycore.pi.MCRPIServiceManager;
import org.mycore.user2.MCRUserManager;

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

    public static final String EDIT_PI_ROLES = "MIR.Strategy.EditPIRoles";

    private static final MCRCache<String, List<MCRCategoryID>> PERMISSION_CATEGORY_MAPPING_CACHE = new MCRCache<>(
        20, "MIRStrategy");

    private static final Pattern TYPE_PATTERN = Pattern.compile("[^_]+_([^_]+)_[0-9]+");

    private static final Logger LOGGER = LogManager.getLogger();

    private static final MCRObjectIDStrategy ID_STRATEGY = new MCRObjectIDStrategy();

    private static final MCRObjectBaseStrategy OBJECT_BASE_STRATEGY = new MCRObjectBaseStrategy();

    private static final MCRCreatorRuleStrategy CREATOR_STRATEGY = new MCRCreatorRuleStrategy();

    private static final MCRAccessKeyStrategy ACCESS_KEY_STRATEGY = new MCRAccessKeyStrategy();

    private static final long CACHE_TIME = 1000 * 60 * 60;

    private final List<String> accessClasses;

    private final MCRCategLinkService linkService;

    private MCRAccessInterface accessImpl;

    public MIRStrategy() {
        accessClasses = MCRConfiguration2.getString("MIR.Access.Strategy.Classifications")
            .map(MCRConfiguration2::splitValue)
            .orElseGet(() -> Stream.of("mir_access"))
            .collect(Collectors.toList());
        linkService = MCRCategLinkServiceFactory.getInstance();
        accessImpl = MCRAccessManager.getAccessImpl();
    }

    private boolean checkObjectPermission(MCRObjectID objectId, String permission) {
        LOGGER.debug("checkObjectPermission({}, {})", objectId, permission);

        // 1. check if the object has a assigned identifier
        final boolean hasRegisteredPI = hasRegisteredPI(objectId);
        if (MCRAccessManager.PERMISSION_DELETE.equalsIgnoreCase(permission) && hasRegisteredPI && !canEditPI()) {
            return false;
        }

        String permissionId = objectId.toString();

        // 2. check read or write key of current user
        boolean isWritePermission = MCRAccessManager.PERMISSION_WRITE.equals(permission);
        boolean isReadPermission = MCRAccessManager.PERMISSION_READ.equals(permission);
        if (isWritePermission || isReadPermission) {
            final String userKey = MCRAccessKeyUserUtils.getUserAccessKeyValue(objectId);
            if (userKey != null) {
                final MCRAccessKey accessKey = MCRAccessKeyManager.getAccessKeyByValue(objectId, userKey);
                if (accessKey != null) {
                    LOGGER.debug("Found match in access key strategy for {} on {}.", permission, objectId);
                    if (ACCESS_KEY_STRATEGY.checkPermission(objectId.toString(), permission, accessKey)) {
                        return true;
                    }
                } else {
                    MCRAccessKeyUserUtils.deleteAccessKey(objectId);
                }
            }
        }

        // 3. check if access mapping for object id exists
        if (ID_STRATEGY.hasRuleMapping(permissionId, permission)) {
            LOGGER.debug("Found match in ID strategy for {} on {}.", permission, objectId);
            return ID_STRATEGY.checkPermission(permissionId, permission);
        }

        // 4. check if creator rule applies
        if (CREATOR_STRATEGY.isCreatorRuleAvailable(permissionId, permission)) {
            LOGGER.debug("Found match in CREATOR strategy for {} on {}.", permission, objectId);
            return CREATOR_STRATEGY.checkPermission(permissionId, permission);
        }
        return getAccessCategory(objectId, null, permission)
            // 5. check if classification rule applies
            .map(c -> {
                LOGGER.debug("using access rule defined for category: " + c);
                return accessImpl.checkPermission(objectId.getTypeId() + ":" + c.toString(), permission);
            })
            //6. fallback to MCRObjectBaseStrategy
            .orElseGet(() -> {
                LOGGER.debug("Using BASE strategy as fallback for {} on {}.", permission, objectId);
                return OBJECT_BASE_STRATEGY.checkPermission(permissionId, permission);
            });
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

    //TODO: remove annotation below and fix code
    @SuppressWarnings("PMD.NPathComplexity")
    private boolean checkDerivatePermission(MCRObjectID derivateId, String permission) {
        LOGGER.debug("checkDerivatePermission({}, {})", derivateId, permission);
        String permissionId = derivateId.toString();

        // 1. check if the object has a assigned identifier
        MCRObjectID objectId = MCRMetadataManager.getObjectId(derivateId, 10, TimeUnit.MINUTES);
        if (MCRAccessManager.PERMISSION_WRITE.equalsIgnoreCase(permission) ||
            MCRAccessManager.PERMISSION_DELETE.equalsIgnoreCase(permission)) {
            final boolean hasRegisteredPI = hasRegisteredPI(objectId);
            if (hasRegisteredPI && !canEditPI()) {
                return false;
            }
        }

        // 2. check read or write key of current user
        boolean isWritePermission = MCRAccessManager.PERMISSION_WRITE.equals(permission);
        boolean isReadPermission = MCRAccessManager.PERMISSION_READ.equals(permission);
        if (isWritePermission || isReadPermission) {
            String userKey = MCRAccessKeyUserUtils.getUserAccessKeyValue(derivateId);
            if (userKey != null) {
                final MCRAccessKey accessKey = MCRAccessKeyManager.getAccessKeyByValue(derivateId, userKey);
                if (accessKey != null) {
                    LOGGER.debug("Found match in access key strategy for {} on {}.", permission, derivateId);
                    if (ACCESS_KEY_STRATEGY.checkPermission(permissionId, permission, accessKey)) {
                        return true;
                    }
                } else {
                    MCRAccessKeyUserUtils.deleteAccessKey(derivateId);
                }
            }
            userKey = MCRAccessKeyUserUtils.getUserAccessKeyValue(objectId);
            if (userKey != null) {
                final MCRAccessKey accessKey = MCRAccessKeyManager.getAccessKeyByValue(objectId, userKey);
                if (accessKey != null) {
                    LOGGER.debug("Found match in access key strategy for {} on {}.", permission, objectId);
                    if (ACCESS_KEY_STRATEGY.checkPermission(objectId.toString(), permission,  accessKey)) {
                        return true;
                    }
                } else {
                    MCRAccessKeyUserUtils.deleteAccessKey(objectId);
                }
            }
        }

        // 2.check if derivate has embargo
        if (objectId == null) {
            //2.1. fallback to MCRObjectBaseStrategy
            LOGGER.debug("Derivate {} is an orphan. Cannot apply rules for MCRObject.", derivateId);
            return OBJECT_BASE_STRATEGY.checkPermission(permissionId, permission);
        }

        String embargo = MCRMODSEmbargoUtils.getEmbargo(objectId);
        if (MCRAccessManager.PERMISSION_READ.equals(permission)
            && embargo != null
            && (!MCRMODSEmbargoUtils.isCurrentUserCreator(objectId) &&
                !MCRAccessManager.checkPermission(MCRMODSEmbargoUtils.POOLPRIVILEGE_EMBARGO))) {
            LOGGER.debug("Derivate {} has embargo {} and current user is not creator and doesn't has {} POOLPRIVILEGE",
                derivateId, embargo, MCRMODSEmbargoUtils.POOLPRIVILEGE_EMBARGO);
            return false;
        }

        // 3. check if access mapping for derivate id exists
        if (ID_STRATEGY.hasRuleMapping(permissionId, permission)) {
            LOGGER.debug("Found match in ID strategy for {} on {}.", permission, derivateId);
            return ID_STRATEGY.checkPermission(permissionId, permission);
        }

        // 4. check if creator rule applies
        if (CREATOR_STRATEGY.isCreatorRuleAvailable(objectId.toString(), permission)) {
            LOGGER.debug("Found match in CREATOR strategy for {} on {}.", permission, derivateId);
            return CREATOR_STRATEGY.checkPermission(objectId.toString(), permission);
        }

        return getAccessCategory(objectId, derivateId, permission)
            // 5. use rule defined for all derivates of object in category
            .map(c -> {
                LOGGER.debug("using access rule defined for category: " + c);
                return accessImpl.checkPermission(derivateId.getTypeId() + ":" + c.toString(), permission);
            })
            .orElseGet(() -> {
                // 6. check if base strategy applies for derivate
                if (OBJECT_BASE_STRATEGY.hasRuleMapping(permissionId, permission)) {
                    return OBJECT_BASE_STRATEGY.checkPermission(permissionId, permission);
                }
                // 7. go for object permission, if object link exists.
                LOGGER.debug("No rule for base strategy found, check against object {}.", objectId);
                return checkObjectPermission(objectId, permission);
            });
    }

    private boolean canEditPI() {
        return MCRConfiguration2.getOrThrow(EDIT_PI_ROLES, MCRConfiguration2::splitValue)
            .anyMatch(MCRUserManager.getCurrentUser()::isUserInRole);
    }

    private Optional<MCRCategoryID> getAccessCategory(MCRObjectID objectId, MCRObjectID derivateId, String permission) {
        String type = Stream.of(derivateId, objectId).filter(Objects::nonNull).map(MCRObjectID::getTypeId).findFirst()
                .get();
        List<MCRCategoryID> amc = getAccessMappedCategories(type, permission, accessClasses);
        return Stream.of(derivateId, objectId)
                .filter(Objects::nonNull)
                .flatMap(id -> getAccessCategory(amc, id).stream())
                .findFirst();
    }

    private Optional<MCRCategoryID> getAccessCategory(List<MCRCategoryID> accessMappedCategories, MCRObjectID id) {
        return Optional.ofNullable(id)
            .map(MCRCategLinkReference::new)
            .flatMap(ref -> accessMappedCategories
                .stream()
                .peek(c -> LOGGER.debug("Checking if {} is in category {}.", id, c))
                .filter(c -> linkService.isInCategory(ref, c))
                .findFirst());
    }

    private boolean hasRegisteredPI(MCRObjectID objectId) {
        return MCRPIServiceManager.getInstance().getServiceList().stream().anyMatch(service -> {
            final List<MCRPIRegistrationInfo> createdIdentifiers = MCRPIManager.getInstance()
                .getCreatedIdentifiers(objectId, service.getType(), service.getServiceID());
            return createdIdentifiers.stream().anyMatch(id -> service.isRegistered(objectId, id.getAdditional()));
        });
    }

    private boolean checkOtherPermission(String id, String permission) {
        return ID_STRATEGY.checkPermission(id, permission);
    }

    private enum PermissionIDType {
        MCRObject, MCRDerivate, Other;

        public static PermissionIDType fromID(String id) {
            Matcher m = TYPE_PATTERN.matcher(id);
            if (m.find() && (m.groupCount() == 1)) {
                return "derivate".equals(m.group(1)) ? MCRDerivate : MCRObject;
            }
            return Other;

        }
    }

    @SuppressWarnings("unchecked")
    private static List<MCRCategoryID> getAccessMappedCategories(String objectType, String permission,
        List<String> accessClasses) {
        List<MCRCategoryID> result = PERMISSION_CATEGORY_MAPPING_CACHE.getIfUpToDate(objectType + "_" + permission,
            System.currentTimeMillis() - CACHE_TIME);
        if (result != null) {
            return result;
        }
        EntityManager em = MCREntityManagerProvider.getCurrentEntityManager();
        CriteriaBuilder cb = em.getCriteriaBuilder();
        CriteriaQuery<String> criteria = cb.createQuery(String.class);
        Root<MCRACCESS> nodes = criteria.from(MCRACCESS.class);
        criteria.select(nodes.get(MCRACCESS_.key).get(MCRACCESSPK_.objid))
            .where(
                cb.like(nodes.get(MCRACCESS_.key).get(MCRACCESSPK_.objid), objectType + ":%"),
                cb.equal(nodes.get(MCRACCESS_.key).get(MCRACCESSPK_.acpool), permission));
        TypedQuery<String> query = em.createQuery(criteria);
        result = generateMCRCategoryIDList(objectType, query.getResultList(), accessClasses);
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
                return accessClasses.indexOf(c1.getRootID()) - accessClasses.indexOf(c2.getRootID());
            })
            .collect(Collectors.toList());
    }

}
