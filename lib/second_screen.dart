import 'package:flutter/material.dart';

class SecondScreen extends StatelessWidget {
  final String payload;
  const SecondScreen({Key? key, required this.payload}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("JustWater"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 100),
              child: Image.asset(
                "assets/images/justwater.png",
              ),
            ),
            Text(payload)
          ],
        ),
      ),
    );
  }
}