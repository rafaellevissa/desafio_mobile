import 'dart:async';

import 'package:desafio/features/authentication/presentation/pages/login_page.dart';
import 'package:desafio/features/home/data/models/position.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:path/path.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  User? user = FirebaseAuth.instance.currentUser;
  double _latitude = 0.0;
  double _longitude = 0.0;
  bool _loading = true;

  late TabController _tabController;

  int _currentTab = 0;

  final Completer<GoogleMapController> _controller = Completer();

  List<PositionUser>? listPositionUser = [];

  late CameraPosition _kGooglePlex;

  @override
  void initState() {
    super.initState();
    _determinePosition();
    findAll();
    _tabController = TabController(vsync: this, length: 2);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  Future<void> _sendAnalyticsEvent(BuildContext context) async {
    FirebaseAnalytics analytics = Provider.of<FirebaseAnalytics>(context);
    await analytics.logEvent(
      name: 'render_map',
      parameters: <String, dynamic>{
        'uuid': user!.uid,
        'renderized': true,
      },
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
            zoom: 17.151926040649414,
          );
          _loading = false;
          save(
            user!.uid,
            position.latitude.toString(),
            position.longitude.toString(),
          );
        },
      ),
    );
  }

  Future<void> _goToThePosition() async {
    _determinePosition();
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

    if(!_loading) _sendAnalyticsEvent(context);

    return SafeArea(
      child: DefaultTabController(
        length: 2,
        child: Builder(
          builder: (BuildContext context) {
            final TabController tabController =
                DefaultTabController.of(context)!;
            tabController.addListener(() {
              if (!tabController.indexIsChanging) {
                setState(() {
                  _currentTab = tabController.index;
                });
                if (tabController.index == 1) {
                  findAll();
                }
              }
            });
            return Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                bottom: TabBar(
                  tabs: [
                    Tab(icon: Icon(Icons.location_on)),
                    Tab(icon: Icon(Icons.list)),
                  ],
                ),
              ),
              backgroundColor: Colors.white,
              body: TabBarView(
                physics: NeverScrollableScrollPhysics(),
                children: [
                  _buildTabMap(context, size),
                  _buildTabList(context, size),
                ],
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.startFloat,
              floatingActionButton: !_loading && _currentTab == 0
                  ? FloatingActionButton.extended(
                      onPressed: _goToThePosition,
                      label: Text('Get current position'),
                      icon: Icon(Icons.location_on),
                    )
                  : Container(),
            );
          },
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
                myLocationEnabled: true,
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
                  child: CircularProgressIndicator(color: Colors.blue),
                ),
              ),
      ),
    );
  }

  Widget _buildTabList(BuildContext context, Size size) {
    return SingleChildScrollView(
      child: Container(
        height: size.height,
        width: size.width,
        margin: EdgeInsets.only(left: 15, right: 15),
        child: Table(
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
            for (int i = 0; i < listPositionUser!.length; i++)
              _criarLinhaTable(listPositionUser![i].uuid +
                  "," +
                  listPositionUser![i].latitude +
                  "," +
                  listPositionUser![i].longitude),
          ],
        ),
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
