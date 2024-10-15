import 'package:college_project/Authentication/IOS_Files/handlers/auth_handler.dart';
import 'package:college_project/Authentication/Providers/error.dart';
import 'package:college_project/constants/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

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
      final internetChecker = await InternetConnection().hasInternetAccess;
      if (internetChecker) {
        late BuildContext forgetPasswordContext;
        showCupertinoDialog(
          context: context,
          builder: (ctx) {
            forgetPasswordContext = ctx;
            handler.forgetPassword(
                _emailController.text.trim(), context, forgetPasswordContext);
            return const Center(
              child: CupertinoActivityIndicator(
                radius: 15,
              ),
            );
          },
        );
      } else {
        if (context.mounted) {
          showCupertinoDialog(
            context: context,
            builder: (ctx) {
              return CupertinoAlertDialog(
                title: Text(
                  'No Internet',
                  style: GoogleFonts.roboto(),
                ),
                content: Text(
                  'Please check your internet connection',
                  style: GoogleFonts.roboto(),
                ),
                actions: [
                  CupertinoDialogAction(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    child: Text(
                      'Okay',
                      style: GoogleFonts.roboto(),
                    ),
                  )
                ],
              );
            },
          );
        }
      }
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
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                        color: Constants.white, shape: BoxShape.circle),
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
                Consumer(
                  builder: (context, ref, child) {
                    final emailError = ref.watch(emailErrorProvider);
                    return SizedBox(
                      height: 75,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              text: 'Email',
                              style: GoogleFonts.lato(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: emailError.isNotEmpty
                                    ? CupertinoColors.systemRed
                                    : CupertinoColors.black,
                              ),
                              children: [
                                TextSpan(
                                  text: '*',
                                  style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.bold,
                                    color: CupertinoColors.systemRed,
                                  ),
                                ),
                              ],
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
                                  color: emailError.isNotEmpty
                                      ? CupertinoColors.systemRed
                                      : CupertinoColors.systemGrey,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
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
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: CupertinoButton(
                    color: CupertinoColors.activeBlue,
                    onPressed: () {
                      _submitPressed();
                    },
                    child: Text(
                      'Submit',
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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
