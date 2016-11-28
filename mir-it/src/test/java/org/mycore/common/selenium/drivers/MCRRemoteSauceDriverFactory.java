package org.mycore.common.selenium.drivers;

import org.openqa.selenium.Dimension;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeOptions;
import org.openqa.selenium.remote.DesiredCapabilities;
import org.openqa.selenium.remote.LocalFileDetector;
import org.openqa.selenium.remote.RemoteWebDriver;

import java.net.MalformedURLException;
import java.net.URL;
import java.util.concurrent.TimeUnit;

public class MCRRemoteSauceDriverFactory extends MCRRemoteDriverFactory {

    @Override
    public DesiredCapabilities getCapabilities() {
        DesiredCapabilities caps = DesiredCapabilities.chrome();
        ChromeOptions options = new ChromeOptions();
        options.addArguments("--lang=de");
        caps.setCapability(ChromeOptions.CAPABILITY, options);
        String version = System.getProperty("SELENIUM_VERSION", "");
        if (!version.equals("")) {
            caps.setCapability("version", version);
        }
        caps.setCapability("browserName", System.getProperty("SELENIUM_BROWSER", ""));
        caps.setCapability("platform", System.getProperty("SELENIUM_PLATFORM", ""));
        return caps;
    }

    @Override
    public WebDriver getDriver() {
        String username = System.getProperty("SAUCE_USER_NAME", "");
        String accessKey = System.getProperty("SAUCE_API_KEY", "");
        String host = System.getProperty("SAUCE_USER_NAME", "");
        String port = System.getProperty("SAUCE_API_KEY", "");
        WebDriver remoteDriver = null;
        try {
            remoteDriver = new RemoteWebDriver(
                    new URL("http://" + username + ":" + accessKey + "@" + host + ":" + port + "/wd/hub"), getCapabilities());
        } catch (MalformedURLException e) {
            e.printStackTrace();
            return remoteDriver;
        }
        remoteDriver.manage().window().setSize(new Dimension(dimX, dimY));
        remoteDriver.manage().timeouts().implicitlyWait(10, TimeUnit.SECONDS);
        ((RemoteWebDriver) remoteDriver).setFileDetector(new LocalFileDetector());
        return remoteDriver;
    }

}
