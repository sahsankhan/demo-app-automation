package com.demo.app.pages;

import com.demo.app.config.TestConfig;
import com.demo.app.context.TestContext;
import org.openqa.selenium.WebDriver;

public final class PageFactory {

    private final WebDriver driver;
    private final String baseUrl;

    public PageFactory(WebDriver driver, String baseUrl) {
        this.driver = driver;
        this.baseUrl = baseUrl;
    }

    public static PageFactory current() {
        return new PageFactory(TestContext.getDriver(), TestConfig.baseUrl());
    }

    public HomePage home() {
        return new HomePage(driver, baseUrl);
    }

    public OnboardingPage onboarding() {
        return new OnboardingPage(driver, baseUrl);
    }

    public KycPage kyc() {
        return new KycPage(driver, baseUrl);
    }

    public AccountPage account() {
        return new AccountPage(driver, baseUrl);
    }

    public PaymentPage payment() {
        return new PaymentPage(driver, baseUrl);
    }
}
