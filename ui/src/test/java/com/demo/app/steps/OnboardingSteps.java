package com.demo.app.steps;

import com.demo.app.data.TestScenario;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;
import io.cucumber.java.en.When;

public class OnboardingSteps extends BaseSteps {

    @Given("^the customer is registered with profile \"([^\"]*)\"$")
    public void customerIsRegistered(String userId) {
        TestScenario scenario = loadScenario(userId);
        journey().prepareRegisteredCustomer(scenario);
    }

    @When("^the customer registers using profile \"([^\"]*)\"$")
    public void customerRegisters(String userId) {
        TestScenario scenario = loadScenario(userId);
        journey().openHomePage();
        journey().registerCustomer(scenario);
    }

    @Then("^registration is successful$")
    public void registrationIsSuccessful() {
        pages().onboarding().assertRegistrationSuccessful();
    }
}
