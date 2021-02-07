import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sahab/extensions/app_localizations.dart';
import 'package:sahab/extensions/error_management.dart';
import 'package:sahab/extensions/global_colors.dart';
import 'package:sahab/screens/home/home_screen.dart';
import 'package:sahab/screens/login/sign_in_screen.dart';
import 'package:sahab/viewmodels/account_provider.dart';
import 'package:sahab/widgets/custom_textfield.dart';
import 'package:sahab/widgets/global_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  AccountProvider _accountProvider;
  AppLocalizations _localizations;
  TextEditingController _emailController;
  TextEditingController _passwordController;
  TextEditingController _passwordAgainController;
  bool isQueryable = false;

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _passwordAgainController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _accountProvider = Provider.of<AccountProvider>(context);
    _localizations = AppLocalizations.of(context);

    var _height = screenHeightExcludingToolbar(context);
    var _width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: _appBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: _height, minWidth: _width),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Hero(tag: 'title', child: GlobalWidgets.appTitle()),
                  SizedBox(
                    height: 48,
                  ),
                  _emailField(),
                  _passwordField(),
                  _passwordAgainField(),
                  _signUpInfoText,
                  SizedBox(
                    height: 48,
                  ),
                  _submitButton(),
                  _createAccountLabel()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _appBar() {
    return AppBar(
      centerTitle: false,
      elevation: 0,
      title: Text(
        _localizations.translate('sign_up'),
        style: GoogleFonts.montserrat(),
      ),
    );
  }

  Widget _emailField() {
    return CustomTextField(
      title: _localizations.translate('email_address'),
      controller: _emailController,
      onChanged: (text) {
        _checkQueryable();
      },
      keyboardType: TextInputType.emailAddress,
    );
  }

  Widget _passwordField() {
    return CustomTextField(
      title: _localizations.translate('password'),
      controller: _passwordController,
      onChanged: (text) {
        _checkQueryable();
      },
      obscureText: true,
      keyboardType: TextInputType.text,
    );
  }

  Widget _passwordAgainField() {
    return CustomTextField(
      title: _localizations.translate('password_again'),
      controller: _passwordAgainController,
      onChanged: (text) {
        _checkQueryable();
      },
      obscureText: true,
      keyboardType: TextInputType.text,
    );
  }

  Widget get _signUpInfoText {
    var defaultStyle = TextStyle(color: Colors.grey, fontSize: 14.0);
    var linkStyle = TextStyle(color: GlobalColors.appColor);
    return RichText(
      textAlign: TextAlign.center,
      softWrap: true,
      text: TextSpan(
        style: defaultStyle,
        children: <TextSpan>[
          TextSpan(
              text:
                  'Kaydol butonuna basarak, gizlilik politikamızı kabul ediyorsun. Verilerin hakkında bilgi almak için '),
          TextSpan(
              text: 'Gizlilik Politikası',
              style: linkStyle,
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  _execPrivacyPage();
                }),
          TextSpan(text: "'nı inceleyebilirsin."),
        ],
      ),
    );
  }

  Widget _submitButton() {
    return InkWell(
      borderRadius: BorderRadius.all(Radius.circular(5)),
      onTap: isQueryable && _accountProvider.state == AccountState.Idle
          ? _register
          : null,
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.grey.shade200,
                  offset: Offset(2, 4),
                  blurRadius: 5,
                  spreadRadius: 2)
            ],
            gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors:
                    isQueryable && _accountProvider.state == AccountState.Idle
                        ? [Colors.purple, GlobalColors.appColor]
                        : [Colors.grey, Colors.blueGrey])),
        child: _accountProvider.state == AccountState.Idle
            ? Text(
                _localizations.translate('sign_up'),
                style: TextStyle(fontSize: 20, color: Colors.white),
              )
            : PlatformCircularProgressIndicator(),
      ),
    );
  }

  Widget _createAccountLabel() {
    return InkWell(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => SignInScreen()));
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20),
        padding: EdgeInsets.all(15),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _localizations.translate('do_you_already_have_an_account'),
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              _localizations.translate('sign_in'),
              style: TextStyle(
                  color: GlobalColors.appColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  void _checkQueryable() {
    var emailValid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(_emailController.text);

    var passwordValid = _passwordController.text.length >= 6 &&
        _passwordAgainController.text.length >= 6;

    setState(() {
      isQueryable = emailValid && passwordValid;
    });
  }

  void _register() async {
    if (_passwordController.text == _passwordAgainController.text) {
      var cQuery = await _accountProvider.createAccount(
          emailAddress: _emailController.text,
          password: _passwordController.text);

      if (cQuery.isSuccess) {
        _execHomeScreen();
      } else {
        await showPlatformDialog(
          context: context,
          builder: (context) => GlobalWidgets.customPlatformDialog(
              title: _localizations.translate('register_error'),
              content: _localizations.translate(
                ErrorManagement.getErrorfromCode(errorCode: cQuery.errorType),
              ),
              actions: [
                PlatformDialogAction(
                    child: Text(
                      _localizations.translate('okey'),
                      style:
                          GoogleFonts.montserrat(color: GlobalColors.appColor),
                    ),
                    onPressed: () {
                      if (cQuery.errorType == 0) {
                        Phoenix.rebirth(context);
                      } else {
                        Navigator.of(context).pop();
                      }
                    })
              ]),
        );
      }
    } else {
      _showPasswordError();
    }
  }

  void _showPasswordError() {
    showPlatformDialog(
        context: context,
        builder: (context) => GlobalWidgets.customPlatformDialog(
                title: _localizations.translate('register_error'),
                content: _localizations.translate('passwords_dont_match'),
                actions: [
                  PlatformDialogAction(
                      child: Text(
                        _localizations.translate('try_again'),
                        style: GoogleFonts.montserrat(
                            color: GlobalColors.appColor),
                      ),
                      onPressed: () {
                        setState(() {
                          isQueryable = false;
                        });
                        Navigator.of(context).pop();
                      })
                ]));
  }

  void _execHomeScreen() {
    Navigator.of(context).pushAndRemoveUntil(
        platformPageRoute(context: context, builder: (context) => HomeScreen()),
        (route) => false);
  }

  double screenHeight(BuildContext context,
      {double dividedBy = 1, double reducedBy = 0.0}) {
    return (MediaQuery.of(context).size.height - reducedBy) / dividedBy;
  }

  double screenHeightExcludingToolbar(BuildContext context,
      {double dividedBy = 1}) {
    return screenHeight(context,
        dividedBy: dividedBy, reducedBy: kToolbarHeight);
  }

  void _execPrivacyPage() async {
    const url = 'http://www.tedariksagla.com/privacy/';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
