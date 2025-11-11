import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:zexerciser/menu_selection_activity.dart';

class MainActivity extends StatefulWidget {
  final BluetoothDevice device;
  final ExerciseConfig config;

  const MainActivity({Key? key, required this.device, required this.config}) : super(key: key);

  @override
  _MainActivityState createState() => _MainActivityState();
}

class _MainActivityState extends State<MainActivity> {
  BluetoothCharacteristic? _txCharacteristic;
  BluetoothCharacteristic? _rxCharacteristic;
  bool _connected = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  // Counters
  int _scissorCount = 0, _pencilCount = 0, _pincherCount = 0, _buttonCount = 0;
  
  // Repeat mode counters (decrementing)
  int _currentScissorCount = 0, _currentPencilCount = 0, _currentPincherCount = 0, _currentButtonCount = 0;

  final Map<String, String> _colorMap = {
    'RED': 'A', 'GREEN': 'B', 'BLUE': 'C', 'MAGENTA': 'D',
    'YELLOW': 'E', 'CYAN': 'F', 'YELLOW AND MAGENTA': 'G',
    'RED AND BLUE': 'H', 'BLUE AND RED': 'I', 'WHITE': 'J',
    'NO COLOR': 'K', 'RANDOM': 'L', 'CHANGING COLOR FORWARD': 'M',
    'CHANGING COLOR BACKWARD': 'N',
  };

  final Map<String, String> _musicMap = {
    'ABC MUSIC BOX': 'abc_music_box',
    'ABC SONG': 'abc_song',
    'Adventures': 'adventures',
    'AT THE FAIR': 'at_the_fair',
    'BAA BAA BLACK SHEEP': 'baa_baa_black_sheep',
    'BEACH': 'beach',
    'BENSOUND HAPPY ROCK': 'bensound_happyrock',
    'CARROUSEL': 'carrousel',
    'CIELO': 'cielo',
    'DIGITAL KID': 'digital_kid',
    'END OF SUMMER': 'end_of_summer',
    'HAPPY': 'happy',
    'HIGHWAY WILDFLOWERS': 'highway_wildflowers',
    'IF YOU HAPPY': 'if_you_happy',
    'JAMBALAYA': 'jambalaya',
    'JAZZ IN PARIS': 'jazz_in_paris',
    'LITTLE BOY': 'little_boy',
    'MY BONNIE': 'my_bonnie',
    'SPRING IN MY STEP': 'spring_in_my_step',
    'THE CREEK': 'the_creek',
    'TWINKLE TWINKLE LITTLE STAR': 'twinkle_little_star',
    'WATER LILLY': 'water_lily',
  };

  // Selected colors and music
  String _selectedScissorColor = 'RED';
  String _selectedPencilColor = 'GREEN'; 
  String _selectedPincherColor = 'BLUE';
  String _selectedButtonColor = 'MAGENTA';
  
  String _selectedScissorMusic = 'HAPPY';
  String _selectedPencilMusic = 'HAPPY';
  String _selectedPincherMusic = 'HAPPY';
  String _selectedButtonMusic = 'HAPPY';

  @override
  void initState() {
    super.initState();
    _connectToDevice();
    // Initialize repeat counters
    _currentScissorCount = widget.config.counts.scissor;
    _currentPencilCount = widget.config.counts.pencil;
    _currentPincherCount = widget.config.counts.pincher;
    _currentButtonCount = widget.config.counts.button;
  }

  Future<void> _connectToDevice() async {
    try {
      // CORRECTED: Use the proper connection method
      await widget.device.connect(autoConnect: false , timeout: Duration(seconds: 15));
      
      setState(() {
        _connected = true;
      });

      List<BluetoothService> services = await widget.device.discoverServices();
      
      for (BluetoothService service in services) {
        String serviceUuid = service.uuid.toString();
        print('Found service: $serviceUuid');
        
        if (serviceUuid.toLowerCase().contains('ffe0')) {
          for (BluetoothCharacteristic characteristic in service.characteristics) {
            String charUuid = characteristic.uuid.toString();
            print('Found characteristic: $charUuid');
            
            if (charUuid.toLowerCase().contains('ffe1')) {
              _txCharacteristic = characteristic;
              _rxCharacteristic = characteristic;
              
              // Enable notifications
              await _rxCharacteristic!.setNotifyValue(true);
              _rxCharacteristic!.onValueReceived.listen((value) {
                _handleData(value);
              });
              
              // Send initial command
              await _sendCommand('0');
              print('Connected and ready to receive data');
              break;
            }
          }
        }
      }

      if (_txCharacteristic == null) {
        print('HM-10 characteristic not found. Available services:');
        for (BluetoothService service in services) {
          print('Service: ${service.uuid}');
          for (BluetoothCharacteristic char in service.characteristics) {
            print('  Characteristic: ${char.uuid}');
          }
        }
      }

    } catch (e) {
      print('Connection error: $e');
      setState(() {
        _connected = false;
      });
    }
  }

  void _handleData(List<int> data) {
    String dataString = String.fromCharCodes(data);
    print('Received data: $dataString');

    if (dataString.contains('scissor~') && widget.config.chkScissor) {
      _handleScissorPress();
    } else if (dataString.contains('pencil_1~') && widget.config.chkPencil) {
      _handlePencilPress();
    } else if (dataString.contains('pincher~') && widget.config.chkPincher) {
      _handlePincherPress();
    } else if (dataString.contains('button~') && widget.config.chkButton) {
      _handleButtonPress();
    }
  }

  void _handleScissorPress() {
    bool shouldPlayMusic = true;
    
    if (widget.config.repeatMode) {
      setState(() {
        _currentScissorCount--;
      });
      
      if (_currentScissorCount == 0) {
        shouldPlayMusic = true;
        _currentScissorCount = widget.config.mode == 6 ? 3 : 5;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Scissor exercise completed!'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        shouldPlayMusic = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Press Scissor $_currentScissorCount more times'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }

    if (!widget.config.repeatMode || shouldPlayMusic) {
      setState(() {
        _scissorCount++;
      });
      
      if (widget.config.musicScissor && shouldPlayMusic) {
        _playSound(_selectedScissorMusic);
      }
      
      _sendColorCommand(_selectedScissorColor);
    }
  }

  void _handlePencilPress() {
    bool shouldPlayMusic = true;
    
    if (widget.config.repeatMode) {
      setState(() {
        _currentPencilCount--;
      });
      
      if (_currentPencilCount == 0) {
        shouldPlayMusic = true;
        _currentPencilCount = widget.config.mode == 6 ? 3 : 5;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pencil exercise completed!'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        shouldPlayMusic = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Press Pencil $_currentPencilCount more times'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }

    if (!widget.config.repeatMode || shouldPlayMusic) {
      setState(() {
        _pencilCount++;
      });
      
      if (widget.config.musicPencil && shouldPlayMusic) {
        _playSound(_selectedPencilMusic);
      }
      
      _sendColorCommand(_selectedPencilColor);
    }
  }

  void _handlePincherPress() {
    bool shouldPlayMusic = true;
    
    if (widget.config.repeatMode) {
      setState(() {
        _currentPincherCount--;
      });
      
      if (_currentPincherCount == 0) {
        shouldPlayMusic = true;
        _currentPincherCount = widget.config.mode == 6 ? 3 : 5;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pincher exercise completed!'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        shouldPlayMusic = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Press Pincher $_currentPincherCount more times'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }

    if (!widget.config.repeatMode || shouldPlayMusic) {
      setState(() {
        _pincherCount++;
      });
      
      if (widget.config.musicPincher && shouldPlayMusic) {
        _playSound(_selectedPincherMusic);
      }
      
      _sendColorCommand(_selectedPincherColor);
    }
  }

  void _handleButtonPress() {
    bool shouldPlayMusic = true;
    
    if (widget.config.repeatMode) {
      setState(() {
        _currentButtonCount--;
      });
      
      if (_currentButtonCount == 0) {
        shouldPlayMusic = true;
        _currentButtonCount = widget.config.mode == 6 ? 3 : 5;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Button exercise completed!'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        shouldPlayMusic = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Press Button $_currentButtonCount more times'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }

    if (!widget.config.repeatMode || shouldPlayMusic) {
      setState(() {
        _buttonCount++;
      });
      
      if (widget.config.musicButton && shouldPlayMusic) {
        _playSound(_selectedButtonMusic);
      }
      
      _sendColorCommand(_selectedButtonColor);
    }
  }

  Future<void> _playSound(String musicName) async {
    String? musicFile = _musicMap[musicName];
    if (musicFile != null) {
      try {
        if (_audioPlayer.state == PlayerState.playing) {
          await _audioPlayer.stop();
        }
        await _audioPlayer.play(AssetSource('sounds/$musicFile.mp3'));
      } catch (e) {
        print('Error playing sound: $e');
      }
    }
  }

  Future<void> _sendColorCommand(String colorName) async {
    if (widget.config.noLed) {
      await _sendCommand('K'); // No color
    } else {
      String? colorCode = _colorMap[colorName];
      if (colorCode != null) {
        await _sendCommand(colorCode);
      }
    }
  }

  Future<void> _sendCommand(String command) async {
    if (_txCharacteristic != null && _connected) {
      try {
        await _txCharacteristic!.write(command.codeUnits);
        print('Sent command: $command');
      } catch (e) {
        print('Error sending command: $e');
      }
    }
  }

  void _toggleConnection() {
    if (_connected) {
      widget.device.disconnect();
      setState(() {
        _connected = false;
      });
    } else {
      _connectToDevice();
    }
  }

  void _goToMenu() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MenuSelectionActivity(device: widget.device),
      ),
    );
  }

  void _quitApp() {
    _sendCommand('1');
    widget.device.disconnect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exercise - ${widget.config.modeName}'),
        actions: [
          IconButton(
            icon: Icon(_connected ? Icons.bluetooth_connected : Icons.bluetooth_disabled),
            onPressed: _toggleConnection,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Mode: ${widget.config.modeName}', 
                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('Connection: ${_connected ? 'Connected' : 'Disconnected'}',
                 style: TextStyle(color: _connected ? Colors.green : Colors.red)),
            SizedBox(height: 20),
            
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                children: [
                  _counterWidget('Scissor', _scissorCount, 
                                widget.config.chkScissor ? Colors.blue : Colors.grey),
                  _counterWidget('Pencil', _pencilCount, 
                                widget.config.chkPencil ? Colors.green : Colors.grey),
                  _counterWidget('Pincher', _pincherCount, 
                                widget.config.chkPincher ? Colors.orange : Colors.grey),
                  _counterWidget('Button', _buttonCount, 
                                widget.config.chkButton ? Colors.purple : Colors.grey),
                ],
              ),
            ),
            
            if (widget.config.repeatMode) ...[
              SizedBox(height: 10),
              Text('Remaining Counts:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (widget.config.chkScissor) 
                    Text('Scissor: $_currentScissorCount'),
                  if (widget.config.chkPencil) 
                    Text('Pencil: $_currentPencilCount'),
                  if (widget.config.chkPincher) 
                    Text('Pincher: $_currentPincherCount'),
                  if (widget.config.chkButton) 
                    Text('Button: $_currentButtonCount'),
                ],
              ),
            ],
            
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: _goToMenu,
                  child: Text('Back to Menu'),
                ),
                ElevatedButton(
                  onPressed: _quitApp,
                  child: Text('Quit'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _counterWidget(String label, int count, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, 
                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('$count', 
                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    widget.device.disconnect();
    super.dispose();
  }
}

class ExerciseConfig {
  final bool chkScissor, chkPencil, chkPincher, chkButton;
  final bool musicScissor, musicPencil, musicPincher, musicButton;
  final bool noLed, repeatMode;
  final int mode;
  final String modeName;
  final ExerciseCounts counts;

  ExerciseConfig({
    this.chkScissor = false, this.chkPencil = false, 
    this.chkPincher = false, this.chkButton = false,
    this.musicScissor = true, this.musicPencil = true, 
    this.musicPincher = true, this.musicButton = true,
    this.noLed = false, this.repeatMode = false, 
    this.mode = 0, this.modeName = '',
    required this.counts,
  });
}

class ExerciseCounts {
  final int scissor, pencil, pincher, button;

  ExerciseCounts({
    this.scissor = 0, this.pencil = 0, this.pincher = 0, this.button = 0,
  });
}