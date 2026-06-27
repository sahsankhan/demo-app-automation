package com.demo.app.hooks;

import com.demo.app.config.TestConfig;
import com.demo.app.context.TestContext;
import io.cucumber.java.After;
import io.cucumber.java.Before;
import io.github.bonigarcia.wdm.WebDriverManager;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.chrome.ChromeOptions;

public class WebDriverHooks {

    private WebDriver driver;

    @Before("@ui")
    public void startBrowser() {
        WebDriverManager.chromedriver().setup();

        ChromeOptions options = new ChromeOptions();
        options.addArguments("--remote-allow-origins=*", "--window-size=1280,900");

        if (TestConfig.isCi()) {
            options.addArguments("--headless=new", "--no-sandbox", "--disable-dev-shm-usage");
        }

        driver = new ChromeDriver(options);
        TestContext.setDriver(driver);
    }

    @After("@ui")
    public void stopBrowser() {
        if (driver != null) {
            driver.quit();
        }
        TestContext.clear();
    }
}
