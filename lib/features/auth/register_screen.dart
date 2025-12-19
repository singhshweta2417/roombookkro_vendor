import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:room_book_kro_vendor/core/constants/app_fonts.dart';
import 'package:room_book_kro_vendor/core/utils/context_extensions.dart';
import 'package:room_book_kro_vendor/core/widgets/app_text.dart';
import 'package:room_book_kro_vendor/core/widgets/custom_scaffold.dart';
import 'package:room_book_kro_vendor/core/widgets/primary_button.dart';
import 'package:room_book_kro_vendor/features/auth/view_model/register_view_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/utils.dart';
import '../../core/widgets/custom_container.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../generated/assets.dart';
import '../../../core/widgets/custom_text_field/text_field_notifier.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends ConsumerState<RegisterScreen> {
  int _currentStep = 0;
  bool rememberMe = false;

  TextEditingController nameCont = TextEditingController();
  TextEditingController mailCont = TextEditingController();
  TextEditingController dobCont = TextEditingController();
  TextEditingController phoneCont = TextEditingController();
  TextEditingController aadharCont = TextEditingController();
  TextEditingController panCont = TextEditingController();

  final picker = ImagePicker();

  File? aadharFront;
  File? aadharBack;
  File? panImage;

  String? aadharFrontBase64;
  String? aadharBackBase64;
  String? panBase64;

  Future<void> pickSingleImage(String type) async {
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      File img = File(pickedFile.path);
      final bytes = await img.readAsBytes();
      final base64Str = base64Encode(bytes);

      setState(() {
        if (type == "aadharFront") {
          aadharFront = img;
          aadharFrontBase64 = base64Str;
        } else if (type == "aadharBack") {
          aadharBack = img;
          aadharBackBase64 = base64Str;
        } else if (type == "pan") {
          panImage = img;
          panBase64 = base64Str;
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
      ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final name = args?['name'] ?? '';
      final email = args?['email'] ?? '';
      final phone = args?['phone'] ?? '';
      if (name.isNotEmpty) {
        ref.read(nameFieldProvider.notifier).updateValue(name);
        nameCont.text = name;
      }
      if (email.isNotEmpty) {
        ref.read(emailFieldProvider.notifier).updateValue(email);
        mailCont.text = email;
      }
      if (phone.isNotEmpty) {
        ref.read(mobileFieldProvider.notifier).updateValue(phone);
        phoneCont.text = phone;
      }
      setState(() {
        rememberMe = phone.isNotEmpty;
      });
    });
  }

  bool _validateStep(int step) {
    switch (step) {
      case 0:
        if (nameCont.text.isEmpty ||
            mailCont.text.isEmpty ||
            dobCont.text.isEmpty ||
            phoneCont.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please fill all fields")),
          );
          return false;
        }
        final nameValid = RegExp(r'^[A-Za-z ]+$').hasMatch(nameCont.text);
        final emailValid = RegExp(
          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
        ).hasMatch(mailCont.text);
        final phoneValid = RegExp(r'^[0-9]{10}$').hasMatch(phoneCont.text);
        if (!nameValid || !emailValid || !phoneValid) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please correct the invalid fields")),
          );
          return false;
        }
        break;

      case 1:
        if (aadharCont.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please enter Aadhar Number")),
          );
          return false;
        }

        final aadharValid = RegExp(r'^[0-9]{12}$').hasMatch(aadharCont.text);
        if (!aadharValid) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Aadhar must be 12 digits")),
          );
          return false;
        }

        if (aadharFront == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please upload Aadhar Front Image")),
          );
          return false;
        }
        if (aadharBack == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please upload Aadhar Back Image")),
          );
          return false;
        }
        if (panCont.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please enter PAN Number")),
          );
          return false;
        }

        final panValid = RegExp(
          r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$',
        ).hasMatch(panCont.text.toUpperCase());
        if (!panValid) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Invalid PAN format. Example: ABCDE1234F"),
            ),
          );
          return false;
        }

        if (panImage == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please upload PAN Card Image")),
          );
          return false;
        }
        break;
    }
    return true;
  }

  void _onStepContinue() {
    if (_validateStep(_currentStep)) {
      if (_currentStep < 2) {
        setState(() {
          _currentStep++;
        });
      } else {
        _submitForm();
      }
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  Future<void> _submitForm() async {
    FocusScope.of(context).unfocus();
    if (rememberMe == false) {
      Utils.show("Please Accept Privacy Policy", context);
      return;
    }
    await ref.read(registerProvider.notifier).signUpApi(
      name: nameCont.text.trim(),
      mail: mailCont.text.trim(),
      phone: phoneCont.text.trim(),
      date: dobCont.text.trim(),
      adharNumber: aadharCont.text.trim(),
      panNumber: panCont.text.trim(),
      adharFront: aadharFrontBase64.toString(),
      adharBack: aadharBackBase64.toString(),
      panImage: panBase64.toString(),
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    final registerState = ref.watch(registerProvider);

    return CustomScaffold(
      child: ListView(
        shrinkWrap: true,
        children: [
          SizedBox(height: context.sh * 0.02),
          TCustomContainer(
            height: context.sh * 0.15,
            width: context.sh * 0.15,
            lightColor: AppColors.secondary(ref),
            shape: BoxShape.circle,
            backgroundImage: const DecorationImage(
              image: AssetImage(Assets.imagesExcitedWomen),
            ),
          ),
          SizedBox(height: context.sh * 0.01),
          AppText(
            textAlign: TextAlign.center,
            text: "Create Your Account",
            fontType: FontType.semiBold,
            fontSize: AppConstants.twenty,
          ),
          Stepper(
            currentStep: _currentStep,
            onStepContinue: _onStepContinue,
            onStepCancel: _onStepCancel,
            physics: NeverScrollableScrollPhysics(),
            connectorColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.secondary(ref);
              }
              return Colors.grey;
            }),
            stepIconBuilder: (index, state) {
              final bool isCompleted = state == StepState.complete;
              return Container(
                height: 25,
                width: 25,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.secondary(ref)
                      : Colors.grey.shade300,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCompleted ? AppColors.secondary(ref) : Colors.grey,
                    width: 1,
                  ),
                ),
                child: isCompleted
                    ? Icon(Icons.check, color: Colors.white, size: 16)
                    : Center(
                  child: AppText(
                    text: "${index + 1}",
                    fontSize: AppConstants.twelve,
                  ),
                ),
              );
            },
            controlsBuilder: (context, details) {
              final isLastStep = _currentStep == 2;
              return Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        label: isLastStep ? 'Sign Up' : 'Next',
                        isLoading: registerState.isLoading,
                        onTap: details.onStepContinue,
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    if (_currentStep > 0) SizedBox(width: 12),
                    if (_currentStep > 0)
                      OutlinedButton(
                        onPressed: details.onStepCancel,
                        child: const Text('Back'),
                      ),
                  ],
                ),
              );
            },
            steps: [
              Step(
                title: AppText(text: 'Basic Info', fontType: FontType.semiBold),
                isActive: _currentStep >= 0,
                stepStyle: StepStyle(color: AppColors.secondary(ref)),
                state: _currentStep > 0 ? StepState.complete : StepState.indexed,
                content: Column(
                  children: [
                    CustomTextField(
                      keyboardType: TextInputType.name,
                      fieldType: FieldType.name,
                      controller: nameCont,
                      hintText: "Enter Owner's Name",
                      labelFontType: FontType.regular,
                      customBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.grey, width: 1.4),
                      ),
                      fillColor: AppColors.background(ref),
                    ),
                    SizedBox(height: context.sh * 0.01),
                    CustomTextField(
                      fieldType: FieldType.email,
                      controller: mailCont,
                      hintText: "Enter Owner's Email",
                      customBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.grey, width: 1.4),
                      ),
                      labelFontType: FontType.regular,
                      keyboardType: TextInputType.emailAddress,
                      fillColor: AppColors.background(ref),
                    ),
                    SizedBox(height: context.sh * 0.01),
                    CustomTextField(
                      fieldType: FieldType.dob,
                      controller: dobCont,
                      hintText: "dd/MM/yyyy",
                      labelFontType: FontType.regular,
                      readOnly: true,
                      customBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.grey, width: 1.4),
                      ),
                      suffixIcon: InkWell(
                        onTap: () async {
                          final selectedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().subtract(
                              const Duration(days: 365 * 18),
                            ),
                            firstDate: DateTime(1980),
                            lastDate: DateTime.now(),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: ColorScheme.light(
                                    primary: Colors.green,
                                    onPrimary: Colors.white,
                                    onSurface: Colors.black,
                                    surface: Colors.white,
                                  ),
                                  textButtonTheme: TextButtonThemeData(
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.green,
                                    ),
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (selectedDate != null) {
                            final formattedDate =
                                "${selectedDate.day.toString().padLeft(2, '0')}/"
                                "${selectedDate.month.toString().padLeft(2, '0')}/"
                                "${selectedDate.year}";
                            ref.read(dobFieldProvider.notifier).updateValue(formattedDate);
                            setState(() {
                              dobCont.text = formattedDate;
                            });
                          }
                        },
                        child: Icon(
                          Icons.calendar_today_rounded,
                          color: Colors.green,
                          size: 20,
                        ),
                      ),
                      fillColor: AppColors.background(ref),
                    ),
                    SizedBox(height: context.sh * 0.01),
                    CustomTextField(
                      fieldType: FieldType.mobile,
                      keyboardType: TextInputType.phone,
                      controller: phoneCont,
                      hintText: "Enter Owner's Phone",
                      labelFontType: FontType.regular,
                      maxLength: 10,
                      readOnly: rememberMe,
                      customBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.grey, width: 1.4),
                      ),
                      fillColor: AppColors.background(ref),
                    ),
                  ],
                ),
              ),
              Step(
                title: AppText(text: "Documents", fontType: FontType.semiBold),
                isActive: _currentStep >= 1,
                stepStyle: StepStyle(color: AppColors.secondary(ref)),
                state: _currentStep > 1 ? StepState.complete : StepState.indexed,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(text: "Enter Your Aadhar*", fontType: FontType.semiBold),
                    SizedBox(height: context.sh * 0.01),
                    CustomTextField(
                      controller: aadharCont,
                      hintText: "Enter Aadhar Number",
                      maxLength: 12,
                      customBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.grey, width: 1.4),
                      ),
                      fillColor: AppColors.background(ref),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: context.sh * 0.01),
                    AppText(text: "Upload Aadhar Front*", fontType: FontType.semiBold),
                    SizedBox(height: context.sh * 0.01),
                    _imageBox(
                      width: context.sw,
                      imageFile: aadharFront,
                      assets: Assets.imagesFront,
                      onTap: () => pickSingleImage("aadharFront"),
                    ),
                    SizedBox(height: context.sh * 0.01),
                    AppText(text: "Upload Aadhar Back*", fontType: FontType.semiBold),
                    _imageBox(
                      width: context.sw,
                      imageFile: aadharBack,
                      assets: Assets.imagesBack,
                      onTap: () => pickSingleImage("aadharBack"),
                    ),
                    SizedBox(height: context.sh * 0.015),
                    AppText(text: "Your PAN Number*", fontType: FontType.semiBold),
                    SizedBox(height: context.sh * 0.01),
                    CustomTextField(
                      controller: panCont,
                      hintText: "Enter PAN Number",
                      maxLength: 10,
                      customBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.grey, width: 1.4),
                      ),
                      fillColor: AppColors.background(ref),
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.characters,
                      onChanged: (value) {
                        final upperCaseValue = value.toUpperCase();
                        if (value != upperCaseValue) {
                          panCont.value = panCont.value.copyWith(
                            text: upperCaseValue,
                            selection: TextSelection.collapsed(
                              offset: upperCaseValue.length,
                            ),
                          );
                        }
                      },
                    ),
                    SizedBox(height: context.sh * 0.01),
                    AppText(text: "Upload PAN Card*", fontType: FontType.semiBold),
                    SizedBox(height: context.sh * 0.01),
                    _imageBox(
                      width: context.sw,
                      imageFile: panImage,
                      assets: Assets.imagesPan,
                      onTap: () => pickSingleImage("pan"),
                    ),
                  ],
                ),
              ),
              Step(
                title: AppText(text: 'Privacy', fontType: FontType.semiBold),
                stepStyle: StepStyle(color: AppColors.secondary(ref)),
                isActive: _currentStep >= 2,
                state: _currentStep > 2 ? StepState.complete : StepState.indexed,
                content: InkWell(
                  onTap: () {
                    setState(() {
                      rememberMe = !rememberMe;
                    });
                  },
                  child: Row(
                    children: [
                      TCustomContainer(
                        width: context.sw * 0.05,
                        height: context.sw * 0.05,
                        border: Border.all(
                          color: AppColors.iconColor(ref),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(2),
                        lightColor: rememberMe
                            ? AppColors.secondary(ref)
                            : Colors.white,
                        child: rememberMe
                            ? Icon(
                          Icons.check,
                          size: context.sw * 0.03,
                          color: Colors.white,
                        )
                            : null,
                      ),
                      SizedBox(width: context.sw * 0.01),
                      Expanded(
                        child: AppText(
                          text: 'By continuing you accept our Privacy Policy',
                          color: AppColors.text(ref),
                          fontSize: AppConstants.twelve,
                          fontType: FontType.medium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _imageBox({
  File? imageFile,
  String? assets,
  required VoidCallback onTap,
  double? width,
}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      height: 150,
      width: width,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
        image: imageFile != null
            ? DecorationImage(image: FileImage(imageFile), fit: BoxFit.fill)
            : DecorationImage(
          image: AssetImage(assets.toString()),
          fit: BoxFit.fill,
          filterQuality: FilterQuality.low,
            colorFilter:ColorFilter.linearToSrgbGamma()
        ),
      ),
      child: imageFile == null
          ? Center(child: Icon(Icons.add_a_photo, size: 40, color: Colors.grey))
          : null,
    ),
  );
}