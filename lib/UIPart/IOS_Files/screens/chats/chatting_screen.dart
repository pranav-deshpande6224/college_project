import 'package:college_project/UIPart/IOS_Files/model/item.dart';
import 'package:college_project/UIPart/Providers/active_inactive_send.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class ChattingScreen extends ConsumerStatefulWidget {
  final Item item;
  const ChattingScreen({required this.item, super.key});

  @override
  ConsumerState<ChattingScreen> createState() => _ChattingScreenState();
}

class _ChattingScreenState extends ConsumerState<ChattingScreen> {
  final chatController = TextEditingController();
  final chatFocusNode = FocusNode();
  @override
  void dispose() {
    super.dispose();
    chatController.dispose();
    chatFocusNode.dispose();
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
                            if (value.isNotEmpty) {
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
                                    print(chatController.text);
                                    chatController.clear();
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
