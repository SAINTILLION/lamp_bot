import 'package:flutter/material.dart';

class FlashlightScreen extends StatefulWidget {
  const FlashlightScreen({super.key});

  @override
  State<FlashlightScreen> createState() => _FlashlightScreenState();
}

class _FlashlightScreenState extends State<FlashlightScreen> {
  bool isFlashlightOn = false; //This means the light is off
  @override
  Widget build(BuildContext context) {
    
    Color background = Colors.black;
    Color active_state = Colors.white;
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
                  color:isFlashlightOn == false ? Colors.white : Colors.black,  // Border color
                  width: 2.0, // Border width
                ),
              ),
              child: const Icon(Icons.mic, size: 50,)
            )
          ),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: isFlashlightOn == false ? Colors.black : Colors.white,
        foregroundColor: isFlashlightOn == false ? Colors.white : Colors.black,
        
      ),
      backgroundColor: isFlashlightOn == false ? Colors.black : Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Flashlight icon
              IconButton(
                icon: Icon(
                  isFlashlightOn == false ? Icons.flashlight_off_outlined : Icons.flashlight_on, 
                  color: Colors.blue,
                  size: 300,
                ),
                onPressed: () {
                  setState(() {
                    isFlashlightOn = !isFlashlightOn;
                    background = Colors.white;
                    active_state = Colors.black;
                  });
                },
                color: Colors.white,
              ),
              // Text indicating tap to on-light
              Text(
                isFlashlightOn == false ? "Tap to on-light" : "Tap to off-light",
                style: TextStyle(
                  color: isFlashlightOn == false ? Colors.white : Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}