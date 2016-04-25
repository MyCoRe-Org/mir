package org.mycore.mir.it.controller;


import org.mycore.common.selenium.drivers.MCRWebdriverWrapper;

public class MIRTestController {

    protected final MCRWebdriverWrapper driver;
    protected final String baseURL;

    public MIRTestController(MCRWebdriverWrapper driver, String baseURL) {
        this.driver = driver;
        this.baseURL = baseURL;
    }
}
