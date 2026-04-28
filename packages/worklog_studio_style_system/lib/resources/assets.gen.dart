// dart format width=120

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

import 'package:flutter/widgets.dart';

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// Directory path: assets/images/m-size
  $AssetsImagesMSizeGen get mSize => const $AssetsImagesMSizeGen();

  /// Directory path: assets/images/preview
  $AssetsImagesPreviewGen get preview => const $AssetsImagesPreviewGen();

  /// Directory path: assets/images/s-size
  $AssetsImagesSSizeGen get sSize => const $AssetsImagesSSizeGen();
}

class $AssetsVectorsGen {
  const $AssetsVectorsGen();

  /// File path: assets/vectors/arrow-small-right-24.svg.vec
  String get arrowSmallRight24Svg => 'packages/worklog_studio_style_system/assets/vectors/arrow-small-right-24.svg.vec';

  /// File path: assets/vectors/arrow-small-right-64.svg.vec
  String get arrowSmallRight64Svg => 'packages/worklog_studio_style_system/assets/vectors/arrow-small-right-64.svg.vec';

  /// File path: assets/vectors/flashlight-24.vec
  String get flashlight24 => 'packages/worklog_studio_style_system/assets/vectors/flashlight-24.vec';

  /// File path: assets/vectors/flashlight-off-24.vec
  String get flashlightOff24 => 'packages/worklog_studio_style_system/assets/vectors/flashlight-off-24.vec';

  /// File path: assets/vectors/history-24.svg.vec
  String get history24Svg => 'packages/worklog_studio_style_system/assets/vectors/history-24.svg.vec';

  /// File path: assets/vectors/play-filled-24.svg.vec
  String get playFilled24Svg => 'packages/worklog_studio_style_system/assets/vectors/play-filled-24.svg.vec';

  /// File path: assets/vectors/play-filled-64.svg.vec
  String get playFilled64Svg => 'packages/worklog_studio_style_system/assets/vectors/play-filled-64.svg.vec';

  /// File path: assets/vectors/player-pause-24.svg.vec
  String get playerPause24Svg => 'packages/worklog_studio_style_system/assets/vectors/player-pause-24.svg.vec';

  /// File path: assets/vectors/player-play-24.svg.vec
  String get playerPlay24Svg => 'packages/worklog_studio_style_system/assets/vectors/player-play-24.svg.vec';

  /// File path: assets/vectors/plus-24.svg.vec
  String get plus24Svg => 'packages/worklog_studio_style_system/assets/vectors/plus-24.svg.vec';

  /// File path: assets/vectors/plus-outlined-24.svg.vec
  String get plusOutlined24Svg => 'packages/worklog_studio_style_system/assets/vectors/plus-outlined-24.svg.vec';

  /// File path: assets/vectors/rotate-clockwise-24.svg.vec
  String get rotateClockwise24Svg => 'packages/worklog_studio_style_system/assets/vectors/rotate-clockwise-24.svg.vec';

  /// File path: assets/vectors/settings-24.svg.vec
  String get settings24Svg => 'packages/worklog_studio_style_system/assets/vectors/settings-24.svg.vec';

  /// File path: assets/vectors/square-filled-24.svg.vec
  String get squareFilled24Svg => 'packages/worklog_studio_style_system/assets/vectors/square-filled-24.svg.vec';

  /// File path: assets/vectors/square-filled-64.svg.vec
  String get squareFilled64Svg => 'packages/worklog_studio_style_system/assets/vectors/square-filled-64.svg.vec';

  /// File path: assets/vectors/square-outlined-24.svg.vec
  String get squareOutlined24Svg => 'packages/worklog_studio_style_system/assets/vectors/square-outlined-24.svg.vec';

  /// List of all assets
  List<String> get values => [
    arrowSmallRight24Svg,
    arrowSmallRight64Svg,
    flashlight24,
    flashlightOff24,
    history24Svg,
    playFilled24Svg,
    playFilled64Svg,
    playerPause24Svg,
    playerPlay24Svg,
    plus24Svg,
    plusOutlined24Svg,
    rotateClockwise24Svg,
    settings24Svg,
    squareFilled24Svg,
    squareFilled64Svg,
    squareOutlined24Svg,
  ];
}

class $AssetsImagesMSizeGen {
  const $AssetsImagesMSizeGen();

  /// File path: assets/images/m-size/eye-icon-512.png
  AssetGenImage get eyeIcon512 => const AssetGenImage('assets/images/m-size/eye-icon-512.png');

  /// List of all assets
  List<AssetGenImage> get values => [eyeIcon512];
}

class $AssetsImagesPreviewGen {
  const $AssetsImagesPreviewGen();

  /// File path: assets/images/preview/click-png-512.png
  AssetGenImage get clickPng512 => const AssetGenImage('assets/images/preview/click-png-512.png');

  /// List of all assets
  List<AssetGenImage> get values => [clickPng512];
}

class $AssetsImagesSSizeGen {
  const $AssetsImagesSSizeGen();

  /// File path: assets/images/s-size/eye-icon-256.png
  AssetGenImage get eyeIcon256 => const AssetGenImage('assets/images/s-size/eye-icon-256.png');

  /// List of all assets
  List<AssetGenImage> get values => [eyeIcon256];
}

class WorklogStudioAssets {
  const WorklogStudioAssets._();

  static const String package = 'worklog_studio_style_system';

  static const $AssetsImagesGen images = $AssetsImagesGen();
  static const $AssetsVectorsGen vectors = $AssetsVectorsGen();
}

class AssetGenImage {
  const AssetGenImage(this._assetName, {this.size, this.flavors = const {}, this.animation});

  final String _assetName;

  static const String package = 'worklog_studio_style_system';

  final Size? size;
  final Set<String> flavors;
  final AssetGenImageAnimation? animation;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    @Deprecated('Do not specify package for a generated library asset') String? package = package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({
    AssetBundle? bundle,
    @Deprecated('Do not specify package for a generated library asset') String? package = package,
  }) {
    return AssetImage(_assetName, bundle: bundle, package: package);
  }

  String get path => _assetName;

  String get keyName => 'packages/worklog_studio_style_system/$_assetName';
}

class AssetGenImageAnimation {
  const AssetGenImageAnimation({required this.isAnimation, required this.duration, required this.frames});

  final bool isAnimation;
  final Duration duration;
  final int frames;
}
