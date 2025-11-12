import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:zexerciser/exercise_config.dart';
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
                _menuButton('Menu 2', 'Pencils only activated', () => _setMenu2()),
                _menuButton('Menu 3', 'Scissors only activated', () => _setMenu3()),
                _menuButton('Menu 4', 'Led Only', () => _setMenu4()),
                _menuButton('Menu 5', 'No Led', () => _setMenu5()),
                _menuButton('Menu 6', 'Repeat 3x', () => _setMenu6()),
                _menuButton('Menu 7', 'Repeat 5x', () => _setMenu7()),
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

  void _setMenu2() {
    setState(() {
      _selectedMenu = 'Selected Menu 2';
      _config = ExerciseConfig(
        chkButton: false, chkPencil: true, chkPincher: false, chkScissor: false,
        musicButton: true, musicPencil: true, musicPincher: true, musicScissor: true,
        noLed: false, repeatMode: false, mode: 2, modeName: 'Pencils only activated',
        counts: ExerciseCounts(button: 0, pencil: 0, pincher: 0, scissor: 0),
      );
    });
  }

  void _setMenu3() {
    setState(() {
      _selectedMenu = 'Selected Menu 3';
      _config = ExerciseConfig(
        chkButton: false, chkPencil: false, chkPincher: false, chkScissor: true,
        musicButton: true, musicPencil: true, musicPincher: true, musicScissor: true,
        noLed: false, repeatMode: false, mode: 3, modeName: 'Scissors only activated',
        counts: ExerciseCounts(button: 0, pencil: 0, pincher: 0, scissor: 0),
      );
    });
  }

  void _setMenu4() {
    setState(() {
      _selectedMenu = 'Selected Menu 4';
      _config = ExerciseConfig(
        chkButton: true, chkPencil: true, chkPincher: true, chkScissor: true,
        musicButton: false, musicPencil: false, musicPincher: false, musicScissor: false,
        noLed: false, repeatMode: false, mode: 4, modeName: 'Led Only',
        counts: ExerciseCounts(button: 0, pencil: 0, pincher: 0, scissor: 0),
      );
    });
  }

  void _setMenu5() {
    setState(() {
      _selectedMenu = 'Selected Menu 5';
      _config = ExerciseConfig(
        chkButton: true, chkPencil: true, chkPincher: true, chkScissor: true,
        musicButton: true, musicPencil: true, musicPincher: true, musicScissor: true,
        noLed: true, repeatMode: false, mode: 5, modeName: 'No Led',
        counts: ExerciseCounts(button: 0, pencil: 0, pincher: 0, scissor: 0),
      );
    });
  }

  void _setMenu6() {
    setState(() {
      _selectedMenu = 'Selected Menu 6';
      _config = ExerciseConfig(
        chkButton: true, chkPencil: true, chkPincher: true, chkScissor: true,
        musicButton: false, musicPencil: false, musicPincher: false, musicScissor: false,
        noLed: false, repeatMode: true, mode: 6, modeName: 'Repeat 3x',
        counts: ExerciseCounts(button: 3, pencil: 3, pincher: 3, scissor: 3),
      );
    });
  }

  void _setMenu7() {
    setState(() {
      _selectedMenu = 'Selected Menu 7';
      _config = ExerciseConfig(
        chkButton: true, chkPencil: true, chkPincher: true, chkScissor: true,
        musicButton: false, musicPencil: false, musicPincher: false, musicScissor: false,
        noLed: false, repeatMode: true, mode: 7, modeName: 'Repeat 5x',
        counts: ExerciseCounts(button: 5, pencil: 5, pincher: 5, scissor: 5),
      );
    });
  }

  void _goToExercise() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MainActivity(
          device: widget.device, 
          config: _config,
        ),
      ),
    );
  }
}

// Make sure these classes are defined (uncomment or add to your main_activity.dart)
