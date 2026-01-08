// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timetables_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Timetables)
final timetablesProvider = TimetablesProvider._();

final class TimetablesProvider
    extends $NotifierProvider<Timetables, Map<String, TimetableRecord>> {
  TimetablesProvider._()
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
  Override overrideWithValue(Map<String, TimetableRecord> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, TimetableRecord>>(value),
    );
  }
}

String _$timetablesHash() => r'44dd49615c7d4a1f7c9c6d2f493232649ac31df0';

abstract class _$Timetables extends $Notifier<Map<String, TimetableRecord>> {
  Map<String, TimetableRecord> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<Map<String, TimetableRecord>, Map<String, TimetableRecord>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                Map<String, TimetableRecord>,
                Map<String, TimetableRecord>
              >,
              Map<String, TimetableRecord>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
