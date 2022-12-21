import 'dart:developer';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:wesh/utils/constants.dart';
import 'package:widget_and_text_animator/widget_and_text_animator.dart';
import '../../services/sharedpreferences.service.dart';
import '../../models/user.dart' as usermodel;

class HappyBirthdayPage extends StatefulWidget {
  final usermodel.User? currentUser;
  const HappyBirthdayPage({Key? key, this.currentUser}) : super(key: key);

  @override
  State<HappyBirthdayPage> createState() => _HappyBirthdayPageState();
}

class _HappyBirthdayPageState extends State<HappyBirthdayPage> {
  late ConfettiController _controllerBottomLeft;
  late ConfettiController _controllerBottomRight;

  // Audio Players
  AssetsAudioPlayer christmasCrowdCheerAudioPlayer = AssetsAudioPlayer();

  @override
  void initState() {
    super.initState();
    _controllerBottomLeft = ConfettiController(duration: const Duration(seconds: 15));
    _controllerBottomRight = ConfettiController(duration: const Duration(seconds: 15));
    _controllerBottomLeft.play();
    _controllerBottomRight.play();
    //
    WidgetsBinding.instance.addPostFrameCallback((_) => playBirthdaySounds());
    UserSimplePreferences.setHappyBirthdayDateTimeWish(DateTime.now().year);
  }

  Future playBirthdaySounds() async {
    try {
      await christmasCrowdCheerAudioPlayer.open(
        Audio(christmasCrowdCheer),
      );

      christmasCrowdCheerAudioPlayer.play();
    } catch (e) {
      //mp3 unreachable
      log('Error while playing sounds : $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controllerBottomLeft.dispose();
    _controllerBottomRight.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            splashRadius: 0.06.sw,
            onPressed: () {
              Navigator.pop(context, false);
            },
            icon: const Icon(
              Icons.close,
              color: Colors.black,
            ),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // MAIN CONTENT
          SafeArea(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Date

              WidgetAnimator(
                atRestEffect: WidgetRestingEffects.size(),
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    DateFormat('dd MMMM', 'fr_Fr').format(widget.currentUser?.birthday ?? DateTime.now()).toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'Moderat',
                      fontSize: 30.sp,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w900,
                      color: kSecondColor,
                    ),
                  ),
                ),
              ),

              // Animated Widget
              Lottie.asset(
                height: 230,
                happyBirthday,
                width: double.infinity,
              ),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: '🎉 Joyeux anniversaire 🎈\n',
                  style: TextStyle(
                    fontSize: 17.sp,
                    color: Colors.black87,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                        text: widget.currentUser != null ? widget.currentUser!.name : '',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

              const SizedBox(height: 25),
              TextButton(
                onPressed: () {
                  // Send 'THANK YOU AS FEEDBACK'
                  Navigator.pop(context, true);
                },
                child: const Text('Merci beaucoup !'),
              )
            ],
          )),

          // CONFETTI

          //  Bottom-Left
          Align(
            alignment: Alignment.bottomLeft,
            child: ConfettiWidget(
              confettiController: _controllerBottomLeft,
              blastDirectionality: BlastDirectionality.explosive,
              maximumSize: const Size(20, 10),
              minimumSize: const Size(10, 5),
              emissionFrequency: 0.03,
              numberOfParticles: 500,
              maxBlastForce: 500,
              minBlastForce: 220,
              gravity: 0.7,
            ),
          ),

          //  Bottom-Right
          Align(
            alignment: Alignment.bottomRight,
            child: ConfettiWidget(
              confettiController: _controllerBottomRight,
              colors: eventAvailableColorsList,
              blastDirectionality: BlastDirectionality.explosive,
              maximumSize: const Size(20, 10),
              minimumSize: const Size(10, 5),
              emissionFrequency: 0.03,
              numberOfParticles: 500,
              maxBlastForce: 500,
              minBlastForce: 220,
              gravity: 0.7,
            ),
          ),
        ],
      ),
    );
  }
}
