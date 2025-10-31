import 'package:aparte/services/database.dart';
import 'package:aparte/services/shared_preferences.dart';
import 'package:aparte/services/widget_support.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Wallet extends StatefulWidget {
  const Wallet({super.key});

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  TextEditingController moneycontroller = TextEditingController();

  Map<String, dynamic>? paymentIntent;
  String? wallet, id;

  String getCurrentDateFormatted() {
    final now = DateTime.now();
    final day = DateFormat('dd').format(now);
    final month = DateFormat('MMM').format(now);
    return '$day\n$month';
  }

  getthesharedpref() async {
    wallet = await SharedpreferenceHelper().getUserWallet();
    id = await SharedpreferenceHelper().getUserId();
    transactionstream = await DatabaseMethods().getUserTransactions(id!);
    setState(() {});
  }

  @override
  void initState() {
    getthesharedpref();
    super.initState();
  }

  Stream? transactionstream;
  Widget allTransaction() {
    return StreamBuilder<QuerySnapshot>(
      stream: transactionstream as Stream<QuerySnapshot>,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No transactions yet'));
        }
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot ds = snapshot.data!.docs[index];
            return Container(
              width: MediaQuery.of(context).size.width / 1.3,
              margin: EdgeInsets.only(left: 20.0, right: 40.0, bottom: 20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        bottomLeft: Radius.circular(20.0),
                      ),
                    ),
                    child: Text(
                      ds['Date'],
                      textAlign: TextAlign.center,
                      style: AppWidget.boldwhitetextstyle(24.0),
                    ),
                  ),
                  SizedBox(width: 50),
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Amount Added',
                          style: AppWidget.normaltextstyle(20.0),
                        ),
                        Text(
                          '\$' + ds['Amount'],
                          style: AppWidget.headlinetextstyle(22.0),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text("Wallet", style: AppWidget.headlinetextstyle(30.0)),
        ),
      ),
      body: wallet == null
          ? Center(child: CircularProgressIndicator())
          : Container(
              child: Column(
                children: [
                  SizedBox(height: 10.0),
                  Center(
                    child: Container(
                      margin: EdgeInsets.only(left: 20.0, right: 20.0),

                      child: Material(
                        elevation: 3.0,
                        borderRadius: BorderRadius.circular(10),

                        child: Container(
                          padding: EdgeInsets.all(10.0),

                          width: MediaQuery.of(context).size.width / 1.2,
                          decoration: BoxDecoration(
                            color: Color(0xFFececf8),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                'images/wallet.png',
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                              SizedBox(width: 50.0),
                              Column(
                                children: [
                                  Text(
                                    'Your Wallet',
                                    style: AppWidget.normaltextstyle(20.0),
                                  ),
                                  Text(
                                    '\$${wallet!}',
                                    style: AppWidget.headlinetextstyle(25.0),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          moneycontroller.text = '50';
                          // makePayment('50');
                        },
                        child: Container(
                          height: 40,
                          width: 100,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(color: Colors.white, width: 2.0),
                          ),
                          child: Center(
                            child: Text(
                              '50',
                              style: AppWidget.boldwhitetextstyle(25.0),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 20.0),
                      GestureDetector(
                        onTap: () {
                          moneycontroller.text = '100';
                          // makePayment('100');
                        },
                        child: Container(
                          height: 40,
                          width: 100,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(color: Colors.white, width: 2.0),
                          ),
                          child: Center(
                            child: Text(
                              '100',
                              style: AppWidget.boldwhitetextstyle(25.0),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 20.0),
                      GestureDetector(
                        onTap: () {
                          moneycontroller.text = '200';
                          // makePayment('200');
                        },
                        child: Container(
                          height: 40,
                          width: 100,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(color: Colors.white, width: 2.0),
                          ),
                          child: Center(
                            child: Text(
                              '200',
                              style: AppWidget.boldwhitetextstyle(25.0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30.0),
                  GestureDetector(
                    onTap: () {
                      openBox();
                    },
                    child: Container(
                      height: 50.0,
                      margin: EdgeInsets.only(left: 20.0, right: 20.0),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          'Add Money',
                          style: AppWidget.boldwhitetextstyle(20.0),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Expanded(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Color(0xFFececf8),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(60.0),
                          topRight: Radius.circular(60.0),
                        ),
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: 10.0),
                          Text(
                            'Your Transactions',
                            style: AppWidget.headlinetextstyle(25.0),
                          ),
                          SizedBox(height: 10.0),
                          Container(
                            color: Colors.white,
                            height: MediaQuery.of(context).size.height / 2.5,
                            child: allTransaction(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> openBox() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: SingleChildScrollView(
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(Icons.cancel),
                    ),
                    SizedBox(width: 50.0),
                    Text(
                      'Add Money',
                      style: TextStyle(
                        color: Color(0xff008080),
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.0),
                Text('Enter Amount'),
                SizedBox(height: 10.0),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: TextField(
                    controller: moneycontroller,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter amount',
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                GestureDetector(
                  onTap: () async {
                    // await makePayment(moneycontroller.text);
                    // Navigator.pop(context);
                  },
                  child: Center(
                    child: Container(
                      width: 100,
                      padding: EdgeInsets.all(5.0),
                      decoration: BoxDecoration(
                        color: Color(0xff008080),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Center(
                        child: Text(
                          'Add',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
