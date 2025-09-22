import 'dart:html' as html;
import 'dart:js_util' as js_util;
import '../models/payment.dart';
import '../models/station.dart';
import 'api_client.dart';
import 'auth_service.dart';

class PaymentService {
  final ApiClient _apiClient = ApiClient();
  final AuthService _authService = AuthService();
  
  String? _clientToken;
  bool _isInitialized = false;

  /// Инициализация сервиса платежей
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Получаем client token от Braintree
      _clientToken = await _apiClient.generateClientToken();
      
      // Создаем Apple аккаунт если нужно
      if (!_authService.isAuthenticated) {
        await _authService.createAppleAccount();
      }
      
      _isInitialized = true;
    } catch (e) {
      throw Exception('Failed to initialize payment service: $e');
    }
  }

  /// Проверить доступность Apple Pay
  bool isApplePayAvailable() {
    try {
      final result = js_util.callMethod(html.window, 'isApplePayAvailable', []);
      return result == true;
    } catch (e) {
      return false;
    }
  }

  /// Получить client token
  String? get clientToken => _clientToken;

  /// Проверить инициализацию
  bool get isInitialized => _isInitialized;

  /// Обработка платежа через Apple Pay
  Future<PaymentResult> processApplePayPayment({
    required String stationId,
    required double amount,
  }) async {
    if (!_isInitialized || _clientToken == null) {
      throw Exception('Payment service not initialized');
    }

    try {
      // Запускаем Apple Pay через JavaScript bridge
      final futureJs = js_util.callMethod(
        html.window, 
        'startApplePay', 
        [_clientToken, amount.toString()]
      );
      
      final nonce = await js_util.promiseToFuture(futureJs);
      
      // Добавляем payment method
      final paymentToken = await _apiClient.addPaymentMethod(
        paymentNonceFromTheClient: nonce.toString(),
        description: 'web',
        paymentType: 'apple',
        jwtToken: _authService.currentAccountId,
      );
      
      // Создаем подписку
      final subscriptionResult = await _apiClient.createSubscription(
        paymentToken: paymentToken,
      );
      
      if (!subscriptionResult.success) {
        throw Exception(subscriptionResult.message ?? 'Subscription failed');
      }
      
      // Арендуем павербанк
      final rentalResult = await _apiClient.rentPowerBank(
        stationId: stationId,
        paymentToken: paymentToken,
      );
      
      return PaymentResult(
        success: rentalResult.success,
        message: rentalResult.message,
        transactionId: subscriptionResult.transactionId,
        powerBankId: rentalResult.powerBankId,
      );
    } catch (e) {
      return PaymentResult(
        success: false,
        message: e.toString(),
      );
    }
  }

  /// Обработка платежа через карту
  Future<PaymentResult> processCardPayment({
    required String stationId,
    required double amount,
  }) async {
    if (!_isInitialized || _clientToken == null) {
      throw Exception('Payment service not initialized');
    }

    try {
      // Инициализируем Drop-in
      final initCall = js_util.callMethod(html.window, 'initDropIn', [_clientToken]);
      await js_util.promiseToFuture(initCall);

      // Запрашиваем payment method
      final req = js_util.callMethod(html.window, 'requestPaymentMethod', []);
      final nonce = await js_util.promiseToFuture(req);

      // Закрываем Drop-in
      try {
        js_util.callMethod(html.window, 'closeDropIn', []);
      } catch (_) {}

      // Добавляем payment method
      final paymentToken = await _apiClient.addPaymentMethod(
        paymentNonceFromTheClient: nonce.toString(),
        description: 'web',
        paymentType: 'card',
        jwtToken: _authService.currentAccountId,
      );
      
      // Создаем подписку
      final subscriptionResult = await _apiClient.createSubscription(
        paymentToken: paymentToken,
      );
      
      if (!subscriptionResult.success) {
        throw Exception(subscriptionResult.message ?? 'Subscription failed');
      }
      
      // Арендуем павербанк
      final rentalResult = await _apiClient.rentPowerBank(
        stationId: stationId,
        paymentToken: paymentToken,
      );
      
      return PaymentResult(
        success: rentalResult.success,
        message: rentalResult.message,
        transactionId: subscriptionResult.transactionId,
        powerBankId: rentalResult.powerBankId,
      );
    } catch (e) {
      // Закрываем Drop-in в случае ошибки
      try {
        js_util.callMethod(html.window, 'closeDropIn', []);
      } catch (_) {}
      
      return PaymentResult(
        success: false,
        message: e.toString(),
      );
    }
  }

  /// Проверить доступность станции
  Future<bool> checkStationAvailability(String stationId) async {
    try {
      return await _apiClient.checkStationAvailability(stationId);
    } catch (e) {
      return false;
    }
  }

  /// Получить информацию о станции
  Future<StationInfo> getStationInfo(String stationId) async {
    try {
      return await _apiClient.getStationInfo(stationId);
    } catch (e) {
      throw Exception('Failed to get station info: $e');
    }
  }
}

class PaymentResult {
  final bool success;
  final String? message;
  final String? transactionId;
  final String? powerBankId;

  PaymentResult({
    required this.success,
    this.message,
    this.transactionId,
    this.powerBankId,
  });
}
