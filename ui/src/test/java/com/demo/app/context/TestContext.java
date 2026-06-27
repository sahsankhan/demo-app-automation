package com.demo.app.context;

import com.demo.app.data.TestScenario;
import org.openqa.selenium.WebDriver;

public final class TestContext {

    private static final ThreadLocal<WebDriver> DRIVER = new ThreadLocal<>();
    private static final ThreadLocal<TestScenario> SCENARIO = new ThreadLocal<>();

    private TestContext() {
    }

    public static void setDriver(WebDriver driver) {
        DRIVER.set(driver);
    }

    public static WebDriver getDriver() {
        WebDriver driver = DRIVER.get();
        if (driver == null) {
            throw new IllegalStateException("WebDriver not initialised — are @ui hooks running?");
        }
        return driver;
    }

    public static void setScenario(TestScenario scenario) {
        SCENARIO.set(scenario);
    }

    public static TestScenario getScenario() {
        TestScenario scenario = SCENARIO.get();
        if (scenario == null) {
            throw new IllegalStateException("No test scenario loaded for this thread");
        }
        return scenario;
    }

    public static void clear() {
        DRIVER.remove();
        SCENARIO.remove();
    }
}
