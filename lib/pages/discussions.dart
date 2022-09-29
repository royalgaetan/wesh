import 'package:flutter/material.dart';
import 'package:wesh/models/discussion.dart';
import 'package:wesh/pages/in.pages/searchpage.dart';
import 'package:wesh/pages/in.pages/settings.dart';
import 'package:wesh/utils/db.dart';
import 'package:wesh/widgets/discussioncard.dart';

class MessagesPage extends StatefulWidget {
  MessagesPage({Key? key}) : super(key: key);

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => const [
          SliverAppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            expandedHeight: 85,
            // pinned: true,
            floating: true,
            snap: true,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.only(left: 15, bottom: 10),
              title: Text(
                'Messages',
                style: TextStyle(color: Colors.black, fontSize: 21),
              ),
            ),
          )
        ],
        body: ListView.builder(
          itemCount: discussionsList.length,
          itemBuilder: (context, index) =>
              DiscussionCard(discussion: discussionsList[index]),
        ),
      ),
    );
  }
}
