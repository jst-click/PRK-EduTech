import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:no_screenshot/no_screenshot.dart';
import 'dart:async';
import '../constants.dart';

class SecurityWrapper extends StatefulWidget {
  final Widget child;

  const SecurityWrapper({Key? key, required this.child}) : super(key: key);

  @override
  State<SecurityWrapper> createState() => _SecurityWrapperState();
}

class _SecurityWrapperState extends State<SecurityWrapper>
    with WidgetsBindingObserver {
  final _noScreenshot = NoScreenshot.instance;
  StreamSubscription<dynamic>? _screenshotSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (kBlockScreenshots) {
      _enableSecurityFeatures();
    } else {
      _disableSecurityFeatures();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _screenshotSubscription?.cancel();
    unawaited(_disableSecurityFeatures());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (kBlockScreenshots) {
        _enableSecurityFeatures();
      } else {
        _disableSecurityFeatures();
      }
    } else if (state == AppLifecycleState.paused) {
      // Additional security when app goes to background
      if (kBlockScreenshots) {
        _noScreenshot.screenshotOff();
      }
    }
  }

  Future<void> _enableSecurityFeatures() async {
    // Disable screenshots using the no_screenshot plugin
    try {
      await _noScreenshot.screenshotOff();
    } catch (e) {
      debugPrint('screenshotOff failed: $e');
    }

    // Start listening for screenshot attempts
    try {
      await _noScreenshot.startScreenshotListening();
    } catch (e) {
      debugPrint('startScreenshotListening failed: $e');
    }

    // Subscribe to screenshot events (optional - for logging purposes)
    _screenshotSubscription?.cancel();
    _screenshotSubscription = _noScreenshot.screenshotStream.listen((value) {
      if (value.wasScreenshotTaken) {
        debugPrint('Screenshot attempt detected!');
        // You could log this event or take other actions
      }
    });

    // Hide system overlays safely through the Flutter API.
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [],
    );

    // Optional native hook, ignore when channel/plugin isn't available.
    const methodChannel = MethodChannel('security_channel');
    try {
      await methodChannel.invokeMethod('preventScreenCapture');
    } on MissingPluginException {
      // No native implementation registered for this build flavor/platform.
    } catch (e) {
      debugPrint('preventScreenCapture failed: $e');
    }
  }

  Future<void> _disableSecurityFeatures() async {
    try {
      await _noScreenshot.screenshotOn();
    } catch (e) {
      debugPrint('screenshotOn failed: $e');
    }

    try {
      await _noScreenshot.stopScreenshotListening();
    } catch (e) {
      debugPrint('stopScreenshotListening failed: $e');
    }

    try {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    } catch (e) {
      debugPrint('setEnabledSystemUIMode failed: $e');
    }

    // Optional native hook, ignore when channel/plugin isn't available.
    const methodChannel = MethodChannel('security_channel');
    try {
      await methodChannel.invokeMethod('allowScreenCapture');
    } on MissingPluginException {
      // No native implementation registered for this build flavor/platform.
    } catch (e) {
      debugPrint('allowScreenCapture failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
