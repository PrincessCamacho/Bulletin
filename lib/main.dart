import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'constants/app_colors.dart';
import 'models/announcement.dart';
import 'models/issue_report.dart';
import 'screens/archive/archive_screen.dart';
import 'screens/announcements/announcements_list_screen.dart';
import 'screens/reports/reports_list_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(AnnouncementAdapter());
  Hive.registerAdapter(IssueReportAdapter());
  await Hive.openBox<Announcement>('announcements');
  await Hive.openBox<IssueReport>('issue_reports');

  runApp(const BarangayBulletinApp());
}

class BarangayBulletinApp extends StatefulWidget {
  const BarangayBulletinApp({super.key});

  @override
  State<BarangayBulletinApp> createState() => _BarangayBulletinAppState();
}

class _BarangayBulletinAppState extends State<BarangayBulletinApp> {
  int _currentIndex = 0;

  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  void _selectTab(int index) {
    if (index == _currentIndex) {
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
      return;
    }
    setState(() {
      _currentIndex = index;
    });
  }

  Widget _buildNavigator(int index) {
    return Offstage(
      offstage: _currentIndex != index,
      child: Navigator(
        key: _navigatorKeys[index],
        onGenerateRoute: (settings) {
          late Widget page;
          switch (index) {
            case 0:
              page = const AnnouncementsListScreen();
              break;
            case 1:
              page = const ReportsListScreen();
              break;
            case 2:
              page = const ArchiveScreen();
              break;
            default:
              page = const SizedBox.shrink();
          }
          return MaterialPageRoute(builder: (_) => page);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barangay Bulletin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
          primary: Color.fromARGB(255, 141, 95, 214),
          secondary: AppColors.secondaryBlue,
          surface: AppColors.surface,
          error: AppColors.error,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.black87,
          onError: Colors.white,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 86, 149, 226),
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        cardTheme: const CardThemeData(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondaryBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: Scaffold(
        body: Stack(
          children: List.generate(_navigatorKeys.length, _buildNavigator),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _selectTab,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.campaign_outlined),
              selectedIcon: Icon(Icons.campaign),
              label: 'Announcements',
            ),
            NavigationDestination(
              icon: Icon(Icons.report_gmailerrorred_outlined),
              selectedIcon: Icon(Icons.report_gmailerrorred),
              label: 'Reports',
            ),
            NavigationDestination(
              icon: Icon(Icons.archive_outlined),
              selectedIcon: Icon(Icons.archive),
              label: 'Archive',
            ),
          ],
        ),
      ),
    );
  }
}
