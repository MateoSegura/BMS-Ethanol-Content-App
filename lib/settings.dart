import 'package:flutter/material.dart';

class SettingPopUp extends StatefulWidget {
  SettingPopUp({Key key, this.data}) : super(key: key);
  final String data;

  @override
  _SettingPopUpState createState() => _SettingPopUpState();
}

class _SettingPopUpState extends State<SettingPopUp> {
  final myController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Stack(
        alignment: Alignment.center,
        overflow: Overflow.visible,
        children: <Widget>[
          Positioned(
            right: -40.0,
            top: -40.0,
            child: InkResponse(
              onTap: () {
                myController.clear();
                Navigator.of(context).pop();
              },
              child: CircleAvatar(
                child: Icon(Icons.close),
                backgroundColor: Colors.red,
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width / 2,
            height: MediaQuery.of(context).size.height / 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Text(
                //   "Settings",
                //   style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                // ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Frequency: ",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      (widget.data == null
                          ? "--"
                          : (int.parse(widget.data.toString().split(',')[0]))
                              .toString()),
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      " Hz",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Voltage: ",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      (widget.data == null
                          ? "--"
                          : (double.parse(
                                      widget.data.toString().split(',')[2]) /
                                  1000)
                              .toStringAsPrecision(3)),
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      " V",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FolderListTile {}
