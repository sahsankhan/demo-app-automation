(function () {
  const STORAGE_KEY = "demoAppSession";

  function getSession() {
    try {
      return JSON.parse(localStorage.getItem(STORAGE_KEY) || "{}");
    } catch {
      return {};
    }
  }

  function saveSession(data) {
    localStorage.setItem(STORAGE_KEY, JSON.stringify({ ...getSession(), ...data }));
  }

  function formatMoney(amount, currency) {
    return new Intl.NumberFormat("en-US", {
      style: "currency",
      currency: currency || "USD",
    }).format(Number(amount || 0));
  }

  function generateId(prefix) {
    return `${prefix}-${Math.random().toString(36).slice(2, 10).toUpperCase()}`;
  }

  document.querySelectorAll(".option-buttons").forEach((group) => {
    const fieldId = group.dataset.field;
    const hiddenInput = document.getElementById(fieldId);

    group.querySelectorAll(".option-btn").forEach((button) => {
      button.addEventListener("click", () => {
        hiddenInput.value = button.dataset.value;
        group.querySelectorAll(".option-btn").forEach((btn) => btn.classList.remove("selected"));
        button.classList.add("selected");
      });
    });
  });

  document.getElementById("onboarding-form")?.addEventListener("submit", function (event) {
    event.preventDefault();
    const firstName = document.getElementById("firstName").value.trim();
    const lastName = document.getElementById("lastName").value.trim();
    const email = document.getElementById("email").value.trim();
    const phone = document.getElementById("phone").value.trim();

    saveSession({ firstName, lastName, email, phone, onboardingComplete: true });

    document.getElementById("onboarding-form").classList.add("hidden");
    document.getElementById("onboarding-success").classList.remove("hidden");
    document.getElementById("welcome-message").textContent = `Welcome, ${firstName} ${lastName}!`;
  });

  document.getElementById("kyc-form")?.addEventListener("submit", function (event) {
    event.preventDefault();
    saveSession({
      kycComplete: true,
      dateOfBirth: document.getElementById("dateOfBirth").value,
      country: document.getElementById("country").value,
    });

    document.getElementById("kyc-form").classList.add("hidden");
    document.getElementById("kyc-success").classList.remove("hidden");
  });

  document.getElementById("account-form")?.addEventListener("submit", function (event) {
    event.preventDefault();
    const currency = document.getElementById("currency").value;
    const initialDeposit = Number(document.getElementById("initialDeposit").value);
    const accountNumber = generateId("ACC");

    saveSession({
      accountComplete: true,
      accountNumber,
      currency,
      balance: initialDeposit,
    });

    document.getElementById("account-form").classList.add("hidden");
    document.getElementById("account-success").classList.remove("hidden");
    document.getElementById("account-number").textContent = accountNumber;
    document.getElementById("account-balance").textContent = formatMoney(initialDeposit, currency);
  });

  const session = getSession();
  const balanceEl = document.getElementById("available-balance");
  if (balanceEl && session.balance != null) {
    balanceEl.textContent = formatMoney(session.balance, session.currency);
  }

  document.getElementById("payment-form")?.addEventListener("submit", function (event) {
    event.preventDefault();
    const current = getSession();
    const amount = Number(document.getElementById("amount").value);
    const newBalance = Number(current.balance || 0) - amount;
    const transactionId = generateId("TXN");

    if (newBalance < 0) {
      alert("Insufficient funds");
      return;
    }

    saveSession({ balance: newBalance, lastTransactionId: transactionId, paymentComplete: true });

    document.getElementById("payment-form").classList.add("hidden");
    document.getElementById("payment-success").classList.remove("hidden");
    document.getElementById("transaction-id").textContent = transactionId;
    document.getElementById("new-balance").textContent = formatMoney(newBalance, current.currency);
  });
})();
