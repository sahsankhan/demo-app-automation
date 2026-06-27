package com.demo.app.steps;

import com.demo.app.data.TestScenario;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;
import io.cucumber.java.en.When;

public class AccountSteps extends BaseSteps {

    @Given("^the customer has an open account with profile \"([^\"]*)\"$")
    public void customerHasOpenAccount(String userId) {
        TestScenario scenario = loadScenario(userId);
        journey().prepareCustomerWithOpenAccount(scenario);
    }

    @When("^the customer opens a bank account$")
    public void customerOpensAccount() {
        journey().openAccount(currentScenario());
    }

    @Then("^the account is opened successfully$")
    public void accountIsOpenedSuccessfully() {
        pages().account().assertAccountOpened();
    }
}
