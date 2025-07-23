class PaymentCard {
  final String id;
  final String cardHolderName;
  final String cardNumber;
  final String expiryMonth;
  final String expiryYear;
  final String cvv;
  final String cardType;
  final bool isDefault;

  PaymentCard({
    required this.id,
    required this.cardHolderName,
    required this.cardNumber,
    required this.expiryMonth,
    required this.expiryYear,
    required this.cvv,
    required this.cardType,
    this.isDefault = false,
  });

  factory PaymentCard.fromFirestore(Map<String, dynamic> data) {
    return PaymentCard(
      id: data['id'] ?? '',
      cardHolderName: data['cardHolderName'] ?? '',
      cardNumber: data['cardNumber'] ?? '',
      expiryMonth: data['expiryMonth'] ?? '',
      expiryYear: data['expiryYear'] ?? '',
      cvv: data['cvv'] ?? '',
      cardType: data['cardType'] ?? '',
      isDefault: data['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'cardHolderName': cardHolderName,
      'cardNumber': cardNumber,
      'expiryMonth': expiryMonth,
      'expiryYear': expiryYear,
      'cvv': cvv,
      'cardType': cardType,
      'isDefault': isDefault,
    };
  }

  String get maskedCardNumber {
    if (cardNumber.length >= 4) {
      return '**** **** **** ${cardNumber.substring(cardNumber.length - 4)}';
    }
    return cardNumber;
  }

  String get formattedExpiry {
    return '$expiryMonth/$expiryYear';
  }
}
