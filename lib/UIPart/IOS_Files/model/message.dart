class Message {
  final String messageId;
  final String senderId;
  final String receiverId;
  final String text;
  final DateTime timeSent;
  final bool isSeen;

  Message({
    required this.messageId,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.timeSent,
    required this.isSeen,
  });
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      messageId: json['messageId'],
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      text: json['text'],
      timeSent: DateTime.parse(json['timeSent']),
      isSeen: json['isSeen'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'timeSent': timeSent.toIso8601String(),
      'isSeen': isSeen,
    };
  }
}
