import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'menu_selection_activity.dart';

class DeviceScanActivity extends StatefulWidget {
  @override
  _DeviceScanActivityState createState() => _DeviceScanActivityState();
}

class _DeviceScanActivityState extends State<DeviceScanActivity> {
  List<BluetoothDevice> _devices = [];
  bool _scanning = false;
  late StreamSubscription<List<ScanResult>> _scanSubscription;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await Permission.location.request();
    await Permission.bluetooth.request();
    await Permission.bluetoothConnect.request();
    await Permission.bluetoothScan.request();
  }

  void _scanDevices(bool enable) {
    setState(() {
      _scanning = enable;
    });

    if (enable) {
      _devices.clear();
      
      _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult result in results) {
          if (!_devices.contains(result.device)) {
            setState(() {
              _devices.add(result.device);
            });
          }
        }
      });

      FlutterBluePlus.startScan(timeout: Duration(seconds: 10));
      
      // Stop after 10 seconds
      Future.delayed(Duration(seconds: 10), () {
        _scanDevices(false);
      });
    } else {
      FlutterBluePlus.stopScan();
      _scanSubscription.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan Devices'),
        actions: [
          _scanning 
            ? IconButton(icon: Icon(Icons.stop), onPressed: () => _scanDevices(false))
            : IconButton(icon: Icon(Icons.search), onPressed: () => _scanDevices(true)),
          IconButton(icon: Icon(Icons.refresh), onPressed: () {
            _scanDevices(false);
            _devices.clear();
            _scanDevices(true);
          }),
        ],
      ),
      body: Column(
        children: [
          if (_scanning) LinearProgressIndicator(),
          Expanded(
            child: ListView.builder(
              itemCount: _devices.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_devices[index].platformName.isEmpty 
                      ? 'Unknown Device' 
                      : _devices[index].platformName),
                  subtitle: Text(_devices[index].remoteId.toString()),
                  onTap: () {
                    _scanDevices(false);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MenuSelectionActivity(
                          device: _devices[index],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scanDevices(false);
    super.dispose();
  }
}