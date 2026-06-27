package com.demo.app.steps;

import io.cucumber.java.en.Given;

public class HomeSteps extends BaseSteps {

    @Given("^the Demo App home page is open$")
    public void homePageIsOpen() {
        journey().openHomePage();
    }
}
