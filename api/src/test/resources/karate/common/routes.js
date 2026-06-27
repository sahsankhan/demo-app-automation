function fn() {
  var map = karate.read('classpath:../../config/journey-map.json');
  var routes = map.api.routes;

  function pathFor(key, params) {
    var route = routes[key];
    if (!route) {
      karate.fail('Unknown API route key: ' + key);
    }
    var segments = route.segments.slice();
    if (params) {
      segments = segments.map(function(segment) {
        if (segment.indexOf('${') === 0) {
          var name = segment.substring(2, segment.length - 1);
          return params[name];
        }
        return segment;
      });
    }
    return segments;
  }

  return {
    health: pathFor('health'),
    onboarding: pathFor('onboarding'),
    kyc: pathFor('kyc'),
    account: pathFor('account'),
    payment: pathFor('payment'),
    reset: pathFor('reset'),
    accountBalance: function(accountId) {
      return pathFor('accountBalance', { accountId: accountId });
    }
  };
}
