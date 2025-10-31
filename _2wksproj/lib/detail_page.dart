import 'dart:math';

import 'package:aparte/services/database.dart';
import 'package:aparte/services/shared_preferences.dart';
import 'package:aparte/services/widget_support.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:random_string/random_string.dart';

class DetailPage extends StatefulWidget {
  final String name, price, wifi, hdtv, kitchen, bathroom, desc, hotelid;
  const DetailPage({
    super.key,
    required this.bathroom,
    required this.desc,
    required this.name,
    required this.price,
    required this.wifi,
    required this.kitchen,
    required this.hdtv,
    required this.hotelid,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  TextEditingController guestscontroller = TextEditingController();
  Map<String, dynamic>? paymentIntent;

  int? finalamount;
  DateTime? startDate;
  DateTime? endDate;
  int daysDifference = 1;
  String? username, userid, userimage;

  getontheload() async {
    username = await SharedpreferenceHelper().getUserName();
    userid = await SharedpreferenceHelper().getUserId();
    userimage = await SharedpreferenceHelper().getUserImage();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    finalamount = int.parse(widget.price);
    getontheload();
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != startDate) {
      setState(() {
        startDate = picked;
        _calculateDiffrerence();
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: endDate ?? (startDate ?? DateTime.now()).add(Duration.zero),
      firstDate: startDate ?? DateTime.now(),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != endDate) {
      setState(() {
        endDate = picked;
        _calculateDiffrerence();
      });
    }
  }

  void _calculateDiffrerence() {
    if (startDate != null && endDate != null) {
      daysDifference = endDate!.difference(startDate!).inDays;
      finalamount = int.parse(widget.price) * daysDifference;
    }
  }

  String _formatDate(DateTime? date) {
    return date != null
        ? DateFormat('dd, MMM yyyy').format(date)
        : 'Select Date';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Stack(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 2.5,
                    child: ClipRRect(
                      borderRadius: BorderRadiusGeometry.only(
                        bottomLeft: Radius.circular(50),
                        bottomRight: Radius.circular(50),
                      ),
                      child: Image.asset(
                        'images/hotel1.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.all(5),
                      margin: EdgeInsets.only(top: 50, left: 20),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(0, 255, 255, 255),
                        borderRadius: BorderRadius.circular(60),
                      ),
                      child: Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.0),
                    Text(widget.name, style: AppWidget.headlinetextstyle(27.0)),
                    Text(
                      '\$${widget.price}',
                      style: AppWidget.normaltextstyle(27.0),
                    ),
                    Divider(thickness: 2.0),
                    SizedBox(height: 10),
                    Text(
                      'What this place offers',
                      style: AppWidget.headlinetextstyle(22.0),
                    ),
                    widget.wifi == 'true'
                        ? Row(
                            children: [
                              Icon(
                                Icons.wifi,
                                color: const Color.fromARGB(255, 33, 149, 243),
                                size: 30.0,
                              ),
                              SizedBox(width: 10.0),
                              Text(
                                'Wifi',
                                style: AppWidget.normaltextstyle(23.0),
                              ),
                            ],
                          )
                        : Container(),
                    SizedBox(height: 20),
                    widget.hdtv == 'true'
                        ? Row(
                            children: [
                              Icon(
                                Icons.tv,
                                color: const Color.fromARGB(255, 33, 149, 243),
                                size: 30.0,
                              ),
                              Text(
                                'HDTV',
                                style: AppWidget.normaltextstyle(23.0),
                              ),
                            ],
                          )
                        : Container(),

                    SizedBox(height: 20.0),
                    widget.kitchen == 'true'
                        ? Row(
                            children: [
                              Icon(
                                Icons.kitchen,
                                color: const Color.fromARGB(255, 33, 149, 243),
                                size: 30.0,
                              ),
                              SizedBox(width: 10.0),
                              Text(
                                'Kitchen',
                                style: AppWidget.normaltextstyle(23.0),
                              ),
                            ],
                          )
                        : Container(),

                    widget.bathroom == 'true'
                        ? Row(
                            children: [
                              Icon(
                                Icons.bathroom,
                                color: const Color.fromARGB(255, 33, 149, 243),
                                size: 30.0,
                              ),
                              SizedBox(width: 10.0),
                              Text(
                                'Bathroom',
                                style: AppWidget.normaltextstyle(23.0),
                              ),
                            ],
                          )
                        : Container(),

                    Divider(thickness: 2.0),
                    Text(
                      'About this place',
                      style: AppWidget.headlinetextstyle(22.0),
                    ),
                    SizedBox(height: 10.0),
                    Text(widget.desc, style: AppWidget.normaltextstyle(22.0)),
                    SizedBox(height: 10),
                    Material(
                      elevation: 3.0,
                      borderRadius: BorderRadius.circular(20),

                      child: Container(
                        padding: EdgeInsets.all(10),

                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10.0),
                            Text(
                              '\$100 for 4 nights',
                              style: AppWidget.headlinetextstyle(21.0),
                            ),
                            SizedBox(height: 5.0),
                            Text(
                              'Check-in Date',
                              style: AppWidget.normaltextstyle(20.0),
                            ),
                            Divider(thickness: 2),
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Icon(
                                    Icons.calendar_month,
                                    color: Colors.white,
                                    size: 30.0,
                                  ),
                                ),
                                SizedBox(width: 10.0),
                                Text(
                                  '02, Apr 2025',
                                  style: AppWidget.normaltextstyle(20),
                                ),
                              ],
                            ),

                            SizedBox(height: 10.0),
                            Text(
                              "\$$finalamount for ${daysDifference}nights",
                              style: AppWidget.headlinetextstyle(21.0),
                            ),
                            SizedBox(height: 5.0),
                            Text(
                              'Check-out Date',
                              style: AppWidget.normaltextstyle(20.0),
                            ),
                            Divider(thickness: 2),
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Icon(
                                    Icons.calendar_month,
                                    color: Colors.white,
                                    size: 30.0,
                                  ),
                                ),
                                SizedBox(width: 10.0),
                                Text(
                                  '05, Apr 2025',
                                  style: AppWidget.normaltextstyle(20),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),

                            Text(
                              'Number of guests',
                              style: AppWidget.normaltextstyle(20.0),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFececf8),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: TextField(
                                onChanged: (value) {
                                  finalamount = finalamount! * int.parse(value);
                                  setState(() {});
                                },
                                controller: guestscontroller,
                                style: AppWidget.headlinetextstyle(20.0),
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.only(left: 10),
                                  hintText: '1',
                                  hintStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20.0),
                            GestureDetector(
                              onTap: () {
                                makePayment(finalamount.toString());
                              },
                              child: Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: Text(
                                    'Book Now',
                                    style: AppWidget.whitetextstyle(22.0),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Map<String, dynamic>?> createPaymentIntent(
    String amount,
    String currency,
  ) async {
    try {
      // You should replace this with your backend call to create a PaymentIntent
      // For demonstration, here's a placeholder using Stripe's API via HTTP
      // In production, NEVER expose your secret key in client code!
      // Instead, call your backend endpoint that creates the PaymentIntent

      // Example using http package (add http to your pubspec.yaml)
      // import 'package:http/http.dart' as http;
      // final response = await http.post(
      //   Uri.parse('https://your-backend.com/create-payment-intent'),
      //   body: {'amount': amount, 'currency': currency},
      // );
      // return jsonDecode(response.body);

      // Placeholder for demonstration:
      return {'client_secret': 'dummy_client_secret_for_demo'};
    } catch (err) {
      print('Error creating payment intent: $err');
      return null;
    }
  }

  Future<void> makePayment(String amount) async {
    try {
      paymentIntent = await createPaymentIntent(amount, 'USD');
      await Stripe.instance
          .initPaymentSheet(
            paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: paymentIntent?['client_secret'],
              style: ThemeMode.dark,
              merchantDisplayName: 'Aparte',
            ),
          )
          .then((value) {});
      displayPaymentSheet(amount);
    } catch (e, s) {
      print('exception:$e$s');
    }
  }

  displayPaymentSheet(String amount) async {
    try {
      await Stripe.instance
          .presentPaymentSheet()
          .then((value) async {
            String addId = randomAlphaNumeric(10);
            Map<String, dynamic> userhotelbooking = {
              "Username": username,
              "Userimage": userimage,
              "Checkin": _formatDate(startDate).toString(),
              "Checkout": _formatDate(endDate).toString(),
              "Guests": guestscontroller.text,
              "Total": finalamount.toString(),
              "Hotelname": widget.name,
            };
            await DatabaseMethods().addUserBooking(
              userhotelbooking,
              userid!,
              addId,
            );
            await DatabaseMethods().addHotelOwnerBooking(
              userhotelbooking,
              widget.hotelid,
              addId,
            );

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.green,
                content: Text(
                  'Hotel booked Successfully',
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
              ),
            );
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        Text('Payment Successfull'),
                      ],
                    ),
                  ],
                ),
              ),
            );
            paymentIntent = null;
          })
          .onError((error, stackTrace) {
            print('Exception/DISPLAYPAYMENTSHEET==> $error $stackTrace');
          });
    } on StripeException catch (e) {
      print('Exception/DISPLAYPAYMENTSHEET==> $e');
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.cancel, color: Colors.red),
                  Text('Payment Cancelled'),
                ],
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      print('$e');
    }
  }
}
