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

    test('registry is lazily materialised - cold start has zero stores', () {
      // The 150MB Elasser budget depends on the fact that asking the
      // registry for its shape (constructing it, asking how many modules
      // it knows about) never touches the asset bundle. Only `storeFor`
      // materialises a store, and even that does not read from disk
      // until `loadManifest` / `loadUnit` is invoked.
      final fresh = AssetContentRegistry();
      expect(fresh.materialisedCount, 0);

      fresh.storeFor('islam');
      expect(fresh.materialisedCount, 1);

      // Repeated asks reuse the cached instance; multi-faith bundles do
      // not accumulate stores unless the UI actually switches modules.
      fresh.storeFor('islam');
      fresh.storeFor('islam');
      expect(fresh.materialisedCount, 1);

      fresh.storeFor('vedic');
      expect(fresh.materialisedCount, 2);
    });
  });
}
