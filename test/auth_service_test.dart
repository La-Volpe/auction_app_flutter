import 'package:flutter_test/flutter_test.dart';
import 'package:car_auction_app/authentication/data/auth_service.dart';

void main() {
  group('MockAuthService', () {
    final authService = MockAuthService();

    test('should return success for valid credentials', () {
      final result = authService.authenticate('user@cos.io', '12345678');
      expect(result['statusCode'], 200);
      expect(result['message'], 'Authentication successful. API token: abc123xyz789');
    });

    test('should return failure for invalid email', () {
      final result = authService.authenticate('invalid@cos.io', 'password');
      expect(result['statusCode'], 401);
      expect(result['message'], 'Invalid email or password');
    });

    test('should return failure for invalid password', () {
      final result = authService.authenticate('user@cos.io', 'invalidpassword');
      expect(result['statusCode'], 401);
      expect(result['message'], 'Invalid email or password');
    });

    test('should return failure for empty email', () {
      final result = authService.authenticate('', 'password');
      expect(result['statusCode'], 401);
      expect(result['message'], 'Invalid email or password');
    });

    test('should return failure for empty password', () {
      final result = authService.authenticate('user@cos.io', '');
      expect(result['statusCode'], 401);
      expect(result['message'], 'Invalid email or password');
    });
  });
}