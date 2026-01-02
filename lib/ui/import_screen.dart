import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urnicar/data/remote_timetable/remote_lectures_provider.dart';
import 'package:urnicar/data/remote_timetable/remote_timetables_provider.dart';
import 'package:urnicar/data/timetable/timetable_scraper.dart';

class ImportScreen extends ConsumerStatefulWidget {
  const ImportScreen({super.key});

  @override
  ConsumerState createState() => _ImportScreenState();
}

class _ImportScreenState extends ConsumerState<ImportScreen> {
  String? timetableId;
  String? studentId;

  Timer? studentIdDebounce;

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
                        child: Text(timetable.name),
                      ),
                  ],
                  onChanged: (value) => setState(() => timetableId = value),
                ),
            },

            SizedBox(height: 8.0),

            TextField(
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

            SizedBox(height: 8.0),

            lecturesPreview(),

            Spacer(),

            SafeArea(
              child: ElevatedButton(
                onPressed: () {},
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
