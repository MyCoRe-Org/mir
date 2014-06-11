/*
 * $Id$
 * $Revision$ $Date$
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
package org.mycore.mir.wizard;

import java.util.HashMap;
import java.util.Map;

import org.jdom2.Element;

public class MIRWizardCommandResult {
    private String name;

    private boolean success;

    private Map<String, String> attributes = new HashMap<String, String>();

    private Element result;

    public MIRWizardCommandResult(String name) {
        this.name = name;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public boolean isSuccess() {
        return success;
    }

    public void setSuccess(boolean success) {
        this.success = success;
    }

    public Map<String, String> getAttributes() {
        return attributes;
    }

    public void setAttributes(Map<String, String> attributes) {
        this.attributes = attributes;
    }

    public void setAttribute(String key, String value) {
        this.attributes.put(key, value);
    }

    public String getAttribute(String key) {
        return this.attributes.get(key);
    }

    protected Element getResult() {
        return result;
    }

    public void setResult(String result) {
        this.result = new Element("result").addContent(result);
    }

    public void setResult(Element result) {
        this.result = new Element("result").addContent(result);
    }

    public Element toElement() {
        Element res = new Element(name);
        res.setAttribute("success", Boolean.toString(success));
        for (String key : attributes.keySet()) {
            res.setAttribute(key, getAttribute(key));
        }

        if (result != null)
            res.addContent(result);

        return res;
    }
}
