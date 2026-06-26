function fn(arg) {
  var userId = typeof arg === 'string' ? arg : arg.userId;
  if (!userId) {
    karate.fail('userId is required');
  }

  var users = karate.read('classpath:data/users/onboarding-users.json');
  var kycFile = karate.read('classpath:data/kyc/kyc-scenarios.json');
  var paymentFile = karate.read('classpath:data/payments/payment-scenarios.json');

  var user = null;
  for (var i = 0; i < users.users.length; i++) {
    if (users.users[i].id === userId) {
      user = users.users[i];
      break;
    }
  }

  var kyc = null;
  for (var j = 0; j < kycFile.scenarios.length; j++) {
    if (kycFile.scenarios[j].userId === userId) {
      kyc = kycFile.scenarios[j];
      break;
    }
  }

  var account = null;
  var payment = null;
  for (var k = 0; k < paymentFile.accounts.length; k++) {
    if (paymentFile.accounts[k].userId === userId) {
      account = paymentFile.accounts[k];
      break;
    }
  }
  for (var m = 0; m < paymentFile.payments.length; m++) {
    if (paymentFile.payments[m].userId === userId) {
      payment = paymentFile.payments[m];
      break;
    }
  }

  if (!user || !kyc || !account || !payment) {
    karate.fail('No complete scenario for userId: ' + userId);
  }

  var initialDeposit = parseFloat(account.initialDeposit);
  var paymentAmount = parseFloat(payment.amount);
  var expectedBalance = initialDeposit - paymentAmount;

  return {
    userId: userId,
    xrayKey: user.xrayKey,
    user: user,
    kyc: kyc,
    account: account,
    payment: payment,
    expectedBalance: expectedBalance
  };
}
