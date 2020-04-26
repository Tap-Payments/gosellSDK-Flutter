import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math';

/// TODOs:
/// - expose these parameters:
///   - Animation Smoothness
///   - minimum arc size
///   -
/// - Extra work:
///   - develop a callback when the loader gets to full state
///   - develop a controller to assign number of rotates or a duration before a full stop
///   - develop the ability to stop on full state
///
class AwesomeLoader extends StatefulWidget {
  const AwesomeLoader(
      {this.outerColor = const Color.fromARGB(255, 66, 62, 60),
      this.innerColor = const Color.fromARGB(255, 66, 62, 60),
      this.strokeWidth = 15,
      this.duration = 4000,
      this.controller});
  final Color outerColor;
  final Color innerColor;
  final double strokeWidth;
  final int duration;
  final AwesomeLoaderController controller;

  @override
  _AwesomeLoaderState createState() => _AwesomeLoaderState();
}

class _AwesomeLoaderState extends State<AwesomeLoader>
    with TickerProviderStateMixin {
  Animation<double> outerAnimation;
  Animation<double> innerAnimation;
  AnimationController outerController;
  AnimationController innerController;

// controls the minimum size of the arc
  static const int minimumArcSize = 5;

  // final int durationPortion = 40;

  Timer timer;
  static const int TIME_PORTION = 10; // 40 milliseconds for each increment

  /// ranges are from 0-100
  /// it is returning back in the build method to 0-2 (to be multiplied by pi)
  double startRectSize = 0;
  double endRectSize = 0;
  double staticSizeCounter = 0;
  static const double staticStatePercent = 0.1;

  // static double SMOOTHNESS = 0.5; // 40 milliseconds for each increment

  // controls the smoothness of the arc animation
  // double arcIncrement;

  final double staticStateInvisibleSize = staticStatePercent * 100;
  bool reverseFlag = false;

  /// the state of the minimum or maximum arc size
  bool staticState = false;

  int i = 1;

  // controls the smoothness of the arc animation
  double arcIncrement;

  /// this swithc is controlled by start() and stop() functions
  /// it is used to wait till loader finishes full circle then stop
  bool isLoaderAskedToStop = false;
  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      widget.controller._awesomeLoaderState = this;
    }

    // TODO(khaled): clarify this equation and exctract a constant
    // controls the smoothness of the arc animation
    arcIncrement = 2 *
        2 *
        (100 - minimumArcSize + (100 * 0.1)) *
        (1 - staticStatePercent) *
        (TIME_PORTION / widget.duration);

    /// determines the size of the rect in initially [0-100]
    endRectSize = 100;

    outerController = AnimationController(
        duration: Duration(milliseconds: widget.duration), vsync: this);

    innerController = AnimationController(
        duration: Duration(milliseconds: widget.duration), vsync: this);

    /// rotates three times per duration
    outerAnimation = Tween<double>(begin: 0, end: 3).animate(CurvedAnimation(
        parent: outerController,
        curve: const Interval(0.0, 1.0, curve: Curves.linear)));

    /// rotates three rotations per duration
    innerAnimation = Tween<double>(begin: 3.0, end: 0.0).animate(
        CurvedAnimation(
            parent: innerController,
            curve: const Interval(0.0, 1.0, curve: Curves.linear)));

    /// if there is no controller, start the loader immediatly
    if (widget.controller == null) {
      start();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          RotationTransition(
            turns: outerAnimation,
            child: CustomPaint(
              //  /50 to return a range from  to 0-2
              painter: OuterArcPainter(widget.outerColor, startRectSize / 50.0,
                  endRectSize / 50.0, widget.strokeWidth),
              child: Container(
                width: 200.0,
                height: 200.0,
              ),
            ),
          ),
          RotationTransition(
            turns: innerAnimation,
            child: CustomPaint(
              painter: InnerArcPainter(widget.innerColor, startRectSize / 50.0,
                  endRectSize / 50.0, widget.strokeWidth),
              child: Container(
                width: 200.0,
                height: 200.0,
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    outerController.dispose();
    innerController.dispose();
    super.dispose();
  }

  void start() {
    isLoaderAskedToStop = false;
    if (!outerController.isAnimating) outerController.repeat();
    if (!innerController.isAnimating) innerController.repeat();
    _startRotation();
  }

  void stopWhenFull() {
    /// turn the switch on, then the animation loop will stop the timer when the loader is in a full circle shape
    isLoaderAskedToStop = true;
  }

  void stopNow() {
    outerController.stop();
    innerController.stop();
    _stopRotation();
  }

  _startRotation() {
    if (timer != null && timer.isActive) timer.cancel();
    timer = Timer.periodic(Duration(milliseconds: TIME_PORTION), (Timer t) {
      if (this.mounted)
        setState(() {
          if (!reverseFlag) {
            if (!staticState) {
              /// modify size only if the staticState is FALSE
              endRectSize = endRectSize + arcIncrement;
            } else {
              staticSizeCounter += arcIncrement;
              if (staticSizeCounter > staticStateInvisibleSize) {
                staticSizeCounter = 0;
                staticState = false;
              }
            }
            if (endRectSize > 100) {
              staticState = true;
              reverseFlag = true;
              startRectSize = 0;
              //// check if loader is asked to stop, stop the timer
              if (isLoaderAskedToStop) {
                stopNow();
              }
            }
          } else {
            if (!staticState) {
              /// modify size only if the staticState is FALSE
              startRectSize = startRectSize + arcIncrement;
              endRectSize = endRectSize - arcIncrement;
            } else {
              staticSizeCounter += arcIncrement;
              if (staticSizeCounter > staticStateInvisibleSize) {
                staticSizeCounter = 0;
                staticState = false;
              }
            }

            if (startRectSize > 100 - minimumArcSize) {
              staticState = true;
              reverseFlag = false;
            }
          }
        });
    });
  }

  _stopRotation() {
    timer.cancel();
  }
}

class OuterArcPainter extends CustomPainter {
  OuterArcPainter(
      this.color, this.startRectSize, this.endRectSize, this.strokeWidth);

  final Color color;
  final double endRectSize;
  final double startRectSize;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint outerPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final Rect outerRect = Rect.fromLTWH(0.0, 0.0, size.width, size.height);
    canvas.drawArc(
        outerRect, startRectSize * pi, endRectSize * pi, false, outerPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class InnerArcPainter extends CustomPainter {
  InnerArcPainter(
    this.color,
    this.startRectSize,
    this.endRectSize,
    this.strokeWidth,
  );
  final Color color;
  final double endRectSize;
  final double startRectSize;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint innerPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final Rect innerRect = Rect.fromLTWH(
        0.0 + (0.35 * size.width) / 2,
        0.0 + (0.35 * size.height) / 2,
        size.width - 0.35 * size.width,
        size.height - 0.35 * size.height);

    canvas.drawArc(
        innerRect, -startRectSize * pi, -endRectSize * pi, false, innerPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class AwesomeLoaderController {
  AwesomeLoaderController();

  _AwesomeLoaderState _awesomeLoaderState;
  void stopWhenFull() {
    _awesomeLoaderState.stopWhenFull();
  }

  void start() {
    _awesomeLoaderState.start();
  }

  void stopNow() {
    _awesomeLoaderState.stopNow();
  }
}
