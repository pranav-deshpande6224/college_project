import 'package:college_project/Authentication/IOS_Files/Screens/auth/email_verification.dart';
import 'package:college_project/Authentication/IOS_Files/handlers/auth_handler.dart';
import 'package:college_project/Authentication/Providers/error.dart';
import 'package:college_project/constants/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../Providers/password_provider.dart';
import 'forget_password.dart';
import 'sign_up.dart';

class LoginIos extends ConsumerStatefulWidget {
  const LoginIos({super.key});

  @override
  ConsumerState<LoginIos> createState() => _LoginIosState();
}

class _LoginIosState extends ConsumerState<LoginIos> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final emailPattern = r'^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$';
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  late AuthHandler handler;
  @override
  void initState() {
    handler = AuthHandler.authHandlerInstance;
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _loginPressed() async {
    late BuildContext loginContext;
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
      return;
    } else if (_passwordController.text.trim().length < 6) {
      ref
          .read(passwordErrorProvider.notifier)
          .updateError('Password should be atleast 6 characters');
      return;
    } else {
      ref.read(passwordErrorProvider.notifier).updateError('');
    }
    final emailError = ref.read(emailErrorProvider);
    final passwordError = ref.read(passwordErrorProvider);
    if (emailError.isEmpty && passwordError.isEmpty) {
      unFocusTextFields();
      showCupertinoDialog(
          context: context,
          builder: (ctx) {
            loginContext = ctx;
            handler.signIn(_emailController.text.trim(),
                _passwordController.text.trim(), context, loginContext);
            return const Center(
              child: CupertinoActivityIndicator(
                color: CupertinoColors.black,
                radius: 15,
              ),
            );
          });
    }
  }


  void unFocusTextFields() {
    _emailFocusNode.unfocus();
    _passwordFocusNode.unfocus();
  }

  void moveToEmailVerification() {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (ctx) => EmailVerification(
          email: _emailController.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Constants.screenBgColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Login',
                  style: GoogleFonts.roboto(
                    fontSize: 25,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'Welcome Back',
                  style: GoogleFonts.roboto(
                    fontSize: 20,
                    color: CupertinoColors.activeBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(
                  height: 30,
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
                          focusNode: _emailFocusNode,
                          keyboardType: TextInputType.emailAddress,
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
                        ? const SizedBox()
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
                  height: 75,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Password',
                        style: GoogleFonts.lato(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Expanded(
                        child: Consumer(
                          builder: (context, ref, child) {
                            final passwordProvider =
                                ref.watch(loginpasswordProviderNotifier);
                            return CupertinoTextField(
                              focusNode: _passwordFocusNode,
                              keyboardType: TextInputType.none,
                              prefix: const Padding(
                                padding: EdgeInsets.only(left: 10),
                                child: Icon(
                                  CupertinoIcons.padlock_solid,
                                  color: CupertinoColors.black,
                                ),
                              ),
                              controller: _passwordController,
                              obscureText: !passwordProvider,
                              suffix: CupertinoButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  ref
                                      .read(loginpasswordProviderNotifier
                                          .notifier)
                                      .togglePassword();
                                },
                                child: Icon(
                                  passwordProvider
                                      ? CupertinoIcons.eye_fill
                                      : CupertinoIcons.eye_slash_fill,
                                  color: CupertinoColors.darkBackgroundGray,
                                ),
                              ),
                              cursorColor: CupertinoColors.black,
                              decoration: BoxDecoration(
                                color: CupertinoColors.white,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                  color: CupertinoColors.systemGrey,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Consumer(
                  builder: (context, ref, child) {
                    final passwordError = ref.watch(passwordErrorProvider);
                    return passwordError.isEmpty
                        ? const SizedBox()
                        : Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              passwordError,
                              style: GoogleFonts.roboto(
                                color: CupertinoColors.systemRed,
                                fontSize: 16,
                              ),
                            ),
                          );
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        ref
                            .read(passwordErrorProvider.notifier)
                            .updateError('');
                        ref.read(emailErrorProvider.notifier).updateError('');
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (ctx) => const ForgetPassword(),
                          ),
                        );
                      },
                      child: Text(
                        'Forget Password?',
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: CupertinoColors.activeBlue,
                        ),
                      ),
                    )
                  ],
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
                      _loginPressed();
                    },
                    child: Text(
                      'Login',
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    const Expanded(
                      child: Divider(
                        height: 1,
                        color: CupertinoColors.black,
                        thickness: 0.5,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Text(
                        'Or Sign in with',
                        style: GoogleFonts.roboto(fontWeight: FontWeight.w400),
                      ),
                    ),
                    const Expanded(
                      child: Divider(
                        height: 1,
                        color: CupertinoColors.black,
                        thickness: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                Row(
                  children: [
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        late BuildContext googleSignInContext;
                        showCupertinoDialog(
                            context: context,
                            builder: (ctx) {
                              googleSignInContext = ctx;
                              handler.googleSignIn(
                                  ref, context, googleSignInContext);
                              return const Center(
                                child: CupertinoActivityIndicator(
                                  radius: 15,
                                ),
                              );
                            });
                      },
                      child: CircleAvatar(
                        backgroundColor: CupertinoColors.white,
                        radius: 30,
                        child: Image.asset(
                          width: 50,
                          height: 50,
                          'assets/images/g_transparent.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 30,
                    ),
                    GestureDetector(
                      onTap: () {
                        // TODO SignIN WITH APPLE
                      },
                      child: CircleAvatar(
                        backgroundColor: CupertinoColors.white,
                        radius: 30,
                        child: Image.asset(
                          width: 50,
                          height: 50,
                          'assets/images/apple_a.png',
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    const Spacer()
                  ],
                ),
                const SizedBox(
                  height: 50,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Don\'t have an account?',
                      style: GoogleFonts.roboto(),
                    ),
                    CupertinoButton(
                      onPressed: () {
                        ref.read(emailErrorProvider.notifier).updateError('');
                        ref
                            .read(passwordErrorProvider.notifier)
                            .updateError('');
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (ctx) => const SignUp(),
                          ),
                        );
                      },
                      child: Text(
                        'Sign Up',
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
