package org.mycore.mir.migration;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotEquals;

import java.io.IOException;

import org.jdom2.Document;
import org.jdom2.Element;
import org.jdom2.JDOMException;
import org.jdom2.input.SAXBuilder;
import org.jdom2.output.Format;
import org.jdom2.output.XMLOutputter;
import org.junit.jupiter.api.Test;
import org.mycore.test.MyCoReTest;

@MyCoReTest
public class MIRMigration202006UtilsTest {

    @Test
    public void testEscaped() throws JDOMException, IOException {
        String dataURL = "data:text/xml;charset=UTF-8;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0idXRmLTgiPz48d"
            + "Gl0bGVJbmZvIHhtbDpsYW5nPSJlbiI+CiAgICAgICAgICAgIDx0aXRsZT5TdHJ1Y3R1cmFsIEJhc2lzIGZvciBDb21wbGV4IEZv"
            + "cm1hdGlvbiBiZXR3ZWVuIEh1bWFuIElSU3A1MyBhbmQgdGhlIFRyYW5zbG9jYXRlZCBJbnRpbWluIFJlY2VwdG9yIFRpciBvZiB"
            + "FbnRlcm9oYWVtb3JyaGFnaWMgJmx0O2kmZ3Q7RS4gY29saSZsdDsvaSZndDsgJmFtcDsgU3RydWN0dXJhbCBDaGFyYWN0ZXJpc2"
            + "F0aW9uIG9mIEFtb3JmcnV0aW5zIEJvdW5kIHRvIFBQQVIgZ2FtbWE8L3RpdGxlPgogICAgICAgICAgPC90aXRsZUluZm8+";
        Element test = new Element("test");
        test.setAttribute("altFormat", dataURL);
        final Document document = MIRMigration202006Utils.getEmbeddedDocument(new SAXBuilder(), test);
        final Element title = document.getRootElement().getChild("title");
        String before = title.getText();
        MIRMigration202006Utils.fixHTML(new XMLOutputter(Format.getRawFormat()), title);
        String after = title.getText();
        assertNotEquals(before, after);
        assertEquals("Structural Basis for Complex Formation between Human IRSp53 and the "
            + "Translocated Intimin Receptor Tir of Enterohaemorrhagic <i>E. coli</i> &amp; Structural "
            + "Characterisation of Amorfrutins Bound to PPAR gamma", after);
    }

    @Test
    public void testUnEscaped() throws JDOMException, IOException {
        String dataURL = "data:text/xml;charset=UTF-8,%3C%3Fxml%20version%3D%221.0%22%20encoding%3D%22UTF-8%22%3F%3E"
            + "%3Cabstract%20xmlns%3Axlink%3D%22http%3A%2F%2Fwww.w3.org%2F1999%2Fxlink%22%20xml%3Alang%3D%22de%22%20"
            + "xlink%3Atype%3D%22simple%22%3E%3Cp%3EAuch%20im%20Buchhandel%20erh%C3%A4ltlich%3A%3Cbr%2F%3E%0D%0A"
            + "Beitrag%20zum%20modelbasierten%20Entwurf%20eingebetteter%20Systeme%20%2F%20Marcus%20M%C3%BCller"
            + "%3Cbr%2F%3E%0D%0AIlmenau%20%3A%20Isle%2C%202014.%20-xv%2C%20204%20S.%3Cbr%2F%3E%3C%2Fabstract%3E";
        Element test = new Element("test");
        test.setAttribute("altFormat", dataURL);
        final Document document = MIRMigration202006Utils.getEmbeddedDocument(new SAXBuilder(), test);
        XMLOutputter xout = new XMLOutputter(Format.getRawFormat());
        final Element abstrct = document.getRootElement();
        String before = xout.outputString(abstrct.getContent());
        MIRMigration202006Utils.fixHTML(new XMLOutputter(Format.getRawFormat()), abstrct);
        String after = abstrct.getText();
        assertEquals(before, after);
    }
}
