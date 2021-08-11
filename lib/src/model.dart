part of '../fl_mlkit_text_recognize.dart';

List<TextBlock>? toTextBlocks(List<dynamic>? data) => data != null
    ? List<TextBlock>.unmodifiable(data.map<dynamic>((dynamic e) {
        final double x = e['x'] as double? ?? 0;
        final double y = e['y'] as double? ?? 0;

        return Offset(x, y);
      }))
    : null;

class TextModel {
  TextModel.fromMap(Map<dynamic, dynamic> data)
      : text = data['text'] as String?,
        textBlocks = toTextBlocks(data['textBlocks'] as List<dynamic>?);

  final String? text;
  final List<TextBlock>? textBlocks;
}

class TextBlock {
  TextBlock.fromMap(Map<dynamic, dynamic> data)
      : text = data['text'] as String?,
        recognizedLanguage = data['recognizedLanguage'] as String?,
        boundingBox = toRect(data['boundingBox'] as Map<dynamic, dynamic>?),
        corners = toCorners(data['corners'] as List<dynamic>?);

  final String? text;
  final String? recognizedLanguage;
  final Rect? boundingBox;
  final List<Offset>? corners;
}

class TextCotent {
  String? text;
  String? recognizedLanguage;
  Rect? boundingBox;
  List<Offset>? corners;

  TextCotent.fromMap(Map<dynamic, dynamic> data)
      : text = data['text'] as String?,
        recognizedLanguage = data['recognizedLanguage'] as String?,
        boundingBox = toRect(data['boundingBox'] as Map<dynamic, dynamic>?),
        corners = toCorners(data['corners'] as List<dynamic>?);
}

List<Offset>? toCorners(List<dynamic>? data) => data != null
    ? List<Offset>.unmodifiable(data.map<dynamic>((dynamic e) {
        final double x = e['x'] as double? ?? 0;
        final double y = e['y'] as double? ?? 0;
        return Offset(x, y);
      }))
    : null;

Rect? toRect(Map<dynamic, dynamic>? data) {
  if (data == null) {
    return null;
  } else {
    if (_isAndroid) {
      final int left = (data['left'] as int?) ?? 0;
      final int top = (data['top'] as int?) ?? 0;
      final int right = (data['right'] as int?) ?? 0;
      final int bottom = (data['bottom'] as int?) ?? 0;
      return Rect.fromLTRB(
          left.toDouble(), top.toDouble(), right.toDouble(), bottom.toDouble());
    } else if (_isIOS) {
      final int x = (data['x'] as int?) ?? 0;
      final int y = (data['y'] as int?) ?? 0;
      final int width = (data['width'] as int?) ?? 0;
      final int height = (data['height'] as int?) ?? 0;
      return Rect.fromLTWH(
          x.toDouble(), y.toDouble(), width.toDouble(), height.toDouble());
    }
  }
}
