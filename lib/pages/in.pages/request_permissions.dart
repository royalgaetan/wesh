import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class RequestPermissionsPage extends StatefulWidget {
  const RequestPermissionsPage({Key? key}) : super(key: key);

  @override
  State<RequestPermissionsPage> createState() => _RequestPermissionsPageState();
}

class _RequestPermissionsPageState extends State<RequestPermissionsPage> {
  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.purple.shade200);
  }
}
