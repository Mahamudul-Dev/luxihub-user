import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/category_item_widget.dart';
import '../../../../core/widgets/service_provider_profile_card_widget.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../saved_providers/domain/usecases/get_saved_provider_ids.dart';
import '../../../saved_providers/domain/usecases/save_provider.dart';
import '../../../saved_providers/domain/usecases/unsave_provider.dart';
import '../../../service_providers/presentation/pages/service_provider_list_page.dart';
import '../bloc/home_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Set<String> _favouriteIds = {};

  @override
  void initState() {
    super.initState();
    _loadSavedIds();
  }

  Future<void> _refresh() async {
    context.read<HomeBloc>().add(const HomeProvidersRequested());
    await _loadSavedIds();
  }

  Future<void> _loadSavedIds() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    try {
      final ids = await sl<GetSavedProviderIds>()(authState.user.id);
      if (mounted) setState(() => _favouriteIds = ids);
    } catch (_) {}
  }

  Future<void> _toggleSave(String providerId, bool isSaved) async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    final uid = authState.user.id;
    // Optimistic update
    setState(() {
      isSaved ? _favouriteIds.remove(providerId) : _favouriteIds.add(providerId);
    });
    try {
      if (isSaved) {
        await sl<UnsaveProvider>()(uid, providerId);
      } else {
        await sl<SaveProvider>()(uid, providerId);
      }
    } catch (_) {
      // Revert on failure
      if (mounted) {
        setState(() {
          isSaved ? _favouriteIds.add(providerId) : _favouriteIds.remove(providerId);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;
    final profileState = context.watch<ProfileBloc>().state;
    final profile = profileState is ProfileLoaded ? profileState.profile : null;

    final rawName =
        profile?.name ?? user?.email?.split('@').first ?? 'there';
    final firstName = rawName.split(' ').first;
    final avatarPath = profile?.avatarPath;

    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Green gradient header ────────────────────────────────────
              _HomeHeader(
                firstName: firstName,
                avatarPath: avatarPath,
                onNotificationTap: () =>
                    context.pushNamed(AppRoutes.notifications.name),
                onSearchTap: () =>
                    context.pushNamed(AppRoutes.serviceProviderList.name),
              ),
        
              SizedBox(height: 20.h),
        
              // ── Categories + Providers ───────────────────────────────────
              BlocBuilder<HomeBloc, HomeState>(
                builder: (context, state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Categories section
                      _SectionLabel(title: 'Browse Categories'),
                      SizedBox(height: 12.h),
                      _CategoriesRow(state: state),
                      SizedBox(height: 24.h),
        
                      // Providers section
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recommended Providers',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => context.pushNamed(
                                  AppRoutes.serviceProviderList.name),
                              child: Text(
                                'See all',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 14.h),
                      _ProvidersGrid(
                        state: state,
                        favouriteIds: _favouriteIds,
                        onFavTap: (id, isFav) => _toggleSave(id, isFav),
                        onProviderTap: (provider) => context.pushNamed(
                          AppRoutes.serviceProviderProfile.name,
                          pathParameters: {'id': provider.id},
                          extra: provider,
                        ),
                      ),
                      SizedBox(height: 32.h),
                    ],
                  );
                },
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.firstName,
    required this.avatarPath,
    required this.onNotificationTap,
    required this.onSearchTap,
  });

  final String firstName;
  final String? avatarPath;
  final VoidCallback onNotificationTap;
  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 16.w, 28.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile row
              Row(
                children: [
                  CircleAvatar(
                    radius: 22.r,
                    backgroundColor:
                        AppColors.textOnPrimary.withValues(alpha: 0.2),
                    backgroundImage: avatarPath?.isNotEmpty == true
                        ? NetworkImage(avatarPath!)
                        : null,
                    child: avatarPath?.isNotEmpty != true
                        ? Icon(
                            Icons.person_rounded,
                            color: AppColors.textOnPrimary,
                            size: 22.r,
                          )
                        : null,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, $firstName 👋',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textOnPrimary,
                          ),
                        ),
                        Text(
                          'What service do you need today?',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textOnPrimary.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Notification bell
                  GestureDetector(
                    onTap: onNotificationTap,
                    child: Container(
                      width: 42.r,
                      height: 42.r,
                      decoration: BoxDecoration(
                        color: AppColors.textOnPrimary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.notifications_outlined,
                        color: AppColors.textOnPrimary,
                        size: 22.r,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20.h),

              // Search bar
              GestureDetector(
                onTap: onSearchTap,
                child: Container(
                  height: 48.h,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(14.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search_rounded,
                          color: AppColors.primary, size: 20.r),
                      SizedBox(width: 10.w),
                      Text(
                        'Search services, providers...',
                        style: TextStyle(
                            fontSize: 14.sp, color: AppColors.textHint),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

// ── Categories row ────────────────────────────────────────────────────────────

class _CategoriesRow extends StatelessWidget {
  const _CategoriesRow({required this.state});
  final HomeState state;

  @override
  Widget build(BuildContext context) {
    if (state is HomeLoading) {
      return SizedBox(
        height: 90.h,
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    if (state is! HomeLoaded) return const SizedBox.shrink();
    final categories = (state as HomeLoaded).categories;
    if (categories.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 90.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        itemCount: categories.length,
        separatorBuilder: (_, _) => SizedBox(width: 12.w),
        itemBuilder: (context, index) {
          final c = categories[index];
          return CategoryItemWidget(
            title: c.name,
            categoryImageUrl: c.imageUrl,
            onTap: () => context.pushNamed(
              AppRoutes.serviceProviderList.name,
              extra: ServiceProviderListArgs(initialCategory: c.name),
            ),
          );
        },
      ),
    );
  }
}

// ── Providers grid ────────────────────────────────────────────────────────────

class _ProvidersGrid extends StatelessWidget {
  const _ProvidersGrid({
    required this.state,
    required this.favouriteIds,
    required this.onFavTap,
    required this.onProviderTap,
  });

  final HomeState state;
  final Set<String> favouriteIds;
  final void Function(String id, bool isFav) onFavTap;
  final void Function(dynamic provider) onProviderTap;

  @override
  Widget build(BuildContext context) {
    if (state is HomeLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (state is HomeError) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 32, horizontal: 20.w),
        child: Center(
          child: Text(
            (state as HomeError).message,
            style: TextStyle(fontSize: 14.sp, color: AppColors.textHint),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    if (state is! HomeLoaded) return const SizedBox.shrink();
    final providers = (state as HomeLoaded).providers;
    if (providers.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.72,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
        ),
        itemCount: providers.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final provider = providers[index];
          final isFav = favouriteIds.contains(provider.id);
          return ServiceProviderProfileCardWidget(
            name: provider.fullName,
            serviceRate: provider.formattedRate,
            rating: provider.rating,
            reviewCount: provider.reviewCount,
            imageProvider: NetworkImage(provider.profileImageUrl),
            isFavourite: isFav,
            onFavouriteTap: () => onFavTap(provider.id, isFav),
            onTap: () => onProviderTap(provider),
          );
        },
      ),
    );
  }
}
