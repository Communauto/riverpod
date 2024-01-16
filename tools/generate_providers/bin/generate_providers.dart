import 'dart:io';

import 'package:dart_style/dart_style.dart';

import '../src/docs.dart';

const _header = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
//
// If you need to modify this file, instead update /tools/generate_providers/bin/generate_providers.dart
//
// You can install this utility by executing:
// dart pub global activate -s path <repository_path>/tools/generate_providers
//
// You can then use it in your terminal by executing:
// generate_providers <riverpod/flutter_riverpod/hooks_riverpod> <path to builder file to update>

''';

enum _DisposeType { keepAlive, autoDispose }

enum _ProviderKind { orphan, family }

sealed class _Builder {
  const _Builder(
    this.providerName, {
    required this.genericsDefinition,
    required this.genericsUsage,
  });

  final String genericsDefinition;
  final String genericsUsage;
  final String providerName;
}

class _FunctionalBuilder extends _Builder {
  _FunctionalBuilder(
    super.providerName, {
    required super.genericsDefinition,
    required super.genericsUsage,
    required this.createdT,
    required this.refT,
  });

  final String createdT;
  final String refT;
}

class _NotifierBuilder extends _Builder {
  _NotifierBuilder(
    super.providerName, {
    required super.genericsDefinition,
    required super.genericsUsage,
  });
}

typedef Matrix = ({
  List<_DisposeType> disposeTypes,
  List<_Builder> providers,
  List<_ProviderKind> kinds,
});

Future<void> main(List<String> args) async {
  if (args.length != 2) {
    stdout.writeln(
      'usage: generate_providers <riverpod/flutter_riverpod> file',
    );
    return;
  }
  if (args.first != 'riverpod' && args.first != 'flutter_riverpod') {
    stderr.writeln('Unknown argument ${args.first}');
    return;
  }

  final file = File.fromUri(Uri.parse(args[1]));
  if (file.existsSync() && file.statSync().type != FileSystemEntityType.file) {
    stderr.writeln('${args[1]} is not a file');
    return;
  }

  Matrix matrix;
  final buffer = StringBuffer(_header);

  switch (args.first) {
    case 'riverpod':
      matrix = (
        disposeTypes: _DisposeType.values,
        providers: [
          _FunctionalBuilder(
            'StateProvider',
            genericsUsage: 'StateT',
            genericsDefinition: 'StateT',
            createdT: 'StateT',
            refT: 'StateProviderRef<StateT>',
          ),
          _FunctionalBuilder(
            'StateNotifierProvider',
            genericsUsage: 'NotifierT, StateT',
            genericsDefinition:
                'NotifierT extends StateNotifier<StateT>, StateT',
            createdT: 'NotifierT',
            refT: 'StateNotifierProviderRef<NotifierT, StateT>',
          ),
          _FunctionalBuilder(
            'Provider',
            genericsUsage: 'StateT',
            genericsDefinition: 'StateT',
            createdT: 'StateT',
            refT: 'Ref<StateT>',
          ),
          _FunctionalBuilder(
            'FutureProvider',
            genericsUsage: 'StateT',
            genericsDefinition: 'StateT',
            createdT: 'FutureOr<StateT>',
            refT: 'Ref<AsyncValue<StateT>>',
          ),
          _FunctionalBuilder(
            'StreamProvider',
            genericsUsage: 'StateT',
            genericsDefinition: 'StateT',
            createdT: 'Stream<StateT>',
            refT: 'Ref<AsyncValue<StateT>>',
          ),
          _NotifierBuilder(
            'NotifierProvider',
            genericsUsage: '<NotifierT, StateT>',
            genericsDefinition: '<NotifierT extends Notifier<StateT>, StateT>',
          ),
          _NotifierBuilder(
            'StreamNotifierProvider',
            genericsUsage: '<NotifierT, StateT>',
            genericsDefinition:
                '<NotifierT extends StreamNotifier<StateT>, StateT>',
          ),
          _NotifierBuilder(
            'AsyncNotifierProvider',
            genericsUsage: '<NotifierT, StateT>',
            genericsDefinition:
                '<NotifierT extends AsyncNotifier<StateT>, StateT>',
          ),
        ],
        kinds: _ProviderKind.values,
      );
      buffer.writeln(
        """
import 'dart:async';

import 'package:meta/meta.dart';
import 'package:state_notifier/state_notifier.dart';

import 'internals.dart';
""",
      );

    case 'flutter_riverpod':
      matrix = (
        disposeTypes: _DisposeType.values,
        providers: [
          _FunctionalBuilder(
            'ChangeNotifierProvider',
            genericsUsage: 'NotifierT',
            genericsDefinition: 'NotifierT extends ChangeNotifier',
            createdT: 'NotifierT',
            refT: 'ChangeProviderRef<NotifierT>',
          ),
        ],
        kinds: _ProviderKind.values,
      );
      buffer.writeln(
        """
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

import 'internals.dart';
""",
      );
    default:
      throw UnsupportedError('Unknown package ${args.first}');
  }

  _generateAll(buffer, matrix);

  await file.writeAsString(
    DartFormatter().format(buffer.toString()),
  );
}

void _generateAll(StringBuffer buffer, Matrix matrix) {
  for (final provider in matrix.providers) {
    for (final disposeType in matrix.disposeTypes) {
      for (final kind in matrix.kinds) {
        if (kind == _ProviderKind.orphan &&
            disposeType == _DisposeType.keepAlive) {
          // That's handled by the provider itself
          continue;
        }

        switch (provider) {
          case _NotifierBuilder():
            _generateNotifierOrphan(buffer, disposeType, provider, kind);
          case _FunctionalBuilder():
            switch (kind) {
              case _ProviderKind.orphan:
                _generateFunctionalOrphan(buffer, disposeType, provider);
              case _ProviderKind.family:
                _generateFunctionalFamily(buffer, disposeType, provider);
            }
        }
      }
    }
  }
}

void _generateFunctionalFamily(
  StringBuffer buffer,
  _DisposeType disposeType,
  _FunctionalBuilder provider,
) {
  final builderName = _builderName(
    provider,
    disposeType,
    kind: _ProviderKind.family,
  );

  buffer.writeln('''
@internal
class $builderName {
  const $builderName();

  $familyDoc
  ${provider.providerName}Family<${provider.genericsUsage}, ArgT> call<${provider.genericsDefinition}, ArgT>(
    ${provider.createdT} Function(${provider.refT} ref, ArgT param) create, {
    String? name,
    Iterable<ProviderOrFamily>? dependencies,
  }) {
    return ${provider.providerName}Family<${provider.genericsUsage}, ArgT>(
      create,
      name: name,
      ${_isAutoDisposeParam(disposeType)}
      dependencies: dependencies,
    );
  }

  ${_autoDisposeModifier(provider, disposeType, _ProviderKind.family)}
}
''');
}

void _generateFunctionalOrphan(
  StringBuffer buffer,
  _DisposeType disposeType,
  _FunctionalBuilder provider,
) {
  final builderName = _builderName(
    provider,
    disposeType,
  );

  buffer.writeln('''
@internal
class $builderName {
  const $builderName();

  $familyDoc
  ${provider.providerName}<${provider.genericsUsage}> call<${provider.genericsDefinition}>(
    ${provider.createdT} Function(${provider.refT} ref) create, {
    String? name,
    Iterable<ProviderOrFamily>? dependencies,
  }) {
    return ${provider.providerName}<${provider.genericsUsage}>(
      create,
      name: name,
      ${_isAutoDisposeParam(disposeType)}
      dependencies: dependencies,
    );
  }

  ${_familyModifier(provider, disposeType, _ProviderKind.orphan)}
  ${_autoDisposeModifier(provider, disposeType, _ProviderKind.orphan)}
}
''');
}

String _builderName(
  _Builder provider,
  _DisposeType disposeType, {
  _ProviderKind kind = _ProviderKind.orphan,
}) {
  var builderName = 'Builder';
  if (kind == _ProviderKind.family) {
    builderName = 'Family$builderName';
  }
  builderName = '${provider.providerName}$builderName';
  if (disposeType == _DisposeType.autoDispose) {
    builderName = 'AutoDispose$builderName';
  }
  return builderName;
}

String _autoDisposeModifier(
  _Builder provider,
  _DisposeType disposeType,
  _ProviderKind kind,
) {
  if (disposeType == _DisposeType.autoDispose) return '';

  final targetBuilder = _builderName(
    provider,
    _DisposeType.autoDispose,
    kind: kind,
  );

  return '''
  $autoDisposeDoc
  $targetBuilder get autoDispose => const $targetBuilder();
''';
}

String _familyModifier(
  _Builder provider,
  _DisposeType disposeType,
  _ProviderKind kind,
) {
  if (kind == _ProviderKind.family) return '';

  final targetBuilder = _builderName(
    provider,
    disposeType,
    kind: _ProviderKind.family,
  );

  return '''
  $familyDoc
  $targetBuilder get family => const $targetBuilder();
''';
}

String _isAutoDisposeParam(_DisposeType disposeType) {
  if (disposeType == _DisposeType.autoDispose) {
    return 'isAutoDispose: true,';
  }
  return '';
}

void _generateNotifierOrphan(
  StringBuffer buffer,
  _DisposeType disposeType,
  _NotifierBuilder provider,
  _ProviderKind kind,
) {
  final builderName = _builderName(
    provider,
    disposeType,
    kind: kind,
  );

  buffer.writeln('''
@internal
class $builderName {
  const $builderName();

  $autoDisposeDoc
  ${provider.providerName}${provider.genericsUsage} call${provider.genericsDefinition}(
    NotifierT Function() create, {
    String? name,
    Iterable<ProviderOrFamily>? dependencies,
  }) {
    return ${provider.providerName}${provider.genericsUsage}(
      create,
      name: name,
      ${_isAutoDisposeParam(disposeType)}
      dependencies: dependencies,
    );
  }

  ${_familyModifier(provider, disposeType, kind)}
  ${_autoDisposeModifier(provider, disposeType, kind)}
}
''');
}
