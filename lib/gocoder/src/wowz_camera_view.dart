part of gocoder;

const _cameraViewChannel = 'flutter_wowza';

enum BroadcastState {
  READY,
  BROADCASTING,
  IDLE,
  IDLE_ERROR,
  READY_ERROR,
  BROADCASTING_ERROR
}

WOWZBroadcastStatus parseBroadcastStatus(String str) =>
    WOWZBroadcastStatus.fromJson(json.decode(str));

String encodeBroadcastStatus(WOWZBroadcastStatus data) => json.encode(data.toJson());

class WOWZBroadcastStatus {
  BroadcastState state;
  String message;
  bool isError = false;

  WOWZBroadcastStatus({required this.state, required this.message});

  factory WOWZBroadcastStatus.fromJson(Map<String, dynamic> json) =>
      WOWZBroadcastStatus(
          state: BroadcastState.values.firstWhere(
                  (type) => type.toString() == "BroadcastState." + json["state"]),
          message: json["message"]);

  Map<String, dynamic> toJson() =>
      {"state": state.toString(), "message": message};
}

enum WOWZMediaConfig {
  FRAME_SIZE_176x144,
  FRAME_SIZE_320x240,
  FRAME_SIZE_352x288,
  FRAME_SIZE_640x480,
  FRAME_SIZE_960x540,
  FRAME_SIZE_1280x720,
  FRAME_SIZE_1440x1080,
  FRAME_SIZE_1920x1080,
  FRAME_SIZE_3840x2160
}

enum ScaleMode {
  RESIZE_TO_ASPECT,
  FILL_VIEW
}

typedef WOWZStatusCallback = Function(WOWZStatus);
typedef WOWZBroadcastStatusCallback = Function(WOWZBroadcastStatus);

abstract class OnWOWZBroadcastStatusCallback {
  void onWZStatus(WOWZBroadcastStatus status);

  void onWZError(WOWZBroadcastStatus status);
}

class WOWZCameraView extends StatefulWidget {
  WOWZCameraView(
      {required this.controller,
        required this.androidLicenseKey,
        required this.iosLicenseKey,
        required this.statusCallback,
        required this.broadcastStatusCallback});

  @override
  _WOWZCameraViewState createState() => _WOWZCameraViewState();

  final WOWZCameraController controller;
  final WOWZStatusCallback statusCallback;
  final WOWZBroadcastStatusCallback broadcastStatusCallback;
  final String androidLicenseKey;
  final String iosLicenseKey;
}

class _WOWZCameraViewState extends State<WOWZCameraView> with AutomaticKeepAliveClientMixin {
  var _viewId = 0;
  late MethodChannel _channel;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      print('controller event: ${widget.controller.value.event}');
      switch (widget.controller.value.event) {
        case _flashlight:
          if (defaultTargetPlatform == TargetPlatform.android)
            _channel.invokeMethod(widget.controller.value.event, widget.controller.value.value);
          else
            _channel.invokeMethod(widget.controller.value.value ? _flashlightOn : _flashlightOff);
          break;
        case _muted:
          if (defaultTargetPlatform == TargetPlatform.android)
            _channel.invokeMethod(widget.controller.value.event, widget.controller.value.value);
          else
            _channel.invokeMethod(widget.controller.value.value ? _mutedOn : _mutedOff);
          break;
        case _startPreview:
        case _stopPreview:
        case _pausePreview:
        case _continuePreview:
        case _isSwitchCameraAvailable:
        case _onPause:
        case _onResume:
        case _switchCamera:
        case _fps:
        case _bps:
        case _khz:
        case _startBroadcast:
        case _endBroadcast:
          _channel.invokeMethod(widget.controller.value.event, widget.controller.value.value);
          break;
        default:
          break;
      }
        });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return (defaultTargetPlatform == TargetPlatform.android)
        ? AndroidView(
      viewType: _cameraViewChannel,
      onPlatformViewCreated: _onPlatformViewCreated,
    )
        : (defaultTargetPlatform == TargetPlatform.iOS)
        ? UiKitView(
      viewType: _cameraViewChannel,
      onPlatformViewCreated: _onPlatformViewCreated,
    )
        : Text('$defaultTargetPlatform is not yet supported by the text_view plugin');
  }

  void _onPlatformViewCreated(int viewId) {
    if (_viewId != viewId) {
      _viewId = viewId;

      _channel = MethodChannel("${_cameraViewChannel}_$viewId");
      widget.controller._setChannel(_channel);

      _channel.setMethodCallHandler((call) async {
        print('wowz: status: ${call.arguments}');
        switch (call.method) {
          case _broadcastStatus:
            widget.broadcastStatusCallback(parseBroadcastStatus(call.arguments));
            break;
          case _broadcastError:
            final status = parseBroadcastStatus(call.arguments);
            switch (status.state) {
              case BroadcastState.IDLE:
                status.state = BroadcastState.IDLE_ERROR;
                break;
              case BroadcastState.BROADCASTING:
                status.state = BroadcastState.BROADCASTING_ERROR;
                break;
              case BroadcastState.READY:
                status.state = BroadcastState.READY_ERROR;
                break;
              default:
                status.state = BroadcastState.BROADCASTING_ERROR;
                break;
            }
            widget.broadcastStatusCallback(status);
            break;
          case _wowzStatus:
            widget.statusCallback(WOWZStatus(call.arguments));
            break;
          case _wowzError:
            widget.statusCallback(WOWZStatus(call.arguments));
            break;
        }
      });

      _channel.invokeMethod(
          _apiLicenseKey,
          (defaultTargetPlatform == TargetPlatform.android)
              ? widget.androidLicenseKey
              : widget.iosLicenseKey);

      if (widget.controller.configIsWaiting) {
        widget.controller.resetConfig();
      }
    }
  }

  @override
  bool get wantKeepAlive => true;
}

@immutable
class WOWZSize {
  WOWZSize(this.width, this.height);

  final int width;
  final int height;
}


class WOWZStatus {
  int mState = 0;

  WOWZStatus(this.mState);

  bool isIdle() {
    return this.mState == 0;
  }

  bool isStarting() {
    return this.mState == 1;
  }

  bool isReady() {
    return this.mState == 2;
  }

  bool isRunning() {
    return this.mState == 3;
  }

  bool isPaused() {
    return this.mState == 5;
  }

  bool isStopping() {
    return this.mState == 4;
  }

  bool isStopped() {
    return this.mState == 6;
  }

  bool isComplete() {
    return this.mState == 7;
  }

  bool isShutdown() {
    return this.mState == 9;
  }

  bool isUnknown() {
    return this.mState == 11;
  }

  bool isBuffering() {
    return this.mState == 12;
  }

  bool isPlayerBuffering() {
    return this.mState == 24;
  }

  bool isPlayerIdle() {
    return this.mState == 20;
  }

  bool isPlayerStopping() {
    return this.mState == 23;
  }

  bool isPlayerRunning() {
    return this.mState == 21;
  }
}
