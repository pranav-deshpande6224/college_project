import 'package:cloud_firestore/cloud_firestore.dart';

class Contact {
  final String contactId;
  final String lastMessage;
  final String nameOfContact;
  final DateTime timeSent;
  final DocumentReference<Map<String,dynamic>> reference;

  Contact({
    required this.contactId,
    required this.lastMessage,
    required this.nameOfContact,
    required this.timeSent,
    required this.reference
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      contactId: json['contactId'],
      lastMessage: json['lastMessage'],
      nameOfContact: json['nameOfContact'],
      timeSent: DateTime.parse(json['timeSent']),
      reference: json['reference']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contactId': contactId,
      'lastMessage': lastMessage,
      'nameOfContact': nameOfContact,
      'timeSent': timeSent.toIso8601String(),
      'reference': reference
    };
  }

}
