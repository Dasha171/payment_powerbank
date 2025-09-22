import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SuccessScreen extends StatelessWidget {
  final String stationId;
  final String? powerBankId;
  
  const SuccessScreen({
    Key? key,
    required this.stationId,
    this.powerBankId,
  }) : super(key: key);

  /// Показать модальное окно успеха
  static Future<void> show(
    BuildContext context, {
    required String stationId,
    String? powerBankId,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => SuccessScreen(
        stationId: stationId,
        powerBankId: powerBankId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final modalHeight = screenHeight * 0.45;
    
    return GestureDetector(
      onTap: () {}, // Предотвращаем закрытие при тапе вне модала
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: GestureDetector(
          onTap: () {}, // Предотвращаем закрытие при тапе на контент
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: modalHeight,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // Индикатор перетаскивания
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Иконка успеха
                          Container(
                            width: 80,
                            height: 80,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Заголовок
                          const Text(
                            'Power Bank Issued!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Информация о станции
                          Text(
                            'Station: $stationId',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          if (powerBankId != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Power Bank ID: $powerBankId',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                          
                          const SizedBox(height: 32),
                          
                          // Инструкция
                          const Text(
                            'Double tap to confirm',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Кнопка подтверждения
                          GestureDetector(
                            onDoubleTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              width: double.infinity,
                              height: 52,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: Text(
                                  'Done',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Ссылка на приложение
                          TextButton(
                            onPressed: () async {
                              // В реальном приложении здесь будет ссылка на мобильное приложение
                              const url = 'https://apps.apple.com/app/powerbank';
                              final uri = Uri.parse(url);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                              }
                            },
                            child: const Text(
                              'Open App',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}