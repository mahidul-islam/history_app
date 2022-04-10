import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';
import 'package:sirah/shared/analytics.dart';
import 'package:sirah/shared/image_service.dart';
import 'package:sirah/shared/util/functions.dart';

import 'navigation_services.dart';

GetIt locator = GetIt.instance;

Future<void> setupLocator() async {
  final d = await imageFromAsset('loading.png');
  await Firebase.initializeApp();
  locator.registerLazySingleton(() => NavigationService());
  locator.registerLazySingleton(() => AnalyticsService());
  locator.registerLazySingleton(() => ImageService(d: d));
}
