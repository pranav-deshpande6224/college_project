import 'package:college_project/Authentication/IOS_Files/handlers/auth_handler.dart';
import 'package:college_project/Authentication/Providers/error.dart';
import 'package:college_project/Authentication/Providers/spinner.dart';
import 'package:college_project/constants/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgetPassword extends ConsumerStatefulWidget {
  const ForgetPassword({super.key});

  @override
  ConsumerState<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends ConsumerState<ForgetPassword> {
  final _emailController = TextEditingController();
  final emailPattern = r'^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$';
  late AuthHandler handler;
  void _submitPressed() async {
    if (_emailController.text.trim().isEmpty) {
      ref
          .read(emailErrorProvider.notifier)
          .updateError('Please enter your Email Address');
    } else if (!RegExp(emailPattern).hasMatch(_emailController.text)) {
      ref
          .read(emailErrorProvider.notifier)
          .updateError('Please enter valid Email Address');
    } else {
      ref.read(emailErrorProvider.notifier).updateError('');
    }
    final emailError = ref.read(emailErrorProvider);
    if (emailError.isEmpty) {
      ref.read(submitSpinner.notifier).isLoading();
      await handler.forgetPassword(_emailController.text.trim(), context, ref);
    }
  }

  @override
  void initState() {
    handler = AuthHandler.authHandlerInstance;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Container(
        height: double.infinity,
        width: double.infinity,
        color: Constants.screenBgColor,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    ref.read(emailErrorProvider.notifier).updateError('');
                    Navigator.of(context).pop();
                  },
                  child: const CircleAvatar(
                    backgroundColor: Constants.white,
                    child: Icon(
                      CupertinoIcons.back,
                      size: 30,
                      color: CupertinoColors.activeBlue,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'Forget Password',
                  style: GoogleFonts.roboto(
                    fontSize: 25,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  height: 75,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Email',
                        style: GoogleFonts.lato(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Expanded(
                        child: CupertinoTextField(
                          prefix: const Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Icon(
                              CupertinoIcons.mail_solid,
                              color: CupertinoColors.black,
                            ),
                          ),
                          controller: _emailController,
                          cursorColor: CupertinoColors.black,
                          decoration: BoxDecoration(
                            color: CupertinoColors.white,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Consumer(
                  builder: (context, ref, child) {
                    final emailError = ref.watch(emailErrorProvider);
                    return emailError.isEmpty
                        ? const SizedBox(
                            height: 0,
                            width: 0,
                          )
                        : Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              emailError,
                              style: GoogleFonts.roboto(
                                color: CupertinoColors.systemRed,
                                fontSize: 16,
                              ),
                            ),
                          );
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                Consumer(
                  builder: (context, ref, child) {
                    final isloading = ref.watch(submitSpinner);
                    return SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: CupertinoButton(
                        color: CupertinoColors.activeBlue,
                        onPressed: () {
                          _submitPressed();
                        },
                        child: isloading
                            ? const CupertinoActivityIndicator(
                                color: CupertinoColors.white,
                              )
                            : Text(
                                'Submit',
                                style: GoogleFonts.roboto(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
