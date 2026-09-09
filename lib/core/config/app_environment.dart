enum AppEnvironment {
  dev,
  prod,
}

extension AppEnvironmentExtension on AppEnvironment {
  String get name {
    switch (this) {
      case AppEnvironment.dev:
        return 'Development (Local)';
      case AppEnvironment.prod:
        return 'Production (Live)';
    }
  }

  bool get isDev => this == AppEnvironment.dev;
  bool get isProd => this == AppEnvironment.prod;
}
