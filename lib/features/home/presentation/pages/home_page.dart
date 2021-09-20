import 'dart:async';

import 'package:desafio/features/authentication/presentation/pages/login_page.dart';
import 'package:desafio/features/home/data/models/position.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:loading/loading.dart';
import 'package:sqflite/sqflite.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:path/path.dart';
import 'package:collection/collection.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? user = FirebaseAuth.instance.currentUser;
  double _latitude = 0.0;
  double _longitude = 0.0;
  bool _loading = true;

  @override
  void initState() {
    _determinePosition();
    findAll();
    super.initState();
  }

  Completer<GoogleMapController> _controller = Completer();

  List<PositionUser>? listPositionUser = [];

  late CameraPosition _kGooglePlex;

  late CameraPosition _kLake;

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  void _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then(
      (position) => setState(
        () {
          _latitude = position.latitude;
          _longitude = position.longitude;
          _kGooglePlex = CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 14.4746,
          );
          _kLake = CameraPosition(
              bearing: 192.8334901395799,
              target: LatLng(position.latitude, position.longitude),
              tilt: 59.440717697143555,
              zoom: 19.151926040649414);
          _loading = false;
        },
      ),
    );
  }

  Future<void> _goToTheLake() async {
    _determinePosition();
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
    save(user!.uid, _latitude.toString(), _longitude.toString());
  }

  Future<Database> createDatabase() {
    return getDatabasesPath().then(
      (dbPath) {
        final String path = join(dbPath, 'challenge.db');
        return openDatabase(
          path,
          onDowngrade: onDatabaseDowngradeDelete,
          onCreate: (db, version) {
            db.execute('CREATE TABLE position('
                'id INTEGER PRIMARY KEY, '
                'latitude TEXT, '
                'longitude TEXT, '
                'uuid TEXT)');
          },
          version: 1,
        );
      },
    );
  }

  void findAll() {
    createDatabase().then((db) {
      return db.query('position').then((maps) {
        List<PositionUser>? positions = <PositionUser>[];
        for (Map<String, dynamic> map in maps) {
          final PositionUser position = PositionUser(
              uuid: map['uuid'],
              latitude: map['latitude'],
              longitude: map['longitude']);
          positions.add(position);
        }
        return positions;
      });
    }).then(
      (list) => list.forEach(
        (element) {
          listPositionUser!.add(element);
        },
      ),
    );
  }

  Future<int> save(String uuid, String latitude, String longitude) {
    return createDatabase().then(
      (db) {
        final Map<String, dynamic> positionUser = Map();
        positionUser['uuid'] = uuid;
        positionUser['latitude'] = latitude;
        positionUser['longitude'] = longitude;
        return db.insert('position', positionUser);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SafeArea(
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.directions_car)),
                Tab(icon: Icon(Icons.directions_transit)),
              ],
            ),
          ),
          backgroundColor: Colors.white,
          body: TabBarView(
            children: [
              _buildTabMap(context, size),
              _buildTabList(context, size),
            ],
          ),
          floatingActionButton: !_loading
              ? FloatingActionButton.extended(
                  onPressed: _goToTheLake,
                  label: Text('Go the positon'),
                  icon: Icon(Icons.location_on),
                )
              : Container(),
        ),
      ),
    );
  }

  Widget _buildTabMap(BuildContext context, Size size) {
    return Container(
      height: size.height,
      width: size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
            ),
            onPressed: () async {
              _signOut(context);
            },
            child: Text(
              'Logout',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
          Text('Latitude: ' + _latitude.toString()),
          Text('Longitude: ' + _longitude.toString()),
          _buildMap(),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
        child: !_loading
            ? GoogleMap(
                mapType: MapType.hybrid,
                initialCameraPosition: _kGooglePlex,
                onMapCreated: (GoogleMapController controller) {
                  if (!_controller.isCompleted) {
                    _controller.complete(controller);
                  }
                },
              )
            : Container(
                color: Colors.white,
                child: Center(
                  child: Loading(
                      indicator: BallPulseIndicator(),
                      size: 100.0,
                      color: Colors.blue),
                ),
              ),
      ),
    );
  }

  Widget _buildTabList(BuildContext context, Size size) {
    return Container(
      height: size.height,
      width: size.width,
      child: Table(
        defaultColumnWidth: FixedColumnWidth(150.0),
        border: TableBorder(
          horizontalInside: BorderSide(
            color: Colors.black,
            style: BorderStyle.solid,
            width: 1.0,
          ),
          verticalInside: BorderSide(
            color: Colors.black,
            style: BorderStyle.solid,
            width: 1.0,
          ),
        ),
        children: [
          _criarLinhaTable('ID, Latitude, Longitude'),
          for(int i = 0;i<listPositionUser!.length;i++) _criarLinhaTable(listPositionUser![i].uuid + "," + listPositionUser![i].latitude + "," + listPositionUser![i].longitude),
        ],
      ),
    );
  }

  _criarLinhaTable(String listaNomes) {
    return TableRow(
      children: listaNomes.split(',').map((name) {
        return Container(
          alignment: Alignment.center,
          child: Text(
            name,
            style: TextStyle(fontSize: 20.0),
          ),
          padding: EdgeInsets.all(8.0),
        );
      }).toList(),
    );
  }
}
