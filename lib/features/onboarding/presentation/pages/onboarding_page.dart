import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/config/utils.dart';
import '../bloc/onboarding_bloc.dart';
import '../widgets/onboarding_1_widget.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _animateToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OnboardingBloc(),
      child: BlocConsumer<OnboardingBloc, OnboardingState>(
        listener: (context, state) async {
          if (state is OnboardingCompleted) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('onboarding_seen', true);
            if (context.mounted) context.goNamed(AppRoutes.login.name);
          } else if (state is OnboardingProgress) {
            _animateToPage(state.currentPage);
          }
        },
        builder: (context, state) {
          final progress = state is OnboardingProgress ? state : null;
          final currentPage = progress?.currentPage ?? 0;
          final totalPages = progress?.totalPages ?? 3;
          final isLastPage = progress?.isLastPage ?? false;

          return Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(Utils.defaultPadding),
                child: Column(
                  children: [
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: (index) => context
                            .read<OnboardingBloc>()
                            .add(OnboardingPageChanged(index)),
                        children: const [
                          Onboarding1Widget(),
                          Onboarding1Widget(),
                          Onboarding1Widget(),
                        ],
                      ),
                    ),

                    // Indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        totalPages,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: index == currentPage ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: index == currentPage
                                ? AppColors.primary
                                : AppColors.primary.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Skip / Next buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => context
                              .read<OnboardingBloc>()
                              .add(const OnboardingSkipped()),
                          child: Text(
                            'Skip',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ),
                        SizedBox(
                          width: isLastPage ? 120 * 1.5 : 120,
                          child: ElevatedButton(
                            onPressed: () => context
                                .read<OnboardingBloc>()
                                .add(const OnboardingNextPressed()),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  Utils.defaultBorderRadius,
                                ),
                              ),
                            ),
                            child: Text(isLastPage ? 'Get Started' : 'Next'),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
