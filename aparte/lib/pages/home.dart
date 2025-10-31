import 'dart:async';

import 'package:aparte/pages/city_hotel.dart';
import 'package:aparte/pages/detail_page.dart';
import 'package:aparte/services/database.dart';
import 'package:aparte/services/location.dart';
import 'package:aparte/services/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:aparte/services/widget_support.dart';
import 'package:geolocator/geolocator.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Stream? hotelStream;
  StreamSubscription<Position>? _positionSubscription;

  String locationLabel = 'Nigeria, Lagos';

  getontheload() async {
    hotelStream = await DatabaseMethods().getallHotels();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getontheload();
    getCityCounts();
    _startLocationTracking;
  }

  Future<void> _startLocationTracking() async {
    final userId = await SharedpreferenceHelper().getUserId();
    if (userId != null && userId.isNotEmpty) {
      await LocationService().startTracking(userId, distanceFilterMeters: 20);
      print('LocationService write started for $userId');
    }

    final locationSettings = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 20,
    );

    _positionSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position pos) {
            setState(() {
              locationLabel =
                  '${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}';
            });
          },
          onError: (e) {
            print('Position stream error: $e');
          },
        );
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    LocationService().stopTracking();
    super.dispose();
  }

  int? lagoscount, abujacitycount, benincitycount, anambracount;
  Future<void> getCityCounts() async {
    final firestore = FirebaseFirestore.instance;

    //Count documents where city == 'abuja city'
    final abujacityQuerySnapshot = await firestore
        .collection('Hotel')
        .where('HotelCity', isEqualTo: 'abujacity')
        .get();

    abujacitycount = abujacityQuerySnapshot.docs.length;

    //Count documents where city == 'lagos'

    final lagosQuerySnapshot = await firestore
        .collection('Hotel')
        .where('HotelCity', isEqualTo: 'lagos')
        .get();

    lagoscount = lagosQuerySnapshot.docs.length;

    final benincityQuerySnapshot = await firestore
        .collection('Hotel')
        .where('HotelCity', isEqualTo: 'benincity')
        .get();

    benincitycount = benincityQuerySnapshot.docs.length;

    final anambraQuerySnapshot = await firestore
        .collection('Hotel')
        .where('HotelCity', isEqualTo: 'anambra')
        .get();

    anambracount = anambraQuerySnapshot.docs.length;

    print('Number of hotels in lagos: $lagoscount');
    print('Number of hotels in abujacity: $abujacitycount');
    print('Number of hotels in benincity: $benincitycount');
    print('Number of hotels in anambra: $anambracount');
  }

  Widget allHotels() {
    return StreamBuilder(
      stream: hotelStream,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.docs[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailPage(
                            image: ds['Image'],
                            bathroom: ds["Bathroom"],
                            desc: ds["HotelDesc"],
                            hdtv: ds["HDTV"],
                            kitchen: ds["Kitchen"],
                            name: ds["HotelName"],
                            price: ds["HotelCharges"],
                            wifi: ds["WIFI"],
                            hotelid: ds.id,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.only(left: 20.0, bottom: 5.0),
                      child: Material(
                        elevation: 2.0,
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(30.0),
                                child: Image.asset(
                                  ds['Image'],
                                  width:
                                      MediaQuery.of(context).size.width / 1.3,
                                  fit: BoxFit.cover,
                                  height: 230,
                                ),
                              ),
                              SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.only(left: 20.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      ds["HotelName"],
                                      style: AppWidget.headlinetextstyle(22),
                                    ),
                                    SizedBox(
                                      width:
                                          MediaQuery.of(context).size.width / 4,
                                    ),

                                    Text(
                                      '\$${ds["HotelCharges"]}',
                                      style: AppWidget.headlinetextstyle(25.0),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 5.0),
                              Padding(
                                padding: const EdgeInsets.only(left: 20.0),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      color: Colors.blue,
                                      size: 30.0,
                                    ),
                                    SizedBox(width: 5.0),
                                    Text(
                                      ds['HotelAddress'],
                                      style: AppWidget.normaltextstyle(20.0),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              )
            : Container();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(242, 255, 255, 255),
      body: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                      child: Image.asset(
                        "images/lags.jpg",
                        width: MediaQuery.of(context).size.width,
                        height: 250,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 250,
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.location_on, color: Colors.white),
                                SizedBox(width: 18.0),
                                Text(
                                  locationLabel,
                                  style: AppWidget.whitetextstyle(20.0),
                                ),
                              ],
                            ),
                            SizedBox(height: 25.0),
                            Text(
                              'Hey, Emma! Tell us where you want to go',
                              style: AppWidget.whitetextstyle(20.0),
                            ),
                            SizedBox(height: 25.0),
                            Container(
                              padding: EdgeInsets.only(bottom: 5.0, top: 5.0),
                              //margin: EdgeInsets.only(right: 10.0),
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(79, 255, 255, 255),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: TextField(
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: Colors.white,
                                  ),
                                  hintText: 'Search places.......',
                                  hintStyle: AppWidget.whitetextstyle(20.0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.0),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'The most relevant',
                    style: AppWidget.headlinetextstyle(22.0),
                  ),
                ),
                SizedBox(height: 20.0),
                SizedBox(height: 320, child: allHotels()),
                SizedBox(height: 20.0),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Text(
                    'Discover New Places ',
                    style: AppWidget.headlinetextstyle(22.0),
                  ),
                ),
                SizedBox(height: 20.0),
                Container(
                  margin: EdgeInsets.only(left: 20.0),

                  height: 280,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CityHotel(city: 'Abuja City'),
                            ),
                          );
                        },
                        child: Container(
                          margin: EdgeInsets.only(bottom: 10.0),
                          child: Material(
                            elevation: 3.0,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadiusGeometry.circular(
                                      20,
                                    ),
                                    child: Image.asset(
                                      'images/Abuja.jpg',
                                      height: 200,
                                      width: 200,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  SizedBox(height: 10.0),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20.0),
                                    child: Text(
                                      'Abuja City',
                                      style: AppWidget.headlinetextstyle(20.0),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20.0),
                                    child: Row(
                                      children: [
                                        Icon(Icons.hotel, color: Colors.blue),
                                        SizedBox(width: 5.0),
                                        Text(
                                          '${abujacitycount ?? 0} Hotels',
                                          style: AppWidget.normaltextstyle(
                                            18.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CityHotel(city: 'Benin City'),
                            ),
                          );
                        },
                        child: Container(
                          margin: EdgeInsets.only(left: 20, bottom: 10),
                          child: Material(
                            elevation: 3.0,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadiusGeometry.circular(
                                      20,
                                    ),
                                    child: Image.asset(
                                      'images/Benin.jpg',
                                      height: 200,
                                      width: 200,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  SizedBox(height: 10.0),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20.0),
                                    child: Text(
                                      'Benin City',
                                      style: AppWidget.headlinetextstyle(20.0),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20.0),
                                    child: Row(
                                      children: [
                                        Icon(Icons.hotel, color: Colors.blue),
                                        SizedBox(width: 5.0),
                                        Text(
                                          '${benincitycount ?? 0} Hotels',
                                          style: AppWidget.normaltextstyle(
                                            18.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 20, bottom: 10),
                        child: Material(
                          elevation: 3.0,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadiusGeometry.circular(
                                    20,
                                  ),
                                  child: Image.asset(
                                    'images/Anambra.jpg',
                                    height: 200,
                                    width: 200,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(height: 10.0),
                                Padding(
                                  padding: const EdgeInsets.only(left: 20.0),
                                  child: Text(
                                    'Anambra City',
                                    style: AppWidget.headlinetextstyle(20.0),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 20.0),
                                  child: Row(
                                    children: [
                                      Icon(Icons.hotel, color: Colors.blue),
                                      SizedBox(width: 5.0),
                                      Text(
                                        '${anambracount ?? 0} Hotels',
                                        style: AppWidget.normaltextstyle(18.0),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 20, bottom: 10),
                        child: Material(
                          elevation: 3.0,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadiusGeometry.circular(
                                    20,
                                  ),
                                  child: Image.asset(
                                    'images/lagos.jpg',
                                    height: 200,
                                    width: 200,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(height: 10.0),
                                Padding(
                                  padding: const EdgeInsets.only(left: 20.0),
                                  child: Text(
                                    'Lagos City',
                                    style: AppWidget.headlinetextstyle(20.0),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 20.0),
                                  child: Row(
                                    children: [
                                      Icon(Icons.hotel, color: Colors.blue),
                                      SizedBox(width: 5.0),
                                      Text(
                                        '${lagoscount ?? 0} Hotels',
                                        style: AppWidget.normaltextstyle(18.0),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
