import 'dart:io';
import 'package:flutter/material.dart';

/// Renders an image from either a network URL or a local file path,
/// picking the right widget automatically. AI-generated images and
/// user-picked gallery/camera images both flow through the same
/// [String] `url` field on our models, so callers previously always used
/// [Image.network] even when the string was a local file path (which
/// silently fails to load).
class SmartImage extends StatelessWidget {
  final String url;
  final Key? imageKey;
  final BoxFit? fit;
  final double? width;
  final double? height;
  final Widget Function(BuildContext, Widget, ImageChunkEvent?)? loadingBuilder;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;

  const SmartImage(
    this.url, {
    super.key,
    this.imageKey,
    this.fit,
    this.width,
    this.height,
    this.loadingBuilder,
    this.errorBuilder,
  });

  static bool isNetworkUrl(String url) =>
      url.startsWith('http://') || url.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    if (isNetworkUrl(url)) {
      return Image.network(
        url,
        key: imageKey,
        fit: fit,
        width: width,
        height: height,
        loadingBuilder: loadingBuilder,
        errorBuilder: errorBuilder,
      );
    }
    return Image.file(
      File(url),
      key: imageKey,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: errorBuilder,
    );
  }
}
