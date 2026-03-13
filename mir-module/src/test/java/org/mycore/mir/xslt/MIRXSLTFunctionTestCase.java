package org.mycore.mir.xslt;

import static org.mycore.common.util.MCRTestCaseXSLTUtil.prepareTestDocument;
import static org.mycore.common.util.MCRTestCaseXSLTUtil.transform;

import java.util.List;
import java.util.Map;

import org.jdom2.Content;
import org.jdom2.Document;
import org.jdom2.Element;
import org.jdom2.Namespace;

public abstract class MIRXSLTFunctionTestCase {

    protected static final Namespace MODS_NAMESPACE = Namespace.getNamespace("mods", "http://www.loc.gov/mods/v3");

    protected Document transformRoot(String xsl, String rootName) throws Exception {
        return transformRoot(xsl, rootName, Map.of());
    }

    protected Document transformRoot(String xsl, String rootName, Map<String, Object> parameters) throws Exception {
        return transform(prepareTestDocument(rootName), xsl, parameters);
    }

    protected Document transformRoot(String xsl, String rootName, Element xml, Map<String, Object> parameters)
        throws Exception {
        return transform(prepareTestDocument(rootName, xml), xsl, parameters);
    }

    protected Document transformRoot(String xsl, String rootName, List<? extends Content> xml,
        Map<String, Object> parameters) throws Exception {
        return transform(prepareTestDocument(rootName, xml), xsl, parameters);
    }

    protected Document transformDocument(Document xml, String xsl, Map<String, Object> parameters) throws Exception {
        return transform(xml, xsl, parameters);
    }

    protected String resultText(String xsl, String rootName, Map<String, Object> parameters) throws Exception {
        return transformRoot(xsl, rootName, parameters).getRootElement().getTextNormalize();
    }

    protected String resultText(String xsl, String rootName, Element xml, Map<String, Object> parameters)
        throws Exception {
        return transformRoot(xsl, rootName, xml, parameters).getRootElement().getTextNormalize();
    }

    protected String resultRawText(String xsl, String rootName, Map<String, Object> parameters) throws Exception {
        return transformRoot(xsl, rootName, parameters).getRootElement().getText();
    }
}
