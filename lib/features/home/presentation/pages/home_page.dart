import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:luxihub_user/core/theme/app_colors.dart';

import 'package:go_router/go_router.dart';

import '../../../../core/config/utils.dart';
import '../../../../core/dummy/dummy.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/widgets/category_item_widget.dart';
import '../../../../core/widgets/service_provider_profile_card_widget.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
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

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Utils.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserProfileBar(
                name: user != null && user.firstName.isNotEmpty
                    ? user.fullName
                    : 'User Name',
                subtitle: user?.email ?? 'example@email.com',
                notificationCount: 3,
                onNotificationTap: () {},
                onAvatarTap: () {},
              ),

              const SizedBox(height: Utils.defaultPadding * 2),

              HomeSearchBar(
                controller: _searchController,
                title: 'Find the Best handyman service',
                hint: 'Search services...',
                filterActive: _filterActive,
                onChanged: (query) {},
                onFilterTap: () =>
                    setState(() => _filterActive = !_filterActive),
                onClearTap: () {},
              ),

              const SizedBox(height: Utils.defaultPadding * 2),

              // Categories
              SizedBox(
                height: 80.h,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: Dummy.categories
                      .map((c) => CategoryItemWidget(
                            title: c.name,
                            categoryImageUrl: c.imageUrl,
                          ))
                      .toList(),
                ),
              ),

              const SizedBox(height: Utils.defaultPadding),

              // title + see all
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recommended Providers',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text('See All', style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary
                    ),),
                  ),
                ],
              ),

              // Recommended providers
              BlocBuilder<HomeBloc, HomeState>(
                builder: (context, state) {
                  if (state is HomeLoading) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (state is HomeError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Text(
                          state.message,
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  if (state is HomeLoaded) {
                    return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: state.providers.length,
                      itemBuilder: (context, index) {
                        final provider = state.providers[index];
                        final isFav = _favouriteIds.contains(provider.id);
                        return ServiceProviderProfileCardWidget(
                          name: provider.fullName,
                          serviceRate: provider.formattedRate,
                          rating: provider.rating,
                          reviewCount: provider.reviewCount,
                          imageProvider: NetworkImage(provider.profileImageUrl),
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
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
