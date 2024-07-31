import 'package:cloud_firestore/cloud_firestore.dart';

class Payment {
  final String paymentId;
  final String messageId;
  final String userSenderId;
  final String userReceiverId;
  final int amount;
  final String transactionId;
  final String paymentMethod;
  final String receiverPhoneNumber;
  final DateTime createdAt;
  // Constructor
  Payment({
    required this.paymentId,
    required this.messageId,
    required this.userSenderId,
    required this.userReceiverId,
    required this.amount,
    required this.transactionId,
    required this.paymentMethod,
    required this.receiverPhoneNumber,
    required this.createdAt,
  });

  // ToJson

  Map<String, dynamic> toJson() => {
        'paymentId': paymentId,
        'messageId': messageId,
        'userSenderId': userSenderId,
        'userReceiverId': userReceiverId,
        'amount': amount,
        'transactionId': transactionId,
        'paymentMethod': paymentMethod,
        'receiverPhoneNumber': receiverPhoneNumber,
        'createdAt': createdAt,
      };

  // From Json
  static Payment fromJson(Map<String, dynamic> json) => Payment(
        paymentId: json['paymentId'] ?? '',
        messageId: json['messageId'] ?? '',
        userSenderId: json['userSenderId'] ?? '',
        userReceiverId: json['userReceiverId'] ?? '',
        amount: json['amount'] ?? 0,
        receiverPhoneNumber: json['receiverPhoneNumber'] ?? '',
        transactionId: json['transactionId'] ?? '',
        paymentMethod: json['paymentMethod'] ?? '',
        //
        createdAt: json['createdAt'] != null && json['createdAt'] != ''
            ? (json['createdAt'] as Timestamp).toDate().toLocal()
            : DateTime.now(),
        //
      );
}
