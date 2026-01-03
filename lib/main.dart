import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_links/app_links.dart';
import 'package:window_manager/window_manager.dart';
import 'providers/magnet_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();

  const windowOptions = WindowOptions(
    size: Size(650, 450),
    minimumSize: Size(500, 350),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
    title: 'MagnetCopy',
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const MagnetCopyApp());
}

class MagnetCopyApp extends StatefulWidget {
  const MagnetCopyApp({super.key});

  @override
  State<MagnetCopyApp> createState() => _MagnetCopyAppState();
}

class _MagnetCopyAppState extends State<MagnetCopyApp> {
  final _magnetProvider = MagnetProvider();
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleIncomingLink(initialUri);
      }
    } catch (e) {
      debugPrint('Failed to get initial link: $e');
    }

    _linkSubscription = _appLinks.uriLinkStream.listen(
      _handleIncomingLink,
      onError: (err) {
        debugPrint('Error receiving deep link: $err');
      },
    );
  }

  void _handleIncomingLink(Uri uri) {
    final magnetLink = uri.toString();
    debugPrint('Received magnet link: $magnetLink');

    final result = _magnetProvider.addLink(magnetLink);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      switch (result) {
        case AddLinkResult.added:
          _showToast('링크가 수집되었습니다');
          break;
        case AddLinkResult.duplicate:
          _showToast('이미 수집된 링크입니다', isWarning: true);
          break;
        case AddLinkResult.invalid:
          _showToast('유효하지 않은 링크입니다', isError: true);
          break;
      }
    });
  }

  void _showToast(String message, {bool isWarning = false, bool isError = false}) {
    final messenger = _scaffoldMessengerKey.currentState;
    if (messenger == null) return;

    Color backgroundColor;
    if (isError) {
      backgroundColor = Colors.red.shade600;
    } else if (isWarning) {
      backgroundColor = Colors.orange.shade600;
    } else {
      backgroundColor = Colors.green.shade600;
    }

    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    _magnetProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _magnetProvider,
      child: MaterialApp(
        title: 'MagnetCopy',
        debugShowCheckedModeBanner: false,
        scaffoldMessengerKey: _scaffoldMessengerKey,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
