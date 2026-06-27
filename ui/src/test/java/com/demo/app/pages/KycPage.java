package com.demo.app.pages;

import com.demo.app.pages.base.BasePage;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;

public final class KycPage extends BasePage {

    public static final class Route {
        public static final String PATH = "/kyc.html";
    }

    public static final class Locators {
        public static final By DATE_OF_BIRTH = By.id("dateOfBirth");
        public static final By NATIONAL_ID = By.id("nationalId");
        public static final By ADDRESS = By.id("address");
        public static final By CITY = By.id("city");
        public static final By VERIFY = By.id("verify-kyc-btn");
        public static final By CONTINUE_ACCOUNT = By.id("continue-account");
    }

    public static final class Text {
        public static final String PAGE_TITLE = "Identity verification";
        public static final String SUCCESS = "KYC verified";
    }

    public KycPage(WebDriver driver, String baseUrl) {
        super(driver, baseUrl);
    }

    public KycPage open() {
        open(Route.PATH);
        return assertLoaded();
    }

    public KycPage assertLoaded() {
        assertTextVisible(Text.PAGE_TITLE);
        return this;
    }

    public KycPage fillVerificationForm(
            String dateOfBirth,
            String nationalId,
            String address,
            String city,
            String countryLabel,
            String documentLabel
    ) {
        type(Locators.DATE_OF_BIRTH, dateOfBirth);
        type(Locators.NATIONAL_ID, nationalId);
        type(Locators.ADDRESS, address);
        type(Locators.CITY, city);
        clickOptionButton(countryLabel);
        clickOptionButton(documentLabel);
        return this;
    }

    public KycPage submitVerification() {
        click(Locators.VERIFY);
        return this;
    }

    public KycPage assertVerificationSuccessful() {
        assertTextVisible(Text.SUCCESS);
        return this;
    }

    public AccountPage continueToAccount() {
        click(Locators.CONTINUE_ACCOUNT);
        return new AccountPage(driver, baseUrl);
    }
}
