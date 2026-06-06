import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/utils.dart';
import '../../../../core/domain/entities/profile.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/text_input_field.dart';
import '../bloc/profile_bloc.dart';

class EditProfilePage extends StatefulWidget {
  final Profile profile;
  const EditProfilePage({super.key, required this.profile});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(text: widget.profile.name);
  late final _phoneController = TextEditingController(text: widget.profile.phone ?? '');
  late final _emailController = TextEditingController(text: widget.profile.email ?? '');
  late final _dobController = TextEditingController(text: widget.profile.dob ?? '');

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final updated = Profile(
      id: widget.profile.id,
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      dob: _dobController.text.trim().isEmpty ? null : _dobController.text.trim(),
      contractType: widget.profile.contractType,
      hourlyRate: widget.profile.hourlyRate,
      serviceArea: widget.profile.serviceArea,
      serviceLat: widget.profile.serviceLat,
      serviceLng: widget.profile.serviceLng,
      serviceRadiusKm: widget.profile.serviceRadiusKm,
      avatarPath: widget.profile.avatarPath,
      isOnline: widget.profile.isOnline,
      isKycVerified: widget.profile.isKycVerified,
      skills: widget.profile.skills,
    );

    context.read<ProfileBloc>().add(ProfileUpdateRequested(updated));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileUpdateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully.')),
          );
          Navigator.of(context).pop();
        } else if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message),
            backgroundColor: AppColors.error,
          ));
        }
      },
      builder: (context, state) {
        final isBusy = state is ProfileUpdating;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Edit Profile'),
            actions: [
              TextButton(
                onPressed: isBusy ? null : _submit,
                child: isBusy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(Utils.defaultPadding),
            child: Form(
              key: _formKey,
              child: Column(
                spacing: Utils.defaultPadding,
                children: [
                  TextInputField(
                    controller: _nameController,
                    label: 'Full Name',
                    textInputAction: TextInputAction.next,
                    enabled: !isBusy,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Name is required' : null,
                  ),
                  TextInputField(
                    controller: _phoneController,
                    label: 'Phone',
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    enabled: !isBusy,
                  ),
                  TextInputField(
                    controller: _emailController,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    enabled: !isBusy,
                    validator: (v) {
                      if (v != null && v.isNotEmpty && !v.contains('@')) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                  TextInputField(
                    controller: _dobController,
                    label: 'Date of Birth',
                    hint: 'YYYY-MM-DD',
                    keyboardType: TextInputType.datetime,
                    textInputAction: TextInputAction.done,
                    enabled: !isBusy,
                    onSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: Utils.defaultPadding),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isBusy ? null : _submit,
                      child: isBusy
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save Changes'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
