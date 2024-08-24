import 'package:flutter/material.dart';

class FlashlightScreen extends StatelessWidget {
  const FlashlightScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions:[
          Container(
            decoration: const BoxDecoration(
              color: Colors.white
            )
          )
        ],
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Flashlight icon
              IconButton(
                icon: const Icon(Icons.flashlight_off_outlined, size: 300),
                onPressed: () {},
                color: Colors.white,
              ),
              // Text indicating tap to on-light
              const Text(
                'Tap to on-light',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}