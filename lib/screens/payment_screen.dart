import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/payment_provider.dart';
import '../services/deep_link_handler.dart';
import '../widgets/app_button.dart';
import '../widgets/error_view.dart';
import '../widgets/loader.dart';
import 'success_screen.dart';

class PaymentScreen extends StatefulWidget {
  final String? stationId;
  
  const PaymentScreen({Key? key, this.stationId}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  static const double _price = 4.99;
  static const double _oldPrice = 9.99;
  static const String _testStationId = 'RECH082203000350';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePayment();
    });
  }

  Future<void> _initializePayment() async {
    final provider = Provider.of<PaymentProvider>(context, listen: false);
    await provider.initialize();
    
    // Получаем stationId из параметров виджета или из URL
    final stationId = widget.stationId ?? 
                     DeepLinkHandler.getStationIdFromUrl() ?? 
                     _testStationId;
    
    await provider.loadStationInfo(stationId);
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _processApplePayPayment() async {
    final provider = Provider.of<PaymentProvider>(context, listen: false);
    final stationId = widget.stationId ?? _testStationId;
    
    await provider.processApplePayPayment(
      stationId: stationId,
      amount: _price,
    );
    
    if (provider.lastPaymentResult?.success == true) {
      if (mounted) {
        SuccessScreen.show(
          context,
          stationId: stationId,
          powerBankId: provider.lastPaymentResult?.powerBankId,
        );
      }
    } else if (provider.error != null) {
      _showError(provider.error!);
    }
  }

  Future<void> _processCardPayment() async {
    final provider = Provider.of<PaymentProvider>(context, listen: false);
    final stationId = widget.stationId ?? _testStationId;
    
    await provider.processCardPayment(
      stationId: stationId,
      amount: _price,
    );
    
    if (provider.lastPaymentResult?.success == true) {
      if (mounted) {
        SuccessScreen.show(
          context,
          stationId: stationId,
          powerBankId: provider.lastPaymentResult?.powerBankId,
        );
      }
    } else if (provider.error != null) {
      _showError(provider.error!);
    }
  }

  Widget _buildPriceSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Monthly Subscription',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${_price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '\$${_oldPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'First month only',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplePayButton(PaymentProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: AppButton(
        text: 'Apple Pay',
        onPressed: provider.isApplePayAvailable && !provider.isLoading
            ? _processApplePayPayment
            : null,
        isLoading: provider.isLoading,
        backgroundColor: Colors.black,
        height: 52,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildCardPaymentButton(PaymentProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
        onTap: provider.isLoading ? null : _processCardPayment,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.credit_card_outlined,
                size: 24,
                color: Colors.black87,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Debit or credit card',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStationInfo(PaymentProvider provider) {
    if (provider.stationInfo == null) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.location_on,
            color: Colors.blue,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Station: ${provider.stationInfo!.stationId}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (provider.stationInfo!.stationName != null)
                  Text(
                    provider.stationInfo!.stationName!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportLink() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: GestureDetector(
        onTap: () {
          // Открыть поддержку
          // В реальном приложении здесь будет ссылка на поддержку
        },
        child: const Text(
          'Nothing happened? Contact support',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
            decoration: TextDecoration.underline,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Power Bank Rental',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<PaymentProvider>(
        builder: (context, provider, child) {
          if (provider.error != null && !provider.isLoading) {
            return ErrorView(
              message: provider.error!,
              onRetry: () {
                provider.clearError();
                _initializePayment();
              },
            );
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildPriceSection(),
                      const SizedBox(height: 20),
                      _buildStationInfo(provider),
                      const SizedBox(height: 30),
                      _buildApplePayButton(provider),
                      const SizedBox(height: 16),
                      _buildCardPaymentButton(provider),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              if (provider.isLoading)
                Container(
                  padding: const EdgeInsets.all(20),
                  child: const Loader(message: 'Processing payment...'),
                ),
              _buildSupportLink(),
            ],
          );
        },
      ),
    );
  }
}