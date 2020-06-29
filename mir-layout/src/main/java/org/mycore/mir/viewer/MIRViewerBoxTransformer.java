package org.mycore.mir.viewer;

import java.io.IOException;

import org.mycore.common.content.MCRContent;
import org.mycore.common.content.MCRStringContent;
import org.mycore.common.content.transformer.MCRParameterizedTransformer;
import org.mycore.common.xsl.MCRParameterCollector;

public class MIRViewerBoxTransformer extends MCRParameterizedTransformer {

    @Override
    public MCRContent transform(MCRContent source, MCRParameterCollector parameter) throws IOException {

        return new MCRStringContent("<div class=\"metadata jumbotron\">\n" + source.asString() + "</div>");
    }

    @Override
    public MCRContent transform(MCRContent source) throws IOException {
        return this.transform(source, (MCRParameterCollector) null);
    }
}
