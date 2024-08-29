import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:convert';
import 'dart:typed_data';

class FlashlightScreen extends StatefulWidget {
  const FlashlightScreen({super.key});

  @override
  State<FlashlightScreen> createState() => _FlashlightScreenState();
}

class _FlashlightScreenState extends State<FlashlightScreen> {
  bool isFlashlightOn = false; // This means the light is off
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool isMicOn = false;
  BluetoothConnection? connection;
  bool isConnected = false;
  BluetoothDevice? device; // Store the Bluetooth device

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _connectToBluetooth();
  }

  Future<void> _connectToBluetooth() async {
    // Find the device to connect to
    List<BluetoothDevice> devices = await FlutterBluetoothSerial.instance.getBondedDevices();
    device = devices.firstWhere((d) => d.name == 'Lightbulb Systemm', orElse: () => devices.first);

    if (device == null) {
      ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Device not found.'),
        
  ),
);
      return;
    }

    try {
      BluetoothConnection.toAddress(device!.address).then((connection) {
        print('Connected to the device');
        this.connection = connection;
        isConnected = true;
        setState(() {});
        connection.input?.listen((Uint8List data) {
          print('Data incoming: ${ascii.decode(data)}');
        }).onDone(() {
          print('Disconnected by remote request');
          setState(() {
            isConnected = false;
          });
        });
      });
    } catch (e) {
      print('Error connecting to device: $e');
    }
  }

  void _sendBluetoothMessage(String message) {
    if (isConnected && connection != null) {
      connection!.output.add(Uint8List.fromList(utf8.encode(message)));
    }
  }

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
              setState(() {
                isMicOn = !isMicOn;
              });
            },
            child: AvatarGlow(
              glowColor: isFlashlightOn == false ? Colors.white : Colors.black,
              glowShape: BoxShape.circle,
              glowRadiusFactor: 3,
              animate: isMicOn,
              startDelay: Duration.zero,
              duration: const Duration(milliseconds: 2000),
              glowCount: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isFlashlightOn == false ? Colors.white : Colors.black,
                    width: 2.0,
                  ),
                ),
                child: const Icon(Icons.mic, size: 50,),
              ),
            ),
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
              IconButton(
                icon: Icon(
                  isFlashlightOn == false ? Icons.flashlight_off_outlined : Icons.flashlight_on,
                  color: isFlashlightOn == false ? Colors.white : Colors.blue,
                  size: 300,
                ),
                onPressed: () {
                  setState(() {
                    isFlashlightOn = !isFlashlightOn;
                    background = Colors.white;
                    active_state = Colors.black;
                    _sendBluetoothMessage(isFlashlightOn ? '1' : '0');
                  });
                },
                color: Colors.white,
              ),
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

  @override
  void dispose() {
    if (isConnected) {
      connection?.close();
    }
    super.dispose();
  }
}
