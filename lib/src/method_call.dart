part of '../fl_mlkit_text_recognize.dart';

enum RecognizedLanguage {
  /// Including English
  /// A language of 26 letters
  latin,

  /// 中文
  chinese,

  /// 日语
  japanese,

  /// Include all above
  // all,
}

class FlMlKitTextRecognizeMethodCall {
  factory FlMlKitTextRecognizeMethodCall() =>
      _singleton ??= FlMlKitTextRecognizeMethodCall._();

  FlMlKitTextRecognizeMethodCall._();

  static FlMlKitTextRecognizeMethodCall? _singleton;

  RecognizedLanguage _recognizedLanguage = RecognizedLanguage.latin;

  final MethodChannel _channel = _flMlKitTextRecognizeChannel;

  MethodChannel get channel => _channel;

  /// 设置设别的语言
  /// Set recognized language
  Future<bool> setRecognizedLanguage(
      RecognizedLanguage recognizedLanguage) async {
    if (!_supportPlatform) return false;
    _recognizedLanguage = recognizedLanguage;
    final bool? state = await _channel.invokeMethod<bool?>(
        'setRecognizedLanguage', _recognizedLanguage.toString().split('.')[1]);
    return state ?? false;
  }

  /// 识别图片字节
  /// Identify picture bytes
  /// [useEvent] 返回消息使用 FLCameraEvent
  /// The return message uses flcameraevent
  /// [rotationDegrees] Only Android is supported
  Future<AnalysisTextModel?> scanImageByte(Uint8List uint8list,
      {int rotationDegrees = 0, bool useEvent = false}) async {
    if (!_supportPlatform) return null;
    if (useEvent) {
      assert(FlCameraEvent().isPaused, 'Please initialize FlCameraEvent');
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
      FlCameraMethodCall().setFlashMode(status);

  /// 相机缩放
  /// Camera zoom
  Future<bool> setZoomRatio(double ratio) =>
      FlCameraMethodCall().setZoomRatio(ratio);

  /// 获取可用摄像头
  /// get available Cameras
  Future<List<CameraInfo>?> availableCameras() =>
      FlCameraMethodCall().availableCameras();

  /// 暂停扫描
  /// Pause scanning
  Future<bool> pause() => _scanncing(false);

  /// 开始扫描
  /// Start scanncing
  Future<bool> start() => _scanncing(true);

  /// 获取识别状态
  /// get scan state
  Future<bool?> getScanState() async {
    if (!_supportPlatform) return null;
    return await _channel.invokeMethod<bool?>('getScanState');
  }

  Future<bool> _scanncing(bool scan) async {
    if (!_supportPlatform) return false;
    final bool? state = await _channel.invokeMethod<bool?>('scan', scan);
    return state ?? false;
  }
}
