import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

class AdUploaded extends StatelessWidget {
  const AdUploaded({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 100, left: 12, right: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(CupertinoIcons.check_mark_circled_solid, size: 100),
              const SizedBox(
                height: 20,
              ),
              Text(
                'Ad Uploaded Successfully',
                style: GoogleFonts.roboto(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 30,
              ),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: CupertinoButton(
                    color: CupertinoColors.activeBlue,
                    child: Text(
                      'Continue',
                      style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }
}
