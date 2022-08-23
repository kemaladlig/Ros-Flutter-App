// import 'dart:typed_data';
//
// import 'package:roslib_deneme/messages/NativeList.dart';
//
// class RosInt8List extends NativeList<Int8List> {
//   RosInt8List({int fixedLength}) : super(fixedLength: fixedLength) {
//     list = Int8List(fixedLength ?? 0);
//   }
//
//   @override
//   RosInt8List.fromList(Int8List list, {bool isFixedLength = true})
//       : super.fromList(list, isFixedLength: isFixedLength);
//
//   @override
//   Int8List convertFromBuffer(ByteBuffer buffer) {
//     return buffer.asInt8List();
//   }
// }
