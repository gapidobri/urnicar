import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:urnicar/data/sync/pocketbase.dart';
import 'package:urnicar/data/sync/user_record.dart';
import 'package:urnicar/data/timetable/selected_timetable_id_provider.dart';
import 'package:urnicar/data/timetable/timetables_provider.dart';

class ProfileDialog extends ConsumerWidget {
  const ProfileDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (pb.authStore.record == null) {
      return SizedBox();
    }

    final user = UserRecord.fromRecord(pb.authStore.record!);

    return Dialog(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(radius: 32.0, child: Icon(Icons.person, size: 32.0)),
            const SizedBox(height: 12.0),
            Text(user.name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4.0),
            Text(user.email),
            Text(user.studentId),
            const SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () async {
                context.pop();
                await ref.read(timetablesProvider.notifier).clearLocal();
                await ref.read(selectedTimetableIdProvider.notifier).set(null);
                pb.authStore.clear();
              },
              child: Text('Odjava'),
            ),
          ],
        ),
      ),
    );
  }
}
