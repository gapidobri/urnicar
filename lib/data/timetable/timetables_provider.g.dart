// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timetables_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Timetables)
const timetablesProvider = TimetablesProvider._();

final class TimetablesProvider
    extends $NotifierProvider<Timetables, List<TimetableRecord>> {
  const TimetablesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'timetablesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$timetablesHash();

  @$internal
  @override
  Timetables create() => Timetables();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<TimetableRecord> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<TimetableRecord>>(value),
    );
  }
}

String _$timetablesHash() => r'91a053072156dd105b871f694ffdb252c915c003';

abstract class _$Timetables extends $Notifier<List<TimetableRecord>> {
  List<TimetableRecord> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<List<TimetableRecord>, List<TimetableRecord>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<TimetableRecord>, List<TimetableRecord>>,
              List<TimetableRecord>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
