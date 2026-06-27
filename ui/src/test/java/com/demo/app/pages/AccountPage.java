package com.demo.app.pages;

import com.demo.app.pages.base.BasePage;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;

public final class AccountPage extends BasePage {

    public static final class Route {
        public static final String PATH = "/account.html";
    }

    public static final class Locators {
        public static final By INITIAL_DEPOSIT = By.id("initialDeposit");
        public static final By OPEN_ACCOUNT = By.id("open-account-btn");
        public static final By CONTINUE_PAYMENT = By.id("continue-payment");
    }

    public static final class Text {
        public static final String PAGE_TITLE = "Open your account";
        public static final String SUCCESS = "Account opened";
    }

    public AccountPage(WebDriver driver, String baseUrl) {
        super(driver, baseUrl);
    }

    public AccountPage open() {
        open(Route.PATH);
        return assertLoaded();
    }

    public AccountPage assertLoaded() {
        assertTextVisible(Text.PAGE_TITLE);
        return this;
    }

    public AccountPage fillAccountForm(String accountTypeLabel, String currency, String initialDeposit) {
        clickOptionButton(accountTypeLabel);
        clickOptionButton(currency);
        type(Locators.INITIAL_DEPOSIT, initialDeposit);
        return this;
    }

    public AccountPage submitAccountOpening() {
        click(Locators.OPEN_ACCOUNT);
        return this;
    }

    public AccountPage assertAccountOpened() {
        assertTextVisible(Text.SUCCESS);
        return this;
    }

    public PaymentPage continueToPayment() {
        click(Locators.CONTINUE_PAYMENT);
        return new PaymentPage(driver, baseUrl);
    }
}
