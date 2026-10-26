import 'package:flutter_test/flutter_test.dart';
import 'package:ritualist/state/content_store.dart';

void main() {
  group('AssetContentRegistry', () {
    test('hands out the same cached store per module id', () {
      final registry = AssetContentRegistry();
      expect(
        identical(registry.storeFor('islam'), registry.storeFor('islam')),
        isTrue,
      );
    });

    test('different modules get separate stores scoped to their own dir', () {
      final registry = AssetContentRegistry();
      final islam = registry.storeFor('islam');
      final stoic = registry.storeFor('stoic');
      expect(identical(islam, stoic), isFalse);
      // Each store only ever reads under assets/modules/<moduleId> - so a
      // module that is never opened performs zero asset reads at cold start.
      expect((islam as AssetContentStore).moduleDir, 'assets/modules/islam');
      expect((stoic as AssetContentStore).moduleDir, 'assets/modules/stoic');
    });
  });
}
