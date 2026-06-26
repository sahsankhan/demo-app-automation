function fn() {
  var env = karate.env || 'local';
  var config = {
    env: env,
    baseUrl: 'http://localhost:4000',
    apiVersion: 'v1'
  };

  if (env === 'staging') {
    config.baseUrl = java.lang.System.getenv('STAGING_API_URL') || 'https://staging-api-bank.example.com';
  }

  config.dataRoot = karate.properties['user.dir'].replace(/\\/g, '/');
  if (config.dataRoot.endsWith('/api')) {
    config.dataRoot = config.dataRoot + '/../data';
  } else {
    config.dataRoot = config.dataRoot + '/data';
  }

  karate.configure('connectTimeout', 10000);
  karate.configure('readTimeout', 30000);
  karate.configure('logPrettyRequest', true);
  karate.configure('logPrettyResponse', true);

  return config;
}
