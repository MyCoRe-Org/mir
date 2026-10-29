package org.mycore.mir.importer;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.io.IOException;
import java.io.StringReader;
import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.List;

import org.jdom2.Document;
import org.jdom2.Element;
import org.jdom2.JDOMException;
import org.jdom2.filter.Filters;
import org.jdom2.input.SAXBuilder;
import org.jdom2.output.Format;
import org.jdom2.output.XMLOutputter;
import org.jdom2.xpath.XPathFactory;
import org.junit.jupiter.api.Test;
import org.mycore.common.MCRConstants;
import org.mycore.common.MCRTestConfiguration;
import org.mycore.common.MCRTestProperty;
import org.mycore.common.config.MCRConfiguration2;
import org.mycore.common.xsl.uriresolver.MCRURIResolver;
import org.mycore.test.MyCoReTest;

@MyCoReTest
public class MIRCrossrefJatsAbstract2ModsAbstractResolverTest {

    public static final String DATASOURCE_URI = "MCR.MODS.EnrichmentResolver.DataSource.CrossRef.doi.URI";

    public static final String USE_ABSTRACTS = "MCR.MODS.EnrichmentResolver.DataSource.CrossRef.UseAbstracts";

    public static final String ALT_FORMAT_PREFIX = "data:text/xml;charset=UTF-8;base64,";

    @Test
    @MCRTestConfiguration(properties = {
        @MCRTestProperty(key = USE_ABSTRACTS, string = "true")
    })
    public void testEnabledAbstractMapping() throws IOException, JDOMException {

        String uri = MCRConfiguration2.getStringOrThrow(DATASOURCE_URI);

        String className = MIRCrossrefJatsAbstract2ModsAbstractResolverTest.class.getSimpleName();
        uri = uri.replace("https://api.crossref.org/works/{0}", "resource:" + className + "/example.json");

        Element element = MCRURIResolver.obtainInstance().resolve(uri);

        System.out.println("MODS:");
        new XMLOutputter(Format.getPrettyFormat()).output(element, System.out);
        System.out.println();

        List<Element> plainTextAbstractElements = evaluate(element, ".//mods:abstract[not(@contentType)]");
        assertEquals(1, plainTextAbstractElements.size());

        Element plainTextAbstractElement = plainTextAbstractElements.getFirst();

        String plainText = plainTextAbstractElement.getText();
        assertEquals("Lorem ipsum dolor sit amet, 2342.", plainText);

        List<Element> htmlAbstractElements = evaluate(element, ".//mods:abstract[@contentType='text/xml']");
        assertEquals(1, htmlAbstractElements.size());

        Element htmlAbstractElement = htmlAbstractElements.getFirst();
        assertEquals(plainTextAbstractElement.getAttributeValue("altRepGroup"),
            htmlAbstractElement.getAttributeValue("altRepGroup"));

        String altFormat = htmlAbstractElement.getAttributeValue("altFormat");
        assertTrue(altFormat.startsWith(ALT_FORMAT_PREFIX));
        String altFormatData = altFormat.substring(ALT_FORMAT_PREFIX.length());
        String altFormatXml = new String(Base64.getDecoder().decode(altFormatData), StandardCharsets.UTF_8);

        Document altFormatDocument = new SAXBuilder().build(new StringReader(altFormatXml));
        Element altFormatElement = altFormatDocument.getRootElement();

        System.out.println("Abstract:");
        new XMLOutputter(Format.getPrettyFormat()).output(altFormatElement, System.out);
        System.out.println();

        assertEquals(htmlAbstractElement.getAttributeValue("altRepGroup"),
            altFormatElement.getAttributeValue("altRepGroup"));

        Document altFormatHtmlDocument = new SAXBuilder().build(new StringReader(altFormatElement.getText()));
        Element altFormatHtmlElement = altFormatHtmlDocument.getRootElement();

        String html = new XMLOutputter(Format.getCompactFormat()).outputString(altFormatHtmlElement);

        System.out.println("HTML:");
        System.out.println(html);

        assertEquals("<p><strong>Lorem ipsum</strong>dolor sit<em>amet</em>, 23<sup>42</sup>.</p>", html);

    }

    @Test
    @MCRTestConfiguration(properties = {
        @MCRTestProperty(key = USE_ABSTRACTS, string = "false")
    })
    public void testDisabledAbstractMapping() throws IOException {

        String uri = MCRConfiguration2.getStringOrThrow(DATASOURCE_URI);

        String className = MIRCrossrefJatsAbstract2ModsAbstractResolverTest.class.getSimpleName();
        uri = uri.replace("https://api.crossref.org/works/{0}", "resource:" + className + "/example.json");

        Element element = MCRURIResolver.obtainInstance().resolve(uri);

        System.out.println("MODS:");
        new XMLOutputter(Format.getPrettyFormat()).output(element, System.out);
        System.out.println();

        List<Element> plainTextAbstractElements = evaluate(element, ".//mods:abstract[not(@contentType)]");
        assertEquals(0, plainTextAbstractElements.size());

    }

    private static List<Element> evaluate(Element element, String xpath) {
        return XPathFactory.instance()
            .compile(xpath, Filters.element(), null, MCRConstants.getStandardNamespaces())
            .evaluate(element);
    }

}
