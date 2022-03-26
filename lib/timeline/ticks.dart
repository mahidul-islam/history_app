import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';

class Ticks {
  static const double margin = 20.0;
  static const double width = 40.0;
  static const double gutter = 45.0;
  static const int gTickDistance = 16;
  static const int gTextTickDistance = 64;
  static const double gTickSize = 15.0;
  static const double gSmallTickSize = 5.0;

  void paint(PaintingContext context, Offset offset, double translation,
      double scale, double height) {
    final Canvas canvas = context.canvas;

    double bottom = height;
    double tickDistance = gTickDistance.toDouble();
    double textTickDistance = gTextTickDistance.toDouble();

    double scaledTickDistance = tickDistance * scale;
    while (scaledTickDistance < gTickDistance) {
      scaledTickDistance *= 2;
      tickDistance *= 2;
      textTickDistance *= 2;
    }
    int numTicks = (height / scaledTickDistance).ceil() + 2;

    // Figure out the position of the top left corner of the screen
    double tickOffset = 0.0;
    double startingTickMarkValue = 0.0;

    double y = ((translation - bottom) / scale);
    startingTickMarkValue = y - (y % tickDistance);
    tickOffset = -(y % tickDistance) * scale - scaledTickDistance;

    // Move back by one tick.
    tickOffset -= scaledTickDistance;
    startingTickMarkValue -= tickDistance;

    canvas.save();

    final Paint tickPaint = Paint()..color = const Color.fromRGBO(0, 0, 0, 0.3);
    final Paint smallTickPaint = Paint()
      ..color = const Color.fromRGBO(0, 0, 0, 0.1);
    canvas.drawRect(
        Rect.fromLTWH(offset.dx, offset.dy, gutter, height), smallTickPaint);

    for (int i = 0; i < numTicks; i++) {
      tickOffset += scaledTickDistance;

      int tt = startingTickMarkValue.round();
      tt = -tt;
      int o = tickOffset.floor();
      if (tt % textTickDistance == 0) {
        canvas.drawRect(
            Rect.fromLTWH(offset.dx + gutter - gTickSize,
                offset.dy + height - o, gTickSize, 1.0),
            tickPaint);
        ui.ParagraphBuilder builder = ui.ParagraphBuilder(
          ui.ParagraphStyle(
            textAlign: TextAlign.start,
            fontFamily: "Arial",
            fontSize: 10.0,
          ),
        )..pushStyle(
            ui.TextStyle(
              color: const Color.fromRGBO(0, 0, 0, 0.6),
            ),
          );

        String label;
        int tta = tt.abs();
        if (tta > 1000000000) {
          label = (tt / 1000000000).toStringAsFixed(3) + "B";
        } else if (tta > 1000000) {
          label = (tt / 1000000).toStringAsFixed(3) + "M";
        } else if (tta > 10000) // N.B. < 10,000
        {
          label = (tt / 1000).toStringAsFixed(3) + "k";
        } else {
          label = tt.toStringAsFixed(0);
        }
        builder.addText(label);
        ui.Paragraph tickParagraph = builder.build();
        tickParagraph.layout(const ui.ParagraphConstraints(width: gutter));
        canvas.drawParagraph(
          tickParagraph,
          Offset(
            offset.dx + gutter - tickParagraph.minIntrinsicWidth - 2,
            offset.dy + height - o - tickParagraph.height - 5,
          ),
        );
      } else {
        canvas.drawRect(
            Rect.fromLTWH(offset.dx + gutter - gSmallTickSize,
                offset.dy + height - o, gSmallTickSize, 1.0),
            smallTickPaint);
      }
      startingTickMarkValue += tickDistance;
    }
  }
}
