import 'package:college_project/Authentication/IOS_Files/handlers/auth_handler.dart';
import 'package:college_project/UIPart/IOS_Files/model/contact.dart';
import 'package:college_project/UIPart/IOS_Files/model/item.dart';
import 'package:college_project/UIPart/IOS_Files/model/message.dart';
import 'package:college_project/UIPart/Providers/active_inactive_send.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

class ChattingScreen extends ConsumerStatefulWidget {
  final Item item;
  const ChattingScreen({required this.item, super.key});

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

  @override
  void dispose() {
    super.dispose();
    chatController.dispose();
    chatFocusNode.dispose();
  }

  sendMessageToDb(String message) async {
    if (handler.newUser.user != null) {
      try {
        final firestore = handler.fireStore;
        var timeSent = DateTime.now();
        final messageId = const Uuid().v1();
        final senderContact = Contact(
            contactId: widget.item.userid,
            lastMessage: message,
            nameOfContact: widget.item.postedBy,
            timeSent: timeSent);
        final recieverContact = Contact(
          contactId: handler.newUser.user!.uid,
          lastMessage: message,
          nameOfContact: handler.newUser.user!.displayName!,
          timeSent: timeSent,
        );
        await firestore.runTransaction((transaction) async {
          await firestore
              .collection('users')
              .doc(handler.newUser.user!.uid)
              .collection('chats')
              .doc(widget.item.userid)
              .set(senderContact.toJson());
          await firestore
              .collection('users')
              .doc(widget.item.userid)
              .collection('chats')
              .doc(handler.newUser.user!.uid)
              .set(
                recieverContact.toJson(),
              );
          await firestore
              .collection('users')
              .doc(handler.newUser.user!.uid)
              .collection('chats')
              .doc(widget.item.userid)
              .collection('messages')
              .doc(messageId)
              .set(
                Message(
                  messageId: messageId,
                  senderId: handler.newUser.user!.uid,
                  receiverId: widget.item.userid,
                  text: message,
                  timeSent: timeSent,
                  isSeen: false,
                ).toJson(),
              );
          await firestore
              .collection('users')
              .doc(widget.item.userid)
              .collection('chats')
              .doc(handler.newUser.user!.uid)
              .collection('messages')
              .doc(messageId)
              .set(
                Message(
                  messageId: messageId,
                  senderId: handler.newUser.user!.uid,
                  receiverId: widget.item.userid,
                  text: message,
                  timeSent: timeSent,
                  isSeen: false,
                ).toJson(),
              );
        }).then((_) {
          chatController.clear();
        });
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
                widget.item.postedBy,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.roboto(),
              ),
            ),
          ],
        ),
      ),
      child: PopScope(
        onPopInvokedWithResult: (didPop, result) {
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Column(
              children: [
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(width: 0.2))),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            widget.item.adTitle,
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
                          '₹ ${widget.item.price.toInt()}',
                          style: GoogleFonts.roboto(
                            fontWeight: FontWeight.bold,
                          ),
                        ))
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: 10,
                    itemBuilder: (ctx, index) {
                      return CupertinoListTile(title: Text('Hi '));
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
                                  .read(activeInactiveSendProvider.notifier)
                                  .setActiveInactive(true);
                            } else {
                              ref
                                  .read(activeInactiveSendProvider.notifier)
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
                                    sendMessageToDb(chatController.text);
                                    // print(chatController.text);
                                    // chatController.clear();
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
        ),
      ),
    );
  }
}
