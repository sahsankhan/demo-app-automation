package com.demo.app.data;

public record TestScenario(
        String userId,
        String firstName,
        String lastName,
        String email,
        String phone,
        String password,
        String dateOfBirth,
        String nationalId,
        String address,
        String city,
        String country,
        String countryLabel,
        String documentType,
        String documentLabel,
        String accountType,
        String accountTypeLabel,
        String currency,
        String initialDeposit,
        String beneficiary,
        String beneficiaryAccount,
        String paymentAmount,
        String paymentReference
) {
}
