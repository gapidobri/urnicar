// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selected_timetable_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SelectedTimetable)
final selectedTimetableProvider = SelectedTimetableProvider._();

final class SelectedTimetableProvider
    extends $NotifierProvider<SelectedTimetable, TimetableRecord?> {
  SelectedTimetableProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedTimetableProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedTimetableHash();

  @$internal
  @override
  SelectedTimetable create() => SelectedTimetable();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TimetableRecord? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TimetableRecord?>(value),
    );
  }
}

String _$selectedTimetableHash() => r'9f3406f7ef2f4d74b87ecc5a1cb0072db9ae79e4';

abstract class _$SelectedTimetable extends $Notifier<TimetableRecord?> {
  TimetableRecord? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<TimetableRecord?, TimetableRecord?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TimetableRecord?, TimetableRecord?>,
              TimetableRecord?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
