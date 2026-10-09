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
  return ref.watch(catalogProvider).whenData((c) {
    final featured = c.wallpapers.where((w) => w.isFeatured).toList();
    // v2.0 catalog may not have isFeatured — show all wallpapers as featured
    return featured.isEmpty ? c.wallpapers : featured;
  });
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

// ── Ringtone sorting ────────────────────────────────────────────────────────
enum RingtoneSort { latest, popular }

final ringtoneSortProvider =
    StateProvider<RingtoneSort>((ref) => RingtoneSort.latest);

final sortedRingtonesProvider =
    Provider<AsyncValue<List<RingtoneModel>>>((ref) {
  final sort = ref.watch(ringtoneSortProvider);
  return ref.watch(catalogProvider).whenData((c) {
    final list = List<RingtoneModel>.from(c.ringtones);
    if (sort == RingtoneSort.popular) {
      list.sort((a, b) => a.title.compareTo(b.title));
    }
    return list;
  });
});

final ringtonesByCategoryProvider =
    Provider.family<AsyncValue<List<RingtoneModel>>, String>((ref, category) {
  return ref.watch(catalogProvider).whenData(
        (c) => c.ringtones.where((r) => r.category == category).toList(),
      );
});

// ── Wallpaper sorting ────────────────────────────────────────────────────────
enum WallpaperSort { latest, popular }

final wallpaperSortProvider =
    StateProvider<WallpaperSort>((ref) => WallpaperSort.latest);

final sortedWallpapersProvider =
    Provider<AsyncValue<List<WallpaperModel>>>((ref) {
  final sort = ref.watch(wallpaperSortProvider);
  return ref.watch(catalogProvider).whenData((c) {
    final list = List<WallpaperModel>.from(c.wallpapers);
    if (sort == WallpaperSort.popular) {
      list.sort((a, b) {
        if (a.isFeatured && !b.isFeatured) return -1;
        if (!a.isFeatured && b.isFeatured) return 1;
        return a.title.compareTo(b.title);
      });
    }
    return list;
  });
});

final selectedWallpaperCategoryProvider = StateProvider<String?>((ref) => null);

final filteredWallpapersProvider = sortedWallpapersProvider;

// ── Bhajan category filter ────────────────────────────────────────────────────
final selectedBhajanCategoryProvider =
    StateProvider<String?>((ref) => null);

final filteredBhajansProvider =
    Provider<AsyncValue<List<BhajanModel>>>((ref) {
  final category = ref.watch(selectedBhajanCategoryProvider);
  return ref.watch(catalogProvider).whenData((c) {
    if (category == null) return c.bhajans;
    final selClean =
        category.toLowerCase().replaceAll(RegExp(r'[-_\s]+'), '').trim();
    return c.bhajans.where((b) {
      final bClean =
          b.category.toLowerCase().replaceAll(RegExp(r'[-_\s]+'), '').trim();
      return bClean == selClean;
    }).toList();
  });
});
