import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:sirah/shared/util/functions.dart';

// import 'package:poster_maker/app/pages/edit_page/bloc/edit_page_bloc.dart';
// import 'package:poster_maker/app/pages/edit_page/util/functions.dart';

class ImageService {
  ImageService({required this.d});

  final Map<String, ui.Image> _images = <String, ui.Image>{};
  final ui.Image d;
  // EditPageBloc? _editPageBloc;

  ui.Image getImage(String url) {
    if (_images[url] != null) {
      return _images[url]!;
    } else {
      _loadImage(url);
      return d;
    }
  }

  Future<void> _loadImage(String url) async {
    ui.Image? image = await loadFromUrl(url);
    if (image == null) {
      if (kDebugMode) {
        print('image loading error error');
      }
    } else {
      _images[url] = image;
      // do some set state
    }
  }
}
