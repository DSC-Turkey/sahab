import 'dart:async';

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sahab/extensions/app_localizations.dart';
import 'package:sahab/extensions/global_styles.dart';
import 'package:sahab/models/account.dart';
import 'package:sahab/screens/home/profile_screen.dart';
import 'package:sahab/viewmodels/account_provider.dart';
import 'package:sahab/widgets/avatar.dart';

class ExploreScreen extends StatefulWidget {
  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  AccountProvider _accountProvider;
  AppLocalizations _localizations;
  List<Account> _allAccounts;
  String _mapStyle;
  GoogleMapController _mapController;
  List<Marker> markers = [];

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

    return Scaffold(
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          _allAccounts != null
              ? Hero(
                  tag: 'map',
                  child: GoogleMap(
                    myLocationButtonEnabled: false,
                    compassEnabled: false,
                    mapType: MapType.normal,
                    initialCameraPosition: _getCurrentCamera(),
                    onMapCreated: (GoogleMapController controller) {
                      _mapController = controller;
                      controller.setMapStyle(_mapStyle);
                    },
                    markers: _getCurrentMarker(),
                  ),
                )
              : Center(
                  child: PlatformCircularProgressIndicator(),
                ),
          Padding(
            padding: const EdgeInsets.only(top: 64.0, left: 16.0, right: 16.0),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              elevation: 8.0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Icon(
                        EvaIcons.chevronLeftOutline,
                        size: 40,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: _allAccounts != null
                  ? ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: 120),
                      child: PageView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _allAccounts.length,
                        controller: PageController(viewportFraction: 0.7),
                        onPageChanged: (index) {
                          var currentLatLng = LatLng(
                              _allAccounts[index].geoPoint.latitude,
                              _allAccounts[index].geoPoint.longitude);
                          _mapController.animateCamera(
                              CameraUpdate.newCameraPosition(CameraPosition(
                                  target: markers[index].position,
                                  zoom: 18,
                                  tilt: 90)));
                        },
                        itemBuilder: (context, index) =>
                            _singleCard(_allAccounts[index], index),
                      ),
                    )
                  : PlatformCircularProgressIndicator(),
            ),
          )
        ],
      ),
    );
  }

  Set<Marker> _getCurrentMarker() {
    var index = 0.000;

    for (var cAccount in _allAccounts) {
      index += 0.001;
      if (cAccount.geoPoint != null) {
        markers.add(
          Marker(
              markerId: MarkerId(cAccount.userId),
              position: LatLng(cAccount.geoPoint.latitude + index,
                  cAccount.geoPoint.longitude)),
        );
      }
    }
    print(markers.toSet());
    return markers.toSet();
  }

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

  Widget _singleCard(Account cAccount, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(platformPageRoute(
            context: context,
            builder: (context) => ProfileScreen(
                  account: cAccount,
                )));
      },
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Avatar(cAccount.avatar, 35),
              Expanded(
                  child: Center(
                child: Wrap(
                  direction: Axis.vertical,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 4.0,
                  runSpacing: 4.0,
                  children: [
                    Text(
                      cAccount.nameAndSurname,
                      textAlign: TextAlign.center,
                      style: GlobalStyles.defaultListTileTitleTextStyle(),
                    ),
                    Text(
                      '${cAccount.job} - ${cAccount.age}',
                      textAlign: TextAlign.center,
                      style: GlobalStyles.defaultListTileDescriptionTextStyle(),
                    ),
                  ],
                ),
              ))
            ],
          ),
        ),
      ),
    );
  }
}
