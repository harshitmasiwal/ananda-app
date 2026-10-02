import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/cloudinary_service.dart';
import '../models/wallpaper_model.dart';
import '../models/bhajan_model.dart';
import '../models/holy_book_model.dart';
import '../models/ringtone_model.dart';

// ── Root catalog provider ─────────────────────────────────────────────────────
/// Fetches the full catalog once; all section providers derive from this.
/// Using [AsyncNotifier] so we can expose refresh capability.
final catalogProvider = AsyncNotifierProvider<CatalogNotifier, AppCatalog>(
  CatalogNotifier.new,
);

class CatalogNotifier extends AsyncNotifier<AppCatalog> {
  @override
  Future<AppCatalog> build() => CloudinaryService.instance.fetchCatalog();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => CloudinaryService.instance.fetchCatalog(forceRefresh: true),
    );
  }
}

// ── Section providers (derived, lazy — only compute when accessed) ────────────

final wallpapersProvider = Provider<AsyncValue<List<WallpaperModel>>>((ref) {
  return ref.watch(catalogProvider).whenData((c) => c.wallpapers);
});

final featuredWallpapersProvider =
    Provider<AsyncValue<List<WallpaperModel>>>((ref) {
  return ref.watch(catalogProvider).whenData(
        (c) => c.wallpapers.where((w) => w.isFeatured).toList(),
      );
});

final bhajansProvider = Provider<AsyncValue<List<BhajanModel>>>((ref) {
  return ref.watch(catalogProvider).whenData((c) => c.bhajans);
});

final bhajansForCategoryProvider =
    Provider.family<AsyncValue<List<BhajanModel>>, String>((ref, category) {
  return ref.watch(catalogProvider).whenData(
        (c) => c.bhajans.where((b) => b.category == category).toList(),
      );
});

final holyBooksProvider = Provider<AsyncValue<List<HolyBookModel>>>((ref) {
  return ref.watch(catalogProvider).whenData((c) => c.holyBooks);
});

final ringtonesProvider = Provider<AsyncValue<List<RingtoneModel>>>((ref) {
  return ref.watch(catalogProvider).whenData((c) => c.ringtones);
});

final ringtonesByCategoryProvider =
    Provider.family<AsyncValue<List<RingtoneModel>>, String>((ref, category) {
  return ref.watch(catalogProvider).whenData(
        (c) => c.ringtones.where((r) => r.category == category).toList(),
      );
});

// ── Wallpaper category filter ─────────────────────────────────────────────────
final selectedWallpaperCategoryProvider = StateProvider<String?>((ref) => null);

final filteredWallpapersProvider =
    Provider<AsyncValue<List<WallpaperModel>>>((ref) {
  final category = ref.watch(selectedWallpaperCategoryProvider);
  return ref.watch(catalogProvider).whenData((c) {
    if (category == null) return c.wallpapers;
    return c.wallpapers.where((w) => w.category == category).toList();
  });
});

// ── Bhajan category filter ────────────────────────────────────────────────────
final selectedBhajanCategoryProvider =
    StateProvider<String?>((ref) => null);

final filteredBhajansProvider =
    Provider<AsyncValue<List<BhajanModel>>>((ref) {
  final category = ref.watch(selectedBhajanCategoryProvider);
  return ref.watch(catalogProvider).whenData((c) {
    if (category == null) return c.bhajans;
    return c.bhajans.where((b) => b.category == category).toList();
  });
});
