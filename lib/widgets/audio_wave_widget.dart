import 'dart:async';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wesh/utils/constants.dart';
import 'package:wesh/utils/functions.dart';

class AudioWaveWidget extends StatefulWidget {
  final String path;
  final bool? isDark;
  final int? noOfSamples;
  final bool? isLoading;
  final Function? onDownloadOrUploadButtonPressed;

  const AudioWaveWidget({
    super.key,
    required this.path,
    this.isDark,
    this.isLoading,
    this.noOfSamples,
    this.onDownloadOrUploadButtonPressed,
  });

  @override
  State<AudioWaveWidget> createState() => _AudioWaveWidgetState();
}

class _AudioWaveWidgetState extends State<AudioWaveWidget> {
  late PlayerController controller;
  late StreamSubscription<PlayerState> playerStateSubscription;
  late StreamSubscription<int> playerDurationSubscription;
  PlayerState playerState = PlayerState.stopped;
  int playerDuration = 0;
  int playerMaxDuration = 0;
  List<double> playerRates = [0.75, 1, 1.5, 2];
  int currentPlayerRateIndex = 1;
  bool isLocallyLoading = false;

  @override
  void initState() {
    super.initState();
    controller = PlayerController();
    prepareAudioWavePlayer();
  }

  goToNextPlayerRate() {
    int newRateIndex =
        currentPlayerRateIndex == playerRates.length - 1 ? currentPlayerRateIndex = 0 : currentPlayerRateIndex += 1;

    controller.setRate(playerRates[newRateIndex]).then((_) {
      setState(() {
        currentPlayerRateIndex = newRateIndex;
      });
    }).catchError((e) {
      debugPrint('An error occured while updating the audio rate: $e');
    });
  }

  void prepareAudioWavePlayer() async {
    setState(() {
      isLocallyLoading = true;
    });
    // Prepare player with extracting waveform
    await controller
        .preparePlayer(
      path: widget.path,
      shouldExtractWaveform: true,
      noOfSamples: widget.noOfSamples ?? 20,
      volume: 1.0,
    )
        .then((_) {
      setState(() {
        controller.startPlayer();
        controller.pausePlayer();
        playerMaxDuration = controller.maxDuration;
        isLocallyLoading = false;
      });
    });

    // Listen to Player change
    playerStateSubscription = controller.onPlayerStateChanged.listen((newState) {
      setState(() {
        playerState = newState;
      });
    });

    // Listen to Player Duration
    playerDurationSubscription = controller.onCurrentDurationChanged.listen((newDuration) {
      setState(() {
        playerDuration = newDuration;
      });
    });
  }

  @override
  void dispose() {
    playerStateSubscription.cancel();
    playerDurationSubscription.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ACTION BUTTONS: play, pause, stop, loader, download, upload
        GestureDetector(
          onTap: () async {
            controller.playerState.isPlaying
                ? await controller.pausePlayer()
                : await controller.startPlayer(finishMode: FinishMode.pause);
          },
          child: Container(
            alignment: Alignment.topCenter,
            width: 30,
            height: 40,
            child:
                // Loader
                isLocallyLoading || widget.isLoading == true
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: RepaintBoundary(
                          child: CircularProgressIndicator(
                            strokeWidth: 1.6,
                            color: widget.isDark == true ? Colors.grey.shade700 : Colors.white,
                          ),
                        ),
                      )
                    :
                    // Play, Pause, Stop
                    Transform.translate(
                        offset: const Offset(0, -8),
                        child: Icon(
                          controller.playerState.isPaused
                              ? Icons.play_arrow_rounded
                              : controller.playerState.isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.stop,
                          size: 35,
                          color: widget.isDark == true ? Colors.grey.shade700 : Colors.white,
                        ),
                      ),
          ),
        ),

        // Audio Seek Bar Containenr
        Expanded(
          child: Column(
            children: [
              // AudioWave
              Container(
                alignment: Alignment.center,
                child: AudioFileWaveforms(
                  margin: const EdgeInsets.only(right: 7),
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  size: Size(1.sw, 20),
                  playerController: controller,
                  waveformType: WaveformType.fitWidth,
                  continuousWaveform: true,
                  enableSeekGesture: true,
                  playerWaveStyle: PlayerWaveStyle(
                    fixedWaveColor: widget.isDark == true ? Colors.grey.shade400 : Colors.grey.shade500,
                    liveWaveColor: widget.isDark == true ? Colors.grey.shade700 : Colors.white,
                    showSeekLine: false,
                    spacing: 6,
                  ),
                ),
              ),

              // Duration Indicator
              if (playerMaxDuration != 0)
                Container(
                  margin: const EdgeInsets.only(top: 6, right: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${getDurationFormat(Duration(milliseconds: playerDuration))} / ${getDurationFormat(Duration(milliseconds: playerMaxDuration))}',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 10.sp,
                          color: widget.isDark == true ? Colors.grey.shade500 : Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),

        // Increase Player rate: 0.75x, 1.0x, 1.5x, 2.0x
        GestureDetector(
            child: Transform.translate(
              offset: const Offset(0, -5),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.fromLTRB(11, 7, 11, 7),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: isLocallyLoading || widget.isLoading == true ? kSecondColor.withOpacity(.5) : kSecondColor,
                ),
                child: Text(
                  "${playerRates[currentPlayerRateIndex]}x",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            onTap: () {
              goToNextPlayerRate();
            }),
      ],
    );
  }
}
