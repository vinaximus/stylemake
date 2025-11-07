import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stylemake/features/masters/data/models/style.dart';
import 'package:stylemake/features/masters/data/repositories/style_repository.dart';

/// Provider for StyleRepository instance
final styleRepositoryProvider = Provider<StyleRepository>((ref) {
  return StyleRepository();
});

/// Provider for styles list with real-time updates
final stylesListProvider = StreamProvider<List<Style>>((ref) {
  final repository = ref.read(styleRepositoryProvider);
  return repository.watchAllStyles();
});

/// Provider for search query
final styleSearchQueryProvider = StateProvider<String>((ref) => '');

/// Provider for filtered styles based on search query
final filteredStylesProvider = Provider<List<Style>>((ref) {
  final stylesAsync = ref.watch(stylesListProvider);
  final query = ref.watch(styleSearchQueryProvider).toLowerCase();

  return stylesAsync.when(
    data: (styles) {
      if (query.isEmpty) {
        return styles;
      }

      return styles.where((style) {
        final nameMatch = style.name.toLowerCase().contains(query);
        final designerMatch =
            style.designer?.toLowerCase().contains(query) ?? false;
        return nameMatch || designerMatch;
      }).toList();
    },
    loading: () => <Style>[],
    error: (_, __) => <Style>[],
  );
});

/// Provider for checking if style can be deleted
final canDeleteStyleProvider = FutureProvider.family<bool, String>((
  ref,
  id,
) async {
  final repository = ref.watch(styleRepositoryProvider);
  return repository.canDeleteStyle(id);
});

/// Provider for unique designers
final styleDesignersProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.watch(styleRepositoryProvider);
  return repository.getUniqueDesigners();
});
