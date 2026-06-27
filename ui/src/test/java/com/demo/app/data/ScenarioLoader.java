package com.demo.app.data;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Map;

public final class ScenarioLoader {

    private static final ObjectMapper MAPPER = new ObjectMapper();

    private static final Map<String, String> COUNTRY_LABELS = Map.of(
            "US", "United States",
            "UK", "United Kingdom",
            "CA", "Canada"
    );

    private static final Map<String, String> DOCUMENT_LABELS = Map.of(
            "passport", "Passport",
            "drivers_license", "Driver's License",
            "national_id", "National ID"
    );

    private static final Map<String, String> ACCOUNT_TYPE_LABELS = Map.of(
            "checking", "Checking",
            "savings", "Savings",
            "premium", "Premium Checking"
    );

    private ScenarioLoader() {
    }

    public static TestScenario load(String userId) {
        try {
            JsonNode users = readData("users/onboarding-users.json").get("users");
            JsonNode kycScenarios = readData("kyc/kyc-scenarios.json").get("scenarios");
            JsonNode paymentFile = readData("payments/payment-scenarios.json");

            JsonNode user = findByField(users, "id", userId);
            JsonNode kyc = findByField(kycScenarios, "userId", userId);
            JsonNode account = findByField(paymentFile.get("accounts"), "userId", userId);
            JsonNode payment = findByField(paymentFile.get("payments"), "userId", userId);

            if (user == null || kyc == null || account == null || payment == null) {
                throw new IllegalArgumentException("No complete scenario for userId: " + userId);
            }

            String country = kyc.get("country").asText();
            String documentType = kyc.get("documentType").asText();
            String accountType = account.get("accountType").asText();

            return new TestScenario(
                    userId,
                    user.get("firstName").asText(),
                    user.get("lastName").asText(),
                    user.get("email").asText(),
                    user.get("phone").asText(),
                    user.get("password").asText(),
                    kyc.get("dateOfBirth").asText(),
                    kyc.get("nationalId").asText(),
                    kyc.get("address").asText(),
                    kyc.get("city").asText(),
                    country,
                    COUNTRY_LABELS.get(country),
                    documentType,
                    DOCUMENT_LABELS.get(documentType),
                    accountType,
                    ACCOUNT_TYPE_LABELS.get(accountType),
                    account.get("currency").asText(),
                    account.get("initialDeposit").asText(),
                    payment.get("beneficiary").asText(),
                    payment.get("beneficiaryAccount").asText(),
                    payment.get("amount").asText(),
                    payment.get("reference").asText()
            );
        } catch (IOException e) {
            throw new IllegalStateException("Failed to load test scenario", e);
        }
    }

    private static JsonNode readData(String relativePath) throws IOException {
        Path external = Paths.get("..", "data", relativePath).normalize();
        if (Files.exists(external)) {
            return MAPPER.readTree(external.toFile());
        }
        InputStream stream = ScenarioLoader.class.getClassLoader().getResourceAsStream("data/" + relativePath);
        if (stream == null) {
            throw new IOException("Missing data file: " + relativePath);
        }
        return MAPPER.readTree(stream);
    }

    private static JsonNode findByField(JsonNode array, String field, String value) {
        for (JsonNode node : array) {
            if (value.equals(node.get(field).asText())) {
                return node;
            }
        }
        return null;
    }
}
