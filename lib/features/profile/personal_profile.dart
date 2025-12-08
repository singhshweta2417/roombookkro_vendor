import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:image_picker/image_picker.dart';
import 'package:room_book_kro_vendor/core/utils/context_extensions.dart';
import 'package:room_book_kro_vendor/features/profile/view_model/profile_view_model.dart';
import '../../core/constants/app_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_text.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/custom_scaffold.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/custom_text_field/text_field_notifier.dart';
import '../../core/widgets/primary_button.dart';
import '../../generated/assets.dart';

class PersonalProfileScreen extends ConsumerStatefulWidget {
  const PersonalProfileScreen({super.key});

  @override
  ConsumerState<PersonalProfileScreen> createState() =>
      _PersonalProfileScreenState();
}

class _PersonalProfileScreenState extends ConsumerState<PersonalProfileScreen> {
  final userImageBase64Provider = StateProvider<String?>((ref) => null);
  final pickedImageProvider = StateProvider<File?>((ref) => null);
  String? localName;
  String? localEmail;
  Future<void> _pickImage(WidgetRef ref) async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        requestFullMetadata: false,
        imageQuality: 80,
        maxWidth: 800,
      );

      if (image != null) {
        final file = File(image.path);
        final bytes = await file.readAsBytes();

        // Validate image size
        if (bytes.length > 10 * 1024 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Image too large. Please select a smaller one.'),
              ),
            );
          }
          return;
        }

        final base64String = base64Encode(bytes);

        ref.read(pickedImageProvider.notifier).state = file;
        ref.read(userImageBase64Provider.notifier).state = base64String;
      }
    } catch (e) {
      debugPrint('❌ Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to pick image')));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(updateProvider.notifier).profileViewApi(context);
      final authState = ref.read(updateProvider);

      if (authState is ProfileSuccess) {
        final profile = authState.profile;
        if (profile != null) {
          nameCont.text = profile.username ?? '';
          mailCont.text = profile.email ?? '';
          phoneCont.text = profile.contact ?? '';
          genderCont.text = profile.gender ?? '';
          dobCont.text = profile.dOB ?? '';
        }
      }
    });
  }

  TextEditingController nameCont = TextEditingController();
  TextEditingController mailCont = TextEditingController();
  TextEditingController dobCont = TextEditingController();
  TextEditingController phoneCont = TextEditingController();
  TextEditingController genderCont = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(updateProvider);
    final pickedImage = ref.watch(pickedImageProvider);
    final profile = (authState is ProfileSuccess) ? authState.profile : null;
    return CustomScaffold(
      appBar: CustomAppBar(
        middle: AppText(
          text: "Personal Profile",
          fontType: FontType.bold,
          fontSize: AppConstants.twentyFive,
        ),
      ),
      child: ListView(
        shrinkWrap: true,
        children: [
          SizedBox(height: context.sh * 0.05),
          Column(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: pickedImage != null
                        ? FileImage(pickedImage)
                        : profile?.userImage == null
                        ? const AssetImage(
                            Assets.iconMoreVertIcon,
                          ) // Default asset
                        : CachedNetworkImageProvider(
                            profile!.userImage.toString(),
                          ), // Network image
                  ),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: InkWell(
                      onTap: () => _pickImage(ref),
                      child: const CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.green,
                        child: Icon(Icons.edit, size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AppText(
                text: localName ?? profile?.username ?? "No Name",
                fontSize: 18,
                fontType: FontType.bold,
              ),
              AppText(
                text: localEmail ?? profile?.email ?? "No Email",
                color: Colors.grey,
              ),
              const SizedBox(height: 20),
            ],
          ),
          SizedBox(height: context.sh * 0.03),

          /// Name
          CustomTextField(
            fieldType: FieldType.name,
            controller: nameCont,
            hintText: "Enter your Name",
            labelTextColor: AppColors.iconColor(ref),
            labelFontType: FontType.regular,
          ),
          SizedBox(height: context.sh * 0.015),

          /// Email
          CustomTextField(
            fieldType: FieldType.email,
            controller: mailCont,
            hintText: "Enter your Email",
            labelTextColor: AppColors.iconColor(ref),
            labelFontType: FontType.regular,
          ),
          SizedBox(height: context.sh * 0.015),

          /// DOB
          CustomTextField(
            fieldType: FieldType.dob,
            controller: dobCont,
            hintText: "dd/MM/yyyy",
            labelTextColor: AppColors.iconColor(ref),
            labelFontType: FontType.regular,
            // provider: dobFieldProvider,
            readOnly: true,
            suffixIcon: InkWell(
              onTap: () async {
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().subtract(
                    const Duration(days: 365 * 18),
                  ),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );

                if (selectedDate != null) {
                  final formattedDate =
                      "${selectedDate.day.toString().padLeft(2, '0')}/"
                      "${selectedDate.month.toString().padLeft(2, '0')}/"
                      "${selectedDate.year}";
                  dobCont.text = formattedDate;
                  ref
                      .read(dobFieldProvider.notifier)
                      .updateValue(formattedDate);
                }
              },
              child: Icon(
                Icons.calendar_today,
                color: AppColors.iconColor(ref),
              ),
            ),
          ),
          SizedBox(height: context.sh * 0.015),

          /// Phone
          CustomTextField(
            fieldType: FieldType.mobile,
            controller: phoneCont,
            maxLength: 10,
            hintText: "Enter your Phone",
            labelTextColor: AppColors.iconColor(ref),
            labelFontType: FontType.regular,
            keyboardType: TextInputType.phone,
          ),
          SizedBox(height: context.sh * 0.015),

          /// Gender
          CustomTextField(
            fieldType: FieldType.dropdown,
            controller: genderCont,
            hintText: "Gender",
            readOnly: true,
            onTap: () async {
              await showDropdownPopup(
                context,
                ref,
                genderDropdownProvider,
                genderList,
                'Select Gender',
              );

              final selected = ref.read(genderDropdownProvider).value;
              if (selected.isNotEmpty) {
                setState(() {
                  genderCont.text = selected;
                });
              }
            },
            suffixIcon: const Icon(Icons.arrow_drop_down),
          ),
          SizedBox(height: context.sh * 0.05),

          /// Update Button
          PrimaryButton(
            isLoading: authState.isLoading,
            onTap: () async {
              try {
                final base64Image = ref.read(userImageBase64Provider);
                final state = ref.read(updateProvider);
                final profile = (state is ProfileSuccess)
                    ? state.profile
                    : null;

                String? imageToSend;

                // Handle image logic more carefully
                if (base64Image != null && base64Image.isNotEmpty) {
                  // New image selected
                  imageToSend = "data:image/png;base64,$base64Image";
                } else if (profile?.userImage != null &&
                    profile!.userImage!.isNotEmpty &&
                    profile.userImage!.toLowerCase() != 'null') {
                  // Keep existing image from server
                  imageToSend = profile.userImage;
                } else {
                  // No image available
                  imageToSend = null;
                }

                // Update local state
                setState(() {
                  localName = nameCont.text.trim();
                  localEmail = mailCont.text.trim();
                });

                // Call update API
                await ref
                    .read(updateProvider.notifier)
                    .profileUpdateApi(
                      name: nameCont.text.trim(),
                      mail: mailCont.text.trim(),
                      contact: phoneCont.text.trim(),
                      dob: dobCont.text.toString(),
                      userImage: imageToSend, // Can be null
                      gender: genderCont.text.trim(),
                      walletBalance: "",
                      context: context,
                    );
              } catch (e) {
                print('Update error: $e');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update profile')),
                  );
                }
              }
            },
            width: context.sw,
            borderRadius: BorderRadius.circular(30),
            label: "Update",
          ),
          SizedBox(height: context.sh * 0.01),
        ],
      ),
    );
  }
}
