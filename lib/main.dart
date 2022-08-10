import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:roslib/roslib.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Roslib Example',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Ros ros;
  int linearCounter = 0;
  int angularCounter = 0;
  late Topic cmd_vel;
  late Topic diagnostic;
  late Topic battery_state;
  late Topic odom;
  late Topic client_count;

  @override
  void initState() {
    ros = Ros(url: 'ws://192.168.3.74:9090');
    cmd_vel = Topic(
        ros: ros,
        name: '/cmd_vel',
        type: "geometry_msgs/Twist",
        reconnectOnClose: true,
        queueLength: 10,
        queueSize: 10);
    diagnostic = Topic(
        ros: ros,
        name: '/diagnostics',
        type: "diagnostic_msgs/DiagnosticArray",
        reconnectOnClose: true,
        queueLength: 10,
        queueSize: 10);
    /*battery_state = Topic(
        ros: ros,
        name: '/battery_state',
        type: "sensor_msgs/BatteryState",
        reconnectOnClose: true,
        queueLength: 10,
        queueSize: 10);*/
    odom = Topic(
        ros: ros,
        name: '/odom',
        type: "nav_msgs/Odometry",
        reconnectOnClose: true,
        queueSize: 10,
        queueLength: 10);

    client_count = Topic(
        ros: ros,
        name: '/client_count',
        type: "std_msgs/Int32",
        reconnectOnClose: true,
        queueLength: 10,
        queueSize: 10);

    super.initState();
  }

  void move(double coordinate, double angle) {
    double linearSpeed = 0.0;
    double angularSpeed = 0.0;
    linearSpeed = linearCounter * coordinate;
    angularSpeed = angularCounter * angle;
    publishCmd(linearSpeed, angularSpeed);
    if (kDebugMode) {
      print('cmd published');
    }
  }

  void initConnection() async {
    ros.connect();
    await cmd_vel.advertise();
    await diagnostic.subscribe();
    //await battery_state.subscribe();
    //await odom.subscribe();
    await client_count.subscribe();
    setState(() {});
  }

  void destroyConnection() async {
    await diagnostic.unsubscribe();
    //await battery_state.unsubscribe();
    //await odom.unsubscribe();
    await client_count.unsubscribe();
    await ros.close();
    setState(() {});
  }

  void publishCmd(double coord, double ang) async {
    var linear = {'x': coord, 'y': 0.0, 'z': 0.0};
    var angular = {'x': 0.0, 'y': 0.0, 'z': ang};
    var geomTwist = {'linear': linear, 'angular': angular};
    await cmd_vel.publish(geomTwist);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Object>(
      stream: ros.statusStream,
      builder: (context, AsyncSnapshot<dynamic> snapshot) {
        return Scaffold(
          backgroundColor: Colors.white70,
          appBar: AppBar(title: const Text('Teleop app'), centerTitle: true),
          body: Container(
            margin:
                const EdgeInsets.only(top: 20, bottom: 20, right: 20, left: 20),
            child: StreamBuilder<Object>(
              stream: ros.statusStream,
              builder: (context, snapshot) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    StreamBuilder(
                      stream: diagnostic.subscription,
                      builder: (context2, snapshot2) {
                        Map<String, dynamic> data =
                            jsonDecode(jsonEncode(snapshot2.data));
                        if (snapshot2.hasData) {
                          return Text(
                              'name: ${data['msg']['status'][0]['name']}\nmessage: ${data['msg']['status'][0]['message']}');
                        } else {
                          return const Text('...');
                        }

                        /*if (snapshot2.hasData) {
                          return Text(
                            '${snapshot2.data}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        } else {
                          return const CircularProgressIndicator();
                        }*/
                      },
                    ),
                    StreamBuilder(
                        stream: client_count.subscription,
                        builder: (contextClientCount, snapshotClientCount) {
                          Map<String, dynamic> clientCountData =
                          jsonDecode(jsonEncode(snapshotClientCount.data));
                          if (snapshotClientCount.hasData) {
                            return Text('client count: ${clientCountData['msg']['data']}');
                          } else {
                            return const Text('client count: 0');
                          }
                        }),
                    /*
                    StreamBuilder(
                        stream: battery_state.subscription,
                        builder: (context3, snapshot3) {
                          if (snapshot3.hasData) {
                            return Text('${snapshot3.data}');
                          } else {
                            return const CircularProgressIndicator();
                          }
                        }),
                    StreamBuilder(
                        stream: odom.subscription,
                        builder: (context4, snapshot4) {
                          if (snapshot4.hasData) {
                            return Text('${snapshot4.data}');
                          } else {
                            return const CircularProgressIndicator();
                          }
                        }),*/
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ActionChip(
                          label: Text(snapshot.data == Status.CONNECTED
                              ? 'DISCONNECT'
                              : 'CONNECT'),
                          backgroundColor: snapshot.data == Status.CONNECTED
                              ? Colors.green[300]
                              : Colors.grey[300],
                          onPressed: () {
                            if (kDebugMode) {
                              print(snapshot.data);
                            }
                            if (snapshot.data != Status.CONNECTED) {
                              initConnection();
                            } else {
                              destroyConnection();
                            }
                          },
                        ),
                      ],
                    ),
                    const Padding(padding: EdgeInsets.only(bottom: 15.0)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(130.0, 40.0),
                            ),
                            onPressed: () {
                              linearCounter++;
                              move(0.05, 0.0);
                            },
                            icon: const Icon(Icons.arrow_upward),
                            label: const Text('Forward')),
                      ],
                    ),
                    const Padding(padding: EdgeInsets.only(bottom: 30.0)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(130.0, 40.0),
                            ),
                            onPressed: () {
                              angularCounter++;
                              move(0.0, 0.05);
                            },
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Left')),
                        ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(130.0, 40.0),
                            ),
                            onPressed: () {
                              angularCounter = 0;
                              linearCounter = 0;
                              move(0.0, 0.0);
                            },
                            icon: const Icon(Icons.stop_circle_outlined),
                            label: const Text('Stop')),
                        ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(130.0, 40.0),
                            ),
                            onPressed: () {
                              angularCounter--;
                              move(0.0, 0.05);
                            },
                            icon: const Icon(Icons.arrow_forward),
                            label: const Text('Right')),
                      ],
                    ),
                    const Padding(padding: EdgeInsets.only(bottom: 30.0)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(130.0, 40.0),
                            ),
                            onPressed: () {
                              linearCounter--;
                              move(0.05, 0.0);
                            },
                            icon: const Icon(Icons.arrow_downward),
                            label: const Text('Backward')),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
