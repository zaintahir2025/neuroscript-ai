// ignore_for_file: avoid_print

import 'dart:io';

import 'package:image/image.dart' as img;

void main() async {
  const sourceDir = r'c:\Users\Zain\Downloads\AppIcons';
  final masterPath = '$sourceDir${Platform.pathSeparator}appstore.png';
  final masterFile = File(masterPath);

  if (!masterFile.existsSync()) {
    print('Master file not found at $masterPath');
    exit(1);
  }

  print('Reading master image: $masterPath');
  final masterBytes = masterFile.readAsBytesSync();
  final master = img.decodeImage(masterBytes);
  if (master == null) {
    print('Failed to decode master image');
    exit(1);
  }
  print('Decoded master image: ${master.width}x${master.height}');

  // 1. Android mipmap icons
  print('\n[1/5] Updating Android launcher icons...');
  final densities = {
    'mipmap-mdpi': 48,
    'mipmap-hdpi': 72,
    'mipmap-xhdpi': 96,
    'mipmap-xxhdpi': 144,
    'mipmap-xxxhdpi': 192,
  };

  for (final entry in densities.entries) {
    final folderName = entry.key;
    final size = entry.value;

    final destFolder = Directory('android/app/src/main/res/$folderName');
    if (!destFolder.existsSync()) {
      destFolder.createSync(recursive: true);
    }

    // Check if downloaded folder already has it
    final sourceIcon = File('$sourceDir/android/$folderName/ic_launcher.png');
    final targetLauncher = File('${destFolder.path}/ic_launcher.png');
    final targetRound = File('${destFolder.path}/ic_launcher_round.png');

    if (sourceIcon.existsSync()) {
      sourceIcon.copySync(targetLauncher.path);
      sourceIcon.copySync(targetRound.path);
      print('  Copied $folderName/ic_launcher.png');
    } else {
      final resized = img.copyResize(master, width: size, height: size);
      File(targetLauncher.path).writeAsBytesSync(img.encodePng(resized));
      File(targetRound.path).writeAsBytesSync(img.encodePng(resized));
      print('  Generated $folderName/ic_launcher.png (${size}x$size)');
    }
  }

  // 2. iOS AppIcon set
  print('\n[2/5] Updating iOS AppIcon set...');
  final iosDest = Directory('ios/Runner/Assets.xcassets/AppIcon.appiconset');
  if (!iosDest.existsSync()) {
    iosDest.createSync(recursive: true);
  }

  final sourceIosDir = Directory(
    '$sourceDir/Assets.xcassets/AppIcon.appiconset/_',
  );
  final sourceContents = File(
    '$sourceDir/Assets.xcassets/AppIcon.appiconset/Contents.json',
  );

  if (sourceContents.existsSync()) {
    sourceContents.copySync('${iosDest.path}/Contents.json');
    print('  Copied Contents.json');
  }

  if (sourceIosDir.existsSync()) {
    for (final file in sourceIosDir.listSync().whereType<File>()) {
      if (file.path.endsWith('.png')) {
        final filename = file.uri.pathSegments.last;
        file.copySync('${iosDest.path}/$filename');
      }
    }
    print('  Copied all iOS icon PNGs to ${iosDest.path}');
  }

  // 3. Web Favicon and PWA icons
  print('\n[3/5] Updating Web favicon & icons...');
  final webFavicon = File('web/favicon.png');
  final faviconImg = img.copyResize(master, width: 64, height: 64);
  webFavicon.writeAsBytesSync(img.encodePng(faviconImg));
  print('  Wrote web/favicon.png (64x64)');

  final webIconsDir = Directory('web/icons');
  if (!webIconsDir.existsSync()) webIconsDir.createSync(recursive: true);

  final webSizes = {
    'web/icons/Icon-192.png': 192,
    'web/icons/Icon-512.png': 512,
    'web/icons/Icon-maskable-192.png': 192,
    'web/icons/Icon-maskable-512.png': 512,
  };

  for (final entry in webSizes.entries) {
    final resized = img.copyResize(
      master,
      width: entry.value,
      height: entry.value,
    );
    File(entry.key).writeAsBytesSync(img.encodePng(resized));
    print('  Wrote ${entry.key} (${entry.value}x${entry.value})');
  }

  // 4. macOS icons
  print('\n[4/5] Updating macOS icons...');
  final macosDir = Directory('macos/Runner/Assets.xcassets/AppIcon.appiconset');
  if (macosDir.existsSync()) {
    final macSizes = {
      16: 'app_icon_16.png',
      32: 'app_icon_32.png',
      64: 'app_icon_64.png',
      128: 'app_icon_128.png',
      256: 'app_icon_256.png',
      512: 'app_icon_512.png',
      1024: 'app_icon_1024.png',
    };
    for (final entry in macSizes.entries) {
      final resized = img.copyResize(
        master,
        width: entry.key,
        height: entry.key,
      );
      File('${macosDir.path}/${entry.value}')
          .writeAsBytesSync(img.encodePng(resized));
      print('  Wrote macos/${entry.value} (${entry.key}x${entry.key})');
    }
  }

  // 5. Windows app_icon.ico
  print('\n[5/5] Updating Windows app_icon.ico...');
  final winIcoFile = File('windows/runner/resources/app_icon.ico');
  if (winIcoFile.parent.existsSync()) {
    final icoImg256 = img.copyResize(master, width: 256, height: 256);
    final icoBytes = img.encodeIco(icoImg256);
    winIcoFile.writeAsBytesSync(icoBytes);
    print('  Wrote windows/runner/resources/app_icon.ico');
  }

  // 6. In-App Branding Assets
  print('\n[6/6] Generating In-App Branding assets...');
  final brandingDir = Directory('assets/branding');
  if (!brandingDir.existsSync()) brandingDir.createSync(recursive: true);

  File('assets/branding/app_logo.png').writeAsBytesSync(masterBytes);
  final inApp512 = img.copyResize(master, width: 512, height: 512);
  File('assets/branding/app_icon_512.png')
      .writeAsBytesSync(img.encodePng(inApp512));
  final inApp128 = img.copyResize(master, width: 128, height: 128);
  File('assets/branding/app_icon_128.png')
      .writeAsBytesSync(img.encodePng(inApp128));
  print('  Wrote assets/branding/app_logo.png');
  print('  Wrote assets/branding/app_icon_512.png');
  print('  Wrote assets/branding/app_icon_128.png');

  print(
    '\nAll icons, logos, and favicons successfully updated across all platforms!',
  );
}
