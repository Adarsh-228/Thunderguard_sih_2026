import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'thunderguard/core/tg_colors.dart';
import 'thunderguard/core/tg_theme.dart';
import 'thunderguard/shell/tg_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: TGColors.surface,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const ThunderGuardApp());
}

class ThunderGuardApp extends StatelessWidget {
  const ThunderGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ThunderGuard — AI Lightning Nowcasting',
      debugShowCheckedModeBanner: false,
      theme: TGTheme.dark,
      home: const ThunderGuardShell(),
    );
  }
}
