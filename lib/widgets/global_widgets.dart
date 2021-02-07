import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sahab/extensions/global_colors.dart';
import 'package:sahab/extensions/global_styles.dart';

class GlobalWidgets {
  static Widget appTitle(
      {bool isInAppBar = false, bool isDark = true, double size = 30}) {
    return Image.asset(
      'assets/images/sahab.png',
      width: 250,
      height: 90,
      fit: BoxFit.cover,
    );
  }

  static Widget customPlatformDialog(
      {String title, String content, List<Widget> actions}) {
    return PlatformAlertDialog(
      title: Center(
        child: Text(
          title,
          style:
              GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
      content: Text(
        content,
        style: GoogleFonts.montserrat(fontSize: 12),
        textAlign: TextAlign.center,
      ),
      actions: actions,
      material: (context, platform) => MaterialAlertDialogData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      cupertino: (context, platform) => CupertinoAlertDialogData(),
    );
  }

  static Widget planOfferCard(
          {String title, String description, String price, Function() onTap}) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          color: Colors.orange,
          child: ListTile(
            title: Text(
              title,
              style: GlobalStyles.defaultListTileTitleTextStyle(
                  textColor: Colors.white),
            ),
            subtitle: Text(
              description,
              style: GlobalStyles.defaultListTileDescriptionTextStyle(
                  textColor: Colors.white),
            ),
            trailing: Text(
              price,
              style: GlobalStyles.defaultListTileTitleTextStyle(
                  textColor: Colors.white),
            ),
          ),
        ),
      );

  static Widget defaultButton(
      {Function() onTap,
      Widget content,
      Color color,
      BorderRadius borderRadius}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: color ?? GlobalColors.appColor,
          borderRadius: borderRadius ?? BorderRadius.circular(15),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: content,
          ),
        ),
      ),
    );
  }
}
