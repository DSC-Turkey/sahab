import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sahab/extensions/app_localizations.dart';
import 'package:sahab/extensions/global_colors.dart';
import 'package:sahab/extensions/global_variables.dart';
import 'package:sahab/locator.dart';
import 'package:sahab/screens/welcome_screen.dart';
import 'package:sahab/viewmodels/account_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  setupLocator();
  _setupOneSignal();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(Phoenix(
      child: MyApp(),
    ));
  });
}

void _setupOneSignal() async {
  //Remove this method to stop OneSignal Debugging
  await OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

  await OneSignal.shared.init(GlobalVariables.oneSignalTokenID, iOSSettings: {
    OSiOSSettings.autoPrompt: false,
    OSiOSSettings.inAppLaunchUrl: false
  });
  await OneSignal.shared
      .setInFocusDisplayType(OSNotificationDisplayType.notification);

// The promptForPushNotificationsWithUserResponse function will show the iOS push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
  await OneSignal.shared
      .promptUserForPushNotificationPermission(fallbackToSettings: true);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AccountProvider>(
          create: (context) => AccountProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Sahab',
        supportedLocales: [
          Locale('en', 'US'),
          Locale('tr', 'TR'),
        ],
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        localeResolutionCallback: (locale, supportedLocales) {
          if (locale == null) {
            return supportedLocales.first;
          }

          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode ||
                supportedLocale.countryCode == locale.countryCode) {
              return supportedLocale;
            }
          }

          return supportedLocales.first;
        },
        theme: ThemeData(
          accentColor: GlobalColors.appColor,
          primaryColor: Colors.white,
          backgroundColor: Colors.white,
          cursorColor: GlobalColors.appColor,
          indicatorColor: GlobalColors.appColor,
          textSelectionHandleColor: GlobalColors.appColor,
          //scaffoldBackgroundColor: Colors.grey[10],
        ),
        home: WelcomeScreen(),
      ),
    );
  }
}
