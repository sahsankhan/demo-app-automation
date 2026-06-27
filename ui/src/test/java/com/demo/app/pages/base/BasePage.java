package com.demo.app.pages.base;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import java.time.Duration;

public abstract class BasePage {

    protected final WebDriver driver;
    protected final WebDriverWait wait;
    protected final String baseUrl;

    protected BasePage(WebDriver driver, String baseUrl) {
        this.driver = driver;
        this.baseUrl = baseUrl.endsWith("/") ? baseUrl.substring(0, baseUrl.length() - 1) : baseUrl;
        this.wait = new WebDriverWait(driver, Duration.ofSeconds(15));
    }

    protected void open(String path) {
        String route = path.startsWith("/") ? path : "/" + path;
        driver.get(baseUrl + route);
    }

    protected void type(By locator, String value) {
        WebElement field = wait.until(ExpectedConditions.visibilityOfElementLocated(locator));
        field.clear();
        field.sendKeys(value);
    }

    protected void click(By locator) {
        wait.until(ExpectedConditions.elementToBeClickable(locator)).click();
    }

    protected void clickOptionButton(String label) {
        String literal = xpathLiteral(label);
        click(By.xpath("//button[contains(@class,'option-btn') and normalize-space()=" + literal + "]"));
    }

    protected void assertTextVisible(String text) {
        String literal = xpathLiteral(text);
        wait.until(ExpectedConditions.visibilityOfElementLocated(
                By.xpath("//*[contains(normalize-space(), " + literal + ")]")
        ));
    }

    private static String xpathLiteral(String value) {
        if (!value.contains("'")) {
            return "'" + value + "'";
        }
        if (!value.contains("\"")) {
            return "\"" + value + "\"";
        }
        StringBuilder expression = new StringBuilder("concat(");
        String[] parts = value.split("'", -1);
        for (int i = 0; i < parts.length; i++) {
            if (i > 0) {
                expression.append(", \"'\", ");
            }
            expression.append("'").append(parts[i]).append("'");
        }
        return expression.append(")").toString();
    }
}
