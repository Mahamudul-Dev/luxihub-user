import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Row(
          children: [
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                'JD',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Text('data')
          ],
        ),
        ],
      ),
    );
  }
}