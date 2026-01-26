class Env {
  static const baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://hello-spring-1-t4e1.onrender.com',
  );
}
