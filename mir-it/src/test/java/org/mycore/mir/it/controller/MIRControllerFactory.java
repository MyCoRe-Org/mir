package org.mycore.mir.it.controller;

import org.mycore.common.selenium.drivers.MCRWebdriverWrapper;

public class MIRControllerFactory {

    protected MCRWebdriverWrapper driver;
    protected String appURL;

    public MIRControllerFactory(MCRWebdriverWrapper driver, String appURL) {
        this.driver = driver;
        this.appURL = appURL;
    }

    public MIRUserController createUserController() {
        return new MIRUserController(driver, appURL);
    }

    public MIRPublishEditorController createPublishEditorController() {
        return new MIRPublishEditorController(driver, appURL);
    }

    public MIRModsEditorController createModsEditorController() {
        return new MIRModsEditorController(driver, appURL);
    }

    public MIRSearchController createSearchController() {
        return new MIRSearchController(driver, appURL);
    }

    public MIRUploadController createUploadController() {
        return new MIRUploadController(driver, appURL);
    }

    public MCRWebdriverWrapper getDriver() {
        return driver;
    }
}
