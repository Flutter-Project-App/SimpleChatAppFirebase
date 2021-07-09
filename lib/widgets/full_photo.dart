import 'package:flutter/material.dart';
import '../utils/utils.dart';
import 'package:photo_view/photo_view.dart';

class FullPhoto extends StatelessWidget {
  const FullPhoto({Key? key, required this.url}) : super(key: key);

  final String url;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "FULL PHOTO",
          style: TextStyle(color: headerColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: themeColor,
        centerTitle: true,
      ),
      body: FullPhotoScreen(url: url),
    );
  }
}

class FullPhotoScreen extends StatefulWidget {
  const FullPhotoScreen({Key? key, required this.url}) : super(key: key);
  final String url;

  @override
  _FullPhotoScreenState createState() => _FullPhotoScreenState(url: url);
}

class _FullPhotoScreenState extends State<FullPhotoScreen> {
  final String url;
  _FullPhotoScreenState({Key? key, required this.url});

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(child: PhotoView(imageProvider: NetworkImage(url),),);
  }
}

