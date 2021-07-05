import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_application/data/models/user_chat.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../widgets/loading.dart';
import '../utils/utils.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../application.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, required this.currentUserId}) : super(key: key);

  final String currentUserId;

  @override
  _HomeScreenState createState() =>
      _HomeScreenState(currentUserId: currentUserId);
}

class _HomeScreenState extends State<HomeScreen> {
  _HomeScreenState({Key? key, required this.currentUserId});

  final String currentUserId;
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final ScrollController listScrollController = ScrollController();

  int _limit = 20;
  int _limitIncrement = 20;
  bool isLoading = false;
  List<Choice> choices = const <Choice>[
    const Choice(title: 'Settings', icon: Icons.settings),
    const Choice(title: 'Log out', icon: Icons.exit_to_app),
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    registerNotification();
    configLocalNotification();
    listScrollController.addListener((scrollListener));
  }

  void registerNotification() {}

  void configLocalNotification() {}

  void scrollListener() {
    if (listScrollController.offset >=
            listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

  void onItemMenuPress(Choice choice) {
    if (choice.title == "Log out") {
      handleSignOut();
    } else {
      // Navigator.push(context, MaterialPageRoute(builder: (context) => ChatSetting()));
    }
  }

  void showNotification(RemoteNotification remoteNotification) async {}

  Future<bool> onBackPress() {
    openDialog();
    return Future.value(false);
  }

  Future<Null> openDialog() async {
    switch (await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            contentPadding: EdgeInsets.all(0),
            children: <Widget>[
              Container(
                color: themeColor,
                margin: EdgeInsets.all(0),
                padding: EdgeInsets.only(bottom: 10, top: 10),
                height: 100,
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.exit_to_app,
                        size: 30,
                        color: Colors.white,
                      ),
                      margin: EdgeInsets.only(bottom: 10),
                    ),
                    Text(
                      "Exit app",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Are you sure to exit app?",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 0);
                },
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.cancel,
                        color: primaryColor,
                      ),
                      margin: EdgeInsets.only(right: 10.0),
                    ),
                    Text(
                      "Cancel",
                      style: TextStyle(
                          color: primaryColor, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 1);
                },
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.check_circle,
                        color: primaryColor,
                      ),
                      margin: EdgeInsets.only(right: 10.0),
                    ),
                    Text(
                      "Cancel",
                      style: TextStyle(
                          color: primaryColor, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              )
            ],
          );
        })) {
      case 0:
        break;
      case 1:
        exit(0);
    }
  }

  Future<Null> handleSignOut() async {
    this.setState(() {
      isLoading = true;
    });

    await FirebaseAuth.instance.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();

    this.setState(() {
      isLoading = false;
    });

    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => Application()),
        (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "HOME CHAT",
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: <Widget>[
          PopupMenuButton<Choice>(
              onSelected: onItemMenuPress,
              itemBuilder: (BuildContext context) {
                return choices.map((Choice choice) {
                  return PopupMenuItem<Choice>(
                      value: choice,
                      child: Row(
                        children: <Widget>[
                          Icon(
                            choice.icon,
                            color: primaryColor,
                          ),
                          Container(
                            width: 10.0,
                          ),
                          Text(
                            choice.title,
                            style: TextStyle(color: primaryColor),
                          )
                        ],
                      ));
                }).toList();
              })
        ],
      ),
      body: WillPopScope(
        child: Stack(
          children: <Widget>[
            Container(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .limit(_limit)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      padding: EdgeInsets.all(10),
                      itemBuilder: (context, index) =>
                          buildItem(context, snapshot.data?.docs[index])!,
                      itemCount: snapshot.data?.docs.length,
                      controller: listScrollController,
                    );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      ),
                    );
                  }
                },
              ),
            ),
            Positioned(child: isLoading ? Loading() : Container())
          ],
        ),
        onWillPop: onBackPress,
      ),
    );
  }

  Widget? buildItem(BuildContext context, DocumentSnapshot? document) {
    if (document != null) {
      UserChat userChat = UserChat.fromDocument(document);
      if (userChat.id == currentUserId) {
        return SizedBox.shrink();
      } else {
        return Container(
          child: TextButton(
            child: Row(
              children: <Widget>[
                // Material(
                //   child: userChat.photoUrl.isNotEmpty
                //       ? Image.network(
                //           userChat.photoUrl,
                //           fit: BoxFit.cover,
                //           width: 50,
                //           height: 50,
                //           loadingBuilder: (BuildContext context, Widget child,
                //               ImageChunkEven? loadingProgress) {
                //             if (loadingProgress == null) return child;
                //             return Container(
                //               width: 50,
                //               height: 50,
                //               child: Center(
                //                 child: CircularProgressIndicator(
                //                   color: primaryColor,
                //                   // value: loadingProgress.expected,
                //                 ),
                //               ),
                //             );
                //           },
                //           errorBuilder: (context, object, stackTrace) {
                //             return Icon(
                //               Icons.account_circle,
                //               size: 50,
                //               color: greyColor,
                //             );
                //           },
                //         )
                //       : Icon(Icons.account_circle, size: 50, color: greyColor),
                //   borderRadius: BorderRadius.all(Radius.circular(25)),
                //   clipBehavior: Clip.hardEdge,
                // ),
                Flexible(
                    child: Container(
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: Text(
                          'Nickname: ${userChat.nickname}',
                          maxLines: 1,
                          style: TextStyle(color: primaryColor),
                        ),
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(10, 0, 0, 5),
                      ),
                      Container(
                        child: Text(
                          'About me: ${userChat.aboutMe}',
                          maxLines: 1,
                          style: TextStyle(color: primaryColor),
                        ),
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                      )
                    ],
                  ),
                  margin: EdgeInsets.only(left: 20),
                ))
              ],
            ),
            onPressed: () {
              // Navigator.push(context, MaterialPageRoute(builder: (context) => Chat()))
            },
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(greyColor2),
                shape: MaterialStateProperty.all<OutlinedBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))))),
          ),
          margin: EdgeInsets.only(bottom: 10, left: 5, right: 5),
        );
      }
    } else {
      return SizedBox.shrink();
    }
  }
}

class Choice {
  const Choice({required this.title, required this.icon});

  final String title;
  final IconData icon;
}
