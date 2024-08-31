import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
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
  bool isMicOn = false;
  BluetoothConnection? connection;
  bool isConnected = false;
  BluetoothDevice? device; // Store the Bluetooth device

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _requestBluetoothPermissions(); // Request permissions at runtime
  }

  Future<void> _requestBluetoothPermissions() async {
    // Requesting Bluetooth permissions
    if (await Permission.bluetooth.isDenied) {
      await Permission.bluetooth.request();
    }

    if (await Permission.bluetoothScan.isDenied) {
      await Permission.bluetoothScan.request();
    }

    if (await Permission.bluetoothConnect.isDenied) {
      await Permission.bluetoothConnect.request();
    }

    if (await Permission.location.isDenied) {
      await Permission.location.request();
    }

    // After permissions are granted, attempt to connect to Bluetooth
    if (await Permission.bluetooth.isGranted &&
        await Permission.bluetoothScan.isGranted &&
        await Permission.bluetoothConnect.isGranted &&
        await Permission.location.isGranted) {
      _connectToBluetooth();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bluetooth and Location permissions are required.'),
        ),
      );
    }
  }

  Future<void> _connectToBluetooth() async {
    // Find the device to connect to
    List<BluetoothDevice> devices =
        await FlutterBluetoothSerial.instance.getBondedDevices();
    device = devices.firstWhere(
        (d) => d.name == 'Lightbulb Systemm',
        orElse: () => devices.first);

    if (device == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Device not found, switch on bluetooth and refresh'),
        ),
      );
      return;
    }

    try {
      BluetoothConnection.toAddress(device!.address).then((connection) {
        this.connection = connection;
        
        setState(() {
          isConnected = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully connected to the Lightbulb Systemm!'),
          ),
        );
        connection.input?.listen((Uint8List data) {
    
        }).onDone(() {
          setState(() {
            isConnected = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
            content: Text('Disconnected from the Lightbulb Systemm.'),
        ),
      );
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

  void _toggleFlashlight() {
    if (isConnected && device?.name == 'Lightbulb Systemm') {
      setState(() {
        isFlashlightOn = !isFlashlightOn;
        _sendBluetoothMessage(isFlashlightOn ? '1' : '0');
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not connected to the Lightbulb Systemm.'),
        ),
      );
    }
  }

  void _handleMicTap() async {
    if (isConnected && device?.name == 'Lightbulb Systemm') {
      setState(() {
        isMicOn = !isMicOn;
      });

      if (isMicOn) {
        bool available = await _speech.initialize();
        if (available) {
          _speech.listen(onResult: (result) {
            if (result.recognizedWords.toLowerCase() == 'on') {
              setState(() {
                isFlashlightOn = true;
                _sendBluetoothMessage('1');
              });
            } else if (result.recognizedWords.toLowerCase() == 'off') {
              setState(() {
                isFlashlightOn = false;
                _sendBluetoothMessage('0');
              });
            }
          });
        }
      } else {
        _speech.stop();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not connected to the Lightbulb Systemm.'),
        ),
      );
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: _handleMicTap,
                child: AvatarGlow(
                  glowColor:
                      isFlashlightOn == false ? Colors.white : Colors.black,
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
                        color: isFlashlightOn == false
                            ? Colors.white
                            : Colors.black,
                        width: 2.0,
                      ),
                    ),
                    child: const Icon(
                      Icons.mic,
                      size: 50,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  setState(() {
                    _requestBluetoothPermissions();
                  });
                },
              ),
            ],
          ),
        ),
        automaticallyImplyLeading: false,
        backgroundColor:
            isFlashlightOn == false ? Colors.black : Colors.white,
        foregroundColor:
            isFlashlightOn == false ? Colors.white : Colors.black,
      ),
      backgroundColor:
          isFlashlightOn == false ? Colors.black : Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                  isFlashlightOn == false
                      ? Icons.flashlight_off_outlined
                      : Icons.flashlight_on,
                  color:
                      isFlashlightOn == false ? Colors.white : Colors.blue,
                  size: 300,
                ),
                onPressed: _toggleFlashlight,
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
