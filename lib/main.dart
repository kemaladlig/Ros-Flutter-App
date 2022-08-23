import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
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
          backgroundColor: Colors.grey[300]),
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
  late Topic map;
  //late Uint8List map_data;


  
  double size = 90;
  double sizeStop = 70;

  bool isPressedUp = false;
  bool isPressedDown = false;
  bool isPressedLeft = false;
  bool isPressedRight = false;
  bool isPressedStop = false;

  //late Map<String, dynamic> sensorData={'msg': '{battery:0.0}'};

  @override
  void initState() {
    ros = Ros(url: 'ws://192.168.3.74:9090');
    cmd_vel = Topic(ros: ros, name: '/cmd_vel', type: "geometry_msgs/Twist",
        reconnectOnClose: true, queueLength: 10, queueSize: 10);
    diagnostic = Topic(ros: ros, name: '/diagnostics', type: "diagnostic_msgs/DiagnosticArray",
        reconnectOnClose: true, queueLength: 10, queueSize: 10);
    odom = Topic(ros: ros, name: '/odom', type: "nav_msgs/Odometry",
        reconnectOnClose: true, queueSize: 10, queueLength: 10);
    client_count = Topic(ros: ros, name: '/client_count', type: "std_msgs/Int32",
        reconnectOnClose: true, queueLength: 10, queueSize: 10);
    sensor_state = Topic(ros: ros, name: 'sensor_state', type: "turtlebot3_msgs/SensorState",
        reconnectOnClose: true, queueLength: 10, queueSize: 10);
    map=Topic(ros:ros, name: '/map', type: "nav_msgs/OccupancyGrid",
        reconnectOnClose: true, queueLength: 10, queueSize: 10);
    super.initState();
  }

  void move(double coordinate, double angle) {
    double linearSpeed = 0.0;
    double angularSpeed = 0.0;
    linearSpeed = linearCounter * coordinate;
    angularSpeed = angularCounter * angle;
    publishCmd(linearSpeed, angularSpeed);
  }

  Widget getImage(String mapContent){
    const Base64Codec base64=Base64Codec();
    return Flexible(
        flex: 1,
        child: Image.memory(
          base64.decode(mapContent),
          gaplessPlayback: true,
          height: 384,
          fit: BoxFit.fill,
        ),);
  }

  void initConnection() async {
    ros.connect();
    await cmd_vel.advertise();
    await diagnostic.subscribe();
    await map.subscribe();
    // await sensor_state.subscribe();
    // await battery_state.subscribe();
    // await odom.subscribe();
    // await client_count.subscribe();
    setState(() {});
  }

  void destroyConnection() async {
    await diagnostic.unsubscribe();
    await map.unsubscribe();
    //await sensor_state.unsubscribe();
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
    double blurUp = isPressedUp ? 10.0 : 20.0;
    Offset distanceDown = isPressedDown ? const Offset(7, 7) : const Offset(15, 15);
    double blurDown = isPressedDown ? 5.0 : 30.0;
    Offset distanceLeft = isPressedLeft ? const Offset(7, 7) : const Offset(15, 15);
    double blurLeft = isPressedLeft ? 5.0 : 30.0;
    Offset distanceStop = isPressedStop ? const Offset(7, 7) : const Offset(15, 15);
    double blurStop = isPressedStop ? 5.0 : 30.0;
    Offset distanceRight = isPressedRight ? const Offset(7, 7) : const Offset(15, 15);
    double blurRight = isPressedRight ? 5.0 : 30.0;
    

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
          body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
              margin: const EdgeInsets.only(top: 10),
              child: StreamBuilder<Object>(
                stream: ros.statusStream,
                builder: (context, snapshot) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const SizedBox(height: 50,),
                      Column(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width -30,
                            height: 400,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(23),
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFFA9A9A9),
                                  Color(0xFFB8B8B8),
                                ],
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0xFF929292),
                                  offset: Offset(5, 5),
                                  blurRadius: 40,
                                  spreadRadius: 0.0,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: Image.asset('assets/tb3_house_map.png'),
                            ),
                            /*Image.asset('assets/tb3_house_map.png'),*/
                            /* Icon(
                              Icons.map_outlined,
                              size: MediaQuery.of(context).size.width-60,
                              color: Colors.amberAccent,
                            ),*/
                          ),
                        ],
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
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ));
                          } else {
                            return const Text('');
                          }
                        },
                      ),

                      StreamBuilder(
                          stream: sensor_state.subscription,
                          builder: (contextSensorState, snapshotSensorState) {
                            Map<String, dynamic> sensorData = jsonDecode(
                                jsonEncode(snapshotSensorState.data));
                            if (snapshotSensorState.hasData) {
                              var sensorBattery = double.parse(
                                      sensorData['msg']['battery'].toString())
                                  .toStringAsFixed(2);
                              //return Text('battery: ${sensorData['msg']['battery'].toString()}');
                              return Text('battery: $sensorBattery');
                            } else {
                              return const Text('');
                            }
                          }),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ActionChip(
                            elevation: 1,
                            label: Text(
                              snapshot.data == Status.CONNECTED
                                  ? 'DISCONNECT'
                                  : 'CONNECT TURTLEBOT3 BURGER',
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w400),
                            ),
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
                          const SizedBox(
                            width: 50,
                          ),
                          Chip(
                            elevation: 1,
                            padding: const EdgeInsets.all(6),
                            backgroundColor: Colors.grey[300],
                            shadowColor: Colors.black,
                            avatar: const Text('63',style: TextStyle(fontWeight: FontWeight.w500),),
                            label: const Icon(
                              Icons.battery_charging_full_sharp,
                              color: Color(0xFF777777),
                            ), //Text
                          ),
                        ],
                      ),
                      const SizedBox(height: 10,),
                      const Padding(padding: EdgeInsets.only(bottom: 15.0)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          //
                          // Forward
                          //
                          Listener(
                            onPointerUp: (_) =>
                                setState(() => isPressedUp = false),
                            onPointerDown: (_) => setState(() {
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
                                    ),
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          //
                          // Left
                          //
                          Listener(
                            onPointerUp: (_) =>
                                setState(() => isPressedLeft = false),
                            onPointerDown: (_) => setState(() {
                              isPressedLeft = true;
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
                          const SizedBox(width: 25,),
                          //
                          // Stop
                          //
                          Listener(
                            onPointerUp: (_) =>
                                setState(() => isPressedStop = false),
                            onPointerDown: (_) => setState(() {
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
                          const SizedBox(width: 25,),
                          //
                          // Right
                          //
                          Listener(
                            onPointerUp: (_) =>
                                setState(() => isPressedRight = false),
                            onPointerDown: (_) => setState(() {
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
                            onPointerUp: (_) =>
                                setState(() => isPressedDown = false),
                            onPointerDown: (_) => setState(() {
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
                      const Padding(padding: EdgeInsets.only(bottom: 30.0),),
                      const SizedBox(height: 50,),
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(23),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFA9A9A9),
                              Color(0xFFB8B8B8),
                            ],
                          ),
                          boxShadow: const [
                          BoxShadow(
                            color: Color(0xFF929292),
                            offset: Offset(5, 5),
                            blurRadius: 40,
                            spreadRadius: 0.0,
                          ),],
                        ),

                        child: StreamBuilder(
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
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ));
                            } else {
                              return const Text('');
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 500,),
                      StreamBuilder(
                        stream: map.subscription,
                        builder: (contextMap, AsyncSnapshot<dynamic> snapshotMap){
                          /*Map<String, dynamic> mapData = jsonDecode(
                              jsonEncode(snapshotMap.data));*/
                          if (snapshotMap.hasData) {
                            Map<String,dynamic> value = Map<String,dynamic>.from(snapshotMap.data);


                            //return Text(value.toString());

                            List<int> intList = value['msg']['data'].cast<int>();

                            //Uint8List bytes = Uint8List.fromList(intList);

                            var buffer=BytesBuilder();

                            for(var e in intList) {
                              switch (e) {
                                case -1:
                                  buffer.add([77, 77, 77, 255]);
                                  break;
                                default:
                                  var grayscale = (((100 - e) / 100.0) * 50)
                                      .round()
                                      .toUnsigned(8);
                                  var r = grayscale;
                                  var b = grayscale;
                                  var g = grayscale;
                                  const a = 255;
                                  buffer.add([r, g, b, a]);
                              }
                            }
                            Uint8List bytes=Uint8List.fromList(buffer.takeBytes());

                            return getImage(bytes.toString());
                            //String bytesStr=base64.encode(Uint8List.fromList(buffer.takeBytes()));
                            //Uint8List bytes=base64.decode(bytesStr);


                            //Uint8List bytes=Uint8List.fromList(buffer.takeBytes());


                            //return Text('${mapData['msg']['data']}');
                            //return Text(bytes.toString());
                            /*return Flexible(
                                flex: 1,
                                child: Image.memory(bytes))*/
                          }
                          else
                          {
                            return const Text('NO MAP RECEIVED YET');
                          }
                        },
                      ),
                      ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
