package org.mycore.mir.sword2;

import java.io.IOException;
import java.util.List;

import jakarta.servlet.http.HttpServletResponse;

import org.apache.abdera.i18n.iri.IRI;
import org.apache.abdera.model.Entry;
import org.jdom2.Element;
import org.jdom2.JDOMException;
import org.mycore.common.content.MCRBaseContent;
import org.mycore.common.content.MCRContent;
import org.mycore.common.content.transformer.MCRXSL2XMLTransformer;
import org.mycore.datamodel.metadata.MCRMetadataManager;
import org.mycore.datamodel.metadata.MCRObject;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.frontend.MCRFrontendUtil;
import org.mycore.sword.MCRSwordUtil;
import org.mycore.sword.application.MCRSwordLifecycleConfiguration;
import org.mycore.sword.application.MCRSwordMetadataProvider;
import org.swordapp.server.DepositReceipt;
import org.swordapp.server.SwordError;
import org.swordapp.server.UriRegistry;
import org.xml.sax.SAXException;

public class MIRSwordMetadataProvider extends MCRSwordMetadataProvider {

    private static final MCRXSL2XMLTransformer XSL_MODS_DC_TRANSFORMER = new MCRXSL2XMLTransformer(
        "xsl/mycoreobject-mods.xsl", "xsl/mods2dc.xsl");

    private MCRSwordLifecycleConfiguration lifecycleConfiguration;

    @Override
    public DepositReceipt provideMetadata(MCRObject object) throws SwordError {
        final IRI iri = new IRI(MCRSwordUtil.BuildLinkUtil.getEditHref(this.lifecycleConfiguration.getCollection(),
            object.getId().toString()));
        final String splashURI = MCRFrontendUtil.getBaseURL() + "receive/" + object.getId();
        final DepositReceipt depositReceipt = MCRSwordUtil.buildDepositReceipt(iri);
        addMetadata(object, depositReceipt);
        depositReceipt.setSplashUri(splashURI);
        final Entry we = depositReceipt.getWrappedEntry();
        MCRSwordUtil.BuildLinkUtil
            .getEditMediaIRIStream(this.lifecycleConfiguration.getCollection(), object.getId().toString())
            .forEach(we::addLink);
        return depositReceipt;
    }

    @Override
    public Entry provideListMetadata(MCRObjectID id) throws SwordError {
        final Entry entry = super.provideListMetadata(id);

        MCRObject mcrObject = MCRMetadataManager.retrieveMCRObject(id);
        MCRSwordUtil.addDatesToEntry(entry, mcrObject);
        return entry;
    }

    public void addMetadata(MCRObject object, DepositReceipt receipt) throws SwordError {
        final MCRBaseContent mcrBaseContent = new MCRBaseContent(object);
        final MCRContent mcrContent;
        try {
            mcrContent = XSL_MODS_DC_TRANSFORMER.transform(mcrBaseContent);
        } catch (IOException e) {
            throw new SwordError(UriRegistry.ERROR_BAD_REQUEST, HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                "Error while transforming mods2dc!", e);
        }

        final List<Element> elementList;
        try {
            elementList = mcrContent.asXML().getRootElement().getChildren();
        } catch (JDOMException | IOException | SAXException e) {
            throw new SwordError(UriRegistry.ERROR_BAD_REQUEST, HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                "Error getting transform result of mods to dc transformation!", e);
        }

        elementList.stream()
            .filter(dcElement -> dcElement.getText().trim().length() > 0)
            .forEach(dcElement -> {
                receipt.addDublinCore(dcElement.getName(), dcElement.getText().trim());
            });

        MCRSwordUtil.addDatesToEntry(receipt.getWrappedEntry(), object);
    }

    @Override
    public void init(MCRSwordLifecycleConfiguration lifecycleConfiguration) {
        super.init(lifecycleConfiguration);
        this.lifecycleConfiguration = lifecycleConfiguration;
    }

    @Override
    public void destroy() {
        //nothing to destroy
    }
}
