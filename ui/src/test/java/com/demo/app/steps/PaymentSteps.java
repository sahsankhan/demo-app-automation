package com.demo.app.steps;

import io.cucumber.java.en.Then;
import io.cucumber.java.en.When;

public class PaymentSteps extends BaseSteps {

    @When("^the customer submits a payment$")
    public void customerSubmitsPayment() {
        journey().submitPayment(currentScenario());
    }

    @Then("^the payment is successful$")
    public void paymentIsSuccessful() {
        pages().payment().assertPaymentSuccessful();
    }
}
