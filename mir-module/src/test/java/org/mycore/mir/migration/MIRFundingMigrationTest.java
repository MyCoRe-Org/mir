package org.mycore.mir.migration;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertNull;

import java.io.IOException;
import java.util.List;

import org.jdom2.Attribute;
import org.jdom2.Element;
import org.jdom2.JDOMException;
import org.junit.jupiter.api.Test;
import org.mycore.common.content.MCRContent;
import org.mycore.common.content.MCRURLContent;
import org.mycore.common.content.transformer.MCRContentTransformer;
import org.mycore.common.content.transformer.MCRContentTransformerFactory;
import org.mycore.mods.MCRMODSWrapper;
import org.mycore.test.MyCoReTest;

@MyCoReTest
public class MIRFundingMigrationTest {

    private static final String FUNDER_NAME = "European Commission";
    private static final String FUNDER_ID = "https://doi.org/10.13039/501100000780";
    private static final String FUNDER_ID_TYPE = "Crossref Funder ID";
    private static final String AWARD_TITLE = "Towards climate-smart sustainable management of agricultural soils";
    private static final String AWARD_NUMBER = "862695";
    private static final String AWARD_URI = "https://cordis.europa.eu/project/id/" + AWARD_NUMBER;

    private static final String FUNDING_REFERENCE_XPATH
        = "mods:extension[@type='datacite-funding']/resource/fundingReferences/fundingReference";
    private static final String OPEN_AIRE_IDENTIFIER_XPATH = "mods:identifier[@type='open-aire']";

    private static final String FILE_PATH_VALID = "/openaire_mods.xml";
    private static final String TRANSFORMER_ID = "migrate-openaire";

    @Test
    public void testMigrationTransformer_success() throws IOException, JDOMException {
        final MCRContent input = loadContent();
        final MCRContentTransformer transformer = MCRContentTransformerFactory.getTransformer(TRANSFORMER_ID);
        final MCRContent result = transformer.transform(input);

        final MCRMODSWrapper wrapper = new MCRMODSWrapper();
        wrapper.setMODS(result.asXML().detachRootElement());

        final Element identifierElement = wrapper.getElement(OPEN_AIRE_IDENTIFIER_XPATH);
        assertNull(identifierElement);
        final List<Element> fundingReferenceElements = wrapper.getElements(FUNDING_REFERENCE_XPATH);
        assertEquals(1, fundingReferenceElements.size());
        final Element fundingReferenceElement = fundingReferenceElements.get(0);
        final Element awardTitleElement = fundingReferenceElement.getChild("awardTitle");
        assertNotNull(awardTitleElement);
        assertEquals(AWARD_TITLE, awardTitleElement.getText());
        final Element funderName = fundingReferenceElement.getChild("funderName");
        assertNotNull(funderName);
        assertEquals(FUNDER_NAME, funderName.getText());
        final Element funderIdentifierElement = fundingReferenceElement.getChild("funderIdentifier");
        assertNotNull(funderIdentifierElement);
        assertEquals(FUNDER_ID, funderIdentifierElement.getText());
        final Attribute funderIdentifierTypeAttribute = funderIdentifierElement.getAttribute("funderIdentifierType");
        assertNotNull(funderIdentifierTypeAttribute);
        assertEquals(FUNDER_ID_TYPE, funderIdentifierTypeAttribute.getValue());
        final Element awardNumberElement = fundingReferenceElement.getChild("awardNumber");
        assertNotNull(awardNumberElement);
        assertEquals(AWARD_NUMBER, awardNumberElement.getText());
        final Attribute awardURIAttribute = awardNumberElement.getAttribute("awardURI");
        assertNotNull(awardURIAttribute);
        assertEquals(AWARD_URI, awardURIAttribute.getValue());
    }

    private static MCRContent loadContent() {
        return new MCRURLContent(MIRFundingMigrationTest.class.getResource(FILE_PATH_VALID));
    }
}
