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

  /// 打开\关闭 闪光灯
  /// Turn flash on / off
  Future<bool> setFlashMode(bool status) =>
      FlCameraMethodCall.instance.setFlashMode(status);

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
