// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'remote_lectures_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(remoteLectures)
final remoteLecturesProvider = RemoteLecturesFamily._();

final class RemoteLecturesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Lecture>>,
          List<Lecture>,
          FutureOr<List<Lecture>>
        >
    with $FutureModifier<List<Lecture>>, $FutureProvider<List<Lecture>> {
  RemoteLecturesProvider._({
    required RemoteLecturesFamily super.from,
    required (String, FilterType, String) super.argument,
  }) : super(
         retry: null,
         name: r'remoteLecturesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$remoteLecturesHash();

  @override
  String toString() {
    return r'remoteLecturesProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<Lecture>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Lecture>> create(Ref ref) {
    final argument = this.argument as (String, FilterType, String);
    return remoteLectures(ref, argument.$1, argument.$2, argument.$3);
  }

  @override
  bool operator ==(Object other) {
    return other is RemoteLecturesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$remoteLecturesHash() => r'614789148d30fa5d47c5ac8b2c95f49a1731ad3c';

final class RemoteLecturesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<Lecture>>,
          (String, FilterType, String)
        > {
  RemoteLecturesFamily._()
    : super(
        retry: null,
        name: r'remoteLecturesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RemoteLecturesProvider call(
    String timetableId,
    FilterType filterType,
    String id,
  ) => RemoteLecturesProvider._(
    argument: (timetableId, filterType, id),
    from: this,
  );

  @override
  String toString() => r'remoteLecturesProvider';
}
