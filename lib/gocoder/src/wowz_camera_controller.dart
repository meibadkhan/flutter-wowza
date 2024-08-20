part of gocoder;

@immutable
class CameraControllerValue {
  CameraControllerValue({required this.event, this.value});

  final String event;

  final dynamic value;
}

class WOWZCameraController extends ValueNotifier<CameraControllerValue> {
  late MethodChannel _channel;

  // Set the connection properties for the target Wowza Streaming Engine server or Wowza Streaming Cloud live stream
  String hostAddress;
  int portNumber;
  String applicationName;
  String streamName;

  //authentication
  String username;
  String password;

  WOWZSize wowzSize;
  WOWZMediaConfig wowzMediaConfig;
  ScaleMode scaleMode;

  int fps;
  int bps;
  int khz;

  bool configIsWaiting = false;

  _setChannel(MethodChannel channel) {
    _channel = channel;
  }

  WOWZCameraController({
    required this.hostAddress,
    required this.portNumber,
    required this.applicationName,
    required this.streamName,
    required this.username,
    required this.password,
    required this.wowzSize,
    required this.wowzMediaConfig,
    required this.scaleMode,
    required this.fps,
    required this.bps,
    required this.khz,
  }) : super(CameraControllerValue(event: ''));

  /// It will not execute immediately when the channel has not been initialized,
  /// and it will wait until the channel is initialized and it will automatically execute the config.
  setWOWZConfig({
    required String hostAddress,
    required int portNumber,
    required String applicationName,
    required String streamName,
    required String username,
    required String password,
    required WOWZSize wowzSize,
    required WOWZMediaConfig wowzMediaConfig,
    required ScaleMode scaleMode,
    required int fps,
    required int bps,
    required int khz,
  }) {
    configIsWaiting = false;

    // Set the connection properties for the target Wowza Streaming Engine server or Wowza Streaming Cloud live stream
    if (hostAddress.isNotEmpty) {
      _channel.invokeMethod(_hostAddress, hostAddress);
    }
    _channel.invokeMethod(_portNumber, portNumber);
    if (applicationName.isNotEmpty) {
      _channel.invokeMethod(_applicationName, applicationName);
    }
    if (streamName.isNotEmpty) {
      _channel.invokeMethod(_streamName, streamName);
    }
    // authentication
    if (username.isNotEmpty) {
      _channel.invokeMethod(_username, username);
    }
    if (password.isNotEmpty) {
      _channel.invokeMethod(_password, password);
    }
    _channel.invokeMethod(_wowzSize, "${wowzSize.width}/${wowzSize.height}");
    _channel.invokeMethod(_wowzMediaConfig, wowzMediaConfig.toString());
    _channel.invokeMethod(_scaleMode, scaleMode.toString());
    _channel.invokeListMethod(_fps, fps);
    _channel.invokeListMethod(_bps, bps);
    _channel.invokeListMethod(_khz, khz);

    _channel.invokeListMethod(_initGoCoder);
  }

  /// Restore settings set in the [setWOWZConfig] method
  resetConfig() {
    configIsWaiting = false;

    // Set the connection properties for the target Wowza Streaming Engine server or Wowza Streaming Cloud live stream
    if (hostAddress.isNotEmpty) {
      _channel.invokeMethod(_hostAddress, hostAddress);
    }
    _channel.invokeMethod(_portNumber, portNumber);
    if (applicationName.isNotEmpty) {
      _channel.invokeMethod(_applicationName, applicationName);
    }
    if (streamName.isNotEmpty) {
      _channel.invokeMethod(_streamName, streamName);
    }
    // authentication
    if (username.isNotEmpty) {
      _channel.invokeMethod(_username, username);
    }
    if (password.isNotEmpty) {
      _channel.invokeMethod(_password, password);
    }
    _channel.invokeMethod(_wowzSize, "${wowzSize.width}/${wowzSize.height}");
    _channel.invokeMethod(_wowzMediaConfig, wowzMediaConfig.toString());
    _channel.invokeMethod(_scaleMode, scaleMode.toString());
    _channel.invokeListMethod(_fps, fps);
    _channel.invokeListMethod(_bps, bps);
    _channel.invokeListMethod(_khz, khz);

    _channel.invokeListMethod(_initGoCoder);
  }

  /// Starts the camera preview display.
  startPreview() {
    value = CameraControllerValue(event: _startPreview);
  }

  /// Stops the camera preview display.
  stopPreview() {
    value = CameraControllerValue(event: _stopPreview);
  }

  pausePreview() {
    value = CameraControllerValue(event: _pausePreview);
  }

  continuePreview() {
    value = CameraControllerValue(event: _continuePreview);
  }

  onPause() {
    value = CameraControllerValue(event: _onPause);
  }

  onResume() {
    value = CameraControllerValue(event: _onResume);
  }

  switchCamera() {
    value = CameraControllerValue(event: _switchCamera);
  }

  flashLight(bool enable) {
    value = CameraControllerValue(event: _flashlight, value: enable);
  }

  Future<bool> isSwitchCameraAvailable() async {
    return await _channel.invokeMethod(_isSwitchCameraAvailable);
  }

  setFps(int fps) {
    value = CameraControllerValue(event: _fps, value: fps);
  }

  setVideoBitrate(int bps) {
    value = CameraControllerValue(event: _bps, value: bps);
  }

  setAudioRate(int khz) {
    value = CameraControllerValue(event: _khz, value: khz);
  }

  setMuted(bool muted) {
    value = CameraControllerValue(event: _muted, value: muted);
  }

  // WOWZBroadcast
  startBroadcast() {
    value = CameraControllerValue(event: _startBroadcast);
  }

  endBroadcast() {
    value = CameraControllerValue(event: _endBroadcast);
  }

  Future<bool> isInitialized() async {
    return await _channel.invokeMethod(_isInitialized);
  }
}
