import 'dart:io';

import 'package:aparte/hotelowner/owner_home.dart';
import 'package:aparte/services/database.dart';
import 'package:aparte/services/shared_preferences.dart';
import 'package:aparte/services/widget_support.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class HotelDetail extends StatefulWidget {
  const HotelDetail({super.key});

  @override
  State<HotelDetail> createState() => _HotelDetailState();
}

class _HotelDetailState extends State<HotelDetail> {
  bool isChecked = false;
  bool isChecked1 = false;
  bool isChecked2 = false;
  bool isChecked3 = false;

  String? id;

  getonthesharedpref() async {
    id = await SharedpreferenceHelper().getUserId();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getonthesharedpref();
  }

  File? selectedImage;
  final ImagePicker _picker = ImagePicker();

  TextEditingController hotelnamecontroller = TextEditingController();
  TextEditingController hotelchargescontroller = TextEditingController();
  TextEditingController hoteladdresscontroller = TextEditingController();
  TextEditingController hoteldescontroller = TextEditingController();
  TextEditingController hotelcitycontroller = TextEditingController();

  Future getImage() async {
    var image = await _picker.pickImage(source: ImageSource.gallery);
    selectedImage = File(image!.path);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Container(
        margin: EdgeInsets.only(top: 40.0),

        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Hotel Details',
                  style: AppWidget.boldwhitetextstyle(26.0),
                ),
              ],
            ),
            SizedBox(height: 20.0),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(left: 20.0, right: 20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                width: MediaQuery.of(context).size.width,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20.0),
                      selectedImage != null
                          ? Center(
                              child: SizedBox(
                                height: 200,
                                width: 200,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.file(
                                    selectedImage!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            )
                          : GestureDetector(
                              onTap: () {
                                getImage();
                              },
                              child: Center(
                                child: Container(
                                  height: 300,
                                  width: 300,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      width: 2.0,
                                      color: Colors.black45,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.camera_alt,
                                    color: Colors.blue,
                                    size: 35.0,
                                  ),
                                ),
                              ),
                            ),
                      SizedBox(height: 20.0),
                      Text(
                        'Hotel Name',
                        style: AppWidget.normaltextstyle(20.0),
                      ),
                      SizedBox(height: 5.0),
                      Container(
                        padding: EdgeInsets.only(left: 20.0),
                        decoration: BoxDecoration(
                          color: Color(0xFFececf8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextField(
                          controller: hotelnamecontroller,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Enter Hotel Name",
                            hintStyle: AppWidget.normaltextstyle(20.0),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Text(
                        'Hotel Room Prices',
                        style: AppWidget.normaltextstyle(20.0),
                      ),
                      SizedBox(height: 5.0),
                      Container(
                        padding: EdgeInsets.only(left: 20.0),
                        decoration: BoxDecoration(
                          color: Color(0xFFececf8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextField(
                          controller: hotelchargescontroller,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Enter Hotel Room Prices",
                            hintStyle: AppWidget.normaltextstyle(20.0),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Text(
                        'Hotel Address',
                        style: AppWidget.normaltextstyle(20.0),
                      ),
                      SizedBox(height: 5.0),
                      Container(
                        padding: EdgeInsets.only(left: 20.0),
                        decoration: BoxDecoration(
                          color: Color(0xFFececf8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextField(
                          controller: hoteladdresscontroller,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Enter Hotel Address",
                            hintStyle: AppWidget.normaltextstyle(20.0),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Text('City', style: AppWidget.normaltextstyle(20.0)),
                      SizedBox(height: 5.0),
                      Container(
                        padding: EdgeInsets.only(left: 20.0),
                        decoration: BoxDecoration(
                          color: Color(0xFFececf8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextField(
                          controller: hotelcitycontroller,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Enter City",
                            hintStyle: AppWidget.normaltextstyle(20.0),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Text(
                        'What service you want to offer',
                        style: AppWidget.normaltextstyle(20.0),
                      ),
                      SizedBox(height: 5.0),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: isChecked,
                            onChanged: (bool? value) {
                              setState(() {
                                isChecked = value!;
                              });
                            },
                          ),
                          Icon(Icons.wifi, color: Colors.blue, size: 30.0),
                          SizedBox(width: 10.0),
                          Text("WIFI", style: AppWidget.normaltextstyle(23.0)),
                        ],
                      ),
                      SizedBox(height: 5.0),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: isChecked1,
                            onChanged: (bool? value) {
                              setState(() {
                                isChecked1 = value!;
                              });
                            },
                          ),
                          Icon(Icons.tv, color: Colors.blue, size: 30.0),
                          SizedBox(width: 10.0),
                          Text("HDTV", style: AppWidget.normaltextstyle(23.0)),
                        ],
                      ),
                      SizedBox(height: 5.0),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: isChecked2,
                            onChanged: (bool? value) {
                              setState(() {
                                isChecked2 = value!;
                              });
                            },
                          ),
                          Icon(Icons.kitchen, color: Colors.blue, size: 30.0),
                          SizedBox(width: 10.0),
                          Text(
                            "Kitchen",
                            style: AppWidget.normaltextstyle(23.0),
                          ),
                        ],
                      ),
                      SizedBox(height: 5.0),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: isChecked3,
                            onChanged: (bool? value) {
                              setState(() {
                                isChecked3 = value!;
                              });
                            },
                          ),
                          Icon(Icons.bathroom, color: Colors.blue, size: 30.0),
                          SizedBox(width: 10.0),
                          Text(
                            "Bathroom",
                            style: AppWidget.normaltextstyle(23.0),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.0),
                      Text(
                        'Hotel Description',
                        style: AppWidget.normaltextstyle(20.0),
                      ),
                      SizedBox(height: 5.0),
                      Container(
                        padding: EdgeInsets.only(left: 20.0),
                        decoration: BoxDecoration(
                          color: Color(0xFFececf8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextField(
                          controller: hoteldescontroller,
                          maxLines: 6,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Enter About Hotel",
                            hintStyle: AppWidget.normaltextstyle(20.0),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      GestureDetector(
                        onTap: () async {
                          // Reference firebaseStorageRef = FirebaseStorage
                          //     .instance
                          //     .ref()
                          //     .child('blogImage')
                          //     .child(addId);
                          // final UploadTask task = firebaseStorageRef.putFile(
                          //   selectedImage!,
                          // );

                          // var downloadUrl = await(await task).ref.getDownloadURL();

                          Map<String, dynamic> addHotel = {
                            "Image": "",
                            "HotelName": hotelnamecontroller.text,
                            "HotelCharges": hotelchargescontroller.text,
                            "HotelCity": hotelcitycontroller.text.toLowerCase(),
                            "HotelAddress": hoteladdresscontroller.text,
                            "HotelDesc": hoteldescontroller.text,
                            "WIFI": isChecked ? "true" : "false",
                            "HDTV": isChecked1 ? "true" : "false",
                            "Kitchen": isChecked2 ? "true" : "false",
                            "Bathroom": isChecked3 ? "true" : "false",
                            "Id": id,
                          };
                          await DatabaseMethods().addHotel(addHotel, id!);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.green,
                              content: Text(
                                'Hotel Details has been uploaded Successfully',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OwnerHome(),
                            ),
                          );
                        },
                        child: Center(
                          child: Container(
                            height: 60,
                            width: MediaQuery.of(context).size.width / 1.5,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                'Submit',
                                style: AppWidget.boldwhitetextstyle(26.0),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
