package com.demo.app.pages;

import com.demo.app.pages.base.BasePage;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;

public final class PaymentPage extends BasePage {

    public static final class Route {
        public static final String PATH = "/payment.html";
    }

    public static final class Locators {
        public static final By BENEFICIARY = By.id("beneficiary");
        public static final By BENEFICIARY_ACCOUNT = By.id("beneficiaryAccount");
        public static final By AMOUNT = By.id("amount");
        public static final By REFERENCE = By.id("reference");
        public static final By SUBMIT = By.id("submit-payment-btn");
    }

    public static final class Text {
        public static final String PAGE_TITLE = "Make a payment";
        public static final String SUCCESS = "Payment successful";
        public static final String JOURNEY_COMPLETE = "Banking journey complete";
    }

    public PaymentPage(WebDriver driver, String baseUrl) {
        super(driver, baseUrl);
    }

    public PaymentPage open() {
        open(Route.PATH);
        return assertLoaded();
    }

    public PaymentPage assertLoaded() {
        assertTextVisible(Text.PAGE_TITLE);
        return this;
    }

    public PaymentPage fillPaymentForm(
            String beneficiary,
            String beneficiaryAccount,
            String amount,
            String reference
    ) {
        type(Locators.BENEFICIARY, beneficiary);
        type(Locators.BENEFICIARY_ACCOUNT, beneficiaryAccount);
        type(Locators.AMOUNT, amount);
        type(Locators.REFERENCE, reference);
        return this;
    }

    public PaymentPage submitPayment() {
        click(Locators.SUBMIT);
        return this;
    }

    public PaymentPage assertPaymentSuccessful() {
        assertTextVisible(Text.SUCCESS);
        return this;
    }

    public PaymentPage assertJourneyComplete() {
        assertTextVisible(Text.JOURNEY_COMPLETE);
        return this;
    }
}
