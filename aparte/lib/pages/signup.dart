import 'package:aparte/hotelowner/hotel.detail.dart';
import 'package:aparte/pages/bottomnav.dart';
import 'package:aparte/pages/login.dart';
import 'package:aparte/services/database.dart';
import 'package:aparte/services/shared_preferences.dart';
import 'package:aparte/services/widget_support.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUp extends StatefulWidget {
  String redirect;
  SignUp({super.key, required this.redirect});
  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  String email = "", password = "", name = "";
  TextEditingController namecontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  TextEditingController mailcontroller = TextEditingController();

  bool isLoading = false;

  registration() async {
    if (passwordcontroller.text.isNotEmpty &&
        namecontroller.text.isNotEmpty &&
        mailcontroller.text.isNotEmpty) {
      try {
        setState(() {
          isLoading = true;
        });
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: mailcontroller.text,
              password: passwordcontroller.text,
            );
        String id = userCredential.user!.uid;
        Map<String, dynamic> userInfoMap = {
          "Name": namecontroller.text,
          "Email": mailcontroller.text,
          "Id": id,
          "role": widget.redirect == "owner" ? "owner" : "user",
          "Wallet": "0",
        };
        await SharedpreferenceHelper().saveUserName(namecontroller.text);
        await SharedpreferenceHelper().saveUserEmail(mailcontroller.text);
        await SharedpreferenceHelper().saveUserId(id);
        await DatabaseMethods().addUserInfo(userInfoMap, id);
        await SharedpreferenceHelper().saveUserWallet("100");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              'Registered Successfully',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
          ),
        );

        widget.redirect == "owner"
            ? Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HotelDetail()),
              )
            : Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Bottomnav()),
              );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.orangeAccent,
              content: Text(
                'Password Provided is too Weak',
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          );
        } else if (e.code == "email-already-in-use") {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.orangeAccent,
              content: Text(
                'Account Already exists',
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          );
        }
      } finally {
        setState(() {
          isLoading = false;
        });
      }
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(195, 255, 255, 255),

      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: const Color.fromARGB(255, 2, 65, 117),
                strokeWidth: 4,
              ),
            )
          : Container(
              margin: EdgeInsets.only(top: 40.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Image.asset(
                        'images/signup.jpg',
                        height: 200,
                        width: 250,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Center(
                      child: Text(
                        'Sign Up',
                        style: AppWidget.headlinetextstyle(25.0),
                      ),
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
                      child: Text(
                        'UserName',
                        style: AppWidget.normaltextstyle(20.0),
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Container(
                      margin: EdgeInsets.only(left: 30.0, right: 30.0),
                      decoration: BoxDecoration(
                        color: Color(0xFFececf8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        controller: namecontroller,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: Icon(
                            Icons.person,
                            color: const Color.fromARGB(255, 2, 65, 117),
                          ),
                          hintText: 'Enter Username',
                          hintStyle: AppWidget.normaltextstyle(16.0),
                          contentPadding: EdgeInsets.symmetric(vertical: 15.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.only(left: 30.0),
                      child: Text(
                        'Email',
                        style: AppWidget.normaltextstyle(20.0),
                      ),
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
                      child: Text(
                        'Password',
                        style: AppWidget.normaltextstyle(20.0),
                      ),
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
                    SizedBox(height: 20.0),
                    GestureDetector(
                      onTap: () async {
                        if (namecontroller.text != "" &&
                            mailcontroller.text != "" &&
                            passwordcontroller.text != "") {
                          setState(() {
                            email = mailcontroller.text;
                            password = passwordcontroller.text;
                          });
                          await registration();
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
                            color: const Color.fromARGB(255, 3, 118, 7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          width: MediaQuery.of(context).size.width / 2,
                          child: Center(
                            child: Text(
                              'Sign Up',
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
                          'Already have an account?',
                          style: AppWidget.normaltextstyle(20.0),
                        ),

                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    LogIn(redirect: widget.redirect),
                              ),
                            );
                          },

                          child: Text(
                            'Login',
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
