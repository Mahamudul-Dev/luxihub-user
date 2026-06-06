import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/service_provider_bloc.dart';
import '../widgets/service_provider_widget.dart';

class ServiceProviderListArgs {
  final String? initialQuery;
  final String? initialCategory;

  const ServiceProviderListArgs({
    this.initialQuery,
    this.initialCategory,
  });
}

class ServiceProviderListPage extends StatefulWidget {
  final String initialSearchText;

  const ServiceProviderListPage({
    super.key,
    this.initialSearchText = '',
  });

  @override
  State<ServiceProviderListPage> createState() =>
      _ServiceProviderListPageState();
}

class _ServiceProviderListPageState extends State<ServiceProviderListPage> {
  late final TextEditingController _searchController;
  final Set<String> _favouriteIds = {};

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialSearchText);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Providers'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<ServiceProviderBloc, ServiceProviderState>(
        builder: (context, state) {
          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: ValueListenableBuilder(
                  valueListenable: _searchController,
                  builder: (_, value, _) {
                    return TextField(
                      controller: _searchController,
                      onChanged: (q) => context
                          .read<ServiceProviderBloc>()
                          .add(ServiceProviderSearchChanged(q)),
                      decoration: InputDecoration(
                        hintText: 'Search by name, category or skill...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: value.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  context
                                      .read<ServiceProviderBloc>()
                                      .add(const ServiceProviderSearchChanged(''));
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 16),
                      ),
                    );
                  },
                ),
              ),

              // Category chips
              if (state is ServiceProviderLoaded)
                _CategoryChips(
                  categories: (state.allProviders.map((p) => p.category).toSet()
                        ..remove(''))
                      .toList()
                    ..sort(),
                  selectedCategory: state.selectedCategory,
                  onSelected: (cat) => context
                      .read<ServiceProviderBloc>()
                      .add(ServiceProviderCategorySelected(cat)),
                ),

              // Provider list
              Expanded(child: _buildContent(context, state)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, ServiceProviderState state) {
    if (state is ServiceProviderLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ServiceProviderError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(state.message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context
                  .read<ServiceProviderBloc>()
                  .add(const ServiceProviderFetchRequested()),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state is ServiceProviderLoaded) {
      final providers = state.filteredProviders;
      if (providers.isEmpty) {
        return const Center(child: Text('No providers found.'));
      }
      return RefreshIndicator(
        onRefresh: () async => context
            .read<ServiceProviderBloc>()
            .add(const ServiceProviderFetchRequested()),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: providers.length,
          itemBuilder: (context, index) {
            final provider = providers[index];
            final isFav = _favouriteIds.contains(provider.id);
            return ServiceProviderWidget(
              provider: provider,
              isFavourite: isFav,
              onFavouriteTap: () => setState(() => isFav
                  ? _favouriteIds.remove(provider.id)
                  : _favouriteIds.add(provider.id)),
              onTap: () => context.pushNamed(
                AppRoutes.serviceProviderProfile.name,
                pathParameters: {'id': provider.id},
                extra: provider,
              ),
            );
          },
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

class _CategoryChips extends StatelessWidget {
  final List<String> categories;
  final String? selectedCategory;
  final void Function(String?) onSelected;

  const _CategoryChips({
    required this.categories,
    required this.selectedCategory,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: const Text('All'),
              selected: selectedCategory == null,
              onSelected: (_) => onSelected(null),
              selectedColor: AppColors.primary.withValues(alpha: 0.2),
              checkmarkColor: AppColors.primary,
            ),
          ),
          ...categories.map((cat) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(cat),
                  selected: selectedCategory == cat,
                  onSelected: (_) => onSelected(cat),
                  selectedColor: AppColors.primary.withValues(alpha: 0.2),
                  checkmarkColor: AppColors.primary,
                ),
              )),
        ],
      ),
    );
  }
}
