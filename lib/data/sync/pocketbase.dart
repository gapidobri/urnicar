import 'package:pocketbase/pocketbase.dart';
import 'package:urnicar/data/secure_storage.dart';

late final PocketBase pb;

Future<void> initPocketBase() async {
  final initial = await secureStorage.read(key: 'auth');

  pb = PocketBase(
    'https://urnicar.gapi.me',
    authStore: AsyncAuthStore(
      save: (data) => secureStorage.write(key: 'auth', value: data),
      clear: () => secureStorage.delete(key: 'auth'),
      initial: initial,
    ),
  );
}
