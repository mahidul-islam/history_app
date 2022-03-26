import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:sirah/timeline/timeline.dart';
import 'package:sirah/timeline/timeline_render_widget.dart';

typedef ShowMenuCallback = Function();

class TimelineWidget extends StatefulWidget {
  final ShowMenuCallback showMenu;
  const TimelineWidget({Key? key, required this.showMenu}) : super(key: key);

  @override
  _TimelineWidgetState createState() => _TimelineWidgetState();
}

class _TimelineWidgetState extends State<TimelineWidget> {
  final Timeline _timeline = Timeline();

  Offset? _lastFocalPoint;
  double _scaleStartYearStart = -100.0;
  double _scaleStartYearEnd = 100.0;

  void _scaleStart(ScaleStartDetails details) {
    _lastFocalPoint = details.focalPoint;
    _scaleStartYearStart = _timeline.start;
    _scaleStartYearEnd = _timeline.end;
    _timeline.isInteracting = true;
    _timeline.setViewport(velocity: 0.0, animate: true);
  }

  void _scaleUpdate(ScaleUpdateDetails details) {
    double changeScale = details.scale;
    double scale =
        (_scaleStartYearEnd - _scaleStartYearStart) / context.size!.height;

    double focus = _scaleStartYearStart + details.focalPoint.dy * scale;
    double focalDiff =
        (_scaleStartYearStart + _lastFocalPoint!.dy * scale) - focus;

    _timeline.setViewport(
        start: focus + (_scaleStartYearStart - focus) / changeScale + focalDiff,
        end: focus + (_scaleStartYearEnd - focus) / changeScale + focalDiff,
        height: context.size!.height,
        animate: true);
  }

  void _scaleEnd(ScaleEndDetails details) {
    double scale = (_timeline.end - _timeline.start) / context.size!.height;
    _timeline.isInteracting = false;
    _timeline.setViewport(
        velocity: details.velocity.pixelsPerSecond.dy * scale, animate: true);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onScaleStart: _scaleStart,
        onScaleUpdate: _scaleUpdate,
        onScaleEnd: _scaleEnd,
        //onTapUp: _tapUp,
        child: Stack(children: <Widget>[
          TimelineRenderWidget(timeline: _timeline),
          Container(
              color: const Color.fromRGBO(238, 240, 242, 0.81),
              height: 56.0,
              width: double.infinity,
              child: IconButton(
                alignment: Alignment.centerLeft,
                icon: const Icon(Icons.arrow_back_ios_new_sharp),
                onPressed: () {
                  widget.showMenu();
                },
              ))
        ]));
  }
}
