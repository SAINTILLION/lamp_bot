import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:avatar_glow/avatar_glow.dart';

class FlashlightScreen extends StatefulWidget {
  const FlashlightScreen({Key? key}) : super(key: key);

  @override
  State<FlashlightScreen> createState() => _FlashlightScreenState();
}

class _FlashlightScreenState extends State<FlashlightScreen> {
  bool isFlashlightOn = false;
  late stt.SpeechToText _speech;
  bool isMicOn = false;
  BluetoothDevice? device;
  BluetoothCharacteristic? characteristic;
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    if (await Permission.bluetooth.isGranted &&
        await Permission.bluetoothScan.isGranted &&
        await Permission.bluetoothConnect.isGranted &&
        await Permission.location.isGranted) {
      _initBluetooth();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bluetooth and Location permissions are required.')),
      );
    }
  }

  Future<void> _initBluetooth() async {
    FlutterBluePlus.adapterState.listen((state) {
      if (state == BluetoothAdapterState.on) {
        _scanAndConnect();
      }
    });

    if (await FlutterBluePlus.isSupported) {
      await FlutterBluePlus.turnOn();
    }
  }

  Future<void> _scanAndConnect() async {
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult r in results) {
        if (r.device.platformName == 'Lightbulb System') {
          _connectToDevice(r.device);
          break;
        }
      }
    });
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      setState(() {
        this.device = device;
        isConnected = true;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connected to the Lightbulb System.')),
        );

      });
      _discoverServices();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An issue has occurred')),
      );
    }
  }

  Future<void> _discoverServices() async {
    List<BluetoothService> services = await device!.discoverServices();
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic c in service.characteristics) {
        if (c.properties.write) {
          characteristic = c;
          break;
        }
      }
      if (characteristic != null) break;
    }
  }

  void _toggleFlashlight() {
    if (isConnected && characteristic != null) {
      setState(() {
        isFlashlightOn = !isFlashlightOn;
        _writeCharacteristic(isFlashlightOn ? '1' : '0');
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not connected to the Lightbulb System.')),
      );
    }
  }

  Future<void> _writeCharacteristic(String value) async {
    if (characteristic != null) {
      await characteristic!.write(value.codeUnits);
    }
  }

  void _handleMicTap() async {
    if (isConnected && characteristic != null) {
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
                _writeCharacteristic('1');
              });
            } else if (result.recognizedWords.toLowerCase() == 'off') {
              setState(() {
                isFlashlightOn = false;
                _writeCharacteristic('0');
              });
            }
          });
        }
      } else {
        _speech.stop();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not connected to the Lightbulb System.')),
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
              Text(
                (isConnected == true) ? "Lightbulb System conncected" : "Lightbulb System not connected",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)
              ),
              InkWell(
                onTap: _handleMicTap,
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
                    child: const Icon(Icons.mic, size: 50),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _scanAndConnect,
              ),
            ],
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

  @override
  void dispose() {
    FlutterBluePlus.stopScan();
    device?.disconnect();
    super.dispose();
  }
}