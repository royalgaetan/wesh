import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wesh/pages/in.pages/create_or_update_contactpage.dart';
import 'package:wesh/pages/in.pages/create_or_update_event.dart';
import 'package:wesh/pages/in.pages/create_or_update_reminder.dart';
import 'package:wesh/pages/profile.dart';

class AddPage extends StatefulWidget {
  AddPage({Key? key}) : super(key: key);

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        toolbarHeight: 100,
        title: const Text(
          'Créer',
          style: TextStyle(
              color: Colors.black, fontSize: 30, fontWeight: FontWeight.w500),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CupertinoButton.filled(
              padding: EdgeInsets.symmetric(vertical: 3),
              borderRadius: BorderRadius.circular(10),
              child: Text(
                'Créer un événement',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
              onPressed: () {
                // Open Create Event Page
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateOrUpdateEventPage(),
                    ));
              },
            ),
            SizedBox(
              height: 10,
            ),
            CupertinoButton(
              color: Color(0xFFF0F0F0),
              padding: EdgeInsets.symmetric(vertical: 3),
              borderRadius: BorderRadius.circular(10),
              child: Text('Créer un rappel',
                  style: TextStyle(color: Colors.black)),
              onPressed: () {
                // Open Create Reminder Page
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateOrUpdateReminderPage(),
                    ));
              },
            ),
            SizedBox(
              height: 10,
            ),
            CupertinoButton(
              color: Color(0xFFF0F0F0),
              padding: EdgeInsets.symmetric(vertical: 3),
              borderRadius: BorderRadius.circular(10),
              child: Text('Créer un contact',
                  style: TextStyle(color: Colors.black)),
              onPressed: () {
                // Open Create Event Page
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateOrUpdateContactPage(),
                    ));
              },
            ),
          ],
        ),
      ),
    );
  }
}