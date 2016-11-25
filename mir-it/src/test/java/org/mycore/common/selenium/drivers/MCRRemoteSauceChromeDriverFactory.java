package org.mycore.common.selenium.drivers;

import org.openqa.selenium.chrome.ChromeOptions;
import org.openqa.selenium.remote.DesiredCapabilities;

public class MCRRemoteSauceChromeDriverFactory extends MCRRemoteDriverFactory {

    @Override
    public DesiredCapabilities getCapabilities() {
        DesiredCapabilities caps = DesiredCapabilities.chrome();
        ChromeOptions options = new ChromeOptions();
        options.addArguments("--lang=de");
        caps.setCapability("version", "54.0");
        caps.setCapability("platform", "Windows 10");
        caps.setCapability("seleniumVersion", "3.0.1");
        caps.setCapability(ChromeOptions.CAPABILITY, options);
        return caps;
    }
}
