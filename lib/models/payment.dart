class PaymentRequest {
  final String paymentToken;
  final String thePlanId;
  final bool disableWelcomeDiscount;
  final int welcomeDiscount;

  PaymentRequest({
    required this.paymentToken,
    this.thePlanId = 'tss2',
    this.disableWelcomeDiscount = false,
    this.welcomeDiscount = 10,
  });

  Map<String, dynamic> toJson() {
    return {
      'paymentToken': paymentToken,
      'thePlanId': thePlanId,
    };
  }
}

class PaymentResponse {
  final bool success;
  final String? message;
  final String? transactionId;

  PaymentResponse({
    required this.success,
    this.message,
    this.transactionId,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse(
      success: json['success'] ?? false,
      message: json['message'],
      transactionId: json['transactionId'],
    );
  }
}

class BraintreeClientToken {
  final String token;

  BraintreeClientToken({required this.token});

  factory BraintreeClientToken.fromJson(Map<String, dynamic> json) {
    return BraintreeClientToken(
      token: json['clientToken'] ?? '',
    );
  }
}

class AppleAccountRequest {
  final String? deviceId;
  final String? pushToken;

  AppleAccountRequest({this.deviceId, this.pushToken});

  Map<String, dynamic> toJson() {
    return {
      if (deviceId != null) 'deviceId': deviceId,
      if (pushToken != null) 'pushToken': pushToken,
    };
  }
}

class AppleAccountResponse {
  final String accountId;
  final String? message;

  AppleAccountResponse({required this.accountId, this.message});

  factory AppleAccountResponse.fromJson(Map<String, dynamic> json) {
    return AppleAccountResponse(
      accountId: json['accountId'] ?? '',
      message: json['message'],
    );
  }
}

class PowerBankRentalRequest {
  final String stationId;
  final String paymentToken;

  PowerBankRentalRequest({
    required this.stationId,
    required this.paymentToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'stationId': stationId,
      'paymentToken': paymentToken,
    };
  }
}

class PowerBankRentalResponse {
  final bool success;
  final String? message;
  final String? powerBankId;

  PowerBankRentalResponse({
    required this.success,
    this.message,
    this.powerBankId,
  });

  factory PowerBankRentalResponse.fromJson(Map<String, dynamic> json) {
    return PowerBankRentalResponse(
      success: json['success'] ?? false,
      message: json['message'],
      powerBankId: json['powerBankId'],
    );
  }
}
