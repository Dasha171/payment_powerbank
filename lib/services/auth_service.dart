import 'dart:html' as html;
import '../models/payment.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();
  String? _currentAccountId;
  String? _deviceId;

  AuthService() {
    _initializeDeviceId();
  }

  /// Инициализация device ID для веб-платформы
  void _initializeDeviceId() {
    // Генерируем уникальный device ID для веб-сессии
    _deviceId = _generateDeviceId();
  }

  String _generateDeviceId() {
    // Используем комбинацию user agent и timestamp для создания уникального ID
    final userAgent = html.window.navigator.userAgent;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'web_${userAgent.hashCode}_$timestamp';
  }

  /// Создать Apple аккаунт
  Future<String> createAppleAccount() async {
    try {
      final response = await _apiClient.createAppleAccount(
        deviceId: _deviceId,
        pushToken: null, // Для веб не используем push токены
      );
      
      _currentAccountId = response.accountId;
      return response.accountId;
    } catch (e) {
      throw Exception('Failed to create Apple account: $e');
    }
  }

  /// Получить текущий account ID
  String? get currentAccountId => _currentAccountId;

  /// Проверить, есть ли активная сессия
  bool get isAuthenticated => _currentAccountId != null;

  /// Очистить сессию
  void clearSession() {
    _currentAccountId = null;
  }

  /// Получить device ID
  String? get deviceId => _deviceId;
}
