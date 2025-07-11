import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'utils/constants.dart';
import 'services/alarm_manager_service.dart';
import 'services/alarm_monitor_service.dart';
import 'services/android_alarm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize alarm manager service (local only, no native calls)
    await AlarmManagerService.instance.initialize();
    
    debugPrint('Basic alarm services initialized');
  } catch (e) {
    debugPrint('Error initializing basic alarm services: $e');
  }
  
  runApp(const BeepSquaredApp());
}

/// Main application widget following Material Design 3
class BeepSquaredApp extends StatefulWidget {
  const BeepSquaredApp({super.key});

  @override
  State<BeepSquaredApp> createState() => _BeepSquaredAppState();
  
  // Global navigator key for alarm screen navigation
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  /// Get global navigator context
  static BuildContext? get globalContext => navigatorKey.currentContext;
}

class _BeepSquaredAppState extends State<BeepSquaredApp> with WidgetsBindingObserver {
  bool _servicesInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Initialize native services after the Flutter engine is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeNativeServices();
    });
  }

  /// Initialize native alarm services after Flutter engine is ready
  Future<void> _initializeNativeServices() async {
    if (_servicesInitialized) return;
    
    try {
      // Initialize Android alarm service (primary alarm mechanism)
      await AndroidAlarmService.instance.initialize();
      
      // Start alarm monitoring as backup (with reduced frequency)
      AlarmMonitorService.instance.startMonitoring();
      
      _servicesInitialized = true;
      debugPrint('Native alarm services initialized successfully');
    } catch (e) {
      debugPrint('Error initializing native alarm services: $e');
      // Continue without native services if they fail
      AlarmMonitorService.instance.startMonitoring();
      _servicesInitialized = true;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Stop monitoring when app is disposed
    AlarmMonitorService.instance.stopMonitoring();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // Ensure services are initialized and resume monitoring when app comes to foreground
        if (!_servicesInitialized) {
          _initializeNativeServices();
        } else if (!AlarmMonitorService.instance.isMonitoring) {
          AlarmMonitorService.instance.startMonitoring();
        }
        break;
      case AppLifecycleState.paused:
        // Keep monitoring but reduce frequency when app is backgrounded
        break;
      case AppLifecycleState.detached:
        // Stop monitoring when app is completely closed
        AlarmMonitorService.instance.stopMonitoring();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: ThemeMode.system,
      home: const HomeScreen(title: AppConstants.appName),
      navigatorKey: BeepSquaredApp.navigatorKey,
      debugShowCheckedModeBanner: false,
    );
  }

  /// Build light theme with Material Design 3
  ThemeData _buildLightTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppConstants.primaryColor,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
    );
  }

  /// Build dark theme with Material Design 3
  ThemeData _buildDarkTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppConstants.primaryColor,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
    );
  }
}
