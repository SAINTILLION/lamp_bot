import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class FlashlightScreen extends StatefulWidget {
  const FlashlightScreen({Key? key}) : super(key: key);

  @override
  State<FlashlightScreen> createState() => _FlashlightScreenState();
}

class _FlashlightScreenState extends State<FlashlightScreen> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothDevice? targetDevice;
  BluetoothCharacteristic? writeCharacteristic;
  bool isFlashlightOn = false;
  bool isConnected = false;
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool isMicOn = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _scanAndConnect();
  }

  void _scanAndConnect() async {
    flutterBlue.scanResults.listen((results) {
      for (ScanResult result in results) {
        if (result.device.name == "Lightbulb System") {
          targetDevice = result.device;
          _connectToDevice();
          break;
        }
      }
    });
    flutterBlue.startScan(timeout: const Duration(seconds: 4));
  }

  void _connectToDevice() async {
    if (targetDevice == null) return;

    await targetDevice!.connect();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Connected to ${targetDevice!.name}')
      ),
    );

    List<BluetoothService> services = await targetDevice!.discoverServices();
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        if (characteristic.properties.write) {
          writeCharacteristic = characteristic;
          setState(() {
            isConnected = true;
          });
          return;
        }
      }
    }
  }

  void _toggleFlashlight() {
    if (writeCharacteristic != null) {
      setState(() {
        isFlashlightOn = !isFlashlightOn;
      });
      writeCharacteristic!.write(utf8.encode(isFlashlightOn ? '1' : '0'));
    }
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) => print('onStatus: $status'),
        onError: (errorNotification) => print('onError: $errorNotification'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            if (result.finalResult) {
              if (result.recognizedWords.toLowerCase().contains('on')) {
                _toggleFlashlight();
              } else if (result.recognizedWords.toLowerCase().contains('off')) {
                _toggleFlashlight();
              }
            }
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        toolbarHeight: 120,
        title: Align(
          alignment: Alignment.topRight,
          child: InkWell(
            onTap: _listen,
            child: AvatarGlow(
              glowColor: isFlashlightOn ? Colors.black : Colors.white,
              glowShape: BoxShape.circle,
              glowRadiusFactor: 3,
              animate: _isListening,
              startDelay: Duration.zero,
              duration: const Duration(milliseconds: 2000),
              glowCount: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isFlashlightOn ? Colors.black : Colors.white,
                    width: 2.0,
                  ),
                ),
                child: const Icon(Icons.mic, size: 50),
              ),
            ),
          ),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: isFlashlightOn ? Colors.white : Colors.black,
        foregroundColor: isFlashlightOn ? Colors.black : Colors.white,
      ),
      backgroundColor: isFlashlightOn ? Colors.white : Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                  isFlashlightOn ? Icons.flashlight_on : Icons.flashlight_off_outlined,
                  color: isFlashlightOn ? Colors.blue : Colors.white,
                  size: 300,
                ),
                onPressed: isConnected ? _toggleFlashlight : null,
                color: Colors.white,
              ),
              Text(
                isConnected
                    ? (isFlashlightOn ? "Tap to off-light" : "Tap to on-light")
                    : "Connecting to device...",
                style: TextStyle(
                  color: isFlashlightOn ? Colors.black : Colors.white,
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