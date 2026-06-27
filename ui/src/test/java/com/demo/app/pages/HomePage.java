package com.demo.app.pages;

import com.demo.app.pages.base.BasePage;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;

public final class HomePage extends BasePage {

    public static final class Route {
        public static final String PATH = "/";
    }

    public static final class Locators {
        public static final By START_ONBOARDING = By.id("start-onboarding");
    }

    public static final class Text {
        public static final String WELCOME = "Welcome to Demo App";
    }

    public HomePage(WebDriver driver, String baseUrl) {
        super(driver, baseUrl);
    }

    public HomePage open() {
        open(Route.PATH);
        return this;
    }

    public HomePage assertLoaded() {
        assertTextVisible(Text.WELCOME);
        return this;
    }

    public OnboardingPage startOnboarding() {
        click(Locators.START_ONBOARDING);
        return new OnboardingPage(driver, baseUrl);
    }
}
