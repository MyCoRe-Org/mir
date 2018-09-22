package org.mycore.mir.importer;

import java.io.IOException;

import org.mycore.common.content.MCRContent;
import org.mycore.common.content.MCRStringContent;
import org.mycore.common.content.transformer.MCRContentTransformer;
import org.mycore.common.content.transformer.MCRContentTransformerFactory;
import org.mycore.common.content.transformer.MCRParameterizedTransformer;
import org.mycore.common.xsl.MCRParameterCollector;

/**
 * Input: JSON string
 * Output: XML as converted by XSLT 3.0 json-to-xml() function
 *
 * @author Frank L\u00FCtzenkirchen
 */
public class JSON2XMLTransformer extends MCRContentTransformer {

    @Override
    public MCRContent transform(MCRContent json) throws IOException {
        MCRContent dummy = new MCRStringContent("<dummy/>");
        MCRContentTransformer t = MCRContentTransformerFactory.getTransformer("dummy-json2xml");
        MCRParameterizedTransformer pt = (MCRParameterizedTransformer) t;
        MCRParameterCollector params = new MCRParameterCollector();
        params.setParameter("json", json.asString());
        MCRContent result = pt.transform(dummy, params);
        return result;
    }
}
