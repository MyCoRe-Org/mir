package org.mycore.mir.it.controller;

import org.mycore.common.selenium.drivers.MCRWebdriverWrapper;

public class MIRControllerFactory {

    public MIRUserController createUserController(MCRWebdriverWrapper driver, String appURL) {
        return new MIRUserController(driver, appURL);
    }

    public MIRPublishEditorController createPublishEditorController(MCRWebdriverWrapper driver, String appURL) {
        return new MIRPublishEditorController(driver, appURL);
    }

    public MIRModsEditorController createModsEditorController(MCRWebdriverWrapper driver, String appURL) {
        return new MIRModsEditorController(driver, appURL);
    }

    public MIRSearchController createSearchController(MCRWebdriverWrapper driver, String appURL) {
        return new MIRSearchController(driver, appURL);
    }

    public MIRUploadController createUploadController(MCRWebdriverWrapper driver, String appURL) {
        return new MIRUploadController(driver, appURL);
    }
}
