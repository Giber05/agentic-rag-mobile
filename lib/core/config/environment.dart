enum Environment { development, staging, production }

class ENV {
  static Environment _environment = Environment.development;

  static Environment get current => _environment;

  static void setEnvironment(Environment env) {
    _environment = env;
  }

  String get baseURL {
    switch (_environment) {
      case Environment.development:
        return 'https://agentic-rag-backend-production.up.railway.app';
      case Environment.staging:
        return 'https://staging-api.yourapp.com';
      case Environment.production:
        return 'https://api.yourapp.com';
    }
  }

  static ENV get instance => ENV();
}
