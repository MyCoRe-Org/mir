/*
 * $Id$
 * $Revision: 5697 $ $Date: Feb 26, 2014 $
 *
 * This file is part of ***  M y C o R e  ***
 * See http://www.mycore.de/ for details.
 *
 * This program is free software; you can use it, redistribute it
 * and / or modify it under the terms of the GNU General Public License
 * (GPL) as published by the Free Software Foundation; either version 2
 * of the License or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program, in a file called gpl.txt or license.txt.
 * If not, write to the Free Software Foundation Inc.,
 * 59 Temple Place - Suite 330, Boston, MA  02111-1307 USA
 */

package org.mycore.mir.it.selenium;

import org.openqa.selenium.By;

/**
 * Selenium methods {@link By#linkText(String)} and {@link By#partialLinkText(String)} uses displayed text in browser,
 * which may have been transformed by CSS property <code>text-transform</code>.
 * This will result in unstable tests, when CSS but not mark-up changes.
 * Use these methods instead.
 * @author Thomas Scheffler (yagee)
 *
 */
public class MIRBy {

    public static By linkText(String linkText) {
        if (linkText == null) {
            throw new IllegalArgumentException("Cannot find elements when link text is null.");
        }
        return new MIRByLinkText(linkText);
    }

    public static By partialLinkText(String linkText) {
        if (linkText == null) {
            throw new IllegalArgumentException("Cannot find elements when link text is null.");
        }
        return new MIRByPartialLinkText(linkText);
    }

    protected static class MIRByLinkText extends By.ByXPath {

        private static final long serialVersionUID = 1L;

        public MIRByLinkText(String linkText) {
            super(toXPathExpression(linkText));
        }

        protected static String toXPathExpression(String linkText) {
            return ".//a[text()='" + linkText + "']";
        }

    }

    protected static class MIRByPartialLinkText extends By.ByXPath {

        private static final long serialVersionUID = 1L;

        public MIRByPartialLinkText(String linkText) {
            super(toXPathExpression(linkText));
        }

        protected static String toXPathExpression(String linkText) {
            return ".//a[contains(text(), '" + linkText + "')]";
        }

    }
}
