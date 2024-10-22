import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:college_project/Authentication/IOS_Files/handlers/auth_handler.dart';
import 'package:college_project/UIPart/IOS_Files/model/contact.dart';
import 'package:college_project/UIPart/IOS_Files/model/item.dart';
import 'package:college_project/UIPart/IOS_Files/model/message.dart';
import 'package:college_project/UIPart/IOS_Files/widgets/chat_bubble.dart';
import 'package:college_project/UIPart/Providers/active_inactive_send.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

class ChattingScreen extends ConsumerStatefulWidget {
  final String name;
  final String recieverId;
  final String senderId;
  final DocumentReference<Map<String, dynamic>> documentReference;
  const ChattingScreen({
    required this.name,
    required this.recieverId,
    required this.senderId,
    required this.documentReference,
    super.key,
  });

  @override
  ConsumerState<ChattingScreen> createState() => _ChattingScreenState();
}

class _ChattingScreenState extends ConsumerState<ChattingScreen> {
  final chatController = TextEditingController();
  final chatFocusNode = FocusNode();
  late AuthHandler handler;
  @override
  void initState() {
    handler = AuthHandler.authHandlerInstance;
    super.initState();
  }

  Stream<List<Message>> getMessages(String receiverId, String itemid) {
    return handler.fireStore
        .collection('users')
        .doc(handler.newUser.user!.uid)
        .collection('chats')
        .doc("${receiverId}_$itemid")
        .collection('messages')
        .orderBy('timeSent', descending: false)
        .snapshots()
        .asyncMap((event) async {
      List<Message> messages = [];
      for (var doc in event.docs) {
        var message = Message.fromJson(doc.data());
        messages.add(message);
      }

      return messages;
    });
  }

  @override
  void dispose() {
    super.dispose();
    chatController.dispose();
    chatFocusNode.dispose();
  }

  sendMessageToDb(String message, Item item) async {
    chatController.clear();
    ref.read(activeInactiveSendProvider.notifier).reset();
    if (handler.newUser.user != null) {
      try {
        await handler.fireStore.runTransaction(
          (transaction) async {
            final firestore = handler.fireStore;
            DocumentSnapshot<Map<String, dynamic>> somedoc = await firestore
                .collection('users')
                .doc(widget.recieverId)
                .get();
            final name = somedoc.data()!['firstName'];
            var timeSent = DateTime.now();
            final messageId = const Uuid().v1();
            final postedAdContact = Contact(
              contactId: widget.recieverId,
              lastMessage: message,
              nameOfContact: name,
              timeSent: timeSent,
              reference: widget.documentReference,
            );
            final replyingToAdContact = Contact(
              contactId: handler.newUser.user!.uid,
              lastMessage: message,
              nameOfContact: handler.newUser.user!.displayName!,
              timeSent: timeSent,
              reference: widget.documentReference,
            );

            await firestore
                .collection('users')
                .doc(widget.senderId)
                .collection('chats')
                .doc("${widget.recieverId}_${item.id}")
                .set(postedAdContact.toJson());
            await firestore
                .collection('users')
                .doc(widget.recieverId)
                .collection('chats')
                .doc("${widget.senderId}_${item.id}")
                .set(
                  replyingToAdContact.toJson(),
                );
            await firestore
                .collection('users')
                .doc(widget.senderId)
                .collection('chats')
                .doc("${widget.recieverId}_${item.id}")
                .collection('messages')
                .doc(messageId)
                .set(
                  Message(
                    messageId: messageId,
                    senderId: widget.senderId,
                    receiverId: widget.recieverId,
                    text: message,
                    timeSent: timeSent,
                    isSeen: false,
                  ).toJson(),
                );
            await firestore
                .collection('users')
                .doc(widget.recieverId)
                .collection('chats')
                .doc("${widget.senderId}_${item.id}")
                .collection('messages')
                .doc(messageId)
                .set(
                  Message(
                    messageId: messageId,
                    senderId: widget.senderId,
                    receiverId: widget.recieverId,
                    text: message,
                    timeSent: timeSent,
                    isSeen: false,
                  ).toJson(),
                );
          },
        );
      } catch (e) {
        print(e.toString());
      }
    } else {
      // Navigate to Login Page
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Row(
          children: [
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: CupertinoColors.black),
              ),
              child: Center(
                child: Icon(
                  CupertinoIcons.person,
                  color: CupertinoColors.black,
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Text(
                widget.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.roboto(),
              ),
            ),
          ],
        ),
      ),
      child: StreamBuilder(
        stream: widget.documentReference.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CupertinoActivityIndicator(),
            );
          }
          if (snapshot.hasError) {
            // this is the error page lets see how to handle it
            return const Center(
              child: Text('Something went wrong'),
            );
          }
          Timestamp? timeStamp = snapshot.data!.data()!['createdAt'];
          timeStamp ??= Timestamp.fromMicrosecondsSinceEpoch(
              DateTime.now().millisecondsSinceEpoch);
          final item = Item.fromJson(
            snapshot.data!.data()!,
            snapshot.data!,
            snapshot.data!.reference,
          );
          return StreamBuilder<List<Message>>(
            stream: getMessages(widget.recieverId, item.id),
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CupertinoActivityIndicator(),
                );
              }
              if (snapshot.hasError) {
                // this is the error page lets see how to handle it
                return const Center(
                  child: Text('Something went wrong'),
                );
              }
              return PopScope(
                onPopInvokedWithResult: (didPop, result) {
                  FocusScope.of(context).unfocus();
                },
                child: SafeArea(
                  child: Column(
                    children: [
                      Container(
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(width: 0.2),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  item.adTitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.roboto(),
                                ),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Expanded(
                                child: Text(
                                  '₹ ${item.price.toInt()}',
                                  style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (ctx, index) {
                            final message = snapshot.data![index];
                            if (message.senderId == handler.newUser.user!.uid) {
                              return ChatBubble(
                                message: message.text,
                                date: message.timeSent,
                                isSender: true,
                                isRead: message.isSeen,
                              );
                            }
                            return ChatBubble(
                              message: message.text,
                              date: message.timeSent,
                              isSender: false,
                              isRead: message.isSeen,
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 8, right: 2, bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: CupertinoTextField(
                                focusNode: chatFocusNode,
                                controller: chatController,
                                onSubmitted: (value) {
                                  if (value.isEmpty) {}
                                },
                                onChanged: (value) {
                                  if (value.trim().isNotEmpty) {
                                    ref
                                        .read(
                                            activeInactiveSendProvider.notifier)
                                        .setActiveInactive(true);
                                  } else {
                                    ref
                                        .read(
                                            activeInactiveSendProvider.notifier)
                                        .setActiveInactive(false);
                                  }
                                },
                                minLines: 1,
                                maxLines: 5,
                                decoration: BoxDecoration(
                                  border: Border.all(),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                placeholder: 'Type a message....',
                              ),
                            ),
                            Consumer(
                              builder: (context, ref, child) {
                                final activeInactiveSend =
                                    ref.watch(activeInactiveSendProvider);
                                return CupertinoButton(
                                  padding: EdgeInsetsDirectional.zero,
                                  onPressed: activeInactiveSend
                                      ? () {
                                          sendMessageToDb(
                                              chatController.text, item);
                                        }
                                      : null,
                                  child: Icon(CupertinoIcons.paperplane),
                                );
                              },
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
