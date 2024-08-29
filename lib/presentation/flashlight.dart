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
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool isMicOn = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initializeBluetooth();
  }

  void _initializeBluetooth() async {
    // Start scanning
    flutterBlue.startScan(timeout: Duration(seconds: 4));

    // Listen to scan results
    var subscription = flutterBlue.scanResults.listen((results) {
      for (ScanResult r in results) {
        if (r.device.name == "Bluetooth Lightbulb Systemm") {
          //print('Found target device: ${r.device.name}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
          content: Text('Found target device: ${r.device.name}')
        ),
      );
          targetDevice = r.device;
          _connectToDevice();
          break;
        }
      }
    });

    // Stop scanning
    flutterBlue.stopScan();
  }

  void _connectToDevice() async {
    if (targetDevice == null) return;

    await targetDevice!.connect();
     ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(' not Connected to ${targetDevice!.name}')
        ),
      );

    List<BluetoothService> services = await targetDevice!.discoverServices();
    services.forEach((service) {
      service.characteristics.forEach((characteristic) {
        if (characteristic.properties.write) {
          writeCharacteristic = characteristic;
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(' not Connected to ${targetDevice!.name}')
              ),
            );
        }
      });
    });
  }

  void _sendCommand(String command) {
    if (writeCharacteristic != null) {
      List<int> bytes = command.codeUnits;
      writeCharacteristic!.write(bytes);
    } else {
      
    }
  }

  void _toggleFlashlight() {
    setState(() {
      isFlashlightOn = !isFlashlightOn;
      _sendCommand(isFlashlightOn ? '1' : '0');
    });
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
            onTap: () {
              setState(() {
                isMicOn = !isMicOn;
              });
            },
            child: AvatarGlow(
              glowColor: isFlashlightOn ? Colors.black : Colors.white,
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
                    color: isFlashlightOn ? Colors.black : Colors.white,
                    width: 2.0,
                  ),
                ),
                child: const Icon(Icons.mic, size: 50,)
              ),
            )
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
                onPressed: _toggleFlashlight,
                color: Colors.white,
              ),
              Text(
                isFlashlightOn ? "Tap to off-light" : "Tap to on-light",
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