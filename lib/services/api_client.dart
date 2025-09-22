import 'package:dio/dio.dart';
import '../models/payment.dart';
import '../models/station.dart';

class ApiClient {
  static const String baseUrl = 'https://goldfish-app-3lf7u.ondigitalocean.app';
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Добавляем интерцептор для логирования
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  /// Получить Braintree client token
  Future<String> generateClientToken() async {
    try {
      final response = await _dio.get('/api/v1/payments/generate-and-save-braintree-client-token');
      final tokenData = BraintreeClientToken.fromJson(response.data);
      return tokenData.token;
    } catch (e) {
      throw Exception('Failed to generate client token: $e');
    }
  }

  /// Создать Apple аккаунт
  Future<AppleAccountResponse> createAppleAccount({
    String? deviceId,
    String? pushToken,
  }) async {
    try {
      final request = AppleAccountRequest(
        deviceId: deviceId,
        pushToken: pushToken,
      );
      
      final response = await _dio.post(
        '/api/v1/auth/apple/generate-account',
        data: request.toJson(),
      );
      
      return AppleAccountResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create Apple account: $e');
    }
  }

  /// Добавить payment method
  Future<String> addPaymentMethod({
    required String paymentNonceFromTheClient,
    required String description,
    required String paymentType,
    String? jwtToken,
  }) async {
    try {
      final data = {
        'paymentNonceFromTheClient': paymentNonceFromTheClient,
        'description': description,
        'paymentType': paymentType,
      };
      
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      
      if (jwtToken != null) {
        headers['Authorization'] = 'Bearer $jwtToken';
      }
      
      final response = await _dio.post(
        '/api/v1/payments/add-payment-method',
        data: data,
        options: Options(headers: headers),
      );
      
      return response.data['paymentToken'] ?? '';
    } catch (e) {
      throw Exception('Failed to add payment method: $e');
    }
  }

  /// Оформить подписку
  Future<PaymentResponse> createSubscription({
    required String paymentToken,
    String thePlanId = 'tss2',
    bool disableWelcomeDiscount = false,
    int welcomeDiscount = 10,
  }) async {
    try {
      final request = PaymentRequest(
        paymentToken: paymentToken,
        thePlanId: thePlanId,
        disableWelcomeDiscount: disableWelcomeDiscount,
        welcomeDiscount: welcomeDiscount,
      );
      
      final response = await _dio.post(
        '/api/v1/payments/subscription/create-subscription-transaction-v2',
        queryParameters: {
          'disableWelcomeDiscount': disableWelcomeDiscount,
          'welcomeDiscount': welcomeDiscount,
        },
        data: request.toJson(),
      );
      
      return PaymentResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create subscription: $e');
    }
  }

  /// Арендовать павербанк
  Future<PowerBankRentalResponse> rentPowerBank({
    required String stationId,
    required String paymentToken,
  }) async {
    try {
      final request = PowerBankRentalRequest(
        stationId: stationId,
        paymentToken: paymentToken,
      );
      
      final response = await _dio.post(
        '/api/v1/payments/rent-power-bank',
        data: request.toJson(),
      );
      
      return PowerBankRentalResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to rent power bank: $e');
    }
  }

  /// Получить информацию о станции
  Future<StationInfo> getStationInfo(String stationId) async {
    try {
      final response = await _dio.get('/api/v1/stations/$stationId');
      return StationInfo.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get station info: $e');
    }
  }

  /// Проверить доступность станции
  Future<bool> checkStationAvailability(String stationId) async {
    try {
      final stationInfo = await getStationInfo(stationId);
      return stationInfo.isOperational;
    } catch (e) {
      return false;
    }
  }
}
