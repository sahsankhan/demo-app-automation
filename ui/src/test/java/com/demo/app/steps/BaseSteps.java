package com.demo.app.steps;

import com.demo.app.context.TestContext;
import com.demo.app.data.ScenarioLoader;
import com.demo.app.data.TestScenario;
import com.demo.app.flows.BankingJourneyFlow;
import com.demo.app.pages.PageFactory;

public abstract class BaseSteps {

    protected PageFactory pages() {
        return PageFactory.current();
    }

    protected BankingJourneyFlow journey() {
        return new BankingJourneyFlow(pages());
    }

    protected TestScenario loadScenario(String userId) {
        TestScenario scenario = ScenarioLoader.load(userId);
        TestContext.setScenario(scenario);
        return scenario;
    }

    protected TestScenario currentScenario() {
        return TestContext.getScenario();
    }
}
