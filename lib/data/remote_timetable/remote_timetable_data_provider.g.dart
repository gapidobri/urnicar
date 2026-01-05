// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'remote_timetable_data_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(remoteTimetableData)
final remoteTimetableDataProvider = RemoteTimetableDataFamily._();

final class RemoteTimetableDataProvider
    extends
        $FunctionalProvider<
          AsyncValue<TimetableData>,
          TimetableData,
          FutureOr<TimetableData>
        >
    with $FutureModifier<TimetableData>, $FutureProvider<TimetableData> {
  RemoteTimetableDataProvider._({
    required RemoteTimetableDataFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'remoteTimetableDataProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$remoteTimetableDataHash();

  @override
  String toString() {
    return r'remoteTimetableDataProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<TimetableData> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<TimetableData> create(Ref ref) {
    final argument = this.argument as String;
    return remoteTimetableData(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RemoteTimetableDataProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$remoteTimetableDataHash() =>
    r'ea712a46aa0d6ab3692078f68508e8975b99084c';

final class RemoteTimetableDataFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<TimetableData>, String> {
  RemoteTimetableDataFamily._()
    : super(
        retry: null,
        name: r'remoteTimetableDataProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RemoteTimetableDataProvider call(String timetableId) =>
      RemoteTimetableDataProvider._(argument: timetableId, from: this);

  @override
  String toString() => r'remoteTimetableDataProvider';
}
