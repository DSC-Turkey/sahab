import 'dart:async';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sahab/extensions/app_localizations.dart';
import 'package:sahab/extensions/global_colors.dart';
import 'package:sahab/extensions/global_styles.dart';
import 'package:sahab/models/account.dart';
import 'package:sahab/screens/explore/explore_screen.dart';
import 'package:sahab/screens/home/setup_account_screen.dart';
import 'package:sahab/viewmodels/account_provider.dart';
import 'package:sahab/widgets/avatar.dart';
import 'package:sahab/widgets/global_widgets.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AppLocalizations _localizations;
  AccountProvider _accountProvider;
  List<Account> _allAccounts = [];
  double bodyHeight;
  String _mapStyle;
  GoogleMapController _mapController;

  static final CameraPosition _sauLocation = CameraPosition(
    tilt: 90,
    target: LatLng(40.742037, 30.3305423),
    zoom: 14.4746,
  );

  @override
  void initState() {
    rootBundle.loadString('assets/styles/map_style.txt').then((value) {
      _mapStyle = value;
    });

    Future.microtask(() {
      if (_accountProvider.currentAccount.geoPoint != null) {
        _fetchUsers();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _localizations = AppLocalizations.of(context);
    _accountProvider = Provider.of<AccountProvider>(context);
    bodyHeight = screenHeightExcludingToolbar(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _appBar,
      body: _accountProvider.currentAccount != null
          ? RefreshIndicator(
              onRefresh: _refreshScreen,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                clipBehavior: Clip.none,
                child: _accountProvider.currentAccount.nameAndSurname != null
                    ? _dashboard
                    : _setupAccountBox,
              ),
            )
          : Container(
              child: Center(
                child: PlatformCircularProgressIndicator(),
              ),
            ),
    );
  }

  Widget get _appBar => AppBar(
        title: Text(
          _localizations.translate('home_screen'),
          style: GlobalStyles.defaultAppBarTitleTextStyle(),
        ),
        centerTitle: false,
        elevation: 0,
        actions: [
          PlatformIconButton(
            onPressed: _signOut,
            icon: Icon(EvaIcons.logOut, color: GlobalColors.appColor),
          ),
        ],
      );

  Widget get _dashboard => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                children: [
                  Avatar(_accountProvider.currentAccount.avatar, 50),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            _accountProvider.currentAccount.nameAndSurname,
                            style: GlobalStyles.defaultListTileTitleTextStyle(
                                fontSize: 16),
                          ),
                          Text(
                            _accountProvider.currentAccount.job,
                            style: GlobalStyles.defaultBodyTextStyle(),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            Row(
              children: [
                /*
                Expanded(
                  child: GlobalWidgets.defaultButton(
                    color: Colors.grey[500],
                    content: Text(
                      _localizations.translate('edit_informations'),
                      style: GlobalStyles.defaultBodyTextStyle(
                          textColor: Colors.white),
                    ),
                  ),
                ),
                SizedBox(
                  width: 8.0,
                ),
                */
                Expanded(
                  child: GlobalWidgets.defaultButton(
                    onTap: _updateLocation,
                    color: Colors.grey[500],
                    content: Text(
                      _localizations.translate('update_location'),
                      style: GlobalStyles.defaultBodyTextStyle(
                          textColor: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 2.0),
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Icon(
                    EvaIcons.pinOutline,
                    color: Colors.blue,
                    size: 16,
                  ),
                  Text(
                    '${_localizations.translate('last_location')}',
                    style: GlobalStyles.defaultListTileTitleTextStyle(
                        fontSize: 12),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: InkWell(
                onTap: _execMapScreen,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Hero(
                          tag: 'map',
                          child: IgnorePointer(
                            ignoring: true,
                            child: GoogleMap(
                              myLocationButtonEnabled: false,
                              compassEnabled: false,
                              scrollGesturesEnabled: false,
                              rotateGesturesEnabled: false,
                              zoomControlsEnabled: false,
                              zoomGesturesEnabled: false,
                              mapType: MapType.normal,
                              initialCameraPosition: _getCurrentCamera(),
                              onMapCreated: (GoogleMapController controller) {
                                _mapController = controller;
                                controller.setMapStyle(_mapStyle);
                              },
                              markers: _getCurrentMarker(),
                            ),
                          ),
                        ),
                        Positioned(
                          child: Container(
                            width: double.infinity,
                            color: GlobalColors.appColor,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _localizations.translate('go_explore'),
                                      style: GlobalStyles.defaultTitleTextStyle(
                                          textColor: Colors.white),
                                    ),
                                  ),
                                  Card(
                                    margin: EdgeInsets.zero,
                                    shape: CircleBorder(),
                                    color: Colors.white,
                                    elevation: 4.0,
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Icon(
                                        EvaIcons.chevronRightOutline,
                                        color: GlobalColors.appColor,
                                        size: 24,
                                      ),
                                    ),
                                  )
                                  /*
                                  Icon(EvaIcons.chevronRightOutline,
                                      color: Colors.white)*/
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Icon(
                    EvaIcons.peopleOutline,
                    color: Colors.blue,
                    size: 16,
                  ),
                  Text(
                    '${_localizations.translate('nearby_accounts')}',
                    style: GlobalStyles.defaultListTileTitleTextStyle(
                        fontSize: 12),
                  ),
                ],
              ),
            ),
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: _allAccounts.length,
              itemBuilder: (context, index) => _singleCard(_allAccounts[index]),
            ),
          ],
        ),
      );

  Widget get _setupAccountBox => Container(
        height: bodyHeight,
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              EvaIcons.personOutline,
              size: 64,
            ),
            SizedBox(
              height: 8,
            ),
            Text(
              _localizations.translate('no_account_setup'),
              style: GlobalStyles.defaultListTileTitleTextStyle(),
            ),
            Text(
              _localizations.translate('last_step'),
              style: GlobalStyles.defaultListTileDescriptionTextStyle(),
            ),
            SizedBox(
              height: 16,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GlobalWidgets.defaultButton(
                  onTap: _execSetupAccountScreen,
                  content: Text(_localizations.translate('setup_account'),
                      style: GlobalStyles.defaultListTileTitleTextStyle(
                        textColor: Colors.white,
                      ))),
            )
          ],
        ),
      );

  CameraPosition _getCurrentCamera() {
    if (_accountProvider.currentAccount.geoPoint != null) {
      return CameraPosition(
        tilt: 90,
        target: LatLng(_accountProvider.currentAccount.geoPoint.latitude,
            _accountProvider.currentAccount.geoPoint.longitude),
        zoom: 14.0,
      );
    } else {
      return _sauLocation;
    }
  }

  void _signOut() async {
    var response = await _accountProvider.signOut();
    if (response) {
      Phoenix.rebirth(context);
    }
  }

  Future<void> _refreshScreen() {
    return Future.value(null);
  }

  double screenHeight(BuildContext context,
      {double dividedBy = 1, double reducedBy = 0.0}) {
    return (MediaQuery.of(context).size.height - reducedBy) / dividedBy;
  }

  double screenHeightExcludingToolbar(BuildContext context,
      {double dividedBy = 1}) {
    var statusBarHeight = MediaQuery.of(context).padding.bottom;
    return screenHeight(context,
            dividedBy: dividedBy, reducedBy: kToolbarHeight) -
        statusBarHeight;
  }

  void _execSetupAccountScreen() {
    Navigator.of(context).push(platformPageRoute(
        context: context,
        builder: (context) => SetupAccountScreen(),
        fullscreenDialog: true));
  }

  void _execMapScreen() {
    Navigator.of(context).push(platformPageRoute(
        context: context, builder: (context) => ExploreScreen()));
  }

  Set<Marker> _getCurrentMarker() {
    if (_accountProvider.currentAccount.geoPoint != null) {
      return {
        Marker(
            markerId: MarkerId(_accountProvider.currentUserId),
            position: LatLng(_accountProvider.currentAccount.geoPoint.latitude,
                _accountProvider.currentAccount.geoPoint.latitude))
      };
    } else {
      return {
        Marker(
          markerId: MarkerId(_accountProvider.currentUserId),
          position: LatLng(40.742037, 30.3305423),
        )
      };
    }
  }

  void _updateLocation() async {
    var result = await _accountProvider.updateUsersLastGeoPoint(
        userId: _accountProvider.currentUserId);

    if (result != null && result) {
      setState(() {
        _mapController
            .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          tilt: 90,
          target: LatLng(_accountProvider.currentAccount.geoPoint.latitude,
              _accountProvider.currentAccount.geoPoint.longitude),
          zoom: 14.0,
        )));
      });
    }
  }

  void _fetchUsers() async {
    var accountList = await _accountProvider.getNearbyUsers(
        userId: _accountProvider.currentUserId,
        geoPoint: _accountProvider.currentAccount.geoPoint);

    if (accountList != null) {
      setState(() {
        _allAccounts = accountList;
      });
    }
    print(_allAccounts);
  }

  Widget _singleCard(Account cAccount) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Avatar(cAccount.avatar, 30),
      title: Text(cAccount.nameAndSurname,
          style: GlobalStyles.defaultListTileTitleTextStyle()),
      subtitle: Text('${cAccount.job} - ${cAccount.age}',
          style: GlobalStyles.defaultListTileDescriptionTextStyle()),
    );
  }
}
