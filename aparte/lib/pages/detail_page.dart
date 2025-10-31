import 'dart:convert';
import 'package:aparte/pages/bottomnav.dart';
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
  final String name, price, wifi, hdtv, kitchen, bathroom, desc, hotelid, image;

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
    required this.image,
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
          endDate ?? (startDate ?? DateTime.now()).add(const Duration(days: 1)),
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
          children: [_buildHeader(context), _buildDetails(context)],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height / 2.5,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(50),
              bottomRight: Radius.circular(50),
            ),
            child: Image.asset(widget.image, fit: BoxFit.cover),
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
    );
  }

  Widget _buildDetails(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(widget.name, style: AppWidget.headlinetextstyle(27.0)),
          Text('\$${widget.price}', style: AppWidget.normaltextstyle(27.0)),
          const Divider(thickness: 2.0),

          const SizedBox(height: 10),
          Text(
            'What this place offers',
            style: AppWidget.headlinetextstyle(22.0),
          ),

          if (widget.wifi == 'true') _buildFacilityRow(Icons.wifi, 'Wi-Fi'),
          if (widget.hdtv == 'true') _buildFacilityRow(Icons.tv, 'HDTV'),
          if (widget.kitchen == 'true')
            _buildFacilityRow(Icons.kitchen, 'Kitchen'),
          if (widget.bathroom == 'true')
            _buildFacilityRow(Icons.bathtub, 'Bathroom'),

          const Divider(thickness: 2.0),
          Text('About this place', style: AppWidget.headlinetextstyle(22.0)),
          const SizedBox(height: 10),
          Text(widget.desc, style: AppWidget.normaltextstyle(22.0)),

          const SizedBox(height: 20),
          _buildBookingSection(context),
        ],
      ),
    );
  }

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
            _buildDateSelector(
              "Check-in Date",
              startDate,
              () => _selectStartDate(context),
            ),
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

            // ✅ Corrected Booking Button
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

                await makePayment(finalamount.toString());
              },
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    "Pay with Card",
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
      // Convert amount to the smallest currency unit (e.g. cents or kobo)
      int amountInSmallestUnit = (int.parse(amount) * 100);

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $secretkey', // replace with your secret key
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': amountInSmallestUnit.toString(),
          'currency': currency,
          'payment_method_types[]': 'card',
        },
      );

      if (response.statusCode == 200) {
        print('✅ PaymentIntent created: ${response.body}');
        return jsonDecode(response.body);
      } else {
        print('❌ Failed to create PaymentIntent: ${response.body}');
        return null;
      }
    } catch (e) {
      print('⚠️ Error creating payment intent: $e');
      return null;
    }
  }

  Future<void> makePayment(String amount) async {
    try {
      print('🟢 Creating PaymentIntent...');
      paymentIntent = await createPaymentIntent(amount, 'usd');

      if (paymentIntent == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Payment failed to initialize.")),
        );
        return;
      }

      print('🟢 Client Secret: ${paymentIntent!['client_secret']}');

      print('🟢 Initializing payment sheet...');
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent!['client_secret'],
          style: ThemeMode.dark,
          merchantDisplayName: 'Aparte',
        ),
      );

      print('🟢 Showing payment sheet...');
      await displayPaymentSheet();
    } catch (e, stack) {
      print('❌ Payment init error: $e');
      print('STACK TRACE: $stack');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error initializing payment: $e')));
    }
  }

  Future<void> displayPaymentSheet() async {
    try {
      print('🟢 Presenting payment sheet...');
      await Stripe.instance.presentPaymentSheet();
      print('✅ Payment sheet completed successfully.');

      // Defer Firestore writes slightly to avoid UI freezing
      Future.microtask(() async {
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

        // Build a transaction map matching the expected parameter type
        Map<String, dynamic> transaction = {
          "TransactionId": addId,
          "UserId": userid,
          "Amount": finalamount.toString(),
          "Hotelname": widget.name,
          "Date": DateFormat('MMM-dd'),
          "Type": "debit",
        };

        print('🟢 Saving booking to Firestore...');
        await DatabaseMethods().addUserBooking(booking, userid!, addId);
        await DatabaseMethods().addHotelOwnerBooking(
          booking,
          widget.hotelid,
          addId,
        );
        await DatabaseMethods().addUserTransaction(transaction, userid!);
        print('✅ Booking saved successfully.');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Bottomnav()),
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.green,
              content: Text('Hotel booked successfully'),
            ),
          );
        }
      });

      paymentIntent = null;
    } on StripeException catch (e) {
      print('⚠️ Stripe error: $e');
      _showDialog('Payment Cancelled', Icons.cancel, Colors.red);
    } catch (e, stack) {
      print('❌ Error displaying payment sheet: $e');
      print('STACK TRACE: $stack');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error completing payment: $e')));
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
