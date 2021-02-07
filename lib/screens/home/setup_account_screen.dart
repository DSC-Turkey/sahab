import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sahab/extensions/app_localizations.dart';
import 'package:sahab/extensions/global_colors.dart';
import 'package:sahab/extensions/global_styles.dart';
import 'package:sahab/viewmodels/account_provider.dart';
import 'package:sahab/widgets/custom_textfield.dart';
import 'package:sahab/widgets/global_widgets.dart';

class SetupAccountScreen extends StatefulWidget {
  @override
  _SetupAccountScreenState createState() => _SetupAccountScreenState();
}

class _SetupAccountScreenState extends State<SetupAccountScreen> {
  AppLocalizations _localizations;
  AccountProvider _accountProvider;
  TextEditingController _nameController;
  TextEditingController _ageController;
  TextEditingController _jobController;
  TextEditingController _instagramController;
  TextEditingController _twitterController;
  TextEditingController _linkedinController;
  bool isValid = false;
  bool lastValid = false;

  @override
  void initState() {
    _nameController = TextEditingController();
    _ageController = TextEditingController();
    _jobController = TextEditingController();
    _instagramController = TextEditingController();
    _twitterController = TextEditingController();
    _linkedinController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _localizations = AppLocalizations.of(context);
    _accountProvider = Provider.of<AccountProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _appBar,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                title: _localizations.translate('name_surname'),
                prefix: Icon(
                  EvaIcons.personOutline,
                  color: Colors.black,
                ),
                onChanged: _checkValid,
                controller: _nameController,
              ),
              CustomTextField(
                title: _localizations.translate('age'),
                prefix: Icon(
                  EvaIcons.person,
                  color: Colors.black,
                ),
                onChanged: _checkValid,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                controller: _ageController,
              ),
              CustomTextField(
                  title: _localizations.translate('job'),
                  prefix: Icon(
                    EvaIcons.briefcaseOutline,
                    color: Colors.black,
                  ),
                  onChanged: _checkValid,
                  controller: _jobController),
              CustomTextField(
                title: _localizations.translate('instagram'),
                prefix: Icon(
                  FontAwesomeIcons.instagram,
                  color: Colors.black,
                ),
                controller: _instagramController,
              ),
              CustomTextField(
                title: _localizations.translate('twitter'),
                prefix: Icon(
                  FontAwesomeIcons.twitter,
                  color: Colors.black,
                ),
                controller: _twitterController,
              ),
              CustomTextField(
                title: _localizations.translate('linkedin'),
                prefix: Icon(
                  FontAwesomeIcons.linkedin,
                  color: Colors.black,
                ),
                controller: _linkedinController,
              ),
              Text(
                _localizations.translate('setup_account_explain'),
                style: GlobalStyles.defaultBodyTextStyle(),
              ),
              SizedBox(
                height: 24,
              ),
              GlobalWidgets.defaultButton(
                onTap: isValid ? _saveInformations : null,
                color: isValid ? GlobalColors.appColor : Colors.grey,
                content: Text(
                  _localizations.translate('save'),
                  style: GlobalStyles.defaultListTileTitleTextStyle(
                      textColor: isValid ? Colors.white : Colors.black87),
                ),
              ),
              SizedBox(
                height: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget get _appBar => AppBar(
        title: Text(
          _localizations.translate('account_information'),
          style: GlobalStyles.defaultAppBarTitleTextStyle(),
        ),
        centerTitle: false,
        elevation: 0,
      );

  void _checkValid(String text) {
    if (_nameController.text.isNotEmpty &&
        _ageController.text.isNotEmpty &&
        _jobController.text.isNotEmpty) {
      isValid = true;
    } else {
      isValid = false;
    }

    if (isValid != lastValid) {
      setState(() {
        lastValid = isValid;
      });
    }
  }

  void _saveInformations() async {
    var result = await _accountProvider.updateInformations(
        userId: _accountProvider.currentUserId,
        name: _nameController.text,
        age: _ageController.text,
        job: _jobController.text,
        instagram: _instagramController.text,
        twitter: _twitterController.text,
        linkedin: _linkedinController.text);

    if (result != null && result) {
      Navigator.of(context).pop();
    }
  }
}
