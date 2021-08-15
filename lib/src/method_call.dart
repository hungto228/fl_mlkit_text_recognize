part of '../fl_mlkit_text_recognize.dart';

class FlMlKitTextRecognizeMethodCall {
  factory FlMlKitTextRecognizeMethodCall() => _getInstance();

  FlMlKitTextRecognizeMethodCall._internal();

  static FlMlKitTextRecognizeMethodCall get instance => _getInstance();
  static FlMlKitTextRecognizeMethodCall? _instance;

  static FlMlKitTextRecognizeMethodCall _getInstance() {
    _instance ??= FlMlKitTextRecognizeMethodCall._internal();
    return _instance!;
  }

  final MethodChannel _channel = _flMlKitTextRecognizeChannel;

  MethodChannel get channel => _channel;

// 识别图片字节
  /// Identify picture bytes
  /// [useEvent] 返回消息使用 FLCameraEvent
  /// The return message uses flcameraevent
  /// [rotationDegrees] Only Android is supported
  Future<AnalysisTextModel?> scanImageByte(Uint8List uint8list,
      {int rotationDegrees = 0, bool useEvent = false}) async {
    if (!_supportPlatform) return null;
    if (useEvent) {
      assert(
          FlCameraEvent.instance.isPaused, 'Please initialize FLCameraEvent');
    }
    final dynamic map = await _channel.invokeMethod<dynamic>(
        'scanImageByte', <String, dynamic>{
      'byte': uint8list,
      'useEvent': useEvent,
      'rotationDegrees': rotationDegrees
    });
    if (map != null && map is Map) return AnalysisTextModel.fromMap(map);
    return null;
  }

  /// 打开\关闭 闪光灯
  /// Turn flash on / off
  Future<bool> setFlashMode(bool status) =>
      FlCameraMethodCall.instance.setFlashMode(status);

  /// 相机缩放
  /// Camera zoom
  Future<bool> setZoomRatio(double ratio) =>
      FlCameraMethodCall.instance.setZoomRatio(ratio);

  /// 获取可用摄像头
  /// get available Cameras
  Future<List<CameraInfo>?> availableCameras() =>
      FlCameraMethodCall.instance.availableCameras();

  /// 暂停扫描
  /// Pause scanning
  Future<bool> pause() => _scanncing(false);

  /// 开始扫描
  /// Start scanncing
  Future<bool> start() => _scanncing(true);

  Future<bool> _scanncing(bool scan) async {
    if (!_supportPlatform) return false;
    final bool? state = await _channel.invokeMethod<bool?>('scan', scan);
    return state ?? false;
  }
}
