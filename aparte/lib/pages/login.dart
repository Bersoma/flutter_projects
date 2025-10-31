import 'package:aparte/hotelowner/owner_home.dart';
import 'package:aparte/pages/bottomnav.dart';
import 'package:aparte/pages/signup.dart';
import 'package:aparte/services/database.dart';
import 'package:aparte/services/shared_preferences.dart';
import 'package:aparte/services/widget_support.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LogIn extends StatefulWidget {
  String redirect;
  LogIn({super.key, required this.redirect});
  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  String email = "", password = "", role = "", name = "", id = "", wallet = "";

  TextEditingController passwordcontroller = TextEditingController();
  TextEditingController mailcontroller = TextEditingController();

  bool isLoading = false;

  userLogin() async {
    setState(() => isLoading = true);
    try {
      // sign in
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // fetch user document by email
      QuerySnapshot querySnapshot = await DatabaseMethods().getUserbyemail(
        email,
      );

      if (querySnapshot.docs.isEmpty) {
        throw Exception('No user document found for $email');
      }

      name = "${querySnapshot.docs[0]['Name']}";
      id = "${querySnapshot.docs[0]['Id']}";
      role = "${querySnapshot.docs[0]['role']}";
      wallet = "${querySnapshot.docs[0]['Wallet']}";

      await SharedpreferenceHelper().saveUserName(name);
      await SharedpreferenceHelper().saveUserEmail(mailcontroller.text);
      await SharedpreferenceHelper().saveUserId(id);
      await SharedpreferenceHelper().saveUserWallet(wallet);

      if (role == "owner") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (c) => OwnerHome()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (c) => Bottomnav()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String msg = 'Authentication error';
      if (e.code == 'user-not-found') {
        msg = "No user found for that email.";
      } else if (e.code == 'wrong-password')
        msg = "Wrong password.";
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      // handle other errors (DB issues, range errors, network, etc.)
      print('Login error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login failed: $e')));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    mailcontroller.dispose();
    passwordcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset('images/login.jpg'),
              ),
              SizedBox(height: 8.0),
              Center(
                child: Text('Login', style: AppWidget.headlinetextstyle(25.0)),
              ),
              Center(
                child: Text(
                  'Please enter the details to continue',
                  style: AppWidget.normaltextstyle(20.0),
                ),
              ),

              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 30.0),
                child: Text('Email', style: AppWidget.normaltextstyle(20.0)),
              ),
              SizedBox(height: 10.0),
              Container(
                margin: EdgeInsets.only(left: 30.0, right: 30.0),
                decoration: BoxDecoration(
                  color: Color(0xFFececf8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: mailcontroller,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: Icon(
                      Icons.email,
                      color: const Color.fromARGB(255, 2, 65, 117),
                    ),
                    hintText: 'Enter Email',
                    hintStyle: AppWidget.normaltextstyle(16.0),
                    contentPadding: EdgeInsets.symmetric(vertical: 15.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 30.0),
                child: Text('Password', style: AppWidget.normaltextstyle(20.0)),
              ),
              SizedBox(height: 10.0),
              Container(
                margin: EdgeInsets.only(left: 30.0, right: 30.0),
                decoration: BoxDecoration(
                  color: Color(0xFFececf8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  obscureText: true,
                  controller: passwordcontroller,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: Icon(
                      Icons.password,
                      color: const Color.fromARGB(255, 2, 65, 117),
                    ),
                    hintText: 'Enter Password',
                    hintStyle: AppWidget.normaltextstyle(16.0),
                    contentPadding: EdgeInsets.symmetric(vertical: 15.0),
                  ),
                ),
              ),
              SizedBox(height: 10.0),
              Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Forgot Password?',
                      style: AppWidget.normaltextstyle(20.0),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.0),
              GestureDetector(
                onTap: () async {
                  if (mailcontroller.text != "" &&
                      passwordcontroller.text != "") {
                    setState(() {
                      email = mailcontroller.text;
                      password = passwordcontroller.text;
                    });
                    await userLogin();
                    setState(() {
                      isLoading = false;
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.red,
                        content: Text(
                          'Please fill all fields',
                          style: TextStyle(fontSize: 18.0),
                        ),
                      ),
                    );
                  }
                },
                child: Center(
                  child: Container(
                    height: 50.0,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 29, 168, 215),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    width: MediaQuery.of(context).size.width / 2,
                    child: Center(
                      child: isLoading
                          ? CircularProgressIndicator(color: Colors.blue)
                          : Text(
                              'Login',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 24.0,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.0),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Dont have an account ?',
                    style: AppWidget.normaltextstyle(20.0),
                  ),

                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SignUp(redirect: widget.redirect),
                        ),
                      );
                    },
                    child: Text(
                      'Sign Up',
                      style: AppWidget.headlinetextstyle(20.0),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
