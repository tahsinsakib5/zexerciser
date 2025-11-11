import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'main_activity.dart';

class MenuSelectionActivity extends StatefulWidget {
  final BluetoothDevice device;

  const MenuSelectionActivity({Key? key, required this.device}) : super(key: key);

  @override
  _MenuSelectionActivityState createState() => _MenuSelectionActivityState();
}

class _MenuSelectionActivityState extends State<MenuSelectionActivity> {
  String _selectedMenu = 'Select a Menu';

  ExerciseConfig _config = ExerciseConfig(
  counts: ExerciseCounts(
    scissor: 0,
    pencil: 0, 
    pincher: 0,
    button: 0,
  )
);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Menu')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(_selectedMenu, style: TextStyle(fontSize: 18)),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              children: [
                _menuButton('Menu 0', 'Buttons only activated', () => _setMenu0()),
                _menuButton('Menu 1', 'Pincher only activated', () => _setMenu1()),
                // _menuButton('Menu 2', 'Pencils only activated', () => _setMenu2()),
                // _menuButton('Menu 3', 'Scissors only activated', () => _setMenu3()),
                // _menuButton('Menu 4', 'Led Only', () => _setMenu4()),
                // _menuButton('Menu 5', 'No Led', () => _setMenu5()),
                // _menuButton('Menu 6', 'Repeat 3x', () => _setMenu6()),
                // _menuButton('Menu 7', 'Repeat 5x', () => _setMenu7()),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _goToExercise,
              child: Text('Start Exercise'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuButton(String title, String description, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text(description, textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  void _setMenu0() {
    setState(() {
      _selectedMenu = 'Selected Menu 0';
      _config = ExerciseConfig(
        chkButton: true, chkPencil: false, chkPincher: false, chkScissor: false,
        musicButton: true, musicPencil: true, musicPincher: true, musicScissor: true,
        noLed: false, repeatMode: false, mode: 0, modeName: 'Buttons only activated',
        counts: ExerciseCounts(button: 0, pencil: 0, pincher: 0, scissor: 0),
      );
    });
  }

  void _setMenu1() {
    setState(() {
      _selectedMenu = 'Selected Menu 1';
      _config = ExerciseConfig(
        chkButton: false, chkPencil: false, chkPincher: true, chkScissor: false,
        musicButton: true, musicPencil: true, musicPincher: true, musicScissor: true,
        noLed: false, repeatMode: false, mode: 1, modeName: 'Pincher only activated',
        counts: ExerciseCounts(button: 0, pencil: 0, pincher: 0, scissor: 0),
      );
    });
  }

  // Add similar methods for menu2-menu7...

  void _goToExercise() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MainActivity(
          device: widget.device, config: _config,
          
        ),
      ),
    );
  }
}

// class ExerciseConfig {
//   final bool chkScissor, chkPencil, chkPincher, chkButton;
//   final bool musicScissor, musicPencil, musicPincher, musicButton;
//   final bool noLed, repeatMode;
//   final int mode;
//   final String modeName;
//   final ExerciseCounts counts;

//   ExerciseConfig({
//     this.chkScissor = false, this.chkPencil = false, this.chkPincher = false, this.chkButton = false,
//     this.musicScissor = true, this.musicPencil = true, this.musicPincher = true, this.musicButton = true,
//     this.noLed = false, this.repeatMode = false, this.mode = 0, this.modeName = '',
//     required this.counts,
//   });
// }

// class ExerciseCounts {
//   final int scissor, pencil, pincher, button;

//   ExerciseCounts({
//     this.scissor = 0, this.pencil = 0, this.pincher = 0, this.button = 0,
//   });
// }