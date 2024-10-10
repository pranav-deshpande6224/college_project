import 'package:college_project/UIPart/IOS_Files/screens/home/display_category_ads.dart';
import 'package:flutter/cupertino.dart';

class FetchCategoryAds extends StatelessWidget {
  final String categoryName;
  final String subCategoryName;
  const FetchCategoryAds(
      {required this.categoryName, required this.subCategoryName, super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(subCategoryName),
        previousPageTitle: 'Back',
      ),
      child: SafeArea(
        child: DisplayCategoryAds(
          categoryName: categoryName,
          subCategoryName: subCategoryName,
        ),
      ),
    );
  }
}
