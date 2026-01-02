// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'remote_timetables_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(remoteTimetables)
const remoteTimetablesProvider = RemoteTimetablesProvider._();

final class RemoteTimetablesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Timetable>>,
          List<Timetable>,
          FutureOr<List<Timetable>>
        >
    with $FutureModifier<List<Timetable>>, $FutureProvider<List<Timetable>> {
  const RemoteTimetablesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'remoteTimetablesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$remoteTimetablesHash();

  @$internal
  @override
  $FutureProviderElement<List<Timetable>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Timetable>> create(Ref ref) {
    return remoteTimetables(ref);
  }
}

String _$remoteTimetablesHash() => r'84dee8571434a3ca15aa7f8ca9e5d70ddc4b2452';
