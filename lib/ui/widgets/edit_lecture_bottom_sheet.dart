import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urnicar/data/remote_timetable/timetable_scraper.dart';

final _lectureTypes = {
  LectureType.lecture: 'Predavanje',
  LectureType.labExercises: 'Laboratorijske vaje',
  LectureType.auditoryExercises: 'Avditorne vaje',
};

class EditLectureBottomSheet extends ConsumerStatefulWidget {
  const EditLectureBottomSheet({
    super.key,
    required this.lecture,
    required this.onUpdate,
  });

  final Lecture lecture;
  final void Function(Lecture) onUpdate;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditLectureBottomSheetState();
}

class _EditLectureBottomSheetState
    extends ConsumerState<EditLectureBottomSheet> {
  late bool ignored;
  late bool pinned;

  @override
  void initState() {
    ignored = widget.lecture.ignored;
    pinned = widget.lecture.pinned;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).primaryColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.lecture.subject.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 2.0),
              Text(
                _lectureTypes[widget.lecture.type] ?? 'Ostalo',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Row(
                children: [
                  Checkbox(
                    value: ignored,
                    onChanged: (value) {
                      setState(() => ignored = value ?? false);
                      widget.onUpdate(widget.lecture.copyWith(ignored: value));
                    },
                  ),
                  Text('Ignoriraj uro'),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: pinned,
                    onChanged: (value) {
                      setState(() => pinned = value ?? false);
                      widget.onUpdate(widget.lecture.copyWith(pinned: value));
                    },
                  ),
                  Text('Zamrzni uro'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
