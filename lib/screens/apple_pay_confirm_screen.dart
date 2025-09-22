import 'package:flutter/material.dart';

class ApplePayConfirmScreen extends StatelessWidget {
  final String amount;
  final String cardName;
  final String maskedCard;
  final String account;
  final VoidCallback onConfirm; // действие при подтверждении (двойной тап)

  const ApplePayConfirmScreen({
    Key? key,
    required this.amount,
    required this.cardName,
    required this.maskedCard,
    required this.account,
    required this.onConfirm,
  }) : super(key: key);

  /// Вызывать так:
  /// ApplePayConfirmScreen.show(context, amount: "\$4.99", ...)
  static Future<void> show(BuildContext context,
      {required String amount,
        required String cardName,
        required String maskedCard,
        required String account,
        required VoidCallback onConfirm}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ApplePayConfirmScreen(
        amount: amount,
        cardName: cardName,
        maskedCard: maskedCard,
        account: account,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.65;
    return GestureDetector(
      onTap: () => Navigator.of(context).maybePop(),
      child: Container(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: () {}, // не закрывать при тапе на контент
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: height,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Хэндл сверху
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Заголовок Apple Pay
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        '',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Pay',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Карточка выбора карты
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      children: [
                        // Картинка карты (заглушка)
                        Container(
                          width: 48,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.purple[200],
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(cardName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                            Text(maskedCard, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 32),

                  // Сумма
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Pay Recharge', style: TextStyle(fontSize: 16)),
                        Text(amount, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Кнопка подтверждения (двойное нажатие)
                  GestureDetector(
                    onDoubleTap: () {
                      Navigator.of(context).pop();
                      onConfirm();
                    },
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF007AFF),
                      ),
                      child: const Icon(Icons.arrow_forward, color: Colors.white, size: 48),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Confirm with Side Button',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
