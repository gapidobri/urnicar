import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urnicar/data/remote_timetable/timetable_scraper.dart';
import '../data/remote_timetable/remote_timetable_data_provider.dart';


class SubjectPickerScreen extends ConsumerStatefulWidget {
  final Set<Subject> selectedSubjects;
  final String timetableId;

  const SubjectPickerScreen({
    super.key,
    required this.selectedSubjects,
    required this.timetableId,
  });

  @override
  ConsumerState createState() => _SubjectPickerScreenState();
}

class _SubjectPickerScreenState extends ConsumerState<SubjectPickerScreen> {
  String query = "";

  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(
      remoteTimetableDataProvider(widget.timetableId),
    );

    return asyncData.when(
      loading: () => Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text("Error: $e"))),
      data: (timetableData) {
        final allSubjects = timetableData.subjects.values.toList();

        final filtered = allSubjects
            .where((s) => s.name.toLowerCase().contains(query.toLowerCase()))
            .toList();

        return Scaffold(
          appBar: AppBar(
            title: Text("Izberi predmet"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context, widget.selectedSubjects);
                },
                child: Text("Končaj"),
              )
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: "Išči predmet...",
                  ),
                  onChanged: (value) {
                    setState(() => query = value);
                  },
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    for (final subject in filtered)
                      ListTile(
                        title: Text(
                          "${subject.name} (${subject.id})",
                        ),
                        trailing: widget.selectedSubjects.contains(subject)
                            ? Icon(Icons.check_circle, color: Colors.green)
                            : Icon(Icons.add),
                        onTap: () {
                          setState(() {
                            if (widget.selectedSubjects.contains(subject)) {
                              widget.selectedSubjects.remove(subject);
                            } else {
                              widget.selectedSubjects.add(subject);
                            }
                          });
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}