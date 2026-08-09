import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/config/utils.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../bloc/profile_bloc.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<ProfileBloc>().add(ProfileFetchRequested(authState.user.id));
    }
  }

  Future<void> _pickAvatar() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null || !mounted) return;

    context.read<ProfileBloc>().add(ProfileAvatarUploadRequested(
          uid: authState.user.id,
          file: File(picked.path),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              if (state is! ProfileLoaded) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () async {
                  await context.pushNamed(
                    AppRoutes.editProfile.name,
                    extra: state.profile,
                  );
                  if (context.mounted) {
                    final authState = context.read<AuthBloc>().state;
                    if (authState is AuthAuthenticated) {
                      context
                          .read<ProfileBloc>()
                          .add(ProfileFetchRequested(authState.user.id));
                    }
                  }
                },
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ));
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProfileError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      final authState = context.read<AuthBloc>().state;
                      if (authState is AuthAuthenticated) {
                        context.read<ProfileBloc>().add(
                              ProfileFetchRequested(authState.user.id),
                            );
                      }
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is! ProfileLoaded) return const SizedBox.shrink();

          final profile = state.profile;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(Utils.defaultPadding),
            child: Column(
              children: [
                // Avatar
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 52,
                      backgroundColor: AppColors.divider,
                      backgroundImage: profile.avatarPath != null
                          ? NetworkImage(profile.avatarPath!)
                          : null,
                      child: profile.avatarPath == null
                          ? const Icon(Icons.person, size: 52, color: AppColors.textSecondary)
                          : null,
                    ),
                    GestureDetector(
                      onTap: _pickAvatar,
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                        padding: const EdgeInsets.all(6),
                        child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: Utils.defaultPadding),

                Text(
                  profile.name.isNotEmpty ? profile.name : 'No name set',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),

                if (profile.isKycVerified) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified, size: 16, color: Colors.green),
                      const SizedBox(width: 4),
                      Text('Verified',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.green)),
                    ],
                  ),
                ],

                const SizedBox(height: Utils.defaultPadding * 1.5),
                const Divider(),

                _InfoTile(icon: Icons.email_outlined, label: 'Email', value: profile.email),
                _InfoTile(icon: Icons.phone_outlined, label: 'Phone', value: profile.phone),
                _InfoTile(icon: Icons.cake_outlined, label: 'Date of Birth', value: profile.dob),

                const Divider(),
                ListTile(
                  leading: const Icon(Icons.receipt_long_outlined, color: AppColors.primary),
                  title: const Text('Transaction History'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(AppRoutes.transactions.path),
                ),

                const SizedBox(height: Utils.defaultPadding * 2),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.read<AuthBloc>().add(const AuthSignOutRequested());
                    },
                    icon: const Icon(Icons.logout, color: AppColors.error),
                    label: const Text('Sign Out',
                        style: TextStyle(color: AppColors.error)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.error),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;

  const _InfoTile({required this.icon, required this.label, this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: AppColors.textSecondary)),
      subtitle: Text(
        value?.isNotEmpty == true ? value! : '—',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}
