import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:wesh/pages/settings.pages/ask_us_question.dart';
import 'package:wesh/utils/constants.dart';
import 'package:wesh/widgets/modal.dart';
import '../../utils/functions.dart';

class HelpCenterPage extends StatefulWidget {
  const HelpCenterPage({super.key});

  @override
  State<HelpCenterPage> createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> {
  final TextEditingController searchTextController = TextEditingController();
  String searchQuery = '';
  TextStyle faqParagraphStyle = TextStyle(fontSize: 13.sp, color: Colors.black87);

  List<HelpItem> helpData = [];
  List<HelpItemContent> quickAnswers = [];
  List<HelpItemContent> helpDataAnswersOnly = [];
  bool isLoadingHelpData = false;

  fetchRandomQuickAnswers() {
    List<int> indexes = [];
    // Use whole Help Items: excepted last one Troubleshooting
    indexes = getRandomIndexes(helpDB.length - 1, 6);

    // Add random question-response from retained Items (excluded its Troubleshooting) in quickAnswers[]
    for (int index in indexes) {
      quickAnswers.add(helpDB[index].content[Random().nextInt(helpDB[index].content.length - 1)]);
    }
  }

  List<HelpItemContent> getSearchAnswers() {
    return helpDataAnswersOnly
        .where((answer) =>
            answer.subHeader != "Troubleshooting" &&
            removeDiacritics(answer.subHeader.trim().toLowerCase())
                .contains(removeDiacritics(searchQuery.trim().toLowerCase())))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    // init Help Items & Quick Answers
    initHelpItems();
  }

  initHelpItems() async {
    // Fake Loader
    setState(() {
      isLoadingHelpData = true;
    });
    await Future.delayed(const Duration(milliseconds: 200));
    // Fetch Help data from hard stored helpDB
    helpData = helpDB;

    // Fetch Quick Answers
    fetchRandomQuickAnswers();

    // Fetch only Help answers
    for (HelpItem item in helpDB) {
      helpDataAnswersOnly.addAll(item.content);
    }

    // Dismiss Loader
    setState(() {
      isLoadingHelpData = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MorphingAppBar(
        toolbarHeight: 46,
        scrolledUnderElevation: 0.0,
        heroTag: 'helpCenterPageAppBar',
        backgroundColor: Colors.white,
        titleSpacing: 0,
        elevation: 0,
        leading: IconButton(
          splashRadius: 0.06.sw,
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.black,
          ),
        ),
        title: const Text(
          'Help Center',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          // CTA Button Create or Edit Reminder
          GestureDetector(
            onTap: () {
              // Redirect to Ask a question
              Navigator.push(
                  context,
                  SwipeablePageRoute(
                    builder: (context) => const AskUsQuestionPage(),
                  ));
            },
            child: Tooltip(
              message: 'Ask us a question',
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 5, 15, 10),
                child: const Icon(Icons.support_agent_rounded, color: kSecondColor),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 0, left: 15, right: 15, bottom: 40),
          child: Column(
            children: [
              // SEARCH BOX
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 15, 10, 20),
                child: CupertinoSearchTextField(
                  controller: searchTextController,
                  onChanged: ((value) {
                    setState(() {
                      searchQuery = removeDiacritics(value.trim());
                    });
                  }),
                  onSubmitted: ((value) {
                    // GET SEARCH RESULT
                    // Handle empty query
                  }),
                  padding: EdgeInsets.symmetric(horizontal: 0.03.sw, vertical: 0.03.sw),
                  prefixIcon: Container(),
                  style: TextStyle(color: Colors.black87, fontSize: 15.sp),
                  placeholderStyle: TextStyle(color: Colors.black54, fontSize: 15.sp),
                  placeholder: "Search for answers...",
                  backgroundColor: const Color(0xFFF0F0F0),
                ),
              ),

              AnimatedCrossFade(
                crossFadeState: searchQuery.isNotEmpty ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                duration: const Duration(milliseconds: 600),
                // SEARCH RESULTS
                firstChild: Padding(
                  padding: const EdgeInsets.fromLTRB(5, 5, 5, 25),
                  child: getSearchAnswers().isEmpty
                      ? Container(
                          padding: const EdgeInsets.all(50),
                          height: 300,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Lottie.asset(
                                height: 100,
                                empty,
                                width: double.infinity,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Text(
                                'No answers found!',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black45,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          children: getSearchAnswers().map((HelpItemContent answer) {
                            return BuildAnswer(key: UniqueKey(), answer: answer);
                          }).toList(),
                        ),
                ),

                // CONTENT
                secondChild: Padding(
                  padding: const EdgeInsets.fromLTRB(5, 5, 5, 25),
                  child: isLoadingHelpData
                      ? const SizedBox(
                          height: 100,
                          child: Center(child: CupertinoActivityIndicator()),
                        )
                      : GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(0),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 1 / 1,
                          ),
                          itemCount: helpData.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                // Show Feature Help Content Modal
                                showModalBottomSheet(
                                  enableDrag: true,
                                  isScrollControlled: true,
                                  context: context,
                                  backgroundColor: Colors.transparent,
                                  builder: ((context) => Modal(
                                        minHeightSize: 350,
                                        maxHeightSize: MediaQuery.of(context).size.height,
                                        child: SizedBox(
                                          width: 200,
                                          child: HelpItem(
                                            icon: helpData[index].icon,
                                            title: helpData[index].title,
                                            content: helpData[index].content,
                                          ),
                                        ),
                                      )),
                                );
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Icon
                                  CircleAvatar(
                                    radius: 25,
                                    backgroundColor: Colors.grey.shade600,
                                    child: Padding(
                                      padding: const EdgeInsets.all(3),
                                      child: helpData[index].icon,
                                    ),
                                  ),

                                  const SizedBox(height: 6),
                                  // Title
                                  Text(
                                    helpData[index].title,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ),

              // Quick Answers
              Visibility(
                visible: searchQuery.isEmpty,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(15, 5, 10, 10),
                  child: Row(
                    children: [
                      Text('Quick Answers', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: searchQuery.isEmpty,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 40),
                  child: isLoadingHelpData
                      ? Container(
                          padding: const EdgeInsets.all(50),
                          height: 30,
                          child: const Center(child: CupertinoActivityIndicator()),
                        )
                      : Column(
                          children: quickAnswers.map((HelpItemContent answer) {
                            return BuildAnswer(key: UniqueKey(), answer: answer);
                          }).toList(),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BuildAnswer extends StatelessWidget {
  final HelpItemContent answer;
  const BuildAnswer({
    super.key,
    required this.answer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: ExpansionTile(
        shape: const Border(),
        tilePadding: const EdgeInsets.only(left: 10, right: 10),
        title: Text(
          answer.subHeader,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
        ),
        maintainState: true,
        textColor: Colors.black87,
        collapsedTextColor: Colors.black87,
        collapsedBackgroundColor: Colors.transparent,
        backgroundColor: Colors.grey.shade100,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 20),
            child: RichText(
              text: TextSpan(
                children: answer.contentList,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class HelpItemContent extends StatelessWidget {
  final String subHeader;
  final List<InlineSpan> contentList;
  const HelpItemContent({super.key, required this.subHeader, required this.contentList});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Subheader
        Text(
          subHeader,
          style: TextStyle(
            color: kSecondColor,
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),

        // Content List
        RichText(
          text: TextSpan(
            children: contentList,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 11.sp,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        const SizedBox(height: 35),
      ],
    );
  }
}

class HelpItem extends StatelessWidget {
  final String title;
  final Widget icon;
  final List<HelpItemContent> content;

  const HelpItem({super.key, required this.title, required this.icon, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Column(
        children: [
          // Title + Icon
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Icon
              CircleAvatar(
                radius: 25,
                backgroundColor: kSecondColor,
                child: Padding(
                  padding: const EdgeInsets.all(7),
                  child: icon,
                ),
              ),
              const SizedBox(height: 10),
              // Title
              Text(
                title,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),

          // Content
          ...content
        ],
      ),
    );
  }
}

TextSpan subSubHelpItem({required String title, String? text, required List<InlineSpan> widgetSpanChildren}) {
  return TextSpan(
    style: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.normal,
      color: Colors.grey.shade800,
    ),
    children: [
      TextSpan(
        // Title
        text: '${'       '}\t\t◆ $title: ',
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
      ),

      // Content
      text != null
          ? TextSpan(
              text: text,
            )
          : const TextSpan(),
      ...widgetSpanChildren
    ],
  );
}
