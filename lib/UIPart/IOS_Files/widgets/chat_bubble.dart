import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final DateTime date;
  final bool isSender;
  final bool isRead;
  const ChatBubble(
      {required this.message,
      required this.date,
      required this.isSender,
      required this.isRead,
      super.key});

  @override
  Widget build(BuildContext context) {
    final formattedTime = DateFormat('hh:mm a').format(date);
    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: isSender
                ? CupertinoColors.activeBlue
                : CupertinoColors.systemGrey5,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
              bottomLeft: isSender ? Radius.circular(12) : Radius.circular(0),
              bottomRight: isSender ? Radius.circular(0) : Radius.circular(12),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Message Text
              Text(
                message,
                style: TextStyle(
                  fontSize: 16,
                  color:
                      isSender ? CupertinoColors.white : CupertinoColors.black,
                ),
              ),
              const SizedBox(height: 5),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formattedTime,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSender
                          ? CupertinoColors.white.withOpacity(0.7)
                          : CupertinoColors.black.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(width: 5),
                  if (isSender) // Show double tick only for sender
                    Icon(Icons.done_all, // Double tick icon
                        size: 16,
                        color: isRead
                            ? CupertinoColors.activeGreen // Read (white)
                            : CupertinoColors.white
                        // Delivered (grey)
                        ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
