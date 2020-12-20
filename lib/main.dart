import 'dart:async';
import 'dart:convert' show utf8;

import 'package:ethanol_content_final_app/icons.dart';
import 'package:ethanol_content_final_app/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

void main() {
  runApp(MainScreen());
}

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Joypad with BLE',
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<BluetoothState>(
        stream: FlutterBlue.instance.state,
        initialData: BluetoothState.unknown,
        builder: (c, snapshot) {
          final state = snapshot.data;
          print(state);
          if (state == BluetoothState.on) {
            return JoyPad();
          }
          return JoyPad();
        },
      ),
    );
  }
}

class JoyPad extends StatefulWidget {
  JoyPad({Key key}) : super(key: key);

  @override
  _JoyPadState createState() => _JoyPadState();
}

class _JoyPadState extends State<JoyPad> {
  // ignore: non_constant_identifier_names
  final String SERVICE_UUID = "6e400001-b5a3-f393-e0a9-e50e24dcca9e";
  // ignore: non_constant_identifier_names
  final String CHARACTERISTIC_UUID = "6e400002-b5a3-f393-e0a9-e50e24dcca9e";
  // ignore: non_constant_identifier_names
  final String TARGET_DEVICE_NAME = "Billet Motorsport ECU001";

  FlutterBlue flutterBlue = FlutterBlue.instance;
  StreamSubscription<ScanResult> scanSubScription;
  Stream<List<int>> stream;

  BluetoothDevice targetDevice;
  BluetoothCharacteristic targetCharacteristic;

  String connectionText = "";
  bool isConnected = false;
  int pageIndex = 3;
  bool vari;

  @override
  void initState() {
    print("initialized");
    super.initState();
    print(vari);
    vari = true;
    startScan();
  }

  startScan() {
    setState(() {
      connectionText = "Start Scanning";
    });
    if (vari) {
      vari = false;
      print("Started Bluetooth Scan");
      scanSubScription =
          flutterBlue.scan().asBroadcastStream().listen((scanResult) {
        print(scanResult.device);
        if (scanResult.device.name == TARGET_DEVICE_NAME) {
          print('DEVICE found');
          stopScan();
          setState(() {
            connectionText = "Found Target Device";
            print(connectionText);
          });

          targetDevice = scanResult.device;
          connectToDevice();
        }
      }, onDone: () => stopScan());
    } else {}
  }

  stopScan() {
    scanSubScription?.cancel();
    scanSubScription = null;
  }

  connectToDevice() async {
    if (targetDevice == null) return;

    setState(() {
      connectionText = "Device Connecting";
      print(connectionText);
    });

    await targetDevice.connect();
    setState(() {
      connectionText = "Device Connected";
      print(connectionText);
    });

    discoverServices();
  }

  disconnectFromDevice() {
    if (targetDevice == null) return;

    targetDevice.disconnect();

    setState(() {
      connectionText = "Device Disconnected";
      print(connectionText);
      isConnected = false;
      pageIndex = 3;
    });
  }

  discoverServices() async {
    if (targetDevice == null) return;

    List<BluetoothService> services = await targetDevice.discoverServices();
    services.forEach((service) {
      // do something with service

      if (service.uuid.toString() == SERVICE_UUID) {
        service.characteristics.forEach((characteristic) {
          print(characteristic.uuid.toString());
          if (characteristic.uuid.toString() == CHARACTERISTIC_UUID) {
            characteristic.setNotifyValue(!characteristic.isNotifying);
            stream = characteristic.value.asBroadcastStream();
            targetCharacteristic = characteristic;
            setState(() {
              isConnected = true;
              connectionText = "All Ready with ${targetDevice.name}";
              print(connectionText);
            });
          }
        });
      }
    });
  }

  writeData(String data) {
    if (targetCharacteristic == null) return;

    List<int> bytes = utf8.encode(data);
    targetCharacteristic.write(bytes);
  }

  void onButtonTapped(index) {
    setState(() {
      pageIndex = index;
    });
  }

  String _dataParser(List<int> dataFromDevice) {
    return utf8.decode(dataFromDevice);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            RawMaterialButton(
              onPressed: () {
                if (isConnected == true) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return StreamBuilder<List<int>>(
                          stream: stream,
                          builder: (context, snapshot) {
                            var currentValue;
                            var device;
                            if (snapshot.hasError)
                              return Text('Error: ${snapshot.error}');

                            if (snapshot.connectionState ==
                                    ConnectionState.active &&
                                snapshot.data.length > 0) {
                              currentValue = _dataParser(snapshot.data);
                              print(currentValue);
                              device = targetDevice;
                            } else {
                              currentValue = null;
                              device = null;
                            }
                            return SettingPopUp(
                              data: currentValue,
                            );
                          });
                    },
                  );
                }
              },
              elevation: 2.0,
              fillColor: Colors.grey[500],
              child: Icon(
                Icons.settings_outlined,
                color: Colors.black87,
                size: 35.0,
              ),
              padding: EdgeInsets.all(15.0),
              shape: CircleBorder(),
            ),
            isConnected == true
                ? StreamBuilder<BluetoothDeviceState>(
                    stream: targetDevice.state,
                    initialData: BluetoothDeviceState.disconnected,
                    builder: (c, snapshot) {
                      return RawMaterialButton(
                        onPressed: () {
                          isConnected
                              ? disconnectFromDevice()
                              : connectToDevice();
                        },
                        elevation: 2.0,
                        fillColor: isConnected ? Colors.green : Colors.blue,
                        child: Icon(
                          Icons.bluetooth,
                          color: Colors.white,
                          size: 35.0,
                        ),
                        padding: EdgeInsets.all(15.0),
                        shape: CircleBorder(),
                      );
                    })
                : RawMaterialButton(
                    onPressed: () {
                      isConnected ? disconnectFromDevice() : connectToDevice();
                    },
                    elevation: 2.0,
                    fillColor: isConnected ? Colors.green : Colors.blue,
                    child: Icon(
                      Icons.bluetooth,
                      color: Colors.white,
                      size: 35.0,
                    ),
                    padding: EdgeInsets.all(15.0),
                    shape: CircleBorder(),
                  ),
          ],
        ),
      ),
      body: Center(
        child: isConnected == true
            ? StreamBuilder<BluetoothDeviceState>(
                stream: targetDevice.state,
                initialData: BluetoothDeviceState.disconnected,
                builder: (c, snapshot) {
                  if (snapshot.data == BluetoothDeviceState.connected) {
                    isConnected = true;
                  } else if (snapshot.data ==
                      BluetoothDeviceState.disconnected) {
                    isConnected = false;
                    pageIndex = 3;
                  }
                  return Container(
                    child: isConnected == true
                        ? StreamBuilder<List<int>>(
                            stream: stream,
                            builder: (BuildContext context,
                                AsyncSnapshot<List<int>> snapshot) {
                              var currentValue;
                              var device;
                              if (snapshot.hasError)
                                return Text('Error: ${snapshot.error}');

                              if (snapshot.connectionState ==
                                      ConnectionState.active &&
                                  snapshot.data.length > 0) {
                                currentValue = _dataParser(snapshot.data);
                                print(currentValue);
                                device = targetDevice;
                              } else {
                                currentValue = null;
                                device = null;
                              }
                              return Home(
                                data: currentValue,
                              );
                            })
                        : Home(
                            data: null,
                          ),
                  );
                },
              )
            : Home(
                data: null,
              ),
      ),
    );
  }
}

class Home extends StatelessWidget {
  final String data;
  const Home({Key key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: Center(
          child: Container(
            margin: EdgeInsets.fromLTRB(0, 0, 0, 100),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image.asset(
                  'assets/images/billet-design-smaller.png',
                  width: MediaQuery.of(context).size.width / 1.25,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: 10,
                    ),
                    CircleAvatar(
                      radius: 80,
                      backgroundColor: Colors.black,
                      child: CircleAvatar(
                        backgroundColor: Colors.orange[900],
                        radius: 70,
                        child: Icon(
                          CustomIcons.local_gas_station,
                          color: Colors.white,
                          size: 90,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Ethanol Content',
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.amber,
                                fontWeight: FontWeight.bold),
                          ),
                          Divider(
                            color: Colors.black,
                            thickness: 1,
                          ),
                          Text(
                            (this.data == null
                                ? "--"
                                : "E" +
                                    (int.parse(this
                                                .data
                                                .toString()
                                                .split(',')[0]) -
                                            50)
                                        .toString()),
                            style: TextStyle(
                              fontSize: 50,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: 10,
                    ),
                    CircleAvatar(
                      radius: 80,
                      backgroundColor: Colors.black,
                      child: CircleAvatar(
                        backgroundColor: Colors.orange[900],
                        radius: 70,
                        child: Icon(
                          Icons.thermostat_sharp,
                          size: 90,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Fuel Temperature',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Divider(
                            color: Colors.black,
                            thickness: 1,
                          ),
                          Text(
                            (this.data == null ? "--" : "--"),
                            style: TextStyle(
                              fontSize: 50,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
