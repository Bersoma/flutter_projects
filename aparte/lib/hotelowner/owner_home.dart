import 'package:aparte/services/database.dart';
import 'package:aparte/services/shared_preferences.dart';
import 'package:aparte/services/widget_support.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OwnerHome extends StatefulWidget {
  const OwnerHome({super.key});

  @override
  State<OwnerHome> createState() => _OwnerHomeState();
}

class _OwnerHomeState extends State<OwnerHome> {
  String? id, name;
  Stream<QuerySnapshot>? bookingStream;

  getonthesharedpref() async {
    id = await SharedpreferenceHelper().getUserId();
    name = await SharedpreferenceHelper().getUserName();

    if (id == null || id!.isEmpty) {
      debugPrint('OwnerHome: no user id');
      setState(() {});
      return;
    }

    // get the stream from the async method
    try {
      bookingStream = await DatabaseMethods().getAdminbooking(id!);
      debugPrint(
        'OwnerHome: bookingStream assigned -> $bookingStream, ownerId=$id',
      );
    } catch (e) {
      debugPrint('OwnerHome: getAdminbooking error: $e');
      bookingStream = null;
    }

    setState(() {});
  }

  @override
  void initState() {
    getonthesharedpref();
    super.initState();
  }

  Widget allAdminBookings() {
    if (bookingStream == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return StreamBuilder<QuerySnapshot>(
      stream: bookingStream,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        debugPrint(
          'OwnerHome: snapshot state=${snapshot.connectionState}, hasData=${snapshot.hasData}, err=${snapshot.error}',
        );

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Error loading bookings: ${snapshot.error}'),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No bookings yet"));
        }

        final docs = snapshot.data!.docs;
        debugPrint('OwnerHome: docs.length=${docs.length}');
        return ListView.builder(
          itemCount: docs.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final ds = docs[index];
            final data = (ds.data() as Map<String, dynamic>?) ?? {};
            debugPrint('OwnerHome: doc ${ds.id} -> $data');

            // handle Timestamp or String for Checkin
            DateTime? checkinDate;
            final rawCheckin = data['Checkin'];
            if (rawCheckin is Timestamp) {
              checkinDate = rawCheckin.toDate();
            } else if (rawCheckin is String) {
              checkinDate = DateTime.tryParse(rawCheckin);
              if (checkinDate == null) {
                try {
                  checkinDate = DateFormat(
                    'dd, MMM yyyy',
                  ).parseLoose(rawCheckin);
                } catch (_) {}
              }
            }

            
          

            final hotelName = data['Hotelname']?.toString() ?? 'Unknown Hotel';
            final checkinText = data['Checkin']?.toString() ?? '-';
            final checkoutText = data['Checkout']?.toString() ?? '-';
            final guests = data['Guests']?.toString() ?? '0';
            final total = data['Total']?.toString() ?? '0';
            return Container(
              margin: const EdgeInsets.only(bottom: 20.0),
              child: Material(
                elevation: 1.5,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFececf8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.asset(
                          'images/hotel1.jpg',
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.hotel, color: Colors.purple),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    hotelName,
                                    style: AppWidget.normaltextstyle(18.0),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_month,
                                  color: Colors.purple,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "$checkinText - $checkoutText",
                                  style: AppWidget.normaltextstyle(15.0),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                const Icon(Icons.group, color: Colors.purple),
                                const SizedBox(width: 6),
                                Text(
                                  guests,
                                  style: AppWidget.normaltextstyle(15.0),
                                ),
                                const SizedBox(width: 10),
                                const Icon(
                                  Icons.monetization_on,
                                  color: Colors.purple,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "\$$total",
                                  style: AppWidget.normaltextstyle(15.0),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
  // ...existing code..

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: name == null
          ? Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Stack(
                children: [
                  // Background image
                  Image.asset(
                    'images/lags.jpg',
                    width: MediaQuery.of(context).size.width,
                    height: 220,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    height: 220,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                    ),
                  ),

                  // Content
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.waving_hand_outlined,
                              color: Colors.yellow,
                            ),
                            const SizedBox(width: 10.0),
                            Text(
                              'Hello, ${name ?? "Owner"}!',
                              style: AppWidget.boldwhitetextstyle(22.0),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 8,
                        ),
                        child: Text(
                          'Ready to welcome\nyour next guest?',
                          style: AppWidget.whitetextstyle(18.0),
                        ),
                      ),

                      // White curved container
                      Expanded(
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30.0),
                              topRight: Radius.circular(30.0),
                            ),
                          ),
                          padding: const EdgeInsets.all(20.0),
                          child: SingleChildScrollView(
                            child: allAdminBookings(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
