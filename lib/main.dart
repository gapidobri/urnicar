import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:urnicar/calendar/calendar_screen.dart';
import 'package:urnicar/hive/hive_registrar.g.dart';
import 'package:urnicar/timetable/timetable_repository.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapters();

  await TimetableRepository.openBox();

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
  routes: [GoRoute(path: '/', builder: (context, state) => CalendarScreen())],
);
