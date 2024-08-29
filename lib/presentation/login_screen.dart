import 'package:flutter/material.dart';
import 'package:lamp_bot/presentation/flashlight.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:  const Color(0xFF121212),
        foregroundColor: Colors.white,
        title: Center(
          child: Row(
            children: [
               Image.asset(
                'assets/images/lamp_bot.jpeg',
                width: 30,
                height: 30,
              ),
              const Text(
                'Lamp Bot',
                style: TextStyle(
                  color: Color.fromARGB(255, 89, 36, 98),
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ]
          ),
        )
      ),
      backgroundColor: Color(0xFF121212), // Dark background color
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
              'assets/images/lamp_bot.jpeg',
              width: 150,
              height: 150,
            ),
             const  Text(
                'Lamp Bot',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const TextField(
                decoration: InputDecoration(
                  hintText: 'Name',
                  hintStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              const TextField(
                decoration: InputDecoration(
                  hintText: 'Reg. Number',
                  hintStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 32),
              
              ElevatedButton(
                onPressed: () {
                  // Next button logic
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>FlashlightScreen()));
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text(
                  'Next',
                   style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}