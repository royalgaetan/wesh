import 'dart:async';

class Counter {
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  bool _isRunning = false;
  bool _isPaused = false;
  bool _isDisposed = false;

  // Duration stream to expose the formatted elapsed time
  final StreamController<Duration> _durationStreamController = StreamController<Duration>.broadcast();
  Stream<Duration> get durationStream => _durationStreamController.stream;

  // Start the counter with a specified interval
  void start(Duration interval) {
    if (_isDisposed) return;

    if (_isPaused) {
      _resume(interval);
    } else {
      _timer?.cancel();
      _elapsed = Duration.zero; // Reset elapsed time when starting anew
      _timer = Timer.periodic(interval, (timer) {
        if (!_isPaused && !_isDisposed) {
          _elapsed += interval;
          _durationStreamController.add(_elapsed);
        }
      });
      _isRunning = true;
    }
  }

  // Pause the counter
  void pause() {
    _isPaused = true;
    _timer?.cancel();
  }

  // Resume the counter
  void _resume(Duration interval) {
    _isPaused = false;
    if (_isRunning) {
      _timer = Timer.periodic(interval, (timer) {
        if (!_isPaused && !_isDisposed) {
          _elapsed += interval;
          _durationStreamController.add(_elapsed);
        }
      });
    }
  }

  // Reset and stop the counter
  void reset() {
    _isPaused = false;
    _timer?.cancel();
    _elapsed = Duration.zero;
    _durationStreamController.add(_elapsed); // Notify listeners with reset value
  }

  // Dispose of the counter and clean up resources
  void dispose() {
    _isDisposed = true;
    _timer?.cancel();
    _durationStreamController.close();
  }
}
