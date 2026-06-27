package com.demo.app.steps;

import com.demo.app.data.TestScenario;
import io.cucumber.java.en.Then;
import io.cucumber.java.en.When;

public class JourneySteps extends BaseSteps {

    @When("^the customer completes the full banking journey with profile \"([^\"]*)\"$")
    public void customerCompletesFullJourney(String userId) {
        TestScenario scenario = loadScenario(userId);
        journey().completeFullJourney(scenario);
    }

    @Then("^the banking journey is complete$")
    public void bankingJourneyIsComplete() {
        pages().payment().assertJourneyComplete();
    }
}
