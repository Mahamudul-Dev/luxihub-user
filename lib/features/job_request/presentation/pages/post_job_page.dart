import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/utils.dart';
import '../../../../core/domain/entities/service_provider_entity.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/text_input_field.dart';
import '../bloc/job_request_bloc.dart';

class PostJobPage extends StatefulWidget {
  final ServiceProviderEntity provider;
  const PostJobPage({super.key, required this.provider});

  @override
  State<PostJobPage> createState() => _PostJobPageState();
}

class _PostJobPageState extends State<PostJobPage> {
  final _formKey = GlobalKey<FormState>();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  void dispose() {
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<(double, double)> _getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return (0.0, 0.0);

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return (0.0, 0.0);
    }
    if (permission == LocationPermission.deniedForever) return (0.0, 0.0);

    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 8),
        ),
      );
      return (pos.latitude, pos.longitude);
    } catch (_) {
      return (0.0, 0.0);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final (lat, lng) = await _getLocation();
    if (!mounted) return;

    final priceText = _priceController.text.trim();
    final offerPrice = priceText.isNotEmpty ? double.tryParse(priceText) : null;

    context.read<JobRequestBloc>().add(JobPostRequested(
          providerId: widget.provider.id,
          category: widget.provider.category,
          description: _descController.text.trim(),
          clientLat: lat,
          clientLng: lng,
          offerPrice: offerPrice,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<JobRequestBloc, JobRequestState>(
      listener: (context, state) {
        if (state is JobRequestPosted) {
          context.goNamed(AppRoutes.jobRequestDetails.name, extra: state.job);
        } else if (state is JobRequestError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Book Service')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(Utils.defaultPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Utils.defaultPadding,
              children: [
                // Provider summary card
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage:
                        NetworkImage(widget.provider.profileImageUrl),
                    onBackgroundImageError: (_, _) {},
                  ),
                  title: Text(
                    widget.provider.fullName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Text(
                    '${widget.provider.category}  •  ${widget.provider.formattedRate}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(Utils.defaultBorderRadius),
                  ),
                  tileColor: AppColors.divider,
                ),

                Text(
                  'Describe your job',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),

                TextInputField(
                  controller: _descController,
                  label: 'Job Description',
                  hint: 'e.g. Fix leaking pipe under the kitchen sink...',
                  maxLines: 5,
                  textInputAction: TextInputAction.next,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Please describe the job'
                      : null,
                ),

                Text(
                  'Your Offer Price (optional)',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),

                TextInputField(
                  controller: _priceController,
                  label: 'Offer Price',
                  hint: 'e.g. 50',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.done,
                  prefixText: '£',
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return null; // optional
                    final parsed = double.tryParse(v.trim());
                    if (parsed == null || parsed <= 0) {
                      return 'Enter a valid price';
                    }
                    return null;
                  },
                ),

                // Provider rate hint
                Text(
                  'Provider charges ${widget.provider.formattedRate}. '
                  'Leave blank to accept the listed rate.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),

                BlocBuilder<JobRequestBloc, JobRequestState>(
                  builder: (context, state) {
                    final isBusy = state is JobRequestPosting;
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isBusy ? null : _submit,
                        child: isBusy
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Confirm Booking'),
                      ),
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
