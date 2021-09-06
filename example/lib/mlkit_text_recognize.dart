import 'package:example/main.dart';
import 'package:fl_mlkit_text_recognize/fl_mlkit_text_recognize.dart';
import 'package:flutter/material.dart';
import 'package:flutter_waya/flutter_waya.dart';

class FlMlKitTextRecognizePage extends StatefulWidget {
  const FlMlKitTextRecognizePage(
      {Key? key, this.recognizedLanguage = RecognizedLanguage.latin})
      : super(key: key);
  final RecognizedLanguage recognizedLanguage;

  @override
  _FlMlKitTextRecognizePageState createState() =>
      _FlMlKitTextRecognizePageState();
}

class _FlMlKitTextRecognizePageState extends State<FlMlKitTextRecognizePage>
    with TickerProviderStateMixin {
  late AnimationController controller;
  AnalysisTextModel? model;
  double ratio = 1;
  double? maxRatio;
  StateSetter? zoomState;
  bool flashState = false;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return ExtendedScaffold(
        onWillPop: () async {
          return false;
        },
        body: Stack(children: <Widget>[
          FlMlKitTextRecognize(
              recognizedLanguage: widget.recognizedLanguage,
              overlay: const ScannerLine(),
              onFlashChange: (FlashState state) {
                showToast('$state');
              },
              onZoomChange: (CameraZoomState zommState) {
                showToast('zoom ratio:${zommState.zoomRatio}');
                if (maxRatio == null && zoomState != null) {
                  maxRatio = zommState.maxZoomRatio;
                  zoomState!(() {});
                }
              },
              resolution: CameraResolution.veryHigh,
              autoScanning: false,
              fit: BoxFit.fitWidth,
              uninitialized: Container(
                  color: Colors.black,
                  alignment: Alignment.center,
                  child: const Text('Camera not initialized',
                      style: TextStyle(color: Colors.white))),
              onListen: (AnalysisTextModel data) {
                if (data.text != null && data.text!.isNotEmpty) {
                  showToast(data.text ?? 'Unknown');
                  model = data;
                  controller.reset();
                }
              }),
          AnimatedBuilder(
              animation: controller,
              builder: (_, __) =>
                  model != null ? _RectBox(model!) : const SizedBox()),
          Align(
              alignment: Alignment.bottomCenter,
              child: StatefulBuilder(builder: (_, StateSetter state) {
                zoomState = state;
                return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Slider(
                          value: ratio,
                          min: 1,
                          max: maxRatio ?? 20,
                          onChanged: (double value) async {
                            ratio = value;
                            zoomState!(() {});
                            FlMlKitTextRecognizeMethodCall()
                                .setZoomRatio(value);
                          }),
                      IconBox(
                          size: 30,
                          color: flashState
                              ? Colors.white
                              : Colors.white.withOpacity(0.6),
                          padding: const EdgeInsets.fromLTRB(10, 10, 10, 40),
                          icon: flashState ? Icons.flash_on : Icons.flash_off,
                          onTap: () async {
                            final bool state =
                                await FlMlKitTextRecognizeMethodCall()
                                    .setFlashMode(!flashState);
                            flashState = !flashState;
                            if (state) zoomState!(() {});
                          })
                    ]);
              })),
          Positioned(
              right: 12,
              left: 12,
              top: getStatusBarHeight + 12,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const BackButton(color: Colors.white, onPressed: pop),
                    ValueBuilder<bool>(
                        initialValue: false,
                        builder: (_, bool? value, ValueCallback<bool> updater) {
                          value ??= false;
                          return ElevatedText(
                            text: value ? 'pause' : 'start',
                            onPressed: () async {
                              final bool data = value!
                                  ? await FlMlKitTextRecognizeMethodCall()
                                      .pause()
                                  : await FlMlKitTextRecognizeMethodCall()
                                      .start();
                              if (data) updater(!value);
                              if (value) {
                                model = null;
                                controller.reset();
                              }
                            },
                          );
                        }),
                  ])),
        ]));
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }
}

class _RectBox extends StatelessWidget {
  const _RectBox(this.model, {Key? key}) : super(key: key);
  final AnalysisTextModel model;

  @override
  Widget build(BuildContext context) {
    final List<TextBlock> blocks = model.textBlocks ?? <TextBlock>[];
    final List<Widget> children = <Widget>[];
    for (final TextBlock block in blocks) {
      children.add(boundingBox(block.boundingBox!));
      children.add(corners(block.corners!));
    }
    return Universal(expand: true, isStack: true, children: children);
  }

  Widget boundingBox(Rect rect) {
    final double w = model.width! / getDevicePixelRatio;
    final double h = model.height! / getDevicePixelRatio;
    return Universal(
        alignment: Alignment.center,
        child: CustomPaint(size: Size(w, h), painter: _LinePainter(rect)));
  }

  Widget corners(List<Offset> corners) {
    final double w = model.width! / getDevicePixelRatio;
    final double h = model.height! / getDevicePixelRatio;
    return Universal(
        alignment: Alignment.center,
        child: CustomPaint(size: Size(w, h), painter: _BoxPainter(corners)));
  }
}

class _LinePainter extends CustomPainter {
  _LinePainter(this.rect);

  final Rect rect;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final Path path = Path();
    final double left = (rect.left) / getDevicePixelRatio;
    final double top = (rect.top) / getDevicePixelRatio;

    final double width = rect.width / getDevicePixelRatio;
    final double height = rect.height / getDevicePixelRatio;

    path.moveTo(left, top);
    path.lineTo(left + width, top);
    path.lineTo(left + width, height + top);
    path.lineTo(left, height + top);
    path.lineTo(left, top);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _BoxPainter extends CustomPainter {
  _BoxPainter(this.corners);

  final List<Offset> corners;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset o0 = Offset(corners[0].dx / getDevicePixelRatio,
        corners[0].dy / getDevicePixelRatio);
    final Offset o1 = Offset(corners[1].dx / getDevicePixelRatio,
        corners[1].dy / getDevicePixelRatio);
    final Offset o2 = Offset(corners[2].dx / getDevicePixelRatio,
        corners[2].dy / getDevicePixelRatio);
    final Offset o3 = Offset(corners[3].dx / getDevicePixelRatio,
        corners[3].dy / getDevicePixelRatio);
    final Paint paint = Paint()
      ..color = Colors.blue.withOpacity(0.4)
      ..strokeWidth = 2;
    final Path path = Path();
    path.moveTo(o0.dx, o0.dy);
    path.lineTo(o1.dx, o1.dy);
    path.lineTo(o2.dx, o2.dy);
    path.lineTo(o3.dx, o3.dy);
    path.lineTo(o0.dx, o0.dy);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
