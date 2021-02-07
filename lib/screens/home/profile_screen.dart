import 'package:flutter/material.dart';
import 'package:sahab/extensions/app_localizations.dart';
import 'package:sahab/extensions/global_styles.dart';
import 'package:sahab/models/account.dart';
import 'package:sahab/widgets/avatar.dart';

class ProfileScreen extends StatefulWidget {
  final Account account;

  const ProfileScreen({Key key, this.account}) : super(key: key);
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  AppLocalizations _localizations;
  @override
  Widget build(BuildContext context) {
    _localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: _appBar,
      body: Container(
        child: Center(
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 8.0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Avatar(widget.account.avatar, 40),
                  Text(
                    widget.account.nameAndSurname,
                    style: GlobalStyles.defaultListTileTitleTextStyle(),
                  ),
                  Text(
                    widget.account.job,
                    style: GlobalStyles.defaultListTileTitleTextStyle(
                        fontSize: 14),
                  ),
                  Text(
                    widget.account.age,
                    style: GlobalStyles.defaultListTileDescriptionTextStyle(),
                  ),
                  Text(
                    widget.account.instagram != null
                        ? 'instagram : ${widget.account.instagram}'
                        : '',
                    style: GlobalStyles.defaultListTileDescriptionTextStyle(),
                  ),
                  Text(
                    widget.account.twitter != null
                        ? 'twitter : ${widget.account.twitter}'
                        : '',
                    style: GlobalStyles.defaultListTileDescriptionTextStyle(),
                  ),
                  Text(
                    widget.account.linkedIn != null
                        ? 'linkedIn : ${widget.account.linkedIn}'
                        : '',
                    style: GlobalStyles.defaultListTileDescriptionTextStyle(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget get _appBar => AppBar(
        title: Text(
          _localizations.translate('profile'),
          style: GlobalStyles.defaultAppBarTitleTextStyle(),
        ),
        centerTitle: false,
        elevation: 0,
      );
}
