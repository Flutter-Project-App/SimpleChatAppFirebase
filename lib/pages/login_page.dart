import 'dart:async';

import 'package:ChatApp/data/models/user_chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../widgets/loading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_page.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  SharedPreferences? prefs;

  bool isLoading = false;
  bool isLoggedIn = false;
  User? currentUser;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isSignedIn();
  }

  void isSignedIn() async {
    this.setState(() {
      isLoading = true;
    });

    prefs = await SharedPreferences.getInstance();

    isLoggedIn = await googleSignIn.isSignedIn();
    if (isLoggedIn && prefs?.getString('id') != null) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => HomeScreen(
                    currentUserId: prefs!.getString('id') ?? "",
                  )));
    }

    this.setState(() {
      isLoading = false;
    });
  }

  Future<Null> handleSignInGoogle() async {
    prefs = await SharedPreferences.getInstance();

    this.setState(() {
      isLoading = true;
    });

    GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser != null) {
      GoogleSignInAuthentication? googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

      User? firebaseUser =
          (await firebaseAuth.signInWithCredential(credential)).user;

      if (firebaseUser != null) {
        final QuerySnapshot result = await FirebaseFirestore.instance
            .collection('users')
            .where('id', isEqualTo: firebaseUser.uid)
            .get();
        final List<DocumentSnapshot> documents = result.docs;
        if (documents.length == 0) {
          FirebaseFirestore.instance
              .collection('users')
              .doc(firebaseUser.uid)
              .set({
            'nickname': firebaseUser.displayName,
            'photoUrl': firebaseUser.photoURL,
            'id': firebaseUser.uid,
            'createAt': DateTime.now().millisecondsSinceEpoch.toString(),
            'chattingWith': null
          });

          // Write data to local
          currentUser = firebaseUser;
          await prefs?.setString('id', currentUser!.uid);
          await prefs?.setString('nickname', currentUser!.displayName ?? "");
          await prefs?.setString('photoUrl', currentUser!.photoURL ?? "");
        } else {
          DocumentSnapshot documentSnapshot = documents[0];
          UserChat userChat = UserChat.fromDocument(documentSnapshot);

          await prefs?.setString('id', userChat.id);
          await prefs?.setString('nickname', userChat.id);
          await prefs?.setString('photoUrl', userChat.id);
          await prefs?.setString('aboutMe', userChat.id);
        }

        Fluttertoast.showToast(msg: "Sign in success");
        this.setState(() {
          isLoading = false;
        });

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => HomeScreen(
                      currentUserId: firebaseUser.uid,
                    )));
      } else {
        Fluttertoast.showToast(msg: "Sign in failed");
        this.setState(() {
          isLoading = false;
        });
      }
    } else {
      Fluttertoast.showToast(msg: "Can not init google sign in");
      this.setState(() {
        isLoading = false;
      });
    }
  }

  Future<Null> handleSignInApple() async {
    final credential = await SignInWithApple.getAppleIDCredential(scopes: [
      AppleIDAuthorizationScopes.email,
      AppleIDAuthorizationScopes.fullName,

    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(color: headerColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: themeColor,
        centerTitle: true,
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          Container(
            child: Image.asset(
              'assets/icons/appchat.png',
              height: MediaQuery.of(context).size.width / 2,
              width: MediaQuery.of(context).size.width / 2,
              fit: BoxFit.cover,
            ),
            padding: EdgeInsets.only(top: 50),
          ),
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: MediaQuery.of(context).size.height / 3,),
                TextButton(
                  onPressed: () => handleSignInGoogle().catchError((err) {
                    Fluttertoast.showToast(msg: err.toString());
                    this.setState(() {
                      isLoading = false;
                    });
                  }),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        child: Image.asset('assets/icons/google.png'),
                        color: Colors.white,
                        width: 45,
                      ),
                      SizedBox(width: 18,),
                      Text(
                        "SIGN IN WITH GOOGLE",
                        style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  style: ButtonStyle(
                      backgroundColor:
                      MaterialStateProperty.all<Color>(Color(0xff4285f4)),
                      padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.only(right: 18, left: 3, top: 3, bottom: 3))
                  ),
                ),
                SizedBox(height: 30,),
                TextButton(
                  onPressed: () => handleSignInApple().catchError((err) {
                    Fluttertoast.showToast(msg: err.toString());
                    this.setState(() {
                      isLoading = false;
                    });
                  }),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        child: Image.asset('assets/icons/facebook.png'),
                        color: Colors.white,
                        width: 45,
                      ),
                      SizedBox(width: 13,),
                      Text(
                        "LOG IN WITH FACEBOOK",
                        style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  style: ButtonStyle(
                      backgroundColor:
                      MaterialStateProperty.all<Color>(Color(0xff3e5994)),
                      padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.only(right: 10, left: 3, top: 3, bottom: 3))
                  ),
                ),
                SizedBox(height: 30,),
                TextButton(
                  onPressed: () => handleSignInApple().catchError((err) {
                    Fluttertoast.showToast(msg: err.toString());
                    this.setState(() {
                      isLoading = false;
                    });
                  }),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        child: Image.asset('assets/icons/apple.png'),
                        color: Colors.white,
                        width: 45,
                      ),
                      SizedBox(width: 24,),
                      Text(
                        "SIGN IN WITH APPLE",
                        style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  style: ButtonStyle(
                      backgroundColor:
                      MaterialStateProperty.all<Color>(Color(0xff000000)),
                      padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.only(right: 30, left: 3, top: 3, bottom: 3))
                  ),
                ),
              ],
            )
          ),
          Positioned(child: isLoading ? const Loading() : Container())
        ],
      ),
    );
  }
}
