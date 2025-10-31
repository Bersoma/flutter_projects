import 'dart:convert';
import 'package:aparte/services/constant.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:random_string/random_string.dart';
import 'package:aparte/services/database.dart';
import 'package:aparte/services/shared_preferences.dart';
import 'package:aparte/services/widget_support.dart';

class DetailPage extends StatefulWidget {
  final String name, price, wifi, hdtv, kitchen, bathroom, desc, hotelid;

  const DetailPage({
    super.key,
    required this.name,
    required this.price,
    required this.wifi,
    required this.hdtv,
    required this.kitchen,
    required this.bathroom,
    required this.desc,
    required this.hotelid,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  TextEditingController guestscontroller = TextEditingController();
  Map<String, dynamic>? paymentIntent;
  int finalamount = 0;
  DateTime? startDate;
  DateTime? endDate;
  int daysDifference = 1;
  String? username, userid, userimage, wallet, id;

  @override
  void initState() {
    super.initState();
    finalamount = int.parse(widget.price);
    getUserData();
  }

  Future<void> getUserData() async {
    username = await SharedpreferenceHelper().getUserName();
    wallet = await SharedpreferenceHelper().getUserWallet();
    userid = await SharedpreferenceHelper().getUserId();
    userimage = await SharedpreferenceHelper().getUserImage();
    id = await SharedpreferenceHelper().getUserId();
    setState(() {});
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
    );
    if (picked != null) {
      setState(() {
        startDate = picked;
        _calculateDifference();
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          endDate ?? (startDate ?? DateTime.now()).add(Duration(days: 1)),
      firstDate: startDate ?? DateTime.now(),
      lastDate: DateTime(2026),
    );
    if (picked != null) {
      setState(() {
        endDate = picked;
        _calculateDifference();
      });
    }
  }

  void _calculateDifference() {
    if (startDate != null && endDate != null) {
      daysDifference = endDate!.difference(startDate!).inDays;
      if (daysDifference <= 0) daysDifference = 1;
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ------------------- Header Image -------------------
            Stack(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 2.5,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(50),
                      bottomRight: Radius.circular(50),
                    ),
                    child: Image.asset('images/hotel1.jpg', fit: BoxFit.cover),
                  ),
                ),
                Positioned(
                  top: 50,
                  left: 20,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: CircleAvatar(
                      backgroundColor: Colors.black.withOpacity(0.4),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),

            // ------------------- Hotel Info -------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(widget.name, style: AppWidget.headlinetextstyle(27.0)),
                  Text(
                    '\$${widget.price}',
                    style: AppWidget.normaltextstyle(27.0),
                  ),
                  const Divider(thickness: 2.0),

                  const SizedBox(height: 10),
                  Text(
                    'What this place offers',
                    style: AppWidget.headlinetextstyle(22.0),
                  ),

                  if (widget.wifi == 'true')
                    _buildFacilityRow(Icons.wifi, 'Wi-Fi'),
                  if (widget.hdtv == 'true')
                    _buildFacilityRow(Icons.tv, 'HDTV'),
                  if (widget.kitchen == 'true')
                    _buildFacilityRow(Icons.kitchen, 'Kitchen'),
                  if (widget.bathroom == 'true')
                    _buildFacilityRow(Icons.bathtub, 'Bathroom'),

                  const Divider(thickness: 2.0),
                  Text(
                    'About this place',
                    style: AppWidget.headlinetextstyle(22.0),
                  ),
                  const SizedBox(height: 10),
                  Text(widget.desc, style: AppWidget.normaltextstyle(22.0)),

                  const SizedBox(height: 20),
                  _buildBookingSection(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------- Widget Helpers -------------------
  Widget _buildFacilityRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 28),
          const SizedBox(width: 10),
          Text(text, style: AppWidget.normaltextstyle(23.0)),
        ],
      ),
    );
  }

  Widget _buildBookingSection(BuildContext context) {
    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Booking Details", style: AppWidget.headlinetextstyle(21.0)),
            const SizedBox(height: 10),

            // Check-in Date
            _buildDateSelector(
              "Check-in Date",
              startDate,
              () => _selectStartDate(context),
            ),

            // Check-out Date
            _buildDateSelector(
              "Check-out Date",
              endDate,
              () => _selectEndDate(context),
            ),

            const SizedBox(height: 10),
            Text("Number of Guests", style: AppWidget.normaltextstyle(20.0)),
            const SizedBox(height: 5),
            _buildGuestField(),

            const SizedBox(height: 20),
            Text(
              "\$$finalamount for $daysDifference night(s)",
              style: AppWidget.headlinetextstyle(22.0),
            ),

            const SizedBox(height: 20),
            GestureDetector(
              onTap: () async {
                if (startDate == null || endDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Please select check-in and check-out dates.",
                      ),
                    ),
                  );
                  return;
                }
                if (int.parse(wallet!) > finalamount) {
                  int updatedamount = int.parse(wallet!) - finalamount;
                  await DatabaseMethods().updateWallet(
                    id!,
                    updatedamount.toString(),
                  );
                  await SharedpreferenceHelper().saveUserWallet(
                    updatedamount.toString(),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.green,
                      content: Text('Hotel booked successfully'),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.red,
                      content: Text('Please Add Money to your Wallet'),
                    ),
                  );
                }
              },
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    "Book Now",
                    style: AppWidget.whitetextstyle(22.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector(String label, DateTime? date, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.calendar_month, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Text(_formatDate(date), style: AppWidget.normaltextstyle(20.0)),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFececf8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: guestscontroller,
        keyboardType: TextInputType.number,
        style: AppWidget.headlinetextstyle(20.0),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.only(left: 10),
          hintText: '1',
        ),
        onChanged: (value) {
          final guests = int.tryParse(value) ?? 1;
          setState(() {
            finalamount = int.parse(widget.price) * daysDifference * guests;
          });
        },
      ),
    );
  }

  // ------------------- Stripe Payment -------------------
  Future<Map<String, dynamic>?> createPaymentIntent(
    String amount,
    String currency,
  ) async {
    try {
      // Stripe requires the amount in the smallest currency unit (e.g., cents)
      int amountInCents = (int.parse(amount) * 100);

      // Call Stripe's API
      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization':
              'Bearer $secretkey', // ⚠️ Replace this with your Stripe Secret Key
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': amountInCents.toString(),
          'currency': currency,
          'payment_method_types[]': 'card', // optional but recommended
        },
      );

      // Decode the JSON response
      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return jsonResponse;
      } else {
        print('Failed to create PaymentIntent: ${response.body}');
        return null;
      }
    } catch (err) {
      print('Error creating payment intent: $err');
      return null;
    }
  }

  Future<void> makePayment(String amount) async {
    try {
      paymentIntent = await createPaymentIntent(amount, 'USD');
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent?['client_secret'],
          style: ThemeMode.dark,
          merchantDisplayName: 'Aparte',
        ),
      );
      await displayPaymentSheet(amount);
    } catch (e, s) {
      print('exception:$e$s');
    }
  }

  Future<void> displayPaymentSheet(String amount) async {
    try {
      await Stripe.instance.presentPaymentSheet();
      String addId = randomAlphaNumeric(10);
      Map<String, dynamic> booking = {
        "Username": username,
        "Userimage": userimage,
        "Checkin": _formatDate(startDate),
        "Checkout": _formatDate(endDate),
        "Guests": guestscontroller.text,
        "Total": finalamount.toString(),
        "Hotelname": widget.name,
      };

      await DatabaseMethods().addUserBooking(booking, userid!, addId);
      await DatabaseMethods().addHotelOwnerBooking(
        booking,
        widget.hotelid,
        addId,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Hotel booked successfully'),
        ),
      );

      paymentIntent = null;
    } on StripeException catch (e) {
      print('Stripe error: $e');
      _showDialog('Payment Cancelled', Icons.cancel, Colors.red);
    } catch (e) {
      print('Error displaying payment sheet: $e');
    }
  }

  void _showDialog(String message, IconData icon, Color color) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 10),
            Text(message),
          ],
        ),
      ),
    );
  }
}
