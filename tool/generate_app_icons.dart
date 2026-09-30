// Renders the HapoPay launcher icons and native splash logo as PNGs.
//
//   dart tool/generate_app_icons.dart
//
// Uses only dart:io, so it runs without `flutter pub get`.
//
// The artwork mirrors `_HapoPayLogoPainter` in
// lib/shared/widgets/hapo_pay_logo.dart. Android's adaptive icon and splash
// logo are vector drawables under android/app/src/main/res/drawable/ and are
// NOT generated here — keep their geometry in sync with the constants below.
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

// Brand colours (AppTokens.primary / AppTokens.accent).
const _purple = [0x7C, 0x4D, 0xFF];
const _teal = [0x00, 0xD4, 0xA1];
const _white = [0xFF, 0xFF, 0xFF];

typedef _Sdf = double Function(double x, double y);

/// Returns straight-alpha RGBA in 0..1 for a point in design units.
typedef _Paint = List<double> Function(double x, double y);

class _Layer {
  const _Layer(this.sdf, this.paint);
  final _Sdf sdf;
  final _Paint paint;
}

// ---------------------------------------------------------------------------
// Shapes (signed distance, negative inside)
// ---------------------------------------------------------------------------

_Sdf _circle(double cx, double cy, double r) =>
    (x, y) => _hypot(x - cx, y - cy) - r;

_Sdf _ring(double cx, double cy, double r, double strokeWidth) =>
    (x, y) => (_hypot(x - cx, y - cy) - r).abs() - strokeWidth / 2;

_Sdf _roundRect(double l, double t, double w, double h, double r) {
  final cx = l + w / 2, cy = t + h / 2;
  final hx = w / 2 - r, hy = h / 2 - r;
  return (x, y) {
    final qx = (x - cx).abs() - hx, qy = (y - cy).abs() - hy;
    return _hypot(math.max(qx, 0), math.max(qy, 0)) +
        math.min(math.max(qx, qy), 0) -
        r;
  };
}

_Sdf _union(List<_Sdf> shapes) =>
    (x, y) => shapes.map((s) => s(x, y)).reduce(math.min);

double _everywhere(double x, double y) => double.negativeInfinity;

double _hypot(double a, double b) => math.sqrt(a * a + b * b);

// ---------------------------------------------------------------------------
// Paints
// ---------------------------------------------------------------------------

_Paint _solid(List<int> rgb, [double alpha = 1]) {
  final c = [rgb[0] / 255, rgb[1] / 255, rgb[2] / 255, alpha];
  return (x, y) => c;
}

/// Purple → teal, top-left → bottom-right across the square at ([l], [t]).
_Paint _brandGradient(double l, double t, double side) => (x, y) {
  final f = (((x - l) + (y - t)) / (2 * side)).clamp(0.0, 1.0);
  return [
    for (var i = 0; i < 3; i++)
      (_purple[i] + (_teal[i] - _purple[i]) * f) / 255,
    1.0,
  ];
};

// ---------------------------------------------------------------------------
// Artwork
// ---------------------------------------------------------------------------

/// Launcher icon in Android adaptive-icon units: a 108×108 canvas whose
/// central 72×72 is what launchers show. Matches
/// drawable/ic_launcher_background.xml + ic_launcher_foreground.xml.
const double _iconVisibleOrigin = 18;
const double _iconVisibleSpan = 72;

final _iconLayers = [
  _Layer(
    _everywhere,
    _brandGradient(_iconVisibleOrigin, _iconVisibleOrigin, _iconVisibleSpan),
  ),
  _Layer(
    _union([
      _roundRect(34, 37.75, 10, 32.5, 3.2), // left pillar
      _roundRect(64, 37.75, 10, 32.5, 3.2), // right pillar
      _roundRect(34, 49.6, 40, 8.8, 3.2), // crossbar
      _circle(75, 33, 3), // accent dot
    ]),
    _solid(_white),
  ),
];

/// In-app emblem (ring + disc + "H" + dot) on a 100×100 canvas. Matches
/// drawable/launch_logo.xml and `_HapoPayLogoPainter`.
final _emblemLayers = [
  _Layer(_ring(50, 50, 47, 4), _brandGradient(0, 0, 100)),
  _Layer(_circle(50, 50, 41), _brandGradient(9, 9, 82)),
  _Layer(
    _union([
      _roundRect(25, 29.7, 12.5, 40.6, 4),
      _roundRect(62.5, 29.7, 12.5, 40.6, 4),
      _roundRect(25, 44.5, 50, 11, 4),
    ]),
    _solid(_white, 0.96),
  ),
  _Layer(_circle(82.8, 20.3, 4.5), _solid(_teal, 0.9)),
];

// ---------------------------------------------------------------------------
// Rasteriser
// ---------------------------------------------------------------------------

/// Renders the square window at ([origin], [origin]) of side [span] (design
/// units) to [size]×[size] pixels. [mask] clips the result; [opaque] drops
/// the alpha channel (required for iOS app icons).
Uint8List _render(
  List<_Layer> layers, {
  required int size,
  required double origin,
  required double span,
  _Sdf? mask,
  bool opaque = false,
}) {
  final pxPerUnit = size / span;
  final channels = opaque ? 3 : 4;
  final stride = size * channels + 1; // +1 for the PNG filter byte
  final raw = Uint8List(stride * size);

  double coverage(_Sdf sdf, double x, double y) =>
      (0.5 - sdf(x, y) * pxPerUnit).clamp(0.0, 1.0);

  for (var py = 0; py < size; py++) {
    final y = origin + (py + 0.5) / pxPerUnit;
    var o = py * stride + 1;
    for (var px = 0; px < size; px++) {
      final x = origin + (px + 0.5) / pxPerUnit;
      var r = 0.0, g = 0.0, b = 0.0, a = 0.0;
      for (final layer in layers) {
        final cov = coverage(layer.sdf, x, y);
        if (cov == 0) continue;
        final c = layer.paint(x, y);
        final sa = c[3] * cov;
        final outA = sa + a * (1 - sa);
        if (outA == 0) continue;
        r = (c[0] * sa + r * a * (1 - sa)) / outA;
        g = (c[1] * sa + g * a * (1 - sa)) / outA;
        b = (c[2] * sa + b * a * (1 - sa)) / outA;
        a = outA;
      }
      if (mask != null) a *= coverage(mask, x, y);
      raw[o++] = (r * 255).round();
      raw[o++] = (g * 255).round();
      raw[o++] = (b * 255).round();
      if (!opaque) raw[o++] = (a * 255).round();
    }
  }
  return _encodePng(raw, size, size, opaque ? 2 : 6);
}

// ---------------------------------------------------------------------------
// PNG encoding
// ---------------------------------------------------------------------------

final List<int> _crcTable = List.generate(256, (n) {
  var c = n;
  for (var k = 0; k < 8; k++) {
    c = (c & 1) != 0 ? 0xEDB88320 ^ (c >> 1) : c >> 1;
  }
  return c;
});

Uint8List _encodePng(Uint8List raw, int width, int height, int colorType) {
  final out = BytesBuilder();
  out.add([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);

  void chunk(String type, List<int> data) {
    final body = [...type.codeUnits, ...data];
    var crc = 0xFFFFFFFF;
    for (final byte in body) {
      crc = _crcTable[(crc ^ byte) & 0xFF] ^ (crc >> 8);
    }
    out.add(_uint32(data.length));
    out.add(body);
    out.add(_uint32(crc ^ 0xFFFFFFFF));
  }

  chunk('IHDR', [..._uint32(width), ..._uint32(height), 8, colorType, 0, 0, 0]);
  chunk('IDAT', ZLibCodec(level: 9).encode(raw));
  chunk('IEND', const []);
  return out.toBytes();
}

List<int> _uint32(int v) => [
  (v >> 24) & 0xFF,
  (v >> 16) & 0xFF,
  (v >> 8) & 0xFF,
  v & 0xFF,
];

// ---------------------------------------------------------------------------
// Outputs
// ---------------------------------------------------------------------------

void _write(String path, Uint8List bytes) {
  File(path)
    ..createSync(recursive: true)
    ..writeAsBytesSync(bytes);
  stdout.writeln('  $path');
}

Uint8List _icon(int size, {bool opaque = true, _Sdf? mask}) => _render(
  _iconLayers,
  size: size,
  origin: _iconVisibleOrigin,
  span: _iconVisibleSpan,
  opaque: opaque,
  mask: mask,
);

Uint8List _emblem(int size) =>
    _render(_emblemLayers, size: size, origin: 0, span: 100);

void main() {
  if (!File('pubspec.yaml').existsSync()) {
    stderr.writeln('Run from the repository root.');
    exit(1);
  }

  stdout.writeln('Store masters:');
  _write('assets/branding/app_icon_1024.png', _icon(1024));
  _write('assets/branding/play_store_icon_512.png', _icon(512));

  stdout.writeln('iOS AppIcon:');
  const iosDir = 'ios/Runner/Assets.xcassets/AppIcon.appiconset';
  const iosIcons = {
    'Icon-App-20x20@1x': 20,
    'Icon-App-20x20@2x': 40,
    'Icon-App-20x20@3x': 60,
    'Icon-App-29x29@1x': 29,
    'Icon-App-29x29@2x': 58,
    'Icon-App-29x29@3x': 87,
    'Icon-App-40x40@1x': 40,
    'Icon-App-40x40@2x': 80,
    'Icon-App-40x40@3x': 120,
    'Icon-App-60x60@2x': 120,
    'Icon-App-60x60@3x': 180,
    'Icon-App-76x76@1x': 76,
    'Icon-App-76x76@2x': 152,
    'Icon-App-83.5x83.5@2x': 167,
    'Icon-App-1024x1024@1x': 1024,
  };
  iosIcons.forEach((name, px) => _write('$iosDir/$name.png', _icon(px)));

  // 92pt matches HapoPayLogo(size: 92) on the Flutter splash screen.
  stdout.writeln('iOS LaunchImage:');
  const launchDir = 'ios/Runner/Assets.xcassets/LaunchImage.imageset';
  _write('$launchDir/LaunchImage.png', _emblem(92));
  _write('$launchDir/LaunchImage@2x.png', _emblem(184));
  _write('$launchDir/LaunchImage@3x.png', _emblem(276));

  // Only used below API 26; newer launchers use the adaptive icon XML.
  stdout.writeln('Android legacy launcher icons:');
  const androidRes = 'android/app/src/main/res';
  const densities = {
    'mdpi': 48,
    'hdpi': 72,
    'xhdpi': 96,
    'xxhdpi': 144,
    'xxxhdpi': 192,
  };
  final legacyMask = _roundRect(
    _iconVisibleOrigin,
    _iconVisibleOrigin,
    _iconVisibleSpan,
    _iconVisibleSpan,
    _iconVisibleSpan * 0.22,
  );
  densities.forEach(
    (density, px) => _write(
      '$androidRes/mipmap-$density/ic_launcher.png',
      _icon(px, opaque: false, mask: legacyMask),
    ),
  );
}
