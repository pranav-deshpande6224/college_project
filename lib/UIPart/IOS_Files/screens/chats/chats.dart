import 'package:college_project/Authentication/IOS_Files/handlers/auth_handler.dart';
import 'package:college_project/UIPart/IOS_Files/model/contact.dart';
import 'package:college_project/UIPart/IOS_Files/screens/chats/chatting_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class Chats extends StatefulWidget {
  const Chats({super.key});

  @override
  State<Chats> createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
  late AuthHandler handler;
  @override
  void initState() {
    handler = AuthHandler.authHandlerInstance;
    super.initState();
  }

  Stream<List<Contact>> getContacts() {
    return handler.fireStore
        .collection('users')
        .doc(handler.newUser.user!.uid)
        .collection('chats')
        .snapshots()
        .asyncMap((event) async {
      List<Contact> contacts = [];
      for (var doc in event.docs) {
        var chatContact = Contact.fromJson(doc.data());
        contacts.add(chatContact);
      }
      return contacts;
    });
  }

  String getTime(DateTime time) {
    final formattedTime = DateFormat('hh:mm a').format(time);
    return formattedTime;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Inbox',
          style: GoogleFonts.roboto(),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(left: 8, top: 8),
          child: StreamBuilder<List<Contact>>(
            stream: getContacts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CupertinoActivityIndicator(),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text('Something went wrong'),
                );
              }
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (ctx, index) {
                  final obj = snapshot.data![index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context, rootNavigator: true).push(
                        CupertinoPageRoute(
                          builder: (ctx) => ChattingScreen(
                            name: obj.nameOfContact,
                            documentReference: obj.reference,
                            recieverId: obj.contactId,   
                            senderId: handler.newUser.user!.uid,        
                          ),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        SizedBox(
                          height: 70,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 60,
                                width: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: CupertinoColors.black),
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
                                child: Container(
                                  decoration: BoxDecoration(
                                    border:
                                        Border(bottom: BorderSide(width: 0.5)),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              obj.nameOfContact,
                                              style: GoogleFonts.roboto(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(right: 8),
                                            child: Text(
                                              getTime(obj.timeSent),
                                              style: GoogleFonts.roboto(
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.done_all,
                                            color: CupertinoColors.systemGrey,
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Expanded(
                                            child: Text(
                                              obj.lastMessage,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        )
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
