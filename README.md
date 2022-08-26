# Ros Flutter App

This is a Flutter cross platform project for interacting with ROS (Robot Operating System) nodes. Main function of the app is navigate the robot and showing some information about the robot sensors, location, map and more. For interfacing with ROS nodes `roslib.dart` library is used.

Some screenshots from application.

![Main](https://user-images.githubusercontent.com/74608802/186696941-eab91e6f-afa9-42b3-a0b8-00374a3e268b.jpg)

![Sub](https://user-images.githubusercontent.com/74608802/186696949-2f5e2785-0f10-4af9-8693-bfdb3738b9f4.jpg)


## Getting Started
A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

## Requirements
- ROS
- RosBridge
- Android Studio or Visual Studio Code
- Flutter

## Installation

In this project Ros Noetic and Ubuntu 20.04 is used.

You can follow this [offical website](http://wiki.ros.org/noetic/Installation/Ubuntu) in order to get ROS Noetic.


Install Ros Bridge.
```bash
sudo apt install ros-melodic-rosbridge-server
```

Also this [website](https://docs.flutter.dev/get-started/install/linux) would guide you to prepare your system to start developing Flutter applications on Android Studio.


## Usage
1. Launch roscore.
```bash
roscore
```
2. Prepare your robot or simulation.

#### Robot

Find the robots ip and change it down below.
```bash
ssh robot_name@192.168.0.0
```
Bring up
```bash
roslaunch turtlebot3_bringup turtlebot3_robot.launch
```

#### Simulation
You can use gazebo turtlebot3 simulation environment.

Type
```bash
roslaunch turtlebot3_gazebo turtlebot3_house.launch
roslaunch turtlebot3_navigation turtlebot3_navigation.launch map_file:=/home/user_name/map_name.yaml
```

3. Run Rosbridge with ROS_HOSTNAME address
```bash
roslaunch rosbridge_server rosbridge_websocket.launch address:=192.168.0.0
```

4. Now, you can start your application and hit connect button.
5. Configure your ip address (ros_hostname) inside the app.

Make sure you are on the same wifi on your mobile device and computer which is running roscore.

You are ready to go.





## Some Examples

Setting up ros and topics example.

```dart
@override
  void initState() {
    ros = Ros(url: 'ws://$ipAddress:9090');

    Topic cmd_vel = Topic(
    ros: ros,
    name: '/cmd_vel',
    type: "geometry_msgs/Twist",
    reconnectOnClose: true,
    queueLength: 10,
    queueSize: 10);

    Topic diagnostic = Topic(
    ros: ros,
    name: '/diagnostics',
    type: "diagnostic_msgs/DiagnosticArray",
    reconnectOnClose: true,
    queueLength: 10,
    queueSize: 10);

    super.initState();
  }
```


Initializing and finishing topics:

```dart
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

```



Diagnostic Subscriber Example
``` dart
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
```

## Some Helpful Resources
[https://pub.dev/packages/roslib/example](https://pub.dev/packages/roslib/example)

[https://github.com/TimWhiting/roslib](https://github.com/TimWhiting/roslib)

[]()






## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

