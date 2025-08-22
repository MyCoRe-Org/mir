/*
 *  This file is part of ***  M y C o R e  ***
 *  See http://www.mycore.de/ for details.
 *
 *  MyCoRe is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  MyCoRe is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with MyCoRe.  If not, see <http://www.gnu.org/licenses/>.
 */

package org.mycore.mir.acl;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import org.junit.jupiter.api.BeforeEach;
import org.mycore.access.facts.MCRFactsAccessSystem;
import org.mycore.access.facts.fact.MCRStringFact;
import org.mycore.access.facts.model.MCRFact;
import org.mycore.common.config.MCRConfiguration2;

public abstract class MIRACLTest {

    MCRFactsAccessSystem accessSystem;

    public void enableDebug() {
        //Configurator.setLevel(LogManager.getLogger(MCRFactsAccessSystem.class).getName(), Level.DEBUG);
    }

    public void disableDebug() {
        //Configurator.setLevel(LogManager.getLogger(MCRFactsAccessSystem.class).getName(), Level.INFO);
    }

    @BeforeEach
    public void setUp() {
        setTestProperties();
        accessSystem = MCRConfiguration2.getInstanceOfOrThrow(MCRFactsAccessSystem.class, "MCR.Access.Class");
    }

    protected void checkWebpage(String webpageURL, boolean shouldBeAbleToRead, String... userRole) {
        boolean hasPermission = accessSystem.checkPermission("webpage:" + webpageURL, "read",
            Arrays.stream(userRole).map(role -> new MCRStringFact("role", role)).collect(Collectors.toList()));

        if (shouldBeAbleToRead) {
            assertTrue(hasPermission, String.join(",", userRole) + " should be able to open the webpage " + webpageURL);
        } else {
            assertFalse(hasPermission,
                String.join(",", userRole) + " should not be able to open the webpage " + webpageURL);
        }
    }

    protected void checkReadId(String id, boolean shouldBeAbleToRead, String... userRole) {
        boolean hasPermission = accessSystem.checkPermission(id, "read",
            Arrays.stream(userRole).map(role -> new MCRStringFact("role", role)).collect(Collectors.toList()));

        if (shouldBeAbleToRead) {
            assertTrue(hasPermission, String.join(",", userRole) + " should be able to read the id " + id);
        } else {
            assertFalse(hasPermission, String.join(",", userRole) + " should not be able to read the id " + id);
        }
    }

    public void testReadObject(String user, String creator, String status, String id, boolean shouldBeAbleToRead,
        String role) {
        testReadWriteObject(user, creator, status, id, shouldBeAbleToRead, true, role);
    }

    public void testWriteObject(String user, String creator, String status, String id, boolean shouldBeAbleToWrite,
        String role) {
        testReadWriteObject(user, creator, status, id, shouldBeAbleToWrite, false, role);
    }

    public void testReadWriteObject(String user, String creator, String status, String id,
        boolean shouldBeAbleToReadWrite,
        boolean read, String role) {
        testReadWriteObject(user, creator, status, id, shouldBeAbleToReadWrite, read, role, false);
    }

    public void testPermission(String user, String action, boolean shouldBeAbleTo, String role) {
        List<MCRFact> facts = Stream.of(
            new MCRStringFact("user", user),
            new MCRStringFact("role", role)).collect(Collectors.toList());

        boolean hasPermission = accessSystem.checkPermission(null, action, facts);

        if (shouldBeAbleTo) {
            assertTrue(hasPermission, user + " should be able to " + action);
        } else {
            assertFalse(hasPermission, user + " should not be able to " + action);
        }
    }

    public void testObject(String user, String creator, String status, String id, boolean shouldBeAbleTo,
        String action, String role, boolean embargo, boolean objIntern, boolean derIntern) {
        List<MCRFact> facts = Stream.of(
            new MCRStringFact("user", user),
            new MCRStringFact("status", status),
            new MCRStringFact("role", role)).collect(Collectors.toList());

        if (embargo) {
            facts.add(new MCRStringFact("embargo", ""));
        }

        if (user.equals(creator)) {
            facts.add(new MCRStringFact("createdby", ""));
        }

        if (objIntern) {
            facts.add(new MCRStringFact("category.objid", "mir_access:intern"));
        }

        if (derIntern) {
            facts.add(new MCRStringFact("category.derid", "mir_access:intern"));
        }

        boolean hasPermission = accessSystem.checkPermission(id, action, facts);

        if (shouldBeAbleTo) {
            assertTrue(hasPermission, user + " should be able to " + action + " the id " + id);
        } else {
            assertFalse(hasPermission, user + " should not be able to " + action + " the id " + id);
        }
    }

    public void testReadWriteObject(String user, String creator, String status, String id,
        boolean shouldBeAbleToReadWrite,
        boolean read, String role, boolean embargo, boolean objIntern, boolean derIntern) {
        testObject(user, creator, status, id, shouldBeAbleToReadWrite, read ? "read" : "writedb", role, embargo,
            objIntern, derIntern);
    }

    public void testReadWriteObject(String user, String creator, String status, String id,
        boolean shouldBeAbleToReadWrite,
        boolean read, String role, boolean embargo) {
        testReadWriteObject(user, creator, status, id, shouldBeAbleToReadWrite, read, role, embargo, false, false);
    }

    private void setTestProperties() {

        MCRConfiguration2.set("MCR.Metadata.Type.mods", "true");
        MCRConfiguration2.set("MCR.Metadata.Type.derivate", "true");

        MCRConfiguration2.set("MCR.Access.Facts.Condition.and",
            "org.mycore.access.facts.condition.combined.MCRAndCondition");
        MCRConfiguration2.set("MCR.Access.Facts.Condition.or",
            "org.mycore.access.facts.condition.combined.MCROrCondition");
        MCRConfiguration2.set("MCR.Access.Facts.Condition.not",
            "org.mycore.access.facts.condition.combined.MCRNotCondition");
        MCRConfiguration2.set("MCR.Access.Facts.Condition.id",
            "org.mycore.access.facts.condition.fact.MCRStringCondition");
        MCRConfiguration2.set("MCR.Access.Facts.Condition.target",
            "org.mycore.access.facts.condition.fact.MCRStringCondition");
        MCRConfiguration2.set("MCR.Access.Facts.Condition.action",
            "org.mycore.access.facts.condition.fact.MCRStringCondition");
        MCRConfiguration2.set("MCR.Access.Facts.Condition.user",
            "org.mycore.access.facts.condition.fact.MCRUserCondition");
        MCRConfiguration2.set("MCR.Access.Facts.Condition.role",
            "org.mycore.access.facts.condition.fact.MCRRoleCondition");
        MCRConfiguration2.set("MCR.Access.Facts.Condition.ip", "org.mycore.access.facts.condition.fact.MCRIPCondition");
        MCRConfiguration2.set("MCR.Access.Facts.Condition.status",
            "org.mycore.access.facts.condition.fact.MCRStateCondition");
        MCRConfiguration2.set("MCR.Access.Facts.Condition.createdby",
            "org.mycore.access.facts.condition.fact.MCRCreatedByCondition");
        MCRConfiguration2.set("MCR.Access.Facts.Condition.regex",
            "org.mycore.access.facts.condition.fact.MCRRegExCondition");
        MCRConfiguration2.set("MCR.Access.Facts.Condition.category",
            "org.mycore.access.facts.condition.fact.MCRCategoryCondition");
        MCRConfiguration2.set("MCR.Access.Facts.Condition.collection",
            "org.mycore.mods.access.facts.condition.MCRMODSCollectionCondition");
        MCRConfiguration2.set("MCR.Access.Facts.Condition.genre",
            "org.mycore.mods.access.facts.condition.MCRMODSGenreCondition");
        MCRConfiguration2.set("MCR.Access.Facts.Condition.embargo",
            "org.mycore.mods.access.facts.condition.MCRMODSEmbargoCondition");

        MCRConfiguration2.set("MCR.URIResolver.ModuleResolver.property", "org.mycore.common.xml.MCRPropertiesResolver");
        MCRConfiguration2.set("MCR.LayoutService.TransformerFactoryClass", "net.sf.saxon.TransformerFactoryImpl");
        MCRConfiguration2.set("MCR.ContentTransformer.rules-helper.Class",
            "org.mycore.common.content.transformer.MCRXSLTransformer");
        MCRConfiguration2.set("MCR.ContentTransformer.rules-helper.TransformerFactoryClass",
            "net.sf.saxon.TransformerFactoryImpl");
        MCRConfiguration2.set("MCR.ContentTransformer.rules-helper.Stylesheet", "xslt/rules-helper.xsl");

        MCRConfiguration2.set("MCR.Access.Strategy.Class", "org.mycore.access.facts.MCRFactsAccessSystem");
        MCRConfiguration2.set("MCR.Access.Class", "org.mycore.access.facts.MCRFactsAccessSystem");

        MCRConfiguration2.set("MCR.Access.RulesURI", "xslTransform:rules-helper:resource:rules/rules.xml");
        MCRConfiguration2.set("MIR.Rules.Solr.Protected.RequestHandler", "find,select");
        MCRConfiguration2.set("MIR.Rules.ClassificationEditor.EditableClasses",
            "crossrefTypes,dctermsDCMIType,ddc,derivate_types,diniPublType,diniVersion,identifier,itunes-podcast,marcgt,marcrelator,mcr-roles,mir_access,mir_filetype,mir_genres,mir_institutes,mir_licenses,mir_rights,nameIdentifier,noteTypes,rfc4646,rfc5646,schemaOrg,sdnb,state,typeOfResource,XMetaDissPlusThesisLevel");

        MCRConfiguration2.set("MCR.Access.Facts.Condition.ip-from-institution",
            "org.mycore.access.facts.condition.fact.MCRIPCondition");
        MCRConfiguration2.set("MCR.Access.Facts.Condition.ip-from-institution.IP", "127.0.0.1/255.255.255.255");

    }
}
