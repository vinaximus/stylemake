import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stylemake/core/models/style.dart';
import 'package:stylemake/core/repositories/style_repository.dart';

/// Provider for StyleRepository instance
final styleRepositoryProvider = Provider<StyleRepository>((ref) {
  return StyleRepository();
});

/// Provider for styles list
final stylesListProvider = FutureProvider<List<Style>>((ref) async {
  final repository = ref.watch(styleRepositoryProvider);
  return repository.getAllStyles();
});

/// Provider for search query
final styleSearchQueryProvider = StateProvider<String>((ref) => '');

/// Provider for filtered styles based on search query
final filteredStylesProvider = Provider<List<Style>>((ref) {
  final styles = ref.watch(stylesListProvider).value ?? [];
  final query = ref.watch(styleSearchQueryProvider).toLowerCase();

  if (query.isEmpty) {
    return styles;
  }

  return styles
      .where((style) => style.name.toLowerCase().contains(query))
      .toList();
});
