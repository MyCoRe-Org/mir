package org.mycore.mir.xslt;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;

import java.util.Map;

import org.jdom2.Document;
import org.jdom2.Element;
import org.jdom2.Namespace;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mycore.common.util.MCRTestCaseClassificationUtil;
import org.mycore.test.MCRJPAExtension;
import org.mycore.test.MyCoReTest;

@MyCoReTest
@ExtendWith(MCRJPAExtension.class)
public class XEditor2ModsXSLTest extends MIRXSLTFunctionTestCase {

    private static final String XSL = "/xslt/editor/xeditor2mods.xsl";
    private static final Namespace MCR_NAMESPACE = Namespace.getNamespace("mcr", "http://www.mycore.org/");
    private static final Namespace XLINK_NAMESPACE = Namespace.getNamespace("xlink", "http://www.w3.org/1999/xlink");

    @BeforeEach
    void setUp() throws Exception {
        MCRTestCaseClassificationUtil.addClassification("/classification/MIRTestClassification.xml");
    }

    @Test
    void testPreservesClassificationBackedGenreWhenSaving() throws Exception {
        Element genre = new Element("genre", MODS_NAMESPACE);
        genre.setAttribute("type", "intern");
        genre.setAttribute("categId", "MIRTestClassification:alpha", MCR_NAMESPACE);

        Document result = transformDocument(createMyCoReObject(genre), XSL, Map.of());

        Element savedGenre = result.getRootElement()
            .getChild("metadata")
            .getChild("def.modsContainer")
            .getChild("modsContainer")
            .getChild("mods", MODS_NAMESPACE)
            .getChild("genre", MODS_NAMESPACE);

        assertEquals("intern", savedGenre.getAttributeValue("type"));
        assertEquals("http://www.mycore.org/classifications/MIRTestClassification",
            savedGenre.getAttributeValue("authorityURI"));
        assertEquals("http://www.mycore.org/classifications/MIRTestClassification#alpha",
            savedGenre.getAttributeValue("valueURI"));
        assertNull(savedGenre.getAttribute("categId", MCR_NAMESPACE));
    }

    @Test
    void testRebuildsTypeOfResourceTextFromEditorCategoryBinding() throws Exception {
        Element typeOfResource = new Element("typeOfResource", MODS_NAMESPACE);
        typeOfResource.setAttribute("categId", "typeOfResource:still_image", MCR_NAMESPACE);

        Document result = transformDocument(createMyCoReObject(typeOfResource), XSL, Map.of());

        Element savedTypeOfResource = result.getRootElement()
            .getChild("metadata")
            .getChild("def.modsContainer")
            .getChild("modsContainer")
            .getChild("mods", MODS_NAMESPACE)
            .getChild("typeOfResource", MODS_NAMESPACE);

        assertEquals("still image", savedTypeOfResource.getTextNormalize());
        assertNull(savedTypeOfResource.getAttribute("categId", MCR_NAMESPACE));
    }

    @Test
    void testRejectsMalformedHostObjectIdWhenBuildingStructure() throws Exception {
        Element relatedItem = new Element("relatedItem", MODS_NAMESPACE);
        relatedItem.setAttribute("type", "host");
        relatedItem.setAttribute("href", "mir_mods_foo", XLINK_NAMESPACE);

        Document mycoreobject = createMyCoReObject(relatedItem);
        mycoreobject.getRootElement().setAttribute("ID", "mir_mods_00000001");

        Document result = transformDocument(mycoreobject, XSL, Map.of());

        assertNull(result.getRootElement().getChild("structure"));
    }

    private Document createMyCoReObject(Element modsChild) {
        Element mods = new Element("mods", MODS_NAMESPACE).addContent(modsChild);
        Element modsContainer = new Element("modsContainer").addContent(mods);
        Element defModsContainer = new Element("def.modsContainer").addContent(modsContainer);
        Element metadata = new Element("metadata").addContent(defModsContainer);
        Element mycoreobject = new Element("mycoreobject").addContent(metadata);
        return new Document(mycoreobject);
    }
}
