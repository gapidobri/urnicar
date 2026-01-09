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
import 'package:urnicar/ui/subject_picker_screen.dart';
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

  Set<Subject> selectedSubjects = {};
  String? preferedName;

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
    final studentLectures = await ref.read(
      remoteLecturesProvider
          .call(timetableId!, FilterType.student, studentId!)
          .future,
    );

    final filteredLectures = studentLectures.where(
          (lecture) => selectedSubjects.any((s) => s.id == lecture.subject.id),
    ).toList();

    // ce so novi
    final existingSubjectIds =
    filteredLectures.map((l) => l.subject.id).toSet();

    final newlyAddedSubjects = selectedSubjects.where(
          (s) => !existingSubjectIds.contains(s.id),
    );

    // za vsakega novega 1 lecture, 1 lab
    for (final subject in newlyAddedSubjects) {
      final allForSubject = await ref.read(
        remoteLecturesProvider
            .call(timetableId!, FilterType.subject, subject.id)
            .future,
      );

      Lecture? predavanje;
      Lecture? vaje;

      for (final lec in allForSubject) {
        if (predavanje == null &&
            lec.type == LectureType.lecture) {
          predavanje = lec;
        }

        if (vaje == null &&
            (lec.type == LectureType.labExercises ||
                lec.type == LectureType.auditoryExercises)) {
          vaje = lec;
        }

        if (predavanje != null && vaje != null) break;
      }

      if (predavanje != null) filteredLectures.add(predavanje);
      if (vaje != null) filteredLectures.add(vaje);
    }

    final uniqueLectures = {
      for (final l in filteredLectures) l.id: l
    }.values.toList();

    final name = preferedName ?? remoteTimetable?.name ?? 'Nov urnik';

    final timetable = TimetableRecord(
      sourceTimetableId: timetableId!,
      studentId: studentId!,
      id: Uuid().v4(),
      name: name,
      lectures: uniqueLectures,
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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  switch (timetables) {
                    AsyncLoading<List<Timetable>>() => LinearProgressIndicator(),
                    AsyncError<List<Timetable>>() => Text('Failed to load timetables'),
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
                  TextField(
                    decoration: InputDecoration(label: Text('Poimenuj urnik')),
                    onChanged: (value) {
                      preferedName = value;
                    },
                  ),
                  SizedBox(height: 16.0),
                  lecturesPreview(),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: timetableId != null && studentId != null
                          ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SubjectPickerScreen(
                              timetableId: timetableId ?? "",
                              selectedSubjects: selectedSubjects,
                            ),
                          ),
                        ).then((updatedSubjects) {
                          if (updatedSubjects != null) {
                            setState(() {
                              selectedSubjects = updatedSubjects;
                            });
                          }
                        });
                      }
                          : null,
                      child: Text('Dodaj predmet'),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: timetableId != null && studentId != null
                          ? handleImportTimetable
                          : null,
                      child: Text('Uvozi urnik'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
        if (selectedSubjects.isEmpty) {
          final loaded = <Subject>{};
          for (final lecture in lectures) {
            loaded.add(lecture.subject);
          }
          selectedSubjects = loaded;
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

            selectedSubjects.isNotEmpty
                ? Column(
              children: [
                for (final subject in selectedSubjects)
                  ListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    title: Text(subject.name),
                    trailing: IconButton(
                      icon: const Icon(Icons.cancel_outlined),
                      onPressed: () {
                        setState(() {
                          selectedSubjects.remove(subject);
                        });
                      },
                    ),
                  ),
              ],
            )
                : Text('Ni najdenih predmetov'),
          ],
        );
    }
  }
}
