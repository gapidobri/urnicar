import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:urnicar/data/timetable/timetable_record.dart';
import 'package:urnicar/hive/boxes.dart';
import 'package:urnicar/hive/hive_registrar.g.dart';
import 'package:urnicar/ui/calendar_screen.dart';
import 'package:urnicar/ui/import_screen.dart';
import 'package:urnicar/ui/login_screen.dart';
import 'package:urnicar/ui/register_screen.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapters();

  timetablesBox = await Hive.openBox<TimetableRecord>('timetables');

  runApp(const ProviderScope(child: App()));
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData(useMaterial3: true),
      routerConfig: _router,
    );
  }
}

final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => CalendarScreen()),
    GoRoute(path: '/import', builder: (context, state) => ImportScreen()),
    GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
    GoRoute(path: '/register', builder: (context, state) => RegisterScreen())
  ],
);
