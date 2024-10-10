import 'package:college_project/Authentication/IOS_Files/handlers/auth_handler.dart';
import 'package:college_project/Authentication/Providers/error.dart';
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
  final _lastNameController = TextEditingController();
  final _firstName = FocusNode();
  final _lastName = FocusNode();
  late AuthHandler handler;

  @override
  void initState() {
    handler = AuthHandler.authHandlerInstance;
    if(handler.newUser.user != null){
      
    }
    super.initState();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _firstName.dispose();
    _lastName.dispose();
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
            ref.read(lnameErrorProvider.notifier).updateError('');
            Navigator.of(context).pop();
          },
          icon: const Icon(
            CupertinoIcons.back,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 8,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(),
                        ),
                        child: Center(
                          child: IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              CupertinoIcons.camera,
                              size: 35,
                            ),
                          ),
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
                              'First Name',
                              style: GoogleFonts.roboto(),
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
                                    color: CupertinoColors.systemGrey,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
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
                              'Last Name',
                              style: GoogleFonts.roboto(),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Expanded(
                              child: CupertinoTextField(
                                focusNode: _lastName,
                                controller: _lastNameController,
                                prefix: const Padding(
                                  padding: EdgeInsets.only(
                                    left: 10,
                                  ),
                                  child: Icon(
                                    CupertinoIcons.person_2,
                                    color: CupertinoColors.black,
                                  ),
                                ),
                                keyboardType: TextInputType.name,
                                cursorColor: CupertinoColors.black,
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
                      Consumer(builder: (ctx, ref, child) {
                        final lNameError = ref.watch(lnameErrorProvider);
                        return lNameError.isEmpty
                            ? const SizedBox()
                            : Text(
                                lNameError,
                                style: GoogleFonts.roboto(),
                              );
                      }),
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
                                readOnly: true,
                                padding: EdgeInsets.zero,
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
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 35,
                  bottom: 35,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    color: CupertinoColors.activeBlue,
                    child: Text(
                      'Submit',
                      style: GoogleFonts.roboto(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    onPressed: () {},
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
