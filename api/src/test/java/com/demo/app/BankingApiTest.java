package com.demo.app;

import com.intuit.karate.junit5.Karate;

class BankingApiTest {

    @Karate.Test
    Karate runAllApiTests() {
        return Karate.run("classpath:karate")
                .tags("~@ignore")
                .relativeTo(getClass());
    }
}
