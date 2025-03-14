/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart' as _svg;
import 'package:vector_graphics/vector_graphics.dart' as _vg;

class $AssetsIconsGen {
  const $AssetsIconsGen();

  /// File path: assets/icons/calculator.svg
  SvgGenImage get calculator =>
      const SvgGenImage('assets/icons/calculator.svg');

  /// File path: assets/icons/history.svg
  SvgGenImage get history => const SvgGenImage('assets/icons/history.svg');

  /// File path: assets/icons/home.svg
  SvgGenImage get home => const SvgGenImage('assets/icons/home.svg');

  /// File path: assets/icons/more.svg
  SvgGenImage get more => const SvgGenImage('assets/icons/more.svg');

  /// File path: assets/icons/profit.svg
  SvgGenImage get profit => const SvgGenImage('assets/icons/profit.svg');

  /// List of all assets
  List<SvgGenImage> get values => [calculator, history, home, more, profit];
}

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/amp.png
  AssetGenImage get amp => const AssetGenImage('assets/images/amp.png');

  /// File path: assets/images/ba.png
  AssetGenImage get ba => const AssetGenImage('assets/images/ba.png');

  /// File path: assets/images/calculator.png
  AssetGenImage get calculator =>
      const AssetGenImage('assets/images/calculator.png');

  /// File path: assets/images/calnit.png
  AssetGenImage get calnit => const AssetGenImage('assets/images/calnit.png');

  /// File path: assets/images/ce.png
  AssetGenImage get ce => const AssetGenImage('assets/images/ce.png');

  /// File path: assets/images/cn.png
  AssetGenImage get cn => const AssetGenImage('assets/images/cn.png');

  /// File path: assets/images/cu15.png
  AssetGenImage get cu15 => const AssetGenImage('assets/images/cu15.png');

  /// File path: assets/images/farmer.png
  AssetGenImage get farmer => const AssetGenImage('assets/images/farmer.png');

  /// File path: assets/images/fe13.png
  AssetGenImage get fe13 => const AssetGenImage('assets/images/fe13.png');

  /// File path: assets/images/fertilizer.png
  AssetGenImage get fertilizer =>
      const AssetGenImage('assets/images/fertilizer.png');

  /// File path: assets/images/google.png
  AssetGenImage get google => const AssetGenImage('assets/images/google.png');

  /// File path: assets/images/history.png
  AssetGenImage get history => const AssetGenImage('assets/images/history.png');

  /// File path: assets/images/ie.png
  AssetGenImage get ie => const AssetGenImage('assets/images/ie.png');

  /// File path: assets/images/kalinitra.png
  AssetGenImage get kalinitra =>
      const AssetGenImage('assets/images/kalinitra.png');

  /// File path: assets/images/logo.png
  AssetGenImage get logo => const AssetGenImage('assets/images/logo.png');

  /// File path: assets/images/m.png
  AssetGenImage get m => const AssetGenImage('assets/images/m.png');

  /// File path: assets/images/mag-s.png
  AssetGenImage get magS => const AssetGenImage('assets/images/mag-s.png');

  /// File path: assets/images/map.png
  AssetGenImage get map => const AssetGenImage('assets/images/map.png');

  /// File path: assets/images/mkp.png
  AssetGenImage get mkp => const AssetGenImage('assets/images/mkp.png');

  /// File path: assets/images/mn13.png
  AssetGenImage get mn13 => const AssetGenImage('assets/images/mn13.png');

  /// File path: assets/images/mne.png
  AssetGenImage get mne => const AssetGenImage('assets/images/mne.png');

  /// File path: assets/images/ms.png
  AssetGenImage get ms => const AssetGenImage('assets/images/ms.png');

  /// File path: assets/images/plant.png
  AssetGenImage get plant => const AssetGenImage('assets/images/plant.png');

  /// File path: assets/images/pmp.png
  AssetGenImage get pmp => const AssetGenImage('assets/images/pmp.png');

  /// File path: assets/images/pn.png
  AssetGenImage get pn => const AssetGenImage('assets/images/pn.png');

  /// File path: assets/images/ps.png
  AssetGenImage get ps => const AssetGenImage('assets/images/ps.png');

  /// File path: assets/images/smd.png
  AssetGenImage get smd => const AssetGenImage('assets/images/smd.png');

  /// File path: assets/images/sop.png
  AssetGenImage get sop => const AssetGenImage('assets/images/sop.png');

  /// File path: assets/images/vitaflex.png
  AssetGenImage get vitaflex =>
      const AssetGenImage('assets/images/vitaflex.png');

  /// File path: assets/images/zn15.png
  AssetGenImage get zn15 => const AssetGenImage('assets/images/zn15.png');

  /// File path: assets/images/zne.png
  AssetGenImage get zne => const AssetGenImage('assets/images/zne.png');

  /// List of all assets
  List<AssetGenImage> get values => [
        amp,
        ba,
        calculator,
        calnit,
        ce,
        cn,
        cu15,
        farmer,
        fe13,
        fertilizer,
        google,
        history,
        ie,
        kalinitra,
        logo,
        m,
        magS,
        map,
        mkp,
        mn13,
        mne,
        ms,
        plant,
        pmp,
        pn,
        ps,
        smd,
        sop,
        vitaflex,
        zn15,
        zne
      ];
}

class Assets {
  Assets._();

  static const $AssetsIconsGen icons = $AssetsIconsGen();
  static const $AssetsImagesGen images = $AssetsImagesGen();
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;

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
    String? package,
    FilterQuality filterQuality = FilterQuality.low,
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
    String? package,
  }) {
    return AssetImage(
      _assetName,
      bundle: bundle,
      package: package,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class SvgGenImage {
  const SvgGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
  }) : _isVecFormat = false;

  const SvgGenImage.vec(
    this._assetName, {
    this.size,
    this.flavors = const {},
  }) : _isVecFormat = true;

  final String _assetName;
  final Size? size;
  final Set<String> flavors;
  final bool _isVecFormat;

  _svg.SvgPicture svg({
    Key? key,
    bool matchTextDirection = false,
    AssetBundle? bundle,
    String? package,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    AlignmentGeometry alignment = Alignment.center,
    bool allowDrawingOutsideViewBox = false,
    WidgetBuilder? placeholderBuilder,
    String? semanticsLabel,
    bool excludeFromSemantics = false,
    _svg.SvgTheme? theme,
    ColorFilter? colorFilter,
    Clip clipBehavior = Clip.hardEdge,
    @deprecated Color? color,
    @deprecated BlendMode colorBlendMode = BlendMode.srcIn,
    @deprecated bool cacheColorFilter = false,
  }) {
    final _svg.BytesLoader loader;
    if (_isVecFormat) {
      loader = _vg.AssetBytesLoader(
        _assetName,
        assetBundle: bundle,
        packageName: package,
      );
    } else {
      loader = _svg.SvgAssetLoader(
        _assetName,
        assetBundle: bundle,
        packageName: package,
        theme: theme,
      );
    }
    return _svg.SvgPicture(
      loader,
      key: key,
      matchTextDirection: matchTextDirection,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      allowDrawingOutsideViewBox: allowDrawingOutsideViewBox,
      placeholderBuilder: placeholderBuilder,
      semanticsLabel: semanticsLabel,
      excludeFromSemantics: excludeFromSemantics,
      colorFilter: colorFilter ??
          (color == null ? null : ColorFilter.mode(color, colorBlendMode)),
      clipBehavior: clipBehavior,
      cacheColorFilter: cacheColorFilter,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
