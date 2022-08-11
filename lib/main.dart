import 'dart:convert';
import 'dart:io';
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
    return MaterialApp(
      title: 'Roslib Example',
      theme: ThemeData(
          //brightness: Brightness.dark,
          backgroundColor: Colors.grey[300]
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
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
  late Topic sensor_state;

  bool isPressedUp = true;
  bool isPressedDown = true;
  bool isPressedLeft = true;
  bool isPressedRight = true;
  bool isPressedStop = true;

  //late Map<String, dynamic> sensorData={'msg': '{battery:0.0}'};

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
    sensor_state = Topic(
        ros: ros,
        name: 'sensor_state',
        type: "turtlebot3_msgs/SensorState",
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
    await sensor_state.subscribe();
    //await battery_state.subscribe();
    //await odom.subscribe();
    //await client_count.subscribe();
    setState(() {});
  }

  void destroyConnection() async {
    await diagnostic.unsubscribe();
    await sensor_state.unsubscribe();
    //await battery_state.unsubscribe();
    //await odom.unsubscribe();
    //await client_count.unsubscribe();
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
    Offset distanceUp = isPressedUp ? const Offset(7, 7) : const Offset(15, 15);
    double blurUp = isPressedUp ? 5.0 : 30.0;
    Offset distanceDown = isPressedDown ? const Offset(7, 7) : const Offset(15, 15);
    double blurDown = isPressedDown ? 5.0 : 30.0;
    Offset distanceLeft = isPressedLeft ? const Offset(7, 7) : const Offset(15, 15);
    double blurLeft = isPressedLeft ? 5.0 : 30.0;
    Offset distanceStop = isPressedStop ? const Offset(7, 7) : const Offset(15, 15);
    double blurStop = isPressedStop? 5.0 : 30.0;
    Offset distanceRight = isPressedRight ? const Offset(7, 7) : const Offset(15, 15);
    double blurRight = isPressedRight ? 5.0 : 30.0;
    double size=90;
    double sizeStop=70;
    return StreamBuilder<Object>(
      stream: ros.statusStream,
      builder: (context, AsyncSnapshot<dynamic> snapshot) {
        return Scaffold(
          /*appBar: AppBar(
            title: const Text('Turtlebot'),
            centerTitle: true,
            //backgroundColor: Colors.purple,
            actions: [
              IconButton(onPressed: () => {}, icon: const Icon(Icons.settings))
            ],
          ),*/
          body: Container(
            margin:
                const EdgeInsets.all(20),
            child: StreamBuilder<Object>(
              stream: ros.statusStream,
              builder: (context, snapshot) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                   Container(

                        child: Container(
                          width: 400,
                          height: 400,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(23),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF868686),
                                Color(0xFFA7A9AF),
                              ],
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0xFF929292),
                                offset: Offset(10, 10),
                                blurRadius: 40,
                                spreadRadius: 0.0,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.map_outlined,
                            size: 300,
                            color: Colors.amberAccent,
                          ),
                        ),
                      ),

                    StreamBuilder(
                      stream: diagnostic.subscription,
                      builder: (context2, snapshot2) {
                        Map<String, dynamic> data =
                            jsonDecode(jsonEncode(snapshot2.data));
                        if (snapshot2.hasData) {
                          return Container(
                              margin: const EdgeInsets.all(30),
                              child: Text(
                                'name: ${data['msg']['status'][0]['name']}\nmessage: ${data['msg']['status'][0]['message']}',
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ));
                        } else {
                          return const Text('.');
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
                        stream: sensor_state.subscription,
                        builder: (contextSensorState, snapshotSensorState) {
                          Map<String, dynamic> sensorData =
                              jsonDecode(jsonEncode(snapshotSensorState.data));
                          if (snapshotSensorState.hasData) {
                            var sensorBattery = double.parse(
                                    sensorData['msg']['battery'].toString())
                                .toStringAsFixed(2);
                            //return Text('battery: ${sensorData['msg']['battery'].toString()}');
                            return Text('battery: $sensorBattery');
                          } else {
                            return const Text('.');
                          }
                        }),
                    /*
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
                        }),*/
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
                              ? Colors.green[200]
                              : Colors.grey[250],
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
                    const SizedBox(height: 50,),
                    const Padding(padding: EdgeInsets.only(bottom: 15.0)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        //
                        // Forward
                        //
                        Listener(
                          onPointerUp: (_) => setState(() => isPressedUp = false),
                          onPointerDown: (_) =>
                              setState( () {
                                isPressedUp = true;
                                linearCounter++;
                                move(0.05, 0.0);
                              }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 100),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: Colors.grey[300],
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: blurUp,
                                    offset: distanceUp,
                                    color: const Color(0xFFA7A9AF),
                                  )
                                ]),
                            child: Icon(
                              Icons.arrow_drop_up_outlined,
                              size: size,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                        //const SizedBox(width: 50,),
                      ],
                    ),
                    const Padding(padding: EdgeInsets.only(bottom: 10.0)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        //
                        // Left
                        //
                        Listener(
                          onPointerUp: (_) => setState(() => isPressedLeft = false),
                          onPointerDown: (_) =>
                              setState( () {
                                isPressedLeft= true;
                                angularCounter++;
                                move(0.0, 0.5);
                              }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 100),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: Colors.grey[300],
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: blurLeft,
                                    offset: distanceLeft,
                                    color: const Color(0xFFA7A9AF),
                                  )
                                ]),
                            child: Icon(
                              Icons.arrow_left_outlined,
                              size: size,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                        //
                        // Stop
                        //
                        Listener(
                          onPointerUp: (_) => setState(() => isPressedStop = false),
                          onPointerDown: (_) =>
                              setState( () {
                                isPressedStop = true;
                                linearCounter++;
                                move(0.0, 0.0);
                              }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 100),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: Colors.grey[300],
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: blurStop,
                                    offset: distanceStop,
                                    color: const Color(0xFFA7A9AF),
                                  )
                                ]),
                            child: Icon(
                              Icons.pause,
                              size: sizeStop,
                              color: Colors.red[200],
                            ),
                          ),
                        ),
                        //
                        // Right
                        //
                        Listener(
                          onPointerUp: (_) => setState(() => isPressedRight = false),
                          onPointerDown: (_) =>
                              setState( () {
                                isPressedRight = true;
                                angularCounter--;
                                move(0.0, 0.5);
                              }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 100),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: Colors.grey[300],
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: blurRight,
                                    offset: distanceRight,
                                    color: const Color(0xFFA7A9AF),
                                  )
                                ]),
                            child: Icon(
                              Icons.arrow_right_outlined,
                              size: size,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Padding(padding: EdgeInsets.only(bottom: 10.0)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        //
                        // Down
                        //
                        Listener(
                          onPointerUp: (_) => setState(() => isPressedDown = false),
                          onPointerDown: (_) =>
                              setState( () {
                                isPressedDown = true;
                                linearCounter--;
                                move(0.05, 0.0);
                              }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 100),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: Colors.grey[300],
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: blurDown,
                                    offset: distanceDown,
                                    color: const Color(0xFFA7A9AF),
                                  )
                                ]),
                            child: Icon(
                              Icons.arrow_drop_down_outlined,
                              size: size,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
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
