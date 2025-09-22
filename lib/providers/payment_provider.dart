import 'package:flutter/foundation.dart';
import '../models/station.dart';
import '../services/payment_service.dart';

class PaymentProvider extends ChangeNotifier {
  final PaymentService _paymentService = PaymentService();
  
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _error;
  StationInfo? _stationInfo;
  PaymentResult? _lastPaymentResult;

  // Getters
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get error => _error;
  StationInfo? get stationInfo => _stationInfo;
  PaymentResult? get lastPaymentResult => _lastPaymentResult;
  bool get isApplePayAvailable => _paymentService.isApplePayAvailable();

  /// Инициализация сервиса платежей
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _setLoading(true);
    _clearError();
    
    try {
      await _paymentService.initialize();
      _isInitialized = true;
    } catch (e) {
      _setError('Failed to initialize payment service: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Загрузить информацию о станции
  Future<void> loadStationInfo(String stationId) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    _setLoading(true);
    _clearError();
    
    try {
      _stationInfo = await _paymentService.getStationInfo(stationId);
    } catch (e) {
      _setError('Failed to load station info: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Проверить доступность станции
  Future<bool> checkStationAvailability(String stationId) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    try {
      return await _paymentService.checkStationAvailability(stationId);
    } catch (e) {
      return false;
    }
  }

  /// Обработать платеж через Apple Pay
  Future<void> processApplePayPayment({
    required String stationId,
    required double amount,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    _setLoading(true);
    _clearError();
    
    try {
      _lastPaymentResult = await _paymentService.processApplePayPayment(
        stationId: stationId,
        amount: amount,
      );
      
      if (!_lastPaymentResult!.success) {
        _setError(_lastPaymentResult!.message ?? 'Payment failed');
      }
    } catch (e) {
      _setError('Apple Pay payment failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Обработать платеж через карту
  Future<void> processCardPayment({
    required String stationId,
    required double amount,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    _setLoading(true);
    _clearError();
    
    try {
      _lastPaymentResult = await _paymentService.processCardPayment(
        stationId: stationId,
        amount: amount,
      );
      
      if (!_lastPaymentResult!.success) {
        _setError(_lastPaymentResult!.message ?? 'Payment failed');
      }
    } catch (e) {
      _setError('Card payment failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Очистить ошибку
  void clearError() {
    _clearError();
  }

  /// Сбросить состояние
  void reset() {
    _isLoading = false;
    _isInitialized = false;
    _error = null;
    _stationInfo = null;
    _lastPaymentResult = null;
    notifyListeners();
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
