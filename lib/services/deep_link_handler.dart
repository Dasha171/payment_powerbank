import 'dart:html' as html;
import 'package:flutter/material.dart';

class DeepLinkHandler {
  static String? getStationIdFromUrl() {
    try {
      final uri = Uri.parse(html.window.location.href);
      return uri.queryParameters['stationId'];
    } catch (e) {
      debugPrint('Error parsing station ID from URL: $e');
      return null;
    }
  }

  static String? getPowerBankIdFromUrl() {
    try {
      final uri = Uri.parse(html.window.location.href);
      return uri.queryParameters['powerBankId'];
    } catch (e) {
      debugPrint('Error parsing power bank ID from URL: $e');
      return null;
    }
  }

  static Map<String, String> getAllQueryParameters() {
    try {
      final uri = Uri.parse(html.window.location.href);
      return uri.queryParameters;
    } catch (e) {
      debugPrint('Error parsing query parameters: $e');
      return {};
    }
  }

  static void updateUrl(String path, {Map<String, String>? queryParameters}) {
    try {
      final uri = Uri(
        path: path,
        queryParameters: queryParameters,
      );
      html.window.history.pushState(null, '', uri.toString());
    } catch (e) {
      debugPrint('Error updating URL: $e');
    }
  }

  static void replaceUrl(String path, {Map<String, String>? queryParameters}) {
    try {
      final uri = Uri(
        path: path,
        queryParameters: queryParameters,
      );
      html.window.history.replaceState(null, '', uri.toString());
    } catch (e) {
      debugPrint('Error replacing URL: $e');
    }
  }

  /// Генерирует QR код URL для станции
  static String generateStationUrl(String stationId, {String? baseUrl}) {
    final base = baseUrl ?? html.window.location.origin;
    final uri = Uri.parse(base).replace(
      queryParameters: {'stationId': stationId},
    );
    return uri.toString();
  }

  /// Проверяет, является ли текущий URL QR кодом станции
  static bool isStationQrCode() {
    return getStationIdFromUrl() != null;
  }

  /// Получает текущий путь без query параметров
  static String getCurrentPath() {
    try {
      final uri = Uri.parse(html.window.location.href);
      return uri.path;
    } catch (e) {
      debugPrint('Error getting current path: $e');
      return '/';
    }
  }
}
