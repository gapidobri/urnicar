import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:urnicar/data/remote_timetable/remote_lectures_provider.dart';
import 'package:urnicar/data/remote_timetable/remote_timetables_provider.dart';
import 'package:urnicar/data/remote_timetable/timetable_scraper.dart';
import 'package:urnicar/data/sync/pocketbase.dart';
import 'package:urnicar/data/timetable/timetable_record.dart';
import 'package:urnicar/data/timetable/timetables_provider.dart';
import 'package:uuid/uuid.dart';

class ImportScreen extends ConsumerStatefulWidget {
  const ImportScreen({super.key});

  @override
  ConsumerState createState() => _ImportScreenState();
}

class _ImportScreenState extends ConsumerState<ImportScreen> {
  String? timetableId;
  String? studentId;

  Timer? studentIdDebounce;

  final studentIdController = TextEditingController();

  @override
  void initState() {
    studentId = pb.authStore.record?.getStringValue('studentId');
    studentIdController.text = studentId ?? '';

    super.initState();
  }

  void handleImportTimetable() async {
    if (timetableId == null || studentId == null) return;

    final existingTimetable = ref
        .read(timetablesProvider)
        .values
        .firstWhereOrNull((t) => t.sourceTimetableId == timetableId);

    if (existingTimetable != null) {
      final doContinue = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Urnik obstaja'),
          content: Text(
            'Urnik, ki ga želiš uvoziti že obstaja. Ali vseeno želiš nadaljevati?',
          ),
          actions: [
            TextButton(onPressed: () => context.pop(false), child: Text('Ne')),
            TextButton(onPressed: () => context.pop(true), child: Text('Da')),
          ],
        ),
      );
      if (!(doContinue ?? false)) return;
    }

    final remoteTimetables = await ref.read(remoteTimetablesProvider.future);

    final remoteTimetable = remoteTimetables.firstWhereOrNull(
      (t) => t.id == timetableId!,
    );

    final lectures = await ref.read(
      remoteLecturesProvider
          .call(timetableId!, FilterType.student, studentId!)
          .future,
    );

    final timetable = TimetableRecord(
      sourceTimetableId: timetableId!,
      studentId: studentId!,
      id: Uuid().v4(),
      name: remoteTimetable?.name ?? 'Nov urnik',
      lectures: lectures,
      updated: DateTime.now(),
    );

    await ref.read(timetablesProvider.notifier).createTimetable(timetable);

    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final timetables = ref.watch(remoteTimetablesProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Uvozi urnik')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            switch (timetables) {
              AsyncLoading<List<Timetable>>() => LinearProgressIndicator(),
              AsyncError<List<Timetable>>() => Text(
                'Failed to load timetables',
              ),
              AsyncData<List<Timetable>>(value: final timetables) =>
                DropdownButton<String>(
                  isExpanded: true,
                  hint: Text('Izberi urnik'),
                  value: timetableId,
                  items: [
                    for (final timetable in timetables)
                      DropdownMenuItem(
                        value: timetable.id,
                        child: Text(
                          timetable.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (value) => setState(() => timetableId = value),
                ),
            },

            SizedBox(height: 8.0),

            TextField(
              controller: studentIdController,
              decoration: InputDecoration(label: Text('Vpisna številka')),
              onChanged: (value) {
                if (studentIdDebounce?.isActive ?? false) {
                  studentIdDebounce?.cancel();
                }
                studentIdDebounce = Timer(
                  const Duration(milliseconds: 500),
                  () => setState(() => studentId = value),
                );
              },
            ),

            SizedBox(height: 16.0),

            lecturesPreview(),

            Spacer(),

            SafeArea(
              child: ElevatedButton(
                onPressed: timetableId != null && studentId != null
                    ? handleImportTimetable
                    : null,
                child: Text('Uvozi urnik'),
              ),
            ),

            SizedBox(height: 8.0),
          ],
        ),
      ),
    );
  }

  Widget lecturesPreview() {
    if (timetableId == null || studentId == null) {
      return SizedBox();
    }

    final lectures = ref.watch(
      remoteLecturesProvider.call(timetableId!, FilterType.student, studentId!),
    );

    switch (lectures) {
      case AsyncLoading<List<Lecture>>():
        return CircularProgressIndicator();
      case AsyncError<List<Lecture>>():
        return Text('Napaka pri nalaganju urnika');
      case AsyncData<List<Lecture>>(value: final lectures):
        final subjects = <Subject>{};
        for (final lecture in lectures) {
          subjects.add(lecture.subject);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Predmeti',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            SizedBox(height: 8.0),
            if (subjects.isNotEmpty)
              for (final subject in subjects)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(subject.name),
                  ),
                )
            else
              Text('Ni najdenih predmetov'),
          ],
        );
    }
  }
}
