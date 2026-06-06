import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:luxihub_user/core/theme/app_colors.dart';

import 'package:go_router/go_router.dart';

import '../../../../core/config/utils.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/widgets/category_item_widget.dart';
import '../../../../core/widgets/service_provider_profile_card_widget.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../service_providers/presentation/pages/service_provider_list_page.dart';
import '../bloc/home_bloc.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/user_profile_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchController = TextEditingController();
  bool _filterActive = false;
  final Set<String> _favouriteIds = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;

    final profileState = context.watch<ProfileBloc>().state;
    final profile = profileState is ProfileLoaded ? profileState.profile : null;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Utils.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserProfileBar(
                name: profile?.name ?? user?.email?.split('@').first ?? 'Welcome',
                subtitle: profile?.email ?? user?.email ?? user?.phone ?? '',
                avatarImageProvider: profile?.avatarPath != null
                    ? NetworkImage(profile!.avatarPath!)
                    : null,
                notificationCount: 0,
                onNotificationTap: () =>
                    context.pushNamed(AppRoutes.notifications.name),
                onAvatarTap: () {},
              ),

              const SizedBox(height: Utils.defaultPadding * 2),

              HomeSearchBar(
                controller: _searchController,
                title: 'Find the Best handyman service',
                hint: 'Search services...',
                filterActive: _filterActive,
                readOnly: true,
                onTap: () => context.pushNamed(
                  AppRoutes.serviceProviderList.name,
                ),
                onFilterTap: () =>
                    setState(() => _filterActive = !_filterActive),
                onClearTap: () {},
              ),

              const SizedBox(height: Utils.defaultPadding * 2),

              // Categories + providers driven by a single BlocBuilder
              BlocBuilder<HomeBloc, HomeState>(
                builder: (context, state) {
                  // ── Categories row ───────────────────────────────────────
                  final categoriesRow = switch (state) {
                    HomeLoading() => SizedBox(
                        height: 80.h,
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                    HomeLoaded(:final categories) when categories.isNotEmpty =>
                      SizedBox(
                        height: 80.h,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: categories
                              .map((c) => CategoryItemWidget(
                                    title: c.name,
                                    categoryImageUrl: c.imageUrl,
                                    onTap: () => context.pushNamed(
                                      AppRoutes.serviceProviderList.name,
                                      extra: ServiceProviderListArgs(
                                          initialCategory: c.name),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    _ => const SizedBox.shrink(),
                  };

                  // ── Provider grid ────────────────────────────────────────
                  final providersGrid = switch (state) {
                    HomeLoading() => const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    HomeError(:final message) => Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Text(
                            message,
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    HomeLoaded(:final providers) => GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: providers.length,
                        itemBuilder: (context, index) {
                          final provider = providers[index];
                          final isFav = _favouriteIds.contains(provider.id);
                          return ServiceProviderProfileCardWidget(
                            name: provider.fullName,
                            serviceRate: provider.formattedRate,
                            rating: provider.rating,
                            reviewCount: provider.reviewCount,
                            imageProvider:
                                NetworkImage(provider.profileImageUrl),
                            isFavourite: isFav,
                            onFavouriteTap: () => setState(() {
                              isFav
                                  ? _favouriteIds.remove(provider.id)
                                  : _favouriteIds.add(provider.id);
                            }),
                            onTap: () => context.pushNamed(
                              AppRoutes.serviceProviderProfile.name,
                              pathParameters: {'id': provider.id},
                              extra: provider,
                            ),
                          );
                        },
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                      ),
                    _ => const SizedBox.shrink(),
                  };

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      categoriesRow,
                      const SizedBox(height: Utils.defaultPadding),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recommended Providers',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                          ),
                          TextButton(
                            onPressed: () => context.pushNamed(
                              AppRoutes.serviceProviderList.name,
                            ),
                            child: Text(
                              'See All',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                      providersGrid,
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
