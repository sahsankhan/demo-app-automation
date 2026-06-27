package com.demo.app.flows;

import com.demo.app.data.TestScenario;
import com.demo.app.pages.PageFactory;

/**
 * Composes page objects into reusable user journeys.
 * Steps stay thin — business flow logic lives here.
 */
public final class BankingJourneyFlow {

    private final PageFactory pages;

    public BankingJourneyFlow(PageFactory pages) {
        this.pages = pages;
    }

    public void openHomePage() {
        pages.home().open().assertLoaded();
    }

    public void registerCustomer(TestScenario scenario) {
        pages.onboarding()
                .open()
                .fillRegistrationForm(
                        scenario.firstName(),
                        scenario.lastName(),
                        scenario.email(),
                        scenario.phone(),
                        scenario.password()
                )
                .submitRegistration()
                .assertRegistrationSuccessful();
    }

    public void completeKyc(TestScenario scenario) {
        pages.onboarding().continueToKyc();
        pages.kyc()
                .assertLoaded()
                .fillVerificationForm(
                        scenario.dateOfBirth(),
                        scenario.nationalId(),
                        scenario.address(),
                        scenario.city(),
                        scenario.countryLabel(),
                        scenario.documentLabel()
                )
                .submitVerification()
                .assertVerificationSuccessful();
    }

    public void openAccount(TestScenario scenario) {
        pages.kyc().continueToAccount();
        pages.account()
                .assertLoaded()
                .fillAccountForm(
                        scenario.accountTypeLabel(),
                        scenario.currency(),
                        scenario.initialDeposit()
                )
                .submitAccountOpening()
                .assertAccountOpened();
    }

    public void submitPayment(TestScenario scenario) {
        pages.account().continueToPayment();
        pages.payment()
                .assertLoaded()
                .fillPaymentForm(
                        scenario.beneficiary(),
                        scenario.beneficiaryAccount(),
                        scenario.paymentAmount(),
                        scenario.paymentReference()
                )
                .submitPayment()
                .assertPaymentSuccessful();
    }

    public void prepareRegisteredCustomer(TestScenario scenario) {
        openHomePage();
        registerCustomer(scenario);
    }

    public void prepareKycVerifiedCustomer(TestScenario scenario) {
        prepareRegisteredCustomer(scenario);
        completeKyc(scenario);
    }

    public void prepareCustomerWithOpenAccount(TestScenario scenario) {
        prepareKycVerifiedCustomer(scenario);
        openAccount(scenario);
    }

    public void completeFullJourney(TestScenario scenario) {
        prepareRegisteredCustomer(scenario);
        completeKyc(scenario);
        openAccount(scenario);
        submitPayment(scenario);
    }
}
