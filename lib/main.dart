import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:urnicar/calendar/calendar_screen.dart';

void main() async {
  // final res = await TimetableScraper.getTimetables();
  // print(res);

  // final res2 = await TimetableScraper.getTimetableData('fri-2025_2026-zimski');
  // print(res2.teachers);

  // final res3 = await TimetableScraper.getLectures(
  //   timetableId: 'fri-2025_2026-zimski',
  //   filterType: FilterType.student,
  //   id: '63230048',
  // );
  // for (final lecture in res3) {
  //   print(lecture);
  // }

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
