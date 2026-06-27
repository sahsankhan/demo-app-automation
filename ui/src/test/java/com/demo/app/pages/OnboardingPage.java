package com.demo.app.pages;

import com.demo.app.pages.base.BasePage;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;

public final class OnboardingPage extends BasePage {

    public static final class Route {
        public static final String PATH = "/onboarding.html";
    }

    public static final class Locators {
        public static final By FIRST_NAME = By.id("firstName");
        public static final By LAST_NAME = By.id("lastName");
        public static final By EMAIL = By.id("email");
        public static final By PHONE = By.id("phone");
        public static final By PASSWORD = By.id("password");
        public static final By REGISTER = By.id("register-btn");
        public static final By CONTINUE_KYC = By.id("continue-kyc");
    }

    public static final class Text {
        public static final String PAGE_TITLE = "Create your account";
        public static final String SUCCESS = "Registration successful";
    }

    public OnboardingPage(WebDriver driver, String baseUrl) {
        super(driver, baseUrl);
    }

    public OnboardingPage open() {
        open(Route.PATH);
        return assertLoaded();
    }

    public OnboardingPage assertLoaded() {
        assertTextVisible(Text.PAGE_TITLE);
        return this;
    }

    public OnboardingPage fillRegistrationForm(
            String firstName,
            String lastName,
            String email,
            String phone,
            String password
    ) {
        type(Locators.FIRST_NAME, firstName);
        type(Locators.LAST_NAME, lastName);
        type(Locators.EMAIL, email);
        type(Locators.PHONE, phone);
        type(Locators.PASSWORD, password);
        return this;
    }

    public OnboardingPage submitRegistration() {
        click(Locators.REGISTER);
        return this;
    }

    public OnboardingPage assertRegistrationSuccessful() {
        assertTextVisible(Text.SUCCESS);
        return this;
    }

    public KycPage continueToKyc() {
        click(Locators.CONTINUE_KYC);
        return new KycPage(driver, baseUrl);
    }
}
