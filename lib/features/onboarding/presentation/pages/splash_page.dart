import 'package:flutter/material.dart';

import '../../../../core/config/assets.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Image.asset(Assets.splashImage),
      ),
    );
  }
}