import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/domain/entities/service_provider_entity.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/service_provider_profile_card_widget.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../domain/usecases/get_saved_providers.dart';
import '../../domain/usecases/unsave_provider.dart';

class SavedProvidersPage extends StatefulWidget {
  const SavedProvidersPage({super.key});

  @override
  State<SavedProvidersPage> createState() => _SavedProvidersPageState();
}

class _SavedProvidersPageState extends State<SavedProvidersPage> {
  List<ServiceProviderEntity> _providers = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final providers = await sl<GetSavedProviders>()(authState.user.id);
      if (mounted) setState(() => _providers = providers);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _unsave(String providerId) async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    // Optimistic remove
    final removed = _providers.firstWhere((p) => p.id == providerId);
    setState(() => _providers.removeWhere((p) => p.id == providerId));
    try {
      await sl<UnsaveProvider>()(authState.user.id, providerId);
    } catch (_) {
      // Revert
      if (mounted) setState(() => _providers.insert(0, removed));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Text(
          'Saved Providers',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.h),
          child: Divider(height: 1.h, color: AppColors.divider),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppColors.primary,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 300,
            child: const Center(child: CircularProgressIndicator()),
          ),
        ],
      );
    }

    if (_error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 400,
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(24.r),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 48.r, color: AppColors.error),
                    SizedBox(height: 12.h),
                    Text(
                      'Something went wrong',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      _error!,
                      style: TextStyle(fontSize: 13.sp, color: AppColors.textHint),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20.h),
                    ElevatedButton(
                      onPressed: _load,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textOnPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (_providers.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 400,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.favorite_border_rounded,
                    size: 64.r,
                    color: AppColors.textHint,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'No saved providers yet',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Tap the heart on a provider card\nto save them here',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13.sp, color: AppColors.textHint),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
      ),
      itemCount: _providers.length,
      itemBuilder: (context, index) {
        final provider = _providers[index];
        return ServiceProviderProfileCardWidget(
          name: provider.fullName,
          serviceRate: provider.formattedRate,
          rating: provider.rating,
          reviewCount: provider.reviewCount,
          imageProvider: NetworkImage(provider.profileImageUrl),
          isFavourite: true,
          onFavouriteTap: () => _unsave(provider.id),
          onTap: () => context.pushNamed(
            AppRoutes.serviceProviderProfile.name,
            pathParameters: {'id': provider.id},
            extra: provider,
          ),
        );
      },
    );
  }
}
