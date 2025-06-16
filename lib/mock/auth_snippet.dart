class MockAuthService {
  /// Authenticates a user based on email and password.
  ///
  /// Returns a map containing:
  /// - statusCode: HTTP status code (200 for success, 401 for failure)
  /// - message: Success message with API token or error message
  Map<String, dynamic> authenticate(String email, String password) {
    const validUsers = {
      'user@cos.io': '12345678',
      'user2@cos.io': 'password',
      'user3@cos.io': 'notpassword',
    };

    if (validUsers[email] == password) {
      return {
        'statusCode': 200,
        'message': 'Authentication successful. API token: abc123xyz789',
      };
    } else {
      return {
        'statusCode': 401,
        'message': 'Invalid email or password',
      };
    }
  }
}