import 'package:flutter/material.dart';

import '../utils/utils.dart';

class Loading extends StatelessWidget {
  // const Loading({Key? key}) : super(key: key);
  const Loading();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(themeColor),
        ),
      ),
      color: Colors.white.withOpacity(0.8),
    );
  }
}
