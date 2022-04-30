import 'package:dartz/dartz.dart' as d;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sirah/app/pages/timeline/model/timeline.dart';
import 'package:sirah/app/pages/timeline/repo/timeline_repo.dart';
import 'package:sirah/app/pages/timeline/widget/timeline_render_widget.dart';
import 'package:sirah/app/pages/timeline/util/timeline_utlis.dart';
import 'package:sirah/app/routes/routes.dart';
import 'package:sirah/shared/util/loader.dart';

typedef ShowMenuCallback = Function();

class TimelineWidget extends StatefulWidget {
  // final ShowMenuCallback showMenu;
  const TimelineWidget({
    Key? key,
    // required this.showMenu,
  }) : super(key: key);

  @override
  _TimelineWidgetState createState() => _TimelineWidgetState();
}

class _TimelineWidgetState extends State<TimelineWidget> {
  Timeline? _timeline;

  Offset? _lastFocalPoint;
  double _scaleStartYearStart = -100.0;
  double _scaleStartYearEnd = 100.0;

  TapTarget? _touchedBubble;

  @override
  void initState() {
    _getTimeline();
    super.initState();
  }

  Future<void> _getTimeline() async {
    TimelineApi _api = HttpTimelineApi();
    d.Either<String, Timeline> _result =
        await _api.getTopicList(forceRefresh: true);
    _result.fold((String error) {
      if (kDebugMode) {
        print('show error');
      }
    }, (Timeline timeline) {
      setState(() {
        _timeline = timeline;
        scaleProper();
      });
    });
  }

  Future<void> scaleProper() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _timeline?.setViewport(start: 564, end: 590, animate: true);
  }

  void _scaleStart(ScaleStartDetails details) {
    _lastFocalPoint = details.focalPoint;
    _scaleStartYearStart = _timeline!.start;
    _scaleStartYearEnd = _timeline!.end;
    _timeline!.isInteracting = true;
    _timeline!.setViewport(velocity: 0.0, animate: true);
  }

  void _tapUp(TapUpDetails details) {
    if (_touchedBubble != null) {
      Navigator.of(context)
          .pushNamed(Routes.topic_details, arguments: <String, dynamic>{
        'article': _touchedBubble!.entry!,
      });
    }
  }

  onTouchBubble(TapTarget? bubble) {
    _touchedBubble = bubble;
  }

  void _scaleUpdate(ScaleUpdateDetails details) {
    double changeScale = details.scale;
    double scale =
        (_scaleStartYearEnd - _scaleStartYearStart) / context.size!.height;

    double focus = _scaleStartYearStart + details.focalPoint.dy * scale;
    double focalDiff =
        (_scaleStartYearStart + _lastFocalPoint!.dy * scale) - focus;

    _timeline!.setViewport(
        start: focus + (_scaleStartYearStart - focus) / changeScale + focalDiff,
        end: focus + (_scaleStartYearEnd - focus) / changeScale + focalDiff,
        height: context.size!.height,
        animate: true);
  }

  void _scaleEnd(ScaleEndDetails details) {
    double scale = (_timeline!.end - _timeline!.start) / context.size!.height;
    _timeline!.isInteracting = false;
    _timeline!.setViewport(
        velocity: details.velocity.pixelsPerSecond.dy * scale, animate: true);
  }

  @override
  Widget build(BuildContext context) {
    if (_timeline == null) {
      return Loader.circular();
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _timeline?.setViewport(start: 564, end: 590, animate: true);
          });
        },
        child: const Icon(
          Icons.restore,
          size: 32,
          color: Colors.white,
        ),
        backgroundColor: const Color.fromARGB(255, 125, 195, 184),
      ),
      body: GestureDetector(
        onScaleStart: _scaleStart,
        onScaleUpdate: _scaleUpdate,
        onScaleEnd: _scaleEnd,
        onTapUp: _tapUp,
        child: Stack(
          children: <Widget>[
            TimelineRenderWidget(
              timeline: _timeline!,
              touchBubble: onTouchBubble,
            ),
            Container(
              color: const Color.fromRGBO(238, 240, 242, 0.81),
              height: 56.0,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}
