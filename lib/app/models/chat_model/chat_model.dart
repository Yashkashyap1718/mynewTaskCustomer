
class ChatModel {
  final String from;
  final String to;
  final String inputType;
  final String message;
  final String receiverName;
  final String senderName;
  final bool isDeleted;
  final int timestamp;

  const ChatModel({
    required this.from,
    required this.to,
    required this.inputType,
    required this.message,
    required this.receiverName,
    required this.senderName,
    required this.isDeleted,
    required this.timestamp,
  });

  // Factory constructor for creating a ChatModel from JSON
  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      from: json['from'] as String? ?? '',
      to: json['to'] as String? ?? '',
      inputType: json['inputType'] as String? ?? 'text',
      message: json['message'] as String? ?? '',
      receiverName: json['receiverName'] as String? ?? '',
      senderName: json['senderName'] as String? ?? '',
      isDeleted: json['isDeleted'] as bool? ?? false,
      timestamp: json['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  // Convert ChatModel to JSON
  Map<String, dynamic> toJson() => {
    'from': from,
    'to': to,
    'inputType': inputType,
    'message': message,
    'receiverName': receiverName,
    'senderName': senderName,
    'isDeleted': isDeleted,
    'timestamp': timestamp,
  };

  // Create a copy of ChatModel with some fields updated
  ChatModel copyWith({
    String? from,
    String? to,
    String? inputType,
    String? message,
    String? receiverName,
    String? senderName,
    bool? isDeleted,
    int? timestamp,
  }) {
    return ChatModel(
      from: from ?? this.from,
      to: to ?? this.to,
      inputType: inputType ?? this.inputType,
      message: message ?? this.message,
      receiverName: receiverName ?? this.receiverName,
      senderName: senderName ?? this.senderName,
      isDeleted: isDeleted ?? this.isDeleted,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  // Override equality operator
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatModel &&
          runtimeType == other.runtimeType &&
          from == other.from &&
          to == other.to &&
          inputType == other.inputType &&
          message == other.message &&
          receiverName == other.receiverName &&
          senderName == other.senderName &&
          isDeleted == other.isDeleted &&
          timestamp == other.timestamp;

  // Override hashCode
  @override
  int get hashCode =>
      from.hashCode ^
      to.hashCode ^
      inputType.hashCode ^
      message.hashCode ^
      receiverName.hashCode ^
      senderName.hashCode ^
      isDeleted.hashCode ^
      timestamp.hashCode;

  // Override toString for better debugging
  @override
  String toString() {
    return 'ChatModel{'
        'from: $from, '
        'to: $to, '
        'inputType: $inputType, '
        'message: $message, '
        'receiverName: $receiverName, '
        'senderName: $senderName, '
        'isDeleted: $isDeleted, '
        'timestamp: $timestamp'
        '}';
  }

  // Helper method to format timestamp
  String get formattedTime {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  // Helper method to check if message is from today
  bool get isFromToday {
    final now = DateTime.now();
    final messageDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return now.year == messageDate.year &&
        now.month == messageDate.month &&
        now.day == messageDate.day;
  }

  // Helper method to get relative time (e.g., "2 hours ago")
  String get relativeTime {
    final now = DateTime.now();
    final messageTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final difference = now.difference(messageTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} years ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}
