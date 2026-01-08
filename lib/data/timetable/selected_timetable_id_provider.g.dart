// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selected_timetable_id_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SelectedTimetableId)
final selectedTimetableIdProvider = SelectedTimetableIdProvider._();

final class SelectedTimetableIdProvider
    extends $NotifierProvider<SelectedTimetableId, String?> {
  SelectedTimetableIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedTimetableIdProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedTimetableIdHash();

  @$internal
  @override
  SelectedTimetableId create() => SelectedTimetableId();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$selectedTimetableIdHash() =>
    r'db11455069b7e6ed2faa39263368ab638a37a842';

abstract class _$SelectedTimetableId extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
