import 'dart:async';

import 'package:meta/meta.dart';

import '../builder.dart';
import '../core/async_value.dart';
import '../framework.dart';
import 'future_provider.dart' show FutureProvider;
import 'notifier.dart';

part 'async_notifier/orphan.dart';
part 'async_notifier/family.dart';

/// Implementation detail of `riverpod_generator`.
/// Do not use.
abstract class $AsyncNotifier<StateT> extends $ClassBase< //
        AsyncValue<StateT>,
        FutureOr<StateT>> //
    with
        $AsyncClassModifier<StateT, FutureOr<StateT>> {}

/// Implementation detail of `riverpod_generator`.
/// Do not use.
abstract base class $AsyncNotifierProvider< //
        NotifierT extends $AsyncNotifier<StateT>,
        StateT> //
    extends $ClassProvider< //
        NotifierT,
        AsyncValue<StateT>,
        FutureOr<StateT>,
        Ref<AsyncValue<StateT>>> //
    with
        $FutureModifier<StateT> {
  const $AsyncNotifierProvider(
    this._createNotifier, {
    required super.name,
    required super.from,
    required super.argument,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.isAutoDispose,
    required super.runNotifierBuildOverride,
  });

  final NotifierT Function() _createNotifier;

  @override
  NotifierT create() => _createNotifier();
}

/// Implementation detail of `riverpod_generator`.
/// Do not use.
class $AsyncNotifierProviderElement< //
        NotifierT extends $AsyncNotifier<StateT>,
        StateT> //
    extends ClassProviderElement< //
        NotifierT,
        AsyncValue<StateT>,
        FutureOr<StateT>> //
    with
        FutureModifierElement<StateT> {
  $AsyncNotifierProviderElement(this.provider, super.container);

  @override
  final $AsyncNotifierProvider<NotifierT, StateT> provider;

  @override
  void handleError(
    Object error,
    StackTrace stackTrace, {
    required bool didChangeDependency,
  }) {
    onError(AsyncError(error, stackTrace), seamless: !didChangeDependency);
  }

  @override
  void handleValue(
    FutureOr<StateT> created, {
    required bool didChangeDependency,
  }) {
    handleFuture(
      () => created,
      didChangeDependency: didChangeDependency,
    );
  }
}
