import 'package:flutter/material.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:wesh/utils/constants.dart';
import 'package:wesh/widgets/audiowidget_extra.dart';

class AudioWidget extends StatefulWidget {
  final String data;
  final String? btnTheme;
  final bool? displaySpeedUpBtn;
  const AudioWidget({Key? key, required this.data, this.btnTheme, this.displaySpeedUpBtn}) : super(key: key);

  @override
  AudioWidgetState createState() => AudioWidgetState();
}

class AudioWidgetState extends State<AudioWidget> with WidgetsBindingObserver {
  final _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    ambiguate(WidgetsBinding.instance)!.addObserver(this);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
    ));
    _init();
  }

  Future<void> _init() async {
    // Inform the operating system of our app's audio attributes etc.
    // We pick a reasonable default for an app that plays speech.
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
    // Listen to errors during playback.
    _player.playbackEventStream.listen((event) {}, onError: (Object e, StackTrace stackTrace) {
      debugPrint('A stream error occurred: $e');
    });
    // Try to load audio from a source and catch any errors.
    try {
      // AAC example: https://dl.espressif.com/dl/audio/ff-16b-2c-44100hz.aac
      await _player.setFilePath(widget.data);
    } catch (e) {
      debugPrint("Error loading audio source: $e");
    }
  }

  @override
  void dispose() {
    ambiguate(WidgetsBinding.instance)!.removeObserver(this);
    // Release decoders and buffers back to the operating system making them
    // available for other apps to use.
    _player.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Release the player's resources when not in use. We use "stop" so that
      // if the app resumes later, it will still remember what position to
      // resume from.
      _player.stop();
    }
  }

  /// Collects the data useful for displaying in a seek bar, using a handy
  /// feature of rx_dart to combine the 3 streams of interest into one.
  Stream<PositionData> get _positionDataStream => Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
      _player.positionStream,
      _player.bufferedPositionStream,
      _player.durationStream,
      (position, bufferedPosition, duration) => PositionData(position, bufferedPosition, duration ?? Duration.zero));

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Display play/pause button
        /// This StreamBuilder rebuilds whenever the player state changes, which
        /// includes the playing/paused state and also the
        /// loading/buffering/ready state. Depending on the state we show the
        /// appropriate button or loading indicator.
        StreamBuilder<PlayerState>(
          stream: _player.playerStateStream,
          builder: (context, snapshot) {
            final playerState = snapshot.data;
            final processingState = playerState?.processingState;
            final playing = playerState?.playing;
            return Expanded(
              flex: 1,
              child: SizedBox(
                width: 0.03.sw,
                child: () {
                  if (processingState == ProcessingState.loading || processingState == ProcessingState.buffering) {
                    return Container(
                      margin: const EdgeInsets.all(2),
                      padding: const EdgeInsets.all(2),
                      width: 4.0,
                      height: 4.0,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: widget.btnTheme == 'white' ? Colors.white : kSecondColor),
                    );
                  } else if (playing != true) {
                    return IconButton(
                      splashRadius: 0.06.sw,
                      icon: const Icon(Icons.play_circle_fill_rounded),
                      padding: const EdgeInsets.all(2),
                      iconSize: 0.12.sw,
                      color: widget.btnTheme == 'white' ? Colors.white : Colors.black54,
                      onPressed: _player.play,
                    );
                  } else if (processingState != ProcessingState.completed) {
                    return IconButton(
                      splashRadius: 0.06.sw,
                      icon: const Icon(Icons.pause_circle_outline_rounded),
                      padding: const EdgeInsets.all(2),
                      iconSize: 0.12.sw,
                      color: widget.btnTheme == 'white' ? Colors.white : Colors.black54,
                      onPressed: _player.pause,
                    );
                  } else {
                    return IconButton(
                      splashRadius: 0.06.sw,
                      padding: const EdgeInsets.all(2),
                      icon: const Icon(Icons.replay_circle_filled_outlined),
                      iconSize: 0.12.sw,
                      color: widget.btnTheme == 'white' ? Colors.white : Colors.black54,
                      onPressed: () => _player.seek(Duration.zero),
                    );
                  }
                }(),
              ),
            );
          },
        ),

        // Display seek bar. Using StreamBuilder, this widget rebuilds
        // each time the position, buffered position or duration changes.
        StreamBuilder<PositionData>(
          stream: _positionDataStream,
          builder: (context, snapshot) {
            final positionData = snapshot.data;
            return Expanded(
              flex: 5,
              child: SeekBar(
                btnTheme: widget.btnTheme,
                duration: positionData?.duration ?? Duration.zero,
                position: positionData?.position ?? Duration.zero,
                bufferedPosition: positionData?.bufferedPosition ?? Duration.zero,
                onChangeEnd: _player.seek,
              ),
            );
          },
        ),

        // Opens speed slider dialog
        widget.displaySpeedUpBtn != null && widget.displaySpeedUpBtn == false
            ? Container()
            : StreamBuilder<double>(
                stream: _player.speedStream,
                builder: (context, snapshot) {
                  return Expanded(
                    flex: 2,
                    child: IconButton(
                      splashRadius: 0.06.sw,
                      icon: Text(
                        "${snapshot.data?.toStringAsFixed(1)}x",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11.sp,
                          color: widget.btnTheme == 'white' ? Colors.white : kSecondColor,
                        ),
                      ),
                      onPressed: () {
                        showSliderDialog(
                          context: context,
                          title: "Ajuster la vitesse",
                          divisions: 10,
                          min: 0.5,
                          max: 1.5,
                          value: _player.speed,
                          stream: _player.speedStream,
                          onChanged: _player.setSpeed,
                        );
                      },
                    ),
                  );
                }),
      ],
    );
  }
}
