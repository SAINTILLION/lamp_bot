import 'package:flutter/material.dart';
import 'package:lamp_bot/presentation/linear_gradient.dart';
import 'package:lamp_bot/presentation/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lamp Bot',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Dark background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/lamp_bot.jpeg',
              width: 100,
              height: 100,
            ),
            const Text(
              'Lamp Bot',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.all(50.0),
              child: Text(
                'Log in to control your smart lamps from anywhere',
                style: TextStyle(
                  color: Color.fromARGB(255, 130, 123, 123),
                  fontSize: 16,
                  fontWeight: FontWeight.bold
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Sign up button logic
              },
              child:SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                child: const Center(child: Text('sign up')),
              )
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Sign up button logic
                Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginScreen()));
              },
              child:SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                child: const Center(child: Text('Log In')),
              )
            ),
          ],
        ),
      ),
    );
  }
}