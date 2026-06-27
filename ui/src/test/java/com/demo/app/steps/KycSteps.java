package com.demo.app.steps;

import com.demo.app.data.TestScenario;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;
import io.cucumber.java.en.When;

public class KycSteps extends BaseSteps {

    @Given("^the customer has verified KYC with profile \"([^\"]*)\"$")
    public void customerHasVerifiedKyc(String userId) {
        TestScenario scenario = loadScenario(userId);
        journey().prepareKycVerifiedCustomer(scenario);
    }

    @When("^the customer completes KYC verification$")
    public void customerCompletesKyc() {
        journey().completeKyc(currentScenario());
    }

    @Then("^KYC verification is successful$")
    public void kycVerificationIsSuccessful() {
        pages().kyc().assertVerificationSuccessful();
    }
}
