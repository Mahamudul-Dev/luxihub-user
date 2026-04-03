

import 'package:flutter/material.dart';

import '../../../../core/config/assets.dart';
import '../../../../core/config/utils.dart';

class Onboarding1Widget extends StatelessWidget {
  const Onboarding1Widget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Utils.defaultPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // image
        Image.asset(Assets.onboardingImage1, width: 200, height: 200),
        // title
        Text(
          'Best Solution for Every House Problems',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        // description
        Text(
          'We provide the best solution for every house problems with our professional and experienced team.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: 16,
          ),
        ),
        ],
      ),
    );
  }
}