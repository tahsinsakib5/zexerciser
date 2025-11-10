// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:zexerciser/menu_selection_activity.dart';

// class MainActivity extends StatefulWidget {
//   final BluetoothDevice device;
//   final ExerciseConfig config;

//   const MainActivity({Key? key, required this.device, required this.config}) : super(key: key);

//   @override
//   _MainActivityState createState() => _MainActivityState();
// }

// class _MainActivityState extends State<MainActivity> {
//   BluetoothCharacteristic? _txCharacteristic;
//   BluetoothCharacteristic? _rxCharacteristic;
//   bool _connected = false;
//   final AudioPlayer _audioPlayer = AudioPlayer();
  
//   // Counters
//   int _scissorCount = 0, _pencilCount = 0, _pincherCount = 0, _buttonCount = 0;

//   final Map<String, String> _colorMap = {
//     'RED': 'A', 'GREEN': 'B', 'BLUE': 'C', 'MAGENTA': 'D',
//     'YELLOW': 'E', 'CYAN': 'F', 'WHITE': 'J', 'NO COLOR': 'K',
//   };

//   final Map<String, String> _musicMap = {
//     'ABC MUSIC BOX': 'abc_music_box',
//     'HAPPY': 'happy',
//     'TWINKLE TWINKLE LITTLE STAR': 'twinkle_little_star',
//     // Add more music files...
//   };

//   @override
//   void initState() {
//     super.initState();
//     _connectToDevice();
//   }

//   Future<void> _connectToDevice() async {
//     try {
//       await widget.device.connect();
//       setState(() {
//         _connected = true;
//       });

//       List<BluetoothService> services = await widget.device.discoverServices();
      
//       for (BluetoothService service in services) {
//         if (service.uuid.toString().toLowerCase().contains('ffe0')) {
//           for (BluetoothCharacteristic characteristic in service.characteristics) {
//             if (characteristic.uuid.toString().toLowerCase().contains('ffe1')) {
//               _txCharacteristic = characteristic;
//               _rxCharacteristic = characteristic;
              
//               // Enable notifications
//               await _rxCharacteristic!.setNotifyValue(true);
//               _rxCharacteristic!.onValueReceived.listen((value) {
//                 _handleData(value);
//               });
              
//               // Send initial command
//               await _sendCommand('0');
//               break;
//             }
//           }
//         }
//       }
//     } catch (e) {
//       print('Connection error: $e');
//     }
//   }

//   void _handleData(List<int> data) {
//     String dataString = String.fromCharCodes(data);
//     print('Received data: $dataString');

//     if (dataString.contains('scissor~') && widget.config.chkScissor) {
//       _handleScissorPress();
//     } else if (dataString.contains('pencil_1~') && widget.config.chkPencil) {
//       _handlePencilPress();
//     } else if (dataString.contains('pincher~') && widget.config.chkPincher) {
//       _handlePincherPress();
//     } else if (dataString.contains('button~') && widget.config.chkButton) {
//       _handleButtonPress();
//     }
//   }

//   void _handleScissorPress() {
//     setState(() {
//       _scissorCount++;
//     });
    
//     if (widget.config.musicScissor) {
//       _playSound('scissor');
//     }
    
//     if (!widget.config.noLed) {
//       _sendCommand(_colorMap['RED']!); // Use selected color from spinner
//     } else {
//       _sendCommand('K');
//     }
//   }

//   // Add similar methods for pencil, pincher, button...

//   Future<void> _playSound(String type) async {
//     String? musicFile = _musicMap['HAPPY']; // Use selected music from spinner
//     if (musicFile != null) {
//       await _audioPlayer.play(AssetSource('sounds/$musicFile.mp3'));
//     }
//   }

//   Future<void> _sendCommand(String command) async {
//     if (_txCharacteristic != null) {
//       await _txCharacteristic!.write(utf8.encode(command));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Exercise'),
//         actions: [
//           IconButton(
//             icon: Icon(_connected ? Icons.bluetooth_connected : Icons.bluetooth_disabled),
//             onPressed: _toggleConnection,
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Text('Mode: ${widget.config.modeName}', style: TextStyle(fontSize: 18)),
//             SizedBox(height: 20),
//             Text('Connection: ${_connected ? 'Connected' : 'Disconnected'}'),
//             SizedBox(height: 20),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 _counterWidget('Scissor', _scissorCount),
//                 _counterWidget('Pencil', _pencilCount),
//               ],
//             ),
//             SizedBox(height: 20),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 _counterWidget('Pincher', _pincherCount),
//                 _counterWidget('Button', _buttonCount),
//               ],
//             ),
//             Spacer(),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 ElevatedButton(
//                   onPressed: _goToMenu,
//                   child: Text('Menu'),
//                 ),
//                 ElevatedButton(
//                   onPressed: _quitApp,
//                   child: Text('Quit'),
//                   style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _counterWidget(String label, int count) {
//     return Column(
//       children: [
//         Text(label, style: TextStyle(fontSize: 16)),
//         Text('$count', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
//       ],
//     );
//   }

//   void _toggleConnection() {
//     if (_connected) {
//       widget.device.disconnect();
//       setState(() {
//         _connected = false;
//       });
//     } else {
//       _connectToDevice();
//     }
//   }

//   void _goToMenu() {
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//         builder: (context) => MenuSelectionActivity(device: widget.device),
//       ),
//     );
//   }

//   void _quitApp() {
//     _sendCommand('1');
//     widget.device.disconnect();
//     // Close app (note: may not work on all platforms)
//   }

//   @override
//   void dispose() {
//     _audioPlayer.dispose();
//     widget.device.disconnect();
//     super.dispose();
//   }
// }