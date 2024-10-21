class Contact {
  final String contactId;
  final String lastMessage;
  final String nameOfContact;
  final DateTime timeSent;

  Contact({
    required this.contactId,
    required this.lastMessage,
    required this.nameOfContact,
    required this.timeSent,
  });
  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      contactId: json['contactId'],
      lastMessage: json['lastMessage'],
      nameOfContact: json['nameOfContact'],
      timeSent: DateTime.parse(json['timeSent']),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'contactId': contactId,
      'lastMessage': lastMessage,
      'nameOfContact': nameOfContact,
      'timeSent': timeSent.toIso8601String(),
    };
  }
}
