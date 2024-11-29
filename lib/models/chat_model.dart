


class ChatModel {
  final String from;
  final String to;
  final String inputType;
  final String message;
  final String receiverName;
  final String senderName;
  final bool isDeleted;
  final int timestamp;

  ChatModel({
    required this.from,
    required this.to,
    required this.inputType,
    required this.message,
    required this.receiverName,
    required this.senderName,
    required this.isDeleted,
    required this.timestamp,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      from: json['from'] ?? '',
      to: json['to'] ?? '',
      inputType: json['inputType'] ?? '',
      message: json['message'] ?? '',
      receiverName: json['receiverName'] ?? '',
      senderName: json['senderName'] ?? '',
      isDeleted: json['isDeleted'] ?? false,
      timestamp: json['timestamp'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'from': from,
      'to': to,
      'inputType': inputType,
      'message': message,
      'receiverName': receiverName,
      'senderName': senderName,
      'isDeleted': isDeleted,
      'timestamp': timestamp,
    };
  }
}
