import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sirah/app/pages/article/article_widget.dart';
import 'package:sirah/app/pages/timeline/timeline_entry.dart';
import 'package:sirah/app/pages/timeline/timeline_widget.dart';
import 'package:sirah/shared/analytics.dart';
import 'package:sirah/shared/locator.dart';

import 'routes.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    locator<AnalyticsService>().sendPageAnalytics(settings.name);
    final Map<String, dynamic>? args =
        settings.arguments as Map<String, dynamic>?;

    switch (settings.name) {
      case Routes.index:
        return MaterialPageRoute<dynamic>(
            builder: (_) => const TimelineWidget());
      case Routes.topic_details:
        locator<AnalyticsService>()
            .sendPageAnalytics((args?['article'] as TimelineEntry).label);
        // if (kDebugMode) {
        //   print((args?['article'] as TimelineEntry).label);
        // }
        return MaterialPageRoute<dynamic>(
            builder: (_) => ArticleWidget(
                  article: args?['article'],
                ));

      default:
        return _route404();
    }
  }

  static Route<dynamic> _route404() {
    return MaterialPageRoute<dynamic>(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('404'),
        ),
        body: const Center(
          child: Text('Page Not Found'),
        ),
      );
    });
  }
}