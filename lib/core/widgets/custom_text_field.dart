import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../constants/app_fonts.dart';
import '../theme/app_colors.dart';
import 'app_text.dart';
import 'custom_text_field/text_field_notifier.dart';

// ================= Custom TextField =================
class CustomTextField extends ConsumerStatefulWidget {
  final String? labelText;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextCapitalization? textCapitalization;
  final FontType? labelFontType;
  final bool obscureText;
  final double? labelFontSize;
  final bool readOnly;
  final bool enabled;
  final Color? fillColor;
  final Color? labelTextColor;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Function(String)? onChanged;
  final Function()? onTap;
  final int? maxLength;
  final int? maxLines;
  final int? minLines;
  final EdgeInsetsGeometry? contentPadding;
  final InputBorder? customBorder;
  final BorderRadius? borderRadius;
  final StateNotifierProvider<FieldNotifier, FieldState>? provider;
  final TextEditingController? controller;
  final List<String>? suggestions;
  final Function(String)? onSuggestionSelected;
  final FieldType? fieldType;

  const CustomTextField({
    super.key,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.textCapitalization,
    this.suffixIcon,
    this.labelFontType,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.fillColor,
    this.labelFontSize,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onTap,
    this.maxLength,
    this.labelTextColor,
    this.maxLines,
    this.minLines,
    this.contentPadding,
    this.customBorder,
    this.borderRadius,
    this.provider,
    this.controller,
    this.suggestions,
    this.onSuggestionSelected,
    this.fieldType,
  });

  @override
  ConsumerState<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends ConsumerState<CustomTextField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  String? _inlineError;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = FocusNode();

    if (widget.provider != null && widget.controller == null) {
      _controller.addListener(() {
        final notifier = ref.read(widget.provider!.notifier);
        if (_controller.text != ref.read(widget.provider!).value) {
          notifier.updateValue(_controller.text);
        }
      });
    }

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) _removeOverlay();
    });
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showSuggestionsOverlay(BuildContext context, List<String> suggestions) {
    _removeOverlay();
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          offset: Offset(0, size.height + 5),
          child: Material(
            elevation: 4,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: suggestions.length,
                itemBuilder: (context, i) => ListTile(
                  title: Text(suggestions[i]),
                  onTap: () {
                    _controller.text = suggestions[i];
                    _controller.selection = TextSelection.fromPosition(
                      TextPosition(offset: suggestions[i].length),
                    );
                    widget.onSuggestionSelected?.call(suggestions[i]);
                    _removeOverlay();
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  String? _getErrorByType(FieldType type, String val) {
    switch (type) {
      case FieldType.name:
        if (val.isEmpty) return "Name is required";
        if (!RegExp(r'^[A-Za-z ]+$').hasMatch(val)) {
          return "Name should contain only letters";
        }
        return null;
      case FieldType.mobile:
        if (val.isEmpty) return "Mobile number is required";
        if (!RegExp(r'^[0-9]+$').hasMatch(val)) return "Only digits allowed";
        if (val.length != 10) return "Must be 10 digits";
        return null;
      case FieldType.email:
        if (val.isEmpty) return "Email is required";
        if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
            .hasMatch(val)) {
          return "Invalid email format";
        }
        return null;

      case FieldType.password:
        if (val.isEmpty) return "Password required";
        if (!RegExp(
            r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>]).{8,}$')
            .hasMatch(val)) {
          return "Weak password";
        }
        return null;
      case FieldType.username:
        if (val.isEmpty) return "Username required";
        if (val.length < 2) return "Too short";
        if (val.length > 30) return "Too long";
        if (!RegExp(r'^[a-zA-Z0-9._]+$').hasMatch(val)) {
          return "Only letters, numbers, . and _ allowed";
        }
        return null;
      case FieldType.dob:
        if (val.isEmpty) return "Date of Birth required";
        final regex = RegExp(r'^\d{2}/\d{2}/\d{4}$');
        if (!regex.hasMatch(val)) return "Format must be dd/MM/yyyy";

        try {
          final parts = val.split('/');
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final year = int.parse(parts[2]);
          final dob = DateTime(year, month, day);
          if (dob.year != year || dob.month != month || dob.day != day) {
            return "Invalid date";
          }

          final now = DateTime.now();
          if (dob.isAfter(now)) return "DOB cannot be in future";

          int age = now.year - dob.year;
          if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
            age -= 1;
          }

          if (age < 18) return "Must be at least 18 years old";
          if (age > 100) return "Invalid age";

          return null;
        } catch (_) {
          return "Invalid date";
        }

      case FieldType.dropdown:
        return val.isEmpty ? "Please make a selection" : null;
      case FieldType.occupation:
        if (val.isEmpty) return "Occupation is required";
        if (!RegExp(r'^[A-Za-z\s\-&]+$').hasMatch(val)) {
          return "Only letters, spaces, hyphens, and & allowed";
        }
        return null;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.provider != null
        ? ref.watch(widget.provider!)
        : FieldState();

    final baseStyle =
    ref.watch(fontProvider)[widget.labelFontType ?? FontType.regular]!;

    final borderRadius = widget.borderRadius ?? BorderRadius.circular(8);
    final baseBorder = OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: const BorderSide(color: Colors.transparent, width: 1.0),
    );
    final errorBorder = OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: const BorderSide(color: Colors.red, width: 1.5),
    );

    return CompositedTransformTarget(
      link: _layerLink,
      child: TextFormField(
        cursorColor: AppColors.secondary(ref),
        controller: _controller,
        focusNode: _focusNode,
        obscureText: widget.obscureText,
        readOnly: widget.readOnly,
        enabled: widget.enabled,
        maxLength: widget.maxLength,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        onTap: widget.onTap,
        onChanged: (val) {
          widget.onChanged?.call(val);

          if (widget.provider != null) {
            ref.read(widget.provider!.notifier).updateValue(val);
          } else if (widget.fieldType != null) {
            setState(() => _inlineError = _getErrorByType(widget.fieldType!, val));
          }

          if (widget.suggestions != null && val.isNotEmpty) {
            final filtered = widget.suggestions!
                .where((s) => s.toLowerCase().contains(val.toLowerCase()))
                .toList();
            if (filtered.isNotEmpty) {
              _showSuggestionsOverlay(context, filtered);
            } else {
              _removeOverlay();
            }
          } else {
            _removeOverlay();
          }
        },
        decoration: InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,
          labelStyle: baseStyle.copyWith(
            fontSize: widget.labelFontSize ?? 16,
            color: widget.labelTextColor ?? Colors.black,
          ),
          hintStyle: baseStyle.copyWith(
            fontSize: widget.labelFontSize ?? 16,
            color: widget.labelTextColor ?? Colors.black54,
          ),
          prefixIcon: widget.prefixIcon,
          suffixIcon: widget.suffixIcon,
          errorText: widget.provider != null ? state.error : _inlineError,
          counterText: "",
          filled: true,
          fillColor: widget.fillColor ?? AppColors.textFieldBg(ref),
          contentPadding: widget.contentPadding ??
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          border: widget.customBorder ?? baseBorder,
          enabledBorder: widget.customBorder ?? baseBorder,
          focusedBorder: widget.customBorder ?? baseBorder,
          errorBorder: widget.customBorder ?? errorBorder,
          focusedErrorBorder: widget.customBorder ?? errorBorder,
        ),
        textCapitalization: widget.textCapitalization ?? TextCapitalization.none,
      ),
    );
  }
}



// ================= Generic Helper Functions for Popups =================
Future<void> showDropdownPopup(
    BuildContext context,
    WidgetRef ref,
    StateNotifierProvider<FieldNotifier, FieldState> provider,
    List<String> items,
    String title,
    ) async {
  final notifier = ref.read(provider.notifier);

  await showModalBottomSheet(
    backgroundColor: AppColors.background(ref),
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText(text:
              title,
            fontSize: 18, fontType: FontType.bold),

            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: AppText(text: items[index]),
                    onTap: () {
                      notifier.updateValue(items[index]);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}


// ================= Predefined Lists =================
final List<String> genderList = [
  'Male',
  'Female',
  'Other',
  'Prefer not to say',
];

final List<String> countryList = [
  'USA',
  'India',
  'UK',
  'Canada',
  'Australia',
  'Germany',
  'France',
];
