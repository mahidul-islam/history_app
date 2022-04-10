import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'package:sirah/shared/dio/global_dio.dart' as global;

Future<ui.Image> convertFileToImage(File picture) async {
  List<int> imageBase64 = picture.readAsBytesSync();
  String imageAsString = base64Encode(imageBase64);
  Uint8List uint8list = base64.decode(imageAsString);
  ui.Image image = await bytesToImage(uint8list);
  return image;
}

Future<ui.Image> bytesToImage(Uint8List imgBytes) async {
  ui.Codec codec = await ui.instantiateImageCodec(imgBytes);
  ui.FrameInfo frame = await codec.getNextFrame();
  return frame.image;
}

Future<ui.Image> base64ToImage(String base64) async {
  ui.Codec codec = await ui.instantiateImageCodec(base64Decode(base64));
  ui.FrameInfo frame = await codec.getNextFrame();
  return frame.image;
}

Future<ui.Image> imageFromAsset(String source) async {
  ByteData data = await rootBundle.load("assets/" + source);
  Uint8List list = Uint8List.view(data.buffer);
  ui.Codec codec = await ui.instantiateImageCodec(list);
  ui.FrameInfo frame = await codec.getNextFrame();
  return frame.image;
}

Future<String> imageToBase64(ui.Image img) async {
  ByteData? bytes = await img.toByteData();
  if (bytes != null) {
    return base64Encode(bytes.buffer.asUint8List());
  }
  return '';
}

Future<ui.Image?> loadFromUrl(String url) async {
  String _name = url.split('/').last;
  final dir = await getApplicationDocumentsDirectory();
  if (await File(dir.path + _name).exists()) {
    return await convertFileToImage(File(dir.path + _name));
  }
  final response = await global.dio.download(url, dir.path + _name);
  if (response.statusCode! >= 200 && response.statusCode! < 300) {
    return await convertFileToImage(File(dir.path + _name));
  } else {
    return null;
  }
}
