import 'package:flutter/material.dart';

import 'UI/icons.dart';

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
                            (this.data == null
                                ? "--"
                                : (41.25 *
                                                double.parse(this
                                                    .data
                                                    .toString()
                                                    .split(',')[1]) -
                                            81.25)
                                        .toStringAsPrecision(3) +
                                    " \u2103"),
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
