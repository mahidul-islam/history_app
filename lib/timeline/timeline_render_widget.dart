import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:sirah/timeline/ticks.dart';
import "dart:ui" as ui;

import 'package:sirah/timeline/timeline.dart';

class TimelineRenderWidget extends LeafRenderObjectWidget {
  final Timeline timeline;
  const TimelineRenderWidget({Key? key, required this.timeline})
      : super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return TimelineRenderObject()..timeline = timeline;
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant TimelineRenderObject renderObject) {
    renderObject.timeline = timeline;
  }
}

class TimelineRenderObject extends RenderBox {
  static const List<Color> lineColors = [
    Color.fromARGB(255, 125, 195, 184),
    Color.fromARGB(255, 190, 224, 146),
    Color.fromARGB(255, 238, 155, 75),
    Color.fromARGB(255, 202, 79, 63),
    Color.fromARGB(255, 128, 28, 15)
  ];

  final Ticks _ticks = Ticks();
  Timeline _timeline = Timeline();

  Timeline get timeline => _timeline;
  set timeline(Timeline value) {
    if (_timeline == value) {
      return;
    }
    _timeline = value;
    _timeline.onNeedPaint = () {
      markNeedsPaint();
    };
    markNeedsLayout();
  }

  @override
  bool get sizedByParent => true;

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void performResize() {
    size = constraints.biggest;
  }

  @override
  void performLayout() {
    if (_timeline != null) {
      _timeline.setViewport(height: size.height, animate: true);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Canvas canvas = context.canvas;
    if (_timeline == null) {
      return;
    }

    double renderStart = _timeline.renderStart;
    double renderEnd = _timeline.renderEnd;
    double scale = size.height / (renderEnd - renderStart);

    //canvas.drawRect(new Offset(0.0, 0.0) & new Size(100.0, 100.0), new Paint()..color = Colors.red);
    _ticks.paint(context, offset, -renderStart * scale, scale, size.height);

    if (timeline.renderAssets != null) {
      canvas.save();
      for (TimelineEntryAsset asset in timeline.renderAssets) {
        if (asset.opacity > 0) {
          //ctx.globalAlpha = asset.opacity;
          double rs = 0.2 + asset.scale * 0.8;

          double w = asset.width! * Timeline.assetScreenScale;
          double h = asset.height! * Timeline.assetScreenScale;
          canvas.drawImageRect(
              asset.image,
              Rect.fromLTWH(0.0, 0.0, asset.width!, asset.height!),
              Rect.fromLTWH(
                  offset.dx + size.width - w, asset.y, w * rs, h * rs),
              Paint()
                ..isAntiAlias = true
                ..filterQuality = ui.FilterQuality.low
                ..color = Colors.white.withOpacity(asset.opacity));
        }
      }
      canvas.restore();
    }
    if (_timeline.entries != null) {
      canvas.save();
      canvas.clipRect(Rect.fromLTWH(offset.dx + Timeline.gutterLeft, offset.dy,
          size.width - Timeline.gutterLeft, size.height));
      drawItems(
          context,
          offset,
          _timeline.entries,
          Timeline.marginLeft -
              Timeline.depthOffset * _timeline.renderOffsetDepth,
          scale,
          0);
      canvas.restore();
    }
  }

  void drawItems(PaintingContext context, Offset offset,
      List<TimelineEntry> entries, double x, double scale, int depth) {
    final Canvas canvas = context.canvas;

    for (TimelineEntry item in entries) {
      if (!item.isVisible ||
          item.y > size.height + Timeline.bubbleHeight ||
          item.endY < -Timeline.bubbleHeight) {
        continue;
      }

      double legOpacity = item.legOpacity * item.opacity;
      canvas.drawCircle(
          Offset(x + Timeline.lineWidth / 2.0, item.y),
          Timeline.edgeRadius,
          Paint()
            ..color = lineColors[depth % lineColors.length]
                .withOpacity(item.opacity));
      if (legOpacity > 0.0) {
        Paint legPaint = Paint()
          ..color =
              lineColors[depth % lineColors.length].withOpacity(legOpacity);
        canvas.drawRect(
            Offset(x, item.y) & Size(Timeline.lineWidth, item.length),
            legPaint);
        canvas.drawCircle(
            Offset(x + Timeline.lineWidth / 2.0, item.y + item.length),
            Timeline.edgeRadius,
            legPaint);
      }

      const double maxLabelWidth = 1200.0;
      const double bubbleHeight = 50.0;
      const double bubblePadding = 20.0;

      ui.ParagraphBuilder builder = ui.ParagraphBuilder(ui.ParagraphStyle(
          textAlign: TextAlign.start, fontFamily: "Arial", fontSize: 18.0))
        ..pushStyle(
            ui.TextStyle(color: const Color.fromRGBO(255, 255, 255, 1.0)));

      builder.addText(item.label!);
      ui.Paragraph labelParagraph = builder.build();
      labelParagraph
          .layout(const ui.ParagraphConstraints(width: maxLabelWidth));
      //canvas.drawParagraph(labelParagraph, new Offset(offset.dx + Gutter - labelParagraph.minIntrinsicWidth-2, offset.dy + height - o - labelParagraph.height - 5));

      double textWidth =
          labelParagraph.maxIntrinsicWidth * item.opacity * item.labelOpacity;
      // ctx.globalAlpha = labelOpacity*itemOpacity;
      // ctx.save();
      // let bubbleX = labelX-DepthOffset*renderOffsetDepth;
      double bubbleX = _timeline.renderLabelX -
          Timeline.depthOffset * _timeline.renderOffsetDepth;
      double bubbleY = item.labelY - bubbleHeight / 2.0;
      canvas.save();
      canvas.translate(bubbleX, bubbleY);
      Path bubble =
          makeBubblePath(textWidth + bubblePadding * 2.0, bubbleHeight);
      canvas.drawPath(
          bubble,
          Paint()
            ..color = lineColors[depth % lineColors.length]
                .withOpacity(item.opacity * item.labelOpacity * 0.95));
      canvas
          .clipRect(Rect.fromLTWH(bubblePadding, 0.0, textWidth, bubbleHeight));

      canvas.drawParagraph(
          labelParagraph,
          Offset(
              bubblePadding, bubbleHeight / 2.0 - labelParagraph.height / 2.0));
      canvas.restore();
      // if(item.asset != null)
      // {
      // 	canvas.drawImageRect(item.asset.image, Rect.fromLTWH(0.0, 0.0, item.asset.width, item.asset.height), Rect.fromLTWH(bubbleX + textWidth + BubblePadding*2.0, bubbleY, item.asset.width, item.asset.height), new Paint()..isAntiAlias=true..filterQuality=ui.FilterQuality.low);
      // }
      if (item.children != null) {
        drawItems(context, offset, item.children!, x + Timeline.depthOffset,
            scale, depth + 1);
      }
    }
  }

  Path makeBubblePath(double width, double height) {
    const double arrowSize = 19.0;
    const double cornerRadius = 10.0;

    const double circularConstant = 0.55;
    const double icircularConstant = 1.0 - circularConstant;

    Path path = Path();

    path.moveTo(cornerRadius, 0.0);
    path.lineTo(width - cornerRadius, 0.0);
    path.cubicTo(width - cornerRadius + cornerRadius * circularConstant, 0.0,
        width, cornerRadius * icircularConstant, width, cornerRadius);
    path.lineTo(width, height - cornerRadius);
    path.cubicTo(
        width,
        height - cornerRadius + cornerRadius * circularConstant,
        width - cornerRadius * icircularConstant,
        height,
        width - cornerRadius,
        height);
    path.lineTo(cornerRadius, height);
    path.cubicTo(cornerRadius * icircularConstant, height, 0.0,
        height - cornerRadius * icircularConstant, 0.0, height - cornerRadius);

    path.lineTo(0.0, height / 2.0 + arrowSize / 2.0);
    path.lineTo(-arrowSize / 2.0, height / 2.0);
    path.lineTo(0.0, height / 2.0 - arrowSize / 2.0);

    path.lineTo(0.0, cornerRadius);

    path.cubicTo(0.0, cornerRadius * icircularConstant,
        cornerRadius * icircularConstant, 0.0, cornerRadius, 0.0);

    path.close();

    return path;
  }
}
