import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:college_project/Authentication/IOS_Files/Screens/auth/login_ios.dart';
import 'package:college_project/Authentication/IOS_Files/handlers/auth_handler.dart';
import 'package:college_project/Authentication/Providers/error.dart';
import 'package:college_project/Authentication/Providers/spinner.dart';
import 'package:college_project/Home/IOS_Files/screens/sell/ad_uploaded.dart';
import 'package:college_project/Home/IOS_Files/screens/sell/phone_brands.dart';
import 'package:college_project/Home/Providers/image_selected.dart';
import 'package:college_project/Home/Providers/select_image.dart';
import 'package:college_project/Home/Providers/selected_item.dart';
import 'package:college_project/constants/constants.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class ProductGetInfo extends ConsumerStatefulWidget {
  final String categoryName;
  final String subCategoryName;

  const ProductGetInfo({
    required this.categoryName,
    required this.subCategoryName,
    super.key,
  });

  @override
  ConsumerState<ProductGetInfo> createState() => _ProductGetInfoState();
}

class _ProductGetInfoState extends ConsumerState<ProductGetInfo> {
  final _brandController = TextEditingController();
  final _adTitleController = TextEditingController();
  final _adDescriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _brandFocus = FocusNode();
  final _adTitleFocus = FocusNode();
  final _adDescriptionFocus = FocusNode();
  final _priceFocus = FocusNode();
  final List<String> _tabletBrands = ['iPad', 'Samsung', 'Other Tablets'];
  final List<String> chargers = ['Mobile', 'Tablet', 'Smart Watch', 'Speakers'];
  late AuthHandler handler;
  void unfocusFields() {
    _brandFocus.unfocus();
    _adTitleFocus.unfocus();
    _adDescriptionFocus.unfocus();
    _priceFocus.unfocus();
  }

  @override
  void initState() {
    handler = AuthHandler.authHandlerInstance;
    super.initState();
  }

  @override
  void dispose() {
    _brandController.dispose();
    _brandFocus.dispose();
    _adTitleController.dispose();
    _adTitleFocus.dispose();
    _adDescriptionController.dispose();
    _adDescriptionFocus.dispose();
    _priceController.dispose();
    _priceFocus.dispose();
    super.dispose();
  }

  void brandErrorText() {
    if (_brandController.text.trim().isEmpty) {
      ref.read(brandError.notifier).updateError('Brand is Mandatory');
    } else {
      ref.read(brandError.notifier).updateError('');
    }
  }

  void priceErrorText() {
    if (_priceController.text.trim().isEmpty) {
      ref.read(priceError.notifier).updateError('Price is Mandatory');
    } else if (double.tryParse(_priceController.text.trim()) == null) {
      ref.read(priceError.notifier).updateError('Price should be a number');
    } else if (double.tryParse(_priceController.text.trim())! <= 0) {
      ref.read(priceError.notifier).updateError('Please Provide Valid Price');
    } else {
      ref.read(priceError.notifier).updateError('');
    }
  }

  void adTitleErrorText() {
    if (_adTitleController.text.trim().isEmpty) {
      ref.read(adTitleError.notifier).updateError('Ad title is Mandatory');
    } else if (_adTitleController.text.trim().length < 10) {
      ref
          .read(adTitleError.notifier)
          .updateError('Ad title should be atleast 10 characters');
    } else {
      ref.read(adTitleError.notifier).updateError('');
    }
  }

  void adDescriptionErrorText() {
    if (_adDescriptionController.text.trim().isEmpty) {
      ref
          .read(adDescriptionError.notifier)
          .updateError('Please provide ad description');
    } else if (_adDescriptionController.text.trim().length < 10) {
      ref
          .read(adDescriptionError.notifier)
          .updateError('Ad description should be atleast 10 characters');
    } else {
      ref.read(adDescriptionError.notifier).updateError('');
    }
  }

  void ipadSelectionErrorText() {
    if (ref.read(selectedIpadProvider) == -1) {
      ref.read(ipadError.notifier).updateError('Please select a brand');
    }
  }

  void saveMyAdToDB() async {
    List<String> url = [];
    final fbStorage = handler.storage;
    final fbCloudFireStore = handler.fireStore;
    final uuid = const Uuid().v4();
    if (handler.user?.uid == null) {
      // then i need to write the code to move to the login screen.
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          CupertinoPageRoute(builder: (ctx) => const LoginIos()),
          (Route<dynamic> route) => false);
      return;
    }
    ref.read(submitAdPostSpinner.notifier).isLoading();
    print(ref.read(imageProvider).length);
    for (int i = 0; i < ref.read(imageProvider).length; i++) {
      String uniqueName = '${handler.user!.uid}/$uuid/image_$i.jpg';
      UploadTask task = fbStorage
          .ref(uniqueName)
          .putFile(File(ref.read(imageProvider)[i].path));
      await task.whenComplete(() => null);
      String downloadURL = await fbStorage.ref(uniqueName).getDownloadURL();
      print(downloadURL);
      url.add(downloadURL);
    }
    if (widget.subCategoryName == Constants.mobilePhone) {
      CollectionReference myActiveAdsCollection = fbCloudFireStore
          .collection('users')
          .doc(handler.user!.uid)
          .collection('MyActiveAds');
      final timeStamp = FieldValue.serverTimestamp();
      DocumentReference adDocRef = await myActiveAdsCollection.add({
        'adTitle': _adTitleController.text.trim(),
        'adDescription': _adDescriptionController.text.trim(),
        'price': double.parse(_priceController.text.trim()),
        'brand': _brandController.text.trim(),
        'images': url,
        'createdAt': timeStamp, // Add server timestamp
      });
      CollectionReference allAdsCollection =
          fbCloudFireStore.collection('AllAds');
      QuerySnapshot existingPost = await allAdsCollection
          .where('adReference', isEqualTo: adDocRef)
          .get();
      if (existingPost.docs.isEmpty) {
        allAdsCollection.add({
          'adReference':
              adDocRef, // Store reference to the ad document in MyActiveAds
          'createdAt': timeStamp
        });
      } else {
        // I can Edit the Product here
      }
      CollectionReference categoryCollection =
          fbCloudFireStore.collection('Category');
      DocumentReference categoryDocRef =
          categoryCollection.doc(widget.categoryName);
      DocumentReference subcategoryDocRef = categoryDocRef
          .collection('Subcategories')
          .doc(widget.subCategoryName);
      QuerySnapshot existingSubcategoryAd = await subcategoryDocRef
          .collection('Ads')
          .where('adReference', isEqualTo: adDocRef)
          .get();

      if (existingSubcategoryAd.docs.isEmpty) {
        // If the ad reference does not exist in the subcategory, add it
        subcategoryDocRef
            .collection('Ads')
            .add({'adReference': adDocRef, 'createdAt': timeStamp});
      } else {
        print("This ad reference already exists in the subcategory");
      }
    }
    if (!context.mounted) {
      return;
    }
    Navigator.of(context)
        .push(CupertinoPageRoute(builder: (ctx) => const AdUploaded()));
    ref.read(submitAdPostSpinner.notifier).isDoneLoading();
  }

  bool checkAtleastOneImage() {
    if (ref.read(imageProvider).isEmpty) {
      return true; // no image
    }
    return false; // Atleast 1 image has uploaded
  }

  uploadImageDialog() {
    showCupertinoDialog(
        context: context,
        builder: (ctx) {
          return CupertinoAlertDialog(
            title: Text('Alert', style: GoogleFonts.roboto()),
            content: Text('Please select atleast 1 image',
                style: GoogleFonts.roboto()),
            actions: [
              CupertinoDialogAction(
                child: Text('Okay', style: GoogleFonts.roboto()),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  void _nextPressed() {
    unfocusFields();
    if (widget.subCategoryName == Constants.mobilePhone) {
      brandErrorText();
      adTitleErrorText();
      adDescriptionErrorText();
      priceErrorText();
      if (ref.read(brandError).isEmpty &&
          ref.read(adTitleError).isEmpty &&
          ref.read(adDescriptionError).isEmpty &&
          ref.read(priceError).isEmpty) {
        if (checkAtleastOneImage()) {
          uploadImageDialog();
          return;
        }
        saveMyAdToDB();
      }
    } else if (widget.subCategoryName == Constants.tablet) {
      ipadSelectionErrorText();
      adTitleErrorText();
      adDescriptionErrorText();
      priceErrorText();

      if (ref.read(selectedIpadProvider) != -1 &&
          ref.read(adTitleError).isEmpty &&
          ref.read(adDescriptionError).isEmpty &&
          ref.read(priceError).isEmpty) {
        print(_tabletBrands[ref.read(selectedIpadProvider)]);
        print(_adTitleController.text);
        print(_adDescriptionController.text);
        print(_priceController.text);
      }
    } else if (widget.subCategoryName == Constants.mobileChargerLaptopCharger) {
      chargerSelectionErrorText();
      adTitleErrorText();
      adDescriptionErrorText();
      priceErrorText();
      if (ref.read(selectChargerProvider) != -1 &&
          ref.read(adTitleError).isEmpty &&
          ref.read(adDescriptionError).isEmpty &&
          ref.read(priceError).isEmpty) {
        print(chargers[ref.read(selectedIpadProvider)]);
        print(_adTitleController.text);
        print(_adDescriptionController.text);
        print(_priceController.text);
      }
    } else {
      adTitleErrorText();
      adDescriptionErrorText();
      priceErrorText();
      if (ref.read(adTitleError).isEmpty &&
          ref.read(adDescriptionError).isEmpty &&
          ref.read(priceError).isEmpty) {
        print(_adTitleController.text);
        print(_adDescriptionController.text);
        print(_priceController.text);
      }
    }
  }

  void chargerSelectionErrorText() {
    if (ref.read(selectChargerProvider) == -1) {
      ref
          .read(chargerError.notifier)
          .updateError('Please select a charger type');
    }
  }

  Consumer getAdTitle() {
    return Consumer(
      builder: (context, ref, child) {
        final error = ref.watch(adTitleError);
        return SizedBox(
          height: 70,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ad Title',
                style: GoogleFonts.roboto(
                    color: error == ''
                        ? CupertinoColors.black
                        : CupertinoColors.systemRed),
              ),
              Expanded(
                child: CupertinoTextField(
                  focusNode: _adTitleFocus,
                  controller: _adTitleController,
                  placeholder: 'Ad Title',
                  cursorColor: CupertinoColors.black,
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: error == ''
                          ? CupertinoColors.systemGrey
                          : CupertinoColors.systemRed,
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Consumer setThePrice() {
    return Consumer(
      builder: (context, ref, child) {
        final error = ref.watch(priceError);
        return SizedBox(
          height: 70,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Set Price',
                style: GoogleFonts.roboto(
                    color: error == ''
                        ? CupertinoColors.black
                        : CupertinoColors.systemRed),
              ),
              Expanded(
                child: CupertinoTextField(
                  keyboardType: TextInputType.number,
                  prefix: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '₹',
                      style: GoogleFonts.roboto(
                        fontSize: 22,
                        color: CupertinoColors.black,
                      ),
                    ),
                  ),
                  controller: _priceController,
                  focusNode: _priceFocus,
                  placeholder: 'Set Price',
                  cursorColor: CupertinoColors.black,
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: error == ''
                          ? CupertinoColors.systemGrey
                          : CupertinoColors.systemRed,
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Consumer getAdDescription() {
    return Consumer(
      builder: (context, ref, child) {
        final error = ref.watch(adDescriptionError);
        return SizedBox(
          height: 120,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Additional Info (Include Condition, features)',
                style: GoogleFonts.roboto(
                    color: error == ''
                        ? CupertinoColors.black
                        : CupertinoColors.systemRed),
              ),
              Expanded(
                child: CupertinoTextField(
                  focusNode: _adDescriptionFocus,
                  controller: _adDescriptionController,
                  maxLines: 10,
                  textAlignVertical: TextAlignVertical.top,
                  cursorColor: CupertinoColors.black,
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: error == ''
                          ? CupertinoColors.systemGrey
                          : CupertinoColors.systemRed,
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget getCupertinoButton() {
    return Consumer(
      builder: (context, ref, child) {
        final isLoading = ref.watch(submitAdPostSpinner);
        return SizedBox(
          height: 50,
          width: double.infinity,
          child: CupertinoButton(
            color: CupertinoColors.activeBlue,
            child: isLoading
                ? const CupertinoActivityIndicator(
                    color: CupertinoColors.white,
                  )
                : Text(
                    'Post Your Ad',
                    style: GoogleFonts.roboto(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
            onPressed: () {
              _nextPressed();
            },
          ),
        );
      },
    );
  }

  Consumer watchingMobileSelection() {
    return Consumer(
      builder: (context, ref, child) {
        final error = ref.watch(brandError);
        return SizedBox(
          height: 70,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Brand',
                style: GoogleFonts.roboto(
                  color: error == ''
                      ? CupertinoColors.black
                      : CupertinoColors.systemRed,
                ),
              ),
              Expanded(
                child: CupertinoTextField(
                  onTap: () async {
                    FocusScope.of(context).unfocus();
                    final selectedBrand =
                        await Navigator.of(context).push<Map<String, String>>(
                      CupertinoPageRoute(
                        fullscreenDialog: true,
                        builder: (ctx) => const PhoneBrands(),
                      ),
                    );
                    if (selectedBrand == null) {
                      print('reaching here');
                      FocusScope.of(context).unfocus();
                      return;
                    }
                    _brandController.text = selectedBrand['brand']!;
                    _brandFocus.unfocus();
                  },
                  suffix: const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(CupertinoIcons.chevron_down),
                  ),
                  focusNode: _brandFocus,
                  controller: _brandController,
                  placeholder: 'Brand Name',
                  cursorColor: CupertinoColors.black,
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: error == ''
                          ? CupertinoColors.systemGrey
                          : CupertinoColors.systemRed,
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Consumer mobileNotSelectionError() {
    return Consumer(
      builder: (ctx, ref, child) {
        final error = ref.watch(brandError);
        return error == ''
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  error,
                  style: GoogleFonts.roboto(color: CupertinoColors.systemRed),
                ),
              );
      },
    );
  }

  Consumer adTitleNotWrittenError() {
    return Consumer(
      builder: (ctx, ref, child) {
        final error = ref.watch(adTitleError);
        return error == ''
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  error,
                  style: GoogleFonts.roboto(color: CupertinoColors.systemRed),
                ),
              );
      },
    );
  }

  Consumer priceNotSetError() {
    return Consumer(
      builder: (ctx, ref, child) {
        final error = ref.watch(priceError);
        return error == ''
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  error,
                  style: GoogleFonts.roboto(color: CupertinoColors.systemRed),
                ),
              );
      },
    );
  }

  Consumer adDescriptionNotWrittenError() {
    return Consumer(
      builder: (ctx, ref, child) {
        final error = ref.watch(adDescriptionError);
        return error == ''
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  error,
                  style: GoogleFonts.roboto(color: CupertinoColors.systemRed),
                ),
              );
      },
    );
  }

  Widget mobileSubCategory() {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                watchingMobileSelection(),
                mobileNotSelectionError(),
                const SizedBox(
                  height: 20,
                ),
                getAdTitle(),
                adTitleNotWrittenError(),
                const SizedBox(
                  height: 20,
                ),
                getAdDescription(),
                adDescriptionNotWrittenError(),
                const SizedBox(
                  height: 20,
                ),
                setThePrice(),
                priceNotSetError(),
                const SizedBox(
                  height: 20,
                ),
                container(),
                const SizedBox(
                  height: 50,
                ),
                getCupertinoButton()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Consumer ipadNotSelectedError() {
    return Consumer(
      builder: (ctx, ref, child) {
        final error = ref.watch(ipadError);
        return error == ''
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  error,
                  style: GoogleFonts.roboto(color: CupertinoColors.systemRed),
                ),
              );
      },
    );
  }

  Consumer chargerNotSelectedError() {
    return Consumer(
      builder: (ctx, ref, child) {
        final error = ref.watch(chargerError);
        return error == ''
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  error,
                  style: GoogleFonts.roboto(color: CupertinoColors.systemRed),
                ),
              );
      },
    );
  }

  Widget tabletSubCategory() {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                getTypeOfTablets(),
                ipadNotSelectedError(),
                const SizedBox(
                  height: 20,
                ),
                getAdTitle(),
                adTitleNotWrittenError(),
                const SizedBox(
                  height: 20,
                ),
                getAdDescription(),
                adDescriptionNotWrittenError(),
                const SizedBox(
                  height: 20,
                ),
                setThePrice(),
                priceNotSetError(),
                const SizedBox(
                  height: 20,
                ),
                container(),
                const SizedBox(
                  height: 50,
                ),
                getCupertinoButton()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getTypeOfChargers() {
    return SizedBox(
      height: 60,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Consumer(
            builder: (ctx, ref, child) {
              final error = ref.watch(chargerError);
              return Text(
                'Charger Type',
                style: GoogleFonts.roboto(
                    color: error != '' ? CupertinoColors.systemRed : null),
              );
            },
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: chargers.length,
              itemBuilder: (context, index) {
                return Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        ref
                            .read(selectChargerProvider.notifier)
                            .updateSelectedItem(index);
                      },
                      child: Consumer(
                        builder: (context, ref, child) {
                          final selectedIndex =
                              ref.watch(selectChargerProvider);
                          return getContainer(
                              chargers[index], selectedIndex, index);
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    )
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget chargerSubCategory() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              getTypeOfChargers(),
              chargerNotSelectedError(),
              const SizedBox(
                height: 20,
              ),
              getAdTitle(),
              adTitleNotWrittenError(),
              const SizedBox(
                height: 20,
              ),
              getAdDescription(),
              adDescriptionNotWrittenError(),
              const SizedBox(
                height: 20,
              ),
              setThePrice(),
              priceNotSetError(),
              const SizedBox(
                height: 20,
              ),
              container(),
              const SizedBox(
                height: 50,
              ),
              getCupertinoButton()
            ],
          ),
        ),
      ),
    );
  }

  Container container() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: CupertinoColors.systemGrey),
        borderRadius: BorderRadius.circular(5),
      ),
      height: 300,
      child: Column(
        children: [
          Consumer(
            builder: (ctx, ref, child) {
              final images = ref.watch(imageProvider);
              return Expanded(
                flex: 8,
                child: images.isEmpty
                    ? Center(
                        child: Image.asset(
                          'assets/images/upload.jpg',
                          height: 100,
                          width: 100,
                        ),
                      )
                    : Consumer(
                        builder: (ctx, ref, child) {
                          final selectedIndex = ref.watch(imageSelectProvider);
                          return Stack(
                            children: [
                              Image.file(
                                File(images[selectedIndex].path),
                                fit: BoxFit.fill,
                              ),
                              Positioned(
                                top: 0,
                                right: -10,
                                child: IconButton(
                                  onPressed: () {
                                    dialog(ctx, images[selectedIndex]);
                                  },
                                  icon: const Icon(
                                    CupertinoIcons.clear_circled_solid,
                                    color: CupertinoColors.systemIndigo,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
              );
            },
          ),
          Container(
            height: 0.5,
            width: double.infinity,
            color: CupertinoColors.black,
          ),
          Expanded(
            flex: 2,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  padding: const EdgeInsets.only(top: 5),
                  onPressed: () {
                    unfocusFields();
                    _uploadImages(context);
                  },
                  icon: const Icon(
                    CupertinoIcons.add_circled_solid,
                    size: 50,
                  ),
                ),
                Expanded(
                  child: Consumer(
                    builder: (ctx, ref, child) {
                      final images = ref.watch(imageProvider);
                      return Row(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: images.length,
                              itemBuilder: (ctx, index) {
                                return GestureDetector(
                                  onTap: () {
                                    ref
                                        .read(imageSelectProvider.notifier)
                                        .changeIndex(index);
                                  },
                                  child: Container(
                                    height: 20,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: CupertinoColors.systemGrey,
                                      ),
                                    ),
                                    child: Center(
                                      child: Image.file(
                                        height: 30,
                                        width: 40,
                                        File(images[index].path),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  void dialog(BuildContext context, XFile image) {
    showCupertinoDialog(
        context: context,
        builder: (ctx) {
          return CupertinoAlertDialog(
            title: Text(
              'Alert',
              style: GoogleFonts.roboto(),
            ),
            content: Text(
              'Are you sure want to delete this image?',
              style: GoogleFonts.roboto(),
            ),
            actions: [
              CupertinoDialogAction(
                child: Text(
                  'Yes',
                  style: GoogleFonts.roboto(),
                ),
                onPressed: () {
                  ref.read(imageProvider.notifier).removeImage(image);
                  ref.read(imageSelectProvider.notifier).changeIndex(0);
                  Navigator.of(ctx).pop();
                },
              ),
              CupertinoDialogAction(
                child: Text(
                  'No',
                  style: GoogleFonts.roboto(),
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          );
        });
  }

  void _cameraPressed(BuildContext ctx) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );
    if (image == null) return;
    ref.read(imageProvider.notifier).addImage([XFile(image.path)]);
  }

  void _galleryPressed(BuildContext ctx) async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      ref.read(imageProvider.notifier).addImage(images);
      if (ctx.mounted) {
        Navigator.of(ctx).pop();
      }
    }
  }

  void _uploadImages(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) {
        return CupertinoActionSheet(
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(ctx).pop();
                _cameraPressed(ctx);
              },
              child: Text(
                'Camera',
                style: GoogleFonts.roboto(),
              ),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                _galleryPressed(ctx);
              },
              child: Text('Gallery', style: GoogleFonts.roboto()),
            )
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Cancel',
              style: GoogleFonts.roboto(color: CupertinoColors.systemRed),
            ),
          ),
        );
      },
    );
  }

  Widget changeUIAccordingly(String subCategoryName) {
    if (subCategoryName == Constants.mobilePhone) {
      return GestureDetector(
          onTap: () {
            unfocusFields();
          },
          child: mobileSubCategory());
    } else if (subCategoryName == Constants.tablet) {
      return tabletSubCategory();
    } else if (subCategoryName == Constants.mobileChargerLaptopCharger) {
      return chargerSubCategory();
    } else {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                getAdTitle(),
                adTitleNotWrittenError(),
                const SizedBox(
                  height: 20,
                ),
                getAdDescription(),
                adDescriptionNotWrittenError(),
                const SizedBox(
                  height: 20,
                ),
                setThePrice(),
                priceNotSetError(),
                const SizedBox(
                  height: 20,
                ),
                container(),
                const SizedBox(
                  height: 50,
                ),
                getCupertinoButton()
              ],
            ),
          ),
        ),
      );
    }
  }

  Container getContainer(String text, int selectedIndex, int index) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        color: index == selectedIndex ? CupertinoColors.activeBlue : null,
        border: Border.all(
          color: CupertinoColors.systemGrey,
        ),
      ),
      height: 30,
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.roboto(
              fontWeight: index == selectedIndex ? FontWeight.bold : null,
              color: index == selectedIndex ? CupertinoColors.white : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget getTypeOfTablets() {
    return SizedBox(
      height: 60,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Consumer(
            builder: (ctx, ref, child) {
              final error = ref.watch(ipadError);
              return Text(
                'Type',
                style: GoogleFonts.roboto(
                    color: error != '' ? CupertinoColors.systemRed : null),
              );
            },
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _tabletBrands.length,
              itemBuilder: (context, index) {
                return Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        ref
                            .read(selectedIpadProvider.notifier)
                            .updateSelectedItem(index);
                      },
                      child: Consumer(
                        builder: (context, ref, child) {
                          final selectedIndex = ref.watch(selectedIpadProvider);
                          return getContainer(
                              _tabletBrands[index], selectedIndex, index);
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    )
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void resetFields() {
    unfocusFields();
    ref.read(selectChargerProvider.notifier).updateSelectedItem(-1);
    ref.read(selectedIpadProvider.notifier).updateSelectedItem(-1);
    ref.read(brandError.notifier).updateError('');
    ref.read(adTitleError.notifier).updateError('');
    ref.read(adDescriptionError.notifier).updateError('');
    ref.read(ipadError.notifier).updateError('');
    ref.read(chargerError.notifier).updateError('');
    ref.read(priceError.notifier).updateError('');
    ref.read(imageProvider.notifier).reset();
    ref.read(imageSelectProvider.notifier).changeIndex(0);
    ref.read(imageProvider.notifier).reset();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        padding: EdgeInsetsDirectional.zero,
        middle: Text(
          'Include some details',
          style: GoogleFonts.roboto(),
        ),
        leading: CupertinoButton(
            padding: EdgeInsetsDirectional.zero,
            child: const Icon(CupertinoIcons.back),
            onPressed: () {
              resetFields();
              Navigator.pop(context);
            }),
      ),
      child: GestureDetector(
        onTap: () {
          unfocusFields();
        },
        child: changeUIAccordingly(
          widget.subCategoryName,
        ),
      ),
    );
  }
}
