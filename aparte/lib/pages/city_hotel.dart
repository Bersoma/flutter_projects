import 'package:aparte/pages/detail_page.dart';
import 'package:aparte/services/database.dart';
import 'package:aparte/services/widget_support.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CityHotel extends StatefulWidget {
  String city;
  CityHotel({super.key, required this.city});

  @override
  State<CityHotel> createState() => _CityHotelState();
}

class _CityHotelState extends State<CityHotel> {
  Stream? cityStream;

  getontheload() async {
    cityStream = await DatabaseMethods().getUserCityHotel(widget.city);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getontheload();
  }

  Widget allHotels() {
    return StreamBuilder(
      stream: cityStream,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? ListView.builder(
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
                      margin: EdgeInsets.only(left: 20.0, bottom: 20.0),
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
                                  width: MediaQuery.of(context).size.width,
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

                                    Padding(
                                      padding: const EdgeInsets.only(
                                        right: 20.0,
                                      ),
                                      child: Text(
                                        '\$${ds["HotelCharges"]}',
                                        style: AppWidget.headlinetextstyle(
                                          25.0,
                                        ),
                                      ),
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
      appBar: AppBar(
        title: Text(widget.city, style: AppWidget.headlinetextstyle(28.0)),
      ),
      body: Container(margin: EdgeInsets.only(right: 20), child: allHotels()),
    );
  }
}
