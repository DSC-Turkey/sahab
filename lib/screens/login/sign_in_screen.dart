import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sahab/extensions/app_localizations.dart';
import 'package:sahab/extensions/error_management.dart';
import 'package:sahab/extensions/global_colors.dart';
import 'package:sahab/screens/home/home_screen.dart';
import 'package:sahab/screens/login/sign_up_screen.dart';
import 'package:sahab/viewmodels/account_provider.dart';
import 'package:sahab/widgets/custom_textfield.dart';
import 'package:sahab/widgets/global_widgets.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  AppLocalizations _localizations;
  AccountProvider _accountProvider;
  TextEditingController _emailController;
  TextEditingController _passwordController;
  bool isQueryable = false;

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
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
        _localizations.translate('sign_in'),
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

  Widget _submitButton() {
    return InkWell(
      borderRadius: BorderRadius.all(Radius.circular(5)),
      onTap: isQueryable && _accountProvider.state == AccountState.Idle
          ? _login
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
                _localizations.translate('sign_in'),
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
            context, MaterialPageRoute(builder: (context) => SignUpScreen()));
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20),
        padding: EdgeInsets.all(15),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _localizations.translate('dont_you_have_an_account'),
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              _localizations.translate('sign_up'),
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

    var passwordValid = _passwordController.text.length >= 6;

    setState(() {
      isQueryable = emailValid && passwordValid;
    });
  }

  void _login() async {
    var cQuery = await _accountProvider.signInWithEmailAndPassword(
        email: _emailController.text, password: _passwordController.text);

    if (cQuery.isSuccess) {
      _execHomeScreen();
    } else {
      await showPlatformDialog(
        context: context,
        builder: (context) => GlobalWidgets.customPlatformDialog(
            title: _localizations.translate('login_error'),
            content: _localizations.translate(
              ErrorManagement.getErrorfromCode(errorCode: cQuery.errorType),
            ),
            actions: [
              PlatformDialogAction(
                  child: Text(
                    _localizations.translate('okey'),
                    style: GoogleFonts.montserrat(color: GlobalColors.appColor),
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

  void _execHomeScreen() {
    Navigator.of(context).pushAndRemoveUntil(
        platformPageRoute(context: context, builder: (context) => HomeScreen()),
        (route) => false);
  }
}
