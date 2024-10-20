import 'package:college_project/Authentication/IOS_Files/Screens/auth/email_verification.dart';
import 'package:college_project/Authentication/IOS_Files/handlers/auth_handler.dart';
import 'package:college_project/Authentication/Providers/error.dart';
import 'package:college_project/Authentication/Providers/password_provider.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../../../../constants/constants.dart';

class SignUp extends ConsumerStatefulWidget {
  const SignUp({super.key});

  @override
  ConsumerState<SignUp> createState() => _SignUpState();
}

class _SignUpState extends ConsumerState<SignUp> {
  final _fnameController = TextEditingController();
  //final _lnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final emailPattern = r'^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$';
  final fnameFocusNode = FocusNode();
  //final lnameFocusNode = FocusNode();
  final emailFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();
  final confirmPasswordFocusNode = FocusNode();
  late AuthHandler handler;

  @override
  void initState() {
    handler = AuthHandler.authHandlerInstance;
    super.initState();
  }

  @override
  void dispose() {
    fnameFocusNode.dispose();
    //lnameFocusNode.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _fnameController.dispose();
    // _lnameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void signupPressed() async {
    late BuildContext signUpContext;
    if (_fnameController.text.trim().isEmpty) {
      ref
          .read(fnameErrorProvider.notifier)
          .updateError('Please enter your Name');
    } else if (_fnameController.text.trim().length < 3) {
      ref
          .read(fnameErrorProvider.notifier)
          .updateError('Name should be atleast 3 characters');
    } else {
      ref.read(fnameErrorProvider.notifier).updateError('');
    }
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
    if (_passwordController.text.trim().isEmpty) {
      ref
          .read(passwordErrorProvider.notifier)
          .updateError('Please enter your Password');
    } else {
      ref.read(passwordErrorProvider.notifier).updateError('');
    }
    if (_confirmPasswordController.text.trim().isEmpty) {
      ref
          .read(confirmPasswordErrorProvider.notifier)
          .updateError('Please enter your Confirm Password');
    } else if (_passwordController.text.trim() !=
        _confirmPasswordController.text.trim()) {
      ref
          .read(confirmPasswordErrorProvider.notifier)
          .updateError('Password does not match');
      return;
    } else {
      ref.read(confirmPasswordErrorProvider.notifier).updateError('');
    }
    final fnameError = ref.read(fnameErrorProvider);
    final emailError = ref.read(emailErrorProvider);
    final passwordError = ref.read(passwordErrorProvider);
    final confirmPasswordError = ref.read(confirmPasswordErrorProvider);
    if (fnameError.isEmpty &&
        emailError.isEmpty &&
        passwordError.isEmpty &&
        confirmPasswordError.isEmpty) {
      unfocusTextFields();
      final internetChecker = await InternetConnection().hasInternetAccess;
      if (internetChecker) {
        showCupertinoDialog(
            context: context,
            builder: (ctx) {
              signUpContext = ctx;
              handler.signUp(
                  _emailController.text.trim(),
                  _passwordController.text.trim(),
                  context,
                  signUpContext,
                  _fnameController.text.trim());
              return const Center(
                child: CupertinoActivityIndicator(
                  radius: 15,
                  
                ),
              );
            });
      } else {
        if (context.mounted) {
          showCupertinoDialog(
            context: context,
            builder: (ctx) {
              return CupertinoAlertDialog(
                title: Text(
                  'No Internet Connection',
                  style: GoogleFonts.roboto(),
                ),
                content: Text(
                  'Please check your internet connection and try again.',
                  style: GoogleFonts.roboto(),
                ),
                actions: [
                  CupertinoDialogAction(
                    child: Text(
                      'Okay',
                      style: GoogleFonts.roboto(),
                    ),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
      }
    }
  }

  void unfocusTextFields() {
    fnameFocusNode.unfocus();
    emailFocusNode.unfocus();
    passwordFocusNode.unfocus();
    confirmPasswordFocusNode.unfocus();
  }

  navigateToEmailVerification(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (ctx) => EmailVerification(
          email: _emailController.text,
        ),
      ),
    );
  }

  SizedBox getTextField(String textGiven, TextEditingController controller,
      IconData data, TextInputType type, FocusNode focusNode, String error) {
    return SizedBox(
      height: 75,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: textGiven,
              style: GoogleFonts.lato(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: error.isNotEmpty
                    ? CupertinoColors.systemRed
                    : CupertinoColors.black,
              ),
              children: [
                TextSpan(
                  text: '*',
                  style: GoogleFonts.roboto(
                    color: CupertinoColors.systemRed,
                  ),
                )
              ],
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Expanded(
            child: CupertinoTextField(
              focusNode: focusNode,
              keyboardType: type,
              prefix: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Icon(
                  data,
                  color: CupertinoColors.black,
                ),
              ),
              controller: controller,
              cursorColor: CupertinoColors.black,
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: error.isNotEmpty
                      ? CupertinoColors.systemRed
                      : CupertinoColors.systemGrey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Constants.screenBgColor,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 15, top: 15, right: 15),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      ref.read(emailErrorProvider.notifier).updateError('');
                      ref.read(passwordErrorProvider.notifier).updateError('');
                      ref
                          .read(confirmPasswordErrorProvider.notifier)
                          .updateError('');
                      ref.read(fnameErrorProvider.notifier).updateError('');

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
                    'Sign Up',
                    style: GoogleFonts.roboto(
                      fontSize: 25,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Consumer(
                    builder: (context, ref, child) {
                      final fnameError = ref.watch(fnameErrorProvider);
                      return getTextField(
                          'Name',
                          _fnameController,
                          CupertinoIcons.person_add_solid,
                          TextInputType.name,
                          fnameFocusNode,
                          fnameError);
                    },
                  ),
                  Consumer(
                    builder: (context, ref, child) {
                      final fnameError = ref.watch(fnameErrorProvider);
                      return fnameError.isEmpty
                          ? const SizedBox()
                          : Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(
                                fnameError,
                                style: GoogleFonts.roboto(
                                    color: CupertinoColors.systemRed,
                                    fontSize: 16),
                              ),
                            );
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Consumer(
                    builder: (context, ref, child) {
                      final emailError = ref.watch(emailErrorProvider);
                      return getTextField(
                          'Email',
                          _emailController,
                          CupertinoIcons.mail_solid,
                          TextInputType.emailAddress,
                          emailFocusNode,
                          emailError);
                    },
                  ),
                  Consumer(
                    builder: (context, ref, child) {
                      final emailError = ref.watch(emailErrorProvider);
                      return emailError.isEmpty
                          ? const SizedBox()
                          : Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(
                                emailError,
                                style: GoogleFonts.roboto(
                                    color: CupertinoColors.systemRed,
                                    fontSize: 16),
                              ),
                            );
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Consumer(
                    builder: (ctx, ref, child) {
                      final passError = ref.watch(passwordErrorProvider);
                      return SizedBox(
                        height: 75,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                text: 'Password',
                                style: GoogleFonts.lato(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: passError.isNotEmpty
                                      ? CupertinoColors.systemRed
                                      : CupertinoColors.black,
                                ),
                                children: [
                                  TextSpan(
                                    text: '*',
                                    style: GoogleFonts.roboto(
                                      color: CupertinoColors.systemRed,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Consumer(
                              builder: (context, ref, child) {
                                final showPassword =
                                    ref.watch(signupPasswordProviderNotifier);
                                return Expanded(
                                  child: CupertinoTextField(
                                    focusNode: passwordFocusNode,
                                    keyboardType: TextInputType.none,
                                    prefix: const Padding(
                                      padding: EdgeInsets.only(left: 10),
                                      child: Icon(
                                        CupertinoIcons.lock_fill,
                                        color: CupertinoColors.black,
                                      ),
                                    ),
                                    obscureText: !showPassword,
                                    suffix: CupertinoButton(
                                      padding: EdgeInsets.zero,
                                      onPressed: () {
                                        ref
                                            .read(signupPasswordProviderNotifier
                                                .notifier)
                                            .togglePassword();
                                      },
                                      child: Icon(
                                        showPassword
                                            ? CupertinoIcons.eye_fill
                                            : CupertinoIcons.eye_slash_fill,
                                        color: CupertinoColors.black,
                                      ),
                                    ),
                                    controller: _passwordController,
                                    cursorColor: CupertinoColors.black,
                                    decoration: BoxDecoration(
                                      color: CupertinoColors.white,
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                        color: passError.isNotEmpty
                                            ? CupertinoColors.systemRed
                                            : CupertinoColors.systemGrey,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  Consumer(
                    builder: (context, ref, child) {
                      final passwordError = ref.watch(passwordErrorProvider);
                      return passwordError.isEmpty
                          ? const SizedBox()
                          : Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(
                                passwordError,
                                style: GoogleFonts.roboto(
                                    color: CupertinoColors.systemRed,
                                    fontSize: 16),
                              ),
                            );
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Consumer(
                    builder: (context, ref, child) {
                      final cpError = ref.watch(confirmPasswordErrorProvider);
                      return SizedBox(
                        height: 75,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                text: 'Confirm Password',
                                style: GoogleFonts.lato(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: cpError.isNotEmpty
                                      ? CupertinoColors.systemRed
                                      : CupertinoColors.black,
                                ),
                                children: [
                                  TextSpan(
                                    text: '*',
                                    style: GoogleFonts.roboto(
                                      color: CupertinoColors.systemRed,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Consumer(
                              builder: (context, ref, child) {
                                final showConfirmPassword = ref.watch(
                                    signupConfirmPasswordProviderNotifier);
                                return Expanded(
                                  child: CupertinoTextField(
                                    focusNode: confirmPasswordFocusNode,
                                    keyboardType: TextInputType.none,
                                    prefix: const Padding(
                                      padding: EdgeInsets.only(left: 10),
                                      child: Icon(
                                        CupertinoIcons.lock_fill,
                                        color: CupertinoColors.black,
                                      ),
                                    ),
                                    obscureText: !showConfirmPassword,
                                    suffix: CupertinoButton(
                                      padding: EdgeInsets.zero,
                                      onPressed: () {
                                        ref
                                            .read(
                                                signupConfirmPasswordProviderNotifier
                                                    .notifier)
                                            .togglePassword();
                                      },
                                      child: Icon(
                                        showConfirmPassword
                                            ? CupertinoIcons.eye_fill
                                            : CupertinoIcons.eye_slash_fill,
                                        color: CupertinoColors.black,
                                      ),
                                    ),
                                    controller: _confirmPasswordController,
                                    padding:
                                        const EdgeInsets.only(top: 0, left: 10),
                                    cursorColor: CupertinoColors.black,
                                    decoration: BoxDecoration(
                                      color: CupertinoColors.white,
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                        color: cpError.isNotEmpty
                                            ? CupertinoColors.systemRed
                                            : CupertinoColors.systemGrey,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  Consumer(
                    builder: (context, ref, child) {
                      final confirmPasswordError =
                          ref.watch(confirmPasswordErrorProvider);
                      return confirmPasswordError.isEmpty
                          ? const SizedBox()
                          : Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(
                                confirmPasswordError,
                                style: GoogleFonts.roboto(
                                    color: CupertinoColors.systemRed,
                                    fontSize: 16),
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
                      padding: EdgeInsets.zero,
                      child: Text(
                        'Sign Up',
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onPressed: () {
                        signupPressed();
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
