import 'package:aparte/services/database.dart';
import 'package:aparte/services/shared_preferences.dart';
import 'package:aparte/services/widget_support.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Booking extends StatefulWidget {
  const Booking({super.key});

  @override
  State<Booking> createState() => _BookingState();
}

class _BookingState extends State<Booking> {
  String? id;
  Stream? bookingStream;
  getontheLoad() async {
    id = await SharedpreferenceHelper().getUserId();
    bookingStream = await DatabaseMethods().getUserbooking(id!);
    print('Userid: $id');
    setState(() {});
  }

  bool incoming = true, past = false;
  @override
  void initState() {
    getontheLoad();
    super.initState();
  }

  Widget allUserBookings() {
    return StreamBuilder(
      stream: bookingStream,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.docs[index];
                  final format = DateFormat('dd, MMM yyyy');
                  final date = format.parse(ds['Checkin']);
                  final now = DateTime.now();
                  return date.isBefore(now) && past
                      ? Container(
                          margin: EdgeInsets.only(bottom: 20.0),
                          child: Material(
                            elevation: 1.5,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: EdgeInsets.all(10.0),
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                color: Color(0xFFececf8),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(30),
                                    child: Image.asset(
                                      'images/hotel1.jpg',
                                      height: 120.0,
                                      width: 120,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  SizedBox(width: 10.0),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.hotel,
                                            color: Colors.blue,
                                            size: 30.0,
                                          ),
                                          SizedBox(width: 8.0),
                                          Text(
                                            ds['Hotelname'],
                                            style: AppWidget.normaltextstyle(
                                              20.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5.0),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_month,
                                            color: Colors.blue,
                                            size: 30.0,
                                          ),
                                          SizedBox(width: 8.0),
                                          SizedBox(
                                            width:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width /
                                                3,
                                            child: Text(
                                              ds['Checkin'] +
                                                  '-' +
                                                  ds['Checkout'],
                                              style: AppWidget.normaltextstyle(
                                                17.0,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5.0),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.group,
                                            color: Colors.blue,
                                            size: 30.0,
                                          ),
                                          SizedBox(width: 8.0),

                                          Text(
                                            ds['Guests'],
                                            style: AppWidget.headlinetextstyle(
                                              20.0,
                                            ),
                                          ),
                                          SizedBox(width: 10.0),
                                          Icon(
                                            Icons.monetization_on,
                                            color: Colors.blue,
                                            size: 30.0,
                                          ),
                                          SizedBox(width: 8.0),
                                          Text(
                                            '\$' + ds['Total'],
                                            style: AppWidget.headlinetextstyle(
                                              20.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : date.isAfter(now) && incoming
                      ? Container(
                          margin: EdgeInsets.only(bottom: 20.0),
                          child: Material(
                            elevation: 1.5,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: EdgeInsets.all(10.0),
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                color: Color(0xFFececf8),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(30),
                                    child: Image.asset(
                                      'images/hotel1.jpg',
                                      height: 120.0,
                                      width: 120,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  SizedBox(width: 10.0),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.hotel,
                                            color: Colors.blue,
                                            size: 30.0,
                                          ),
                                          SizedBox(width: 8.0),
                                          Text(
                                            ds['Hotelname'],
                                            style: AppWidget.normaltextstyle(
                                              20.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5.0),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_month,
                                            color: Colors.blue,
                                            size: 30.0,
                                          ),
                                          SizedBox(width: 8.0),
                                          SizedBox(
                                            width:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width /
                                                3,
                                            child: Text(
                                              ds['Checkin'] +
                                                  '-' +
                                                  ds['Checkout'],
                                              style: AppWidget.normaltextstyle(
                                                17.0,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5.0),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.group,
                                            color: Colors.blue,
                                            size: 30.0,
                                          ),
                                          SizedBox(width: 8.0),

                                          Text(
                                            ds['Guests'],
                                            style: AppWidget.headlinetextstyle(
                                              20.0,
                                            ),
                                          ),
                                          SizedBox(width: 10.0),
                                          Icon(
                                            Icons.monetization_on,
                                            color: Colors.blue,
                                            size: 30.0,
                                          ),
                                          SizedBox(width: 8.0),
                                          Text(
                                            '\$' + ds['Total'],
                                            style: AppWidget.headlinetextstyle(
                                              20.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : Container();
                },
              )
            : Container();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('Booking', style: AppWidget.headlinetextstyle(40.0)),
        ),
      ),
      body: Container(
        margin: EdgeInsets.only(left: 20.0, right: 20.0),
        child: Column(
          children: [
            Row(
              children: [
                incoming
                    ? Material(
                        elevation: 3.0,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: EdgeInsets.all(10.0),
                          width: 200,
                          decoration: BoxDecoration(
                            color: const Color(0xFFececf8),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Image.asset(
                                'images/incomingbooking.png',
                                height: 120,
                                width: 120,
                                fit: BoxFit.cover,
                              ),
                              Text(
                                'Incoming\nBooking ',
                                style: AppWidget.headlinetextstyle(20.0),
                              ),
                            ],
                          ),
                        ),
                      )
                    : GestureDetector(
                        onTap: () {
                          setState(() {
                            incoming = true;
                            past = false;
                          });
                        },
                        child: Container(
                          width: 150,
                          padding: EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFFececf8),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Image.asset(
                                'images/incomingbooking.png',
                                height: 120,
                                width: 120,
                                fit: BoxFit.cover,
                              ),
                              Text(
                                'incoming\nBooking ',
                                style: AppWidget.normaltextstyle(20.0),
                              ),
                            ],
                          ),
                        ),
                      ),
                SizedBox(width: 20.0),
                past
                    ? Material(
                        elevation: 3.0,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: EdgeInsets.all(10.0),
                          width: 200,
                          decoration: BoxDecoration(
                            color: const Color(0xFFececf8),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Image.asset(
                                'images/pastbooking.png',
                                height: 120,
                                width: 120,
                                fit: BoxFit.cover,
                              ),
                              Text(
                                'past\nBooking ',
                                style: AppWidget.headlinetextstyle(20.0),
                              ),
                            ],
                          ),
                        ),
                      )
                    : GestureDetector(
                        onTap: () {
                          setState(() {
                            past = true;
                            incoming = false;
                          });
                        },
                        child: Container(
                          width: 150,
                          padding: EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFFececf8),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Image.asset(
                                'images/pastbooking.png',
                                height: 120,
                                width: 120,
                                fit: BoxFit.cover,
                              ),
                              Text(
                                'Past\nBooking ',
                                style: AppWidget.normaltextstyle(20.0),
                              ),
                            ],
                          ),
                        ),
                      ),
              ],
            ),
            SizedBox(height: 30.0),
            Container(
              height: MediaQuery.of(context).size.width / 1,

              child: allUserBookings(),
            ),
          ],
        ),
      ),
    );
  }
}
