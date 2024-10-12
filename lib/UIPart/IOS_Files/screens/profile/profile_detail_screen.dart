import 'package:college_project/Authentication/IOS_Files/handlers/auth_handler.dart';
import 'package:college_project/Authentication/Providers/error.dart';
import 'package:college_project/UIPart/repository/user_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileDetailScreen extends ConsumerStatefulWidget {
  const ProfileDetailScreen({super.key});

  @override
  ConsumerState<ProfileDetailScreen> createState() =>
      _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends ConsumerState<ProfileDetailScreen> {
  final _firstNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _firstName = FocusNode();
  UserRepository userRepository = UserRepository();

  late AuthHandler handler;

  void submitPressed() async {
    if (_firstNameController.text.trim().isEmpty) {
      ref
          .read(fnameErrorProvider.notifier)
          .updateError('Please enter your Name');
    } else if (_firstNameController.text.trim().length < 3) {
      ref
          .read(fnameErrorProvider.notifier)
          .updateError('Name should be atleast 3 characters');
    } else {
      ref.read(fnameErrorProvider.notifier).updateError('');
    }
    late BuildContext profileUpdateContext;
    try {
      FocusScope.of(context).unfocus();
      showCupertinoDialog(
          context: context,
          builder: (ctx) {
            profileUpdateContext = ctx;
            return const Center(
              child: CupertinoActivityIndicator(
                radius: 15,
                color: CupertinoColors.black,
              ),
            );
          });
      await userRepository.putData(_firstNameController.text);
      if (!profileUpdateContext.mounted) return;
      Navigator.pop(profileUpdateContext);
      Navigator.of(context).pop();
    } catch (e) {
      if (!profileUpdateContext.mounted) return;
      Navigator.pop(profileUpdateContext);
      showCupertinoDialog(
        context: context,
        builder: (ctx) {
          return CupertinoAlertDialog(
            title: Text(
              'Alert',
              style: GoogleFonts.roboto(),
            ),
            content: Text(
              e.toString(),
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
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void initState() {
    handler = AuthHandler.authHandlerInstance;
    _firstNameController.text = handler.newUser.firstName ?? '';
    _emailController.text = handler.newUser.email ?? '';
    super.initState();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _emailController.dispose();
    _firstName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Edit Profile',
          style: GoogleFonts.roboto(),
        ),
        leading: IconButton(
          padding: EdgeInsetsDirectional.zero,
          onPressed: () {
            ref.read(fnameErrorProvider.notifier).updateError('');

            Navigator.of(context).pop();
          },
          icon: const Icon(
            CupertinoIcons.back,
          ),
        ),
      ),
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                flex: 8,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Consumer(
                          builder: (context, ref, child) {
                            final fnameError = ref.watch(fnameErrorProvider);
                            return SizedBox(
                              height: 75,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Name',
                                    style: GoogleFonts.roboto(
                                      color: fnameError.isNotEmpty
                                          ? CupertinoColors.systemRed
                                          : CupertinoColors.black,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Expanded(
                                    child: CupertinoTextField(
                                      focusNode: _firstName,
                                      keyboardType: TextInputType.name,
                                      controller: _firstNameController,
                                      cursorColor: CupertinoColors.black,
                                      prefix: const Padding(
                                        padding: EdgeInsets.only(
                                          left: 10,
                                        ),
                                        child: Icon(
                                          CupertinoIcons.person,
                                          color: CupertinoColors.black,
                                        ),
                                      ),
                                      decoration: BoxDecoration(
                                        color: CupertinoColors.white,
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(
                                          color: fnameError.isNotEmpty
                                              ? CupertinoColors.systemRed
                                              : CupertinoColors.systemGrey,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                        Consumer(
                          builder: (ctx, ref, child) {
                            final fnameError = ref.watch(fnameErrorProvider);
                            return fnameError.isEmpty
                                ? const SizedBox()
                                : Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      fnameError,
                                      style: GoogleFonts.roboto(
                                          color: CupertinoColors.systemRed),
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
                                'Email',
                                style: GoogleFonts.roboto(),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Expanded(
                                child: CupertinoTextField(
                                  controller: _emailController,
                                  readOnly: true,
                                  decoration: BoxDecoration(
                                    color: CupertinoColors.white,
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      color: CupertinoColors.systemGrey,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 50,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: CupertinoButton(
                            color: CupertinoColors.activeBlue,
                            child: Text(
                              'Submit',
                              style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            onPressed: () {
                              submitPressed();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
