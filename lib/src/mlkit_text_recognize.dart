part of '../fl_mlkit_text_recognize.dart';

typedef EventBarcodeListen = void Function(dynamic barcodes);

class FlMlKitTextRecognize extends StatefulWidget {
  FlMlKitTextRecognize({
    Key? key,
    this.onListen,
    this.overlay,
    this.uninitialized,
    this.onFlashChange,
    this.isFullScreen = true,
    this.useBackCamera = true,
    this.zoomQuality = ZoomQuality.low,
    this.autoScanning = true,
  }) : super(key: key);

  /// 是否使用后置摄像头
  /// Using the back camera
  final bool useBackCamera;

  /// 相机预览缩放质量
  /// Camera preview zoom quality
  final ZoomQuality zoomQuality;

  /// 识别回调
  /// Identify callback
  final EventBarcodeListen? onListen;

  /// 显示在预览框上面
  /// Display above preview box
  final Widget? overlay;

  /// 相机在未初始化时显示的UI
  /// The UI displayed when the camera is not initialized
  final Widget? uninitialized;

  /// Flash change
  final ValueChanged<FlashState>? onFlashChange;

  /// 是否全屏
  /// Full screen
  final bool isFullScreen;

  /// 是否自动扫描 默认为[true]
  /// Auto scan defaults to [true]
  final bool autoScanning;

  @override
  _FlMlKitTextRecognizeState createState() => _FlMlKitTextRecognizeState();
}

class _FlMlKitTextRecognizeState extends FlCameraState<FlMlKitTextRecognize> {
  @override
  void initState() {
    currentChannel = _flMlKitTextRecognizeChannel;
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((Duration time) => init());
  }

  Future<void> init() async {
    fullScreen = widget.isFullScreen;
    uninitialized = widget.uninitialized;

    /// Add message callback
    await initEvent(eventListen);

    /// Initialize camera
    if (await initCamera()) {
      setState(() {});

      /// Start scan
      if (widget.autoScanning) FlMlKitTextRecognizeMethodCall.instance.start();
    }
  }

  void eventListen(dynamic data) {
    if (widget.onListen != null) {
      widget.onListen!(data);
    }
  }

  @override
  void onFlashChange(FlashState state) {
    super.onFlashChange(state);
    if (widget.onFlashChange != null) widget.onFlashChange!(state);
  }

  @override
  void didUpdateWidget(covariant FlMlKitTextRecognize oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.overlay != widget.overlay ||
        oldWidget.onFlashChange != widget.onFlashChange ||
        oldWidget.uninitialized != widget.uninitialized ||
        oldWidget.autoScanning != widget.autoScanning ||
        oldWidget.isFullScreen != widget.isFullScreen ||
        oldWidget.onListen != widget.onListen) {
      cameraMethodCall.dispose().then((bool value) {
        if (value) init();
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      init();
    } else {
      super.didChangeAppLifecycleState(state);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget camera = super.build(context);
    if (widget.overlay != null)
      camera = Stack(children: <Widget>[
        camera,
        SizedBox.expand(child: widget.overlay),
      ]);
    return camera;
  }
}
