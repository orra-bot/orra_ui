import 'package:flutter/widgets.dart';
import 'package:orra_desktop_shell/orra_desktop_shell.dart';

import 'gallery_app.dart';

Future<void> main() async {
  await RaDesktopWindow.ensureInitialized(const RaWindowOptions(title: 'orra gallery'));
  runApp(const GalleryApp());
}
