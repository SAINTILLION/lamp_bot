import 'package:flutter/material.dart';

class FlashlightScreen extends StatefulWidget {
  const FlashlightScreen({super.key});

  @override
  State<FlashlightScreen> createState() => _FlashlightScreenState();
}

class _FlashlightScreenState extends State<FlashlightScreen> {
  String state = "OFF";
  @override
  Widget build(BuildContext context) {
    String state = "OFF";
    const String instruction = "tap to on-light";
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        toolbarHeight: 120,
        title: Align(
          alignment: Alignment.topRight,
          child: InkWell(
            onTap: () {
              //Add functionality for speeh recognition
            },
            child: Container(
               decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white, // Border color
                  width: 2.0, // Border width
                ),
              ),
              child: const Icon(Icons.mic, size: 100,)
            )
          ),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        
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
                instruction,
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