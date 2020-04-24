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

  const AwesomeLoader({
    this.outerColor = const Color.fromARGB(255, 66, 62, 60),
    this.innerColor = const Color.fromARGB(255, 66, 62, 60),
    this.strokeWidth = 15,
    this.duration = 4000
  });
  final Color outerColor;
  final Color innerColor;
  final double strokeWidth;
  final int duration;

  @override
  _AwesomeLoaderState createState() => _AwesomeLoaderState();
}

class _AwesomeLoaderState extends State<AwesomeLoader> with TickerProviderStateMixin {
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

  @override
  void initState() {
    super.initState();

  // TODO(khaled): clarify this equation and exctract a constant
  // controls the smoothness of the arc animation
   final double arcIncrement = 2 *
      2 *
      (100 - minimumArcSize + (100 * 0.1)) *
      (1 - staticStatePercent) *
      (TIME_PORTION / widget.duration);

    endRectSize = 0;

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
    outerController.repeat();
    innerController.repeat();
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
    final Paint outerPaint =  Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final Rect outerRect =  Rect.fromLTWH(0.0, 0.0, size.width, size.height);
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
    final Paint innerPaint =  Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final Rect innerRect =  Rect.fromLTWH(
        0.0 + (0.35 * size.width) / 2,
        0.0 + (0.35 * size.height) / 2,
        size.width - 0.35 * size.width,
        size.height - 0.35 * size.height);

    canvas.drawArc(innerRect, - startRectSize * pi, - endRectSize  * pi, false,
        innerPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
