package com.demo.app.config;

public final class TestConfig {

    private TestConfig() {
    }

    public static String baseUrl() {
        String url = System.getenv().getOrDefault("BASE_URL", "http://localhost:3000");
        return url.endsWith("/") ? url.substring(0, url.length() - 1) : url;
    }

    public static boolean isCi() {
        return Boolean.parseBoolean(System.getenv().getOrDefault("CI", "false"));
    }
}
