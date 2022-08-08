import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:roslib/roslib.dart';

void main() {
  runApp(ExampleApp());
}

class ExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Roslib Example',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Ros ros;
  int linearCounter = 0;
  int angularCounter = 0;
  late Topic cmd_vel;
  late Topic diagnostic;

  @override
  void initState() {
    ros = Ros(url: 'ws://192.168.3.74:9090');

    cmd_vel = Topic(
        ros: ros,
        name: '/cmd_vel',
        type: "geometry_msgs/Twist",
        reconnectOnClose: true,
        queueLength: 10,
        queueSize: 10
    );
    diagnostic = Topic(
        ros:ros,
        name: '/diagnostics',
        type: "diagnostic_msgs/DiagnosticArray",
        reconnectOnClose: true,
        queueLength: 10,
        queueSize: 10
    );
    super.initState();
  }
  void move(double coordinate, double angle) {
    double linearSpeed = 0.0;
    double angularSpeed = 0.0;
    linearSpeed = linearCounter * coordinate;
    angularSpeed = angularCounter * angle;
    publishCmd(linearSpeed, angularSpeed);

    if(kDebugMode)
    {
      print('cmd published');
    }
  }
  void initConnection() async {
    ros.connect();
    await cmd_vel.advertise();
    await diagnostic.subscribe();
    setState(() {});
  }

  void destroyConnection() async {
    await diagnostic.unsubscribe();
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
          backgroundColor: Colors.grey[700],
          appBar: AppBar(
              title: const Text('Teleop app'),
              centerTitle: true
          ),
          body: StreamBuilder<Object>(
            stream: ros.statusStream,
            builder: (context, snapshot){
              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  StreamBuilder(
                    stream: diagnostic.subscription,
                    builder: (context2, snapshot2){
                      if(snapshot2.hasData)
                      {
                        return Text('${snapshot2.data}');
                      }
                      else{
                        return const CircularProgressIndicator();
                      }
                    },
                  )
                  ,
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
                          label: const Text('Forward')
                      ),
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
                          label: const Text('Left')
                      ),
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
                          label: const Text('Stop')
                      ),
                      ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(130.0, 40.0),
                          ),
                          onPressed: () {
                            angularCounter--;
                            move(0.0, 0.05);
                          },
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text('Right')
                      ),
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
                          label: const Text('Backward')
                      ),
                    ],
                  ),
                ], );
            },

          ),
        );
      },
    );
  }
}