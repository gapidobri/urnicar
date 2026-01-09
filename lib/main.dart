import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:urnicar/data/sync/pocketbase.dart';
import 'package:urnicar/data/timetable/timetable_record.dart';
import 'package:urnicar/data/timetable/timetables_provider.dart';
import 'package:urnicar/hive/boxes.dart';
import 'package:urnicar/hive/hive_registrar.g.dart';
import 'package:urnicar/ui/calendar_screen.dart';
import 'package:urnicar/ui/edit_screen.dart';
import 'package:urnicar/ui/import_screen.dart';
import 'package:urnicar/ui/login_screen.dart';
import 'package:urnicar/ui/register_screen.dart';
import 'package:urnicar/ui/remote_timetable_screen.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapters();

  timetablesBox = await Hive.openBox<TimetableRecord>('timetables');

  await initPocketBase();

  runApp(const ProviderScope(child: App()));
}

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  void initState() {
    ref.read(timetablesProvider.notifier).syncTimetables();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData(useMaterial3: true),
      darkTheme: ThemeData.dark(),
      routerConfig: _router,
    );
  }
}

final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => CalendarScreen()),
    GoRoute(path: '/import', builder: (context, state) => ImportScreen()),
    GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
    GoRoute(path: '/register', builder: (context, state) => RegisterScreen()),
    GoRoute(
      path: '/edit/:timetableId',
      builder: (context, state) =>
          EditScreen(timetableId: state.pathParameters['timetableId']!),
    ),
    GoRoute(
      path: '/remoteTimetable/:remoteTimetableId',
      builder: (context, state) {
        final params = state.extra as RemoteTimetableScreenParams;
        return RemoteTimetableScreen(
          timetableId: state.pathParameters['remoteTimetableId']!,
          filterType: params.filterType,
          filterId: params.filterId,
          title: params.title,
        );
      },
    ),
  ],
);
