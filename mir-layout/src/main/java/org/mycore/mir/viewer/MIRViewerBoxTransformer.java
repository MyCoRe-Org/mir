/*
 * This file is part of ***  M y C o R e  ***
 * See https://www.mycore.de/ for details.
 *
 * MyCoRe is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * MyCoRe is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with MyCoRe.  If not, see <http://www.gnu.org/licenses/>.
 */

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
