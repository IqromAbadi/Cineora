import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/models/favorite_movie.dart';
import '../../../routes/app_pages.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/movie_card.dart';
import '../../../shared/widgets/sliver_fill_message.dart';
import '../../../shared/widgets/sliver_movie_grid.dart';
import '../../detail/controllers/detail_arguments.dart';
import '../controllers/favorites_controller.dart';

class FavoritesView extends GetView<FavoritesController> {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final gutter = Responsive.gutter(media.size.width);
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: Obx(() {
        final favorites = controller.favorites;
        final count = favorites.length;
        return CustomScrollView(
          slivers: [
            SliverSafeArea(
              bottom: false,
              sliver: SliverPadding(
                padding: EdgeInsets.fromLTRB(gutter, 24, gutter, 20),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(
                          'Favorites',
                          style: text.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        count == 0
                            ? 'Saved titles live on this device.'
                            : '$count saved ${count == 1 ? 'title' : 'titles'}, available offline',
                        style: text.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (count == 0)
              SliverFillMessage(
                child: EmptyStateWidget(
                  icon: Icons.favorite_border_rounded,
                  title: 'Nothing saved yet',
                  message:
                      'Tap the heart on any poster to keep it here. Saved titles open even without a connection.',
                  actionLabel: 'Browse movies',
                  onAction: controller.browseMovies,
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: gutter),
                sliver: SliverMovieGrid(
                  itemCount: count,
                  itemBuilder: (context, index) =>
                      _card(context, favorites[index]),
                ),
              ),
            SliverToBoxAdapter(
              child: SizedBox(height: media.padding.bottom + 24),
            ),
          ],
        );
      }),
    );
  }

  Widget _card(BuildContext context, FavoriteMovie favorite) {
    final tag = 'favorites-${favorite.imdbId}';
    return MovieCard(
      key: ValueKey(favorite.imdbId),
      movie: favorite.movie,
      heroTag: tag,
      isFavorite: true,
      onTap: () => Get.toNamed(
        Routes.DETAIL,
        arguments: DetailArguments(movie: favorite.movie, heroTag: tag),
      ),
      onFavoritePressed: () => _remove(context, favorite),
    );
  }

  Future<void> _remove(BuildContext context, FavoriteMovie favorite) async {
    final messenger = ScaffoldMessenger.of(context);
    final removed = await controller.remove(favorite.imdbId);
    if (removed == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Removed “${removed.movie.title}” from favorites'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => controller.undoRemove(removed),
          ),
        ),
      );
  }
}
