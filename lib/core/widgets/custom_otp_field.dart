// ================= OTP Field Widget =================
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class OtpTextField extends ConsumerStatefulWidget {
  final StateNotifierProvider<FieldNotifier, FieldState> provider;
  final double boxSize;
  final double spacing;
  final bool autoFocus;

  const OtpTextField({
    super.key,
    required this.provider,
    this.boxSize = 55,
    this.spacing = 12,
    this.autoFocus = true,
  });

  @override
  ConsumerState<OtpTextField> createState() => _OtpTextFieldState();
}

class _OtpTextFieldState extends ConsumerState<OtpTextField> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(4, (_) => TextEditingController());
    _focusNodes = List.generate(4, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onChanged(int index, String value) {
    if (value.length > 1) {
      // Keep only the last digit if pasted multiple digits
      value = value.characters.last;
      _controllers[index].text = value;
      _controllers[index].selection =
          TextSelection.fromPosition(TextPosition(offset: 1));
    }

    if (value.isNotEmpty && index < 3) {
      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
    } else if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }

    // Combine all digits into one string
    final otpValue = _controllers.map((e) => e.text).join();

    // Update Riverpod state
    ref.read(widget.provider.notifier).updateValue(otpValue);

    // Dismiss keyboard automatically when 4 digits entered
    if (otpValue.length == 4) {
      _focusNodes[index].unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(widget.provider);
    final notifier = ref.read(widget.provider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (index) {
            return Container(
              width: widget.boxSize,
              height: widget.boxSize,
              margin: EdgeInsets.symmetric(horizontal: widget.spacing / 2),
              child: TextField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                autofocus: widget.autoFocus && index == 0,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                onChanged: (val) => _onChanged(index, val),
                decoration: InputDecoration(
                  counterText: "",
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.blue.shade400, width: 1.5),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            );
          }),
        ),
        if (state.error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Center(
              child: Text(
                state.error!,
                style: const TextStyle(color: Colors.red, fontSize: 13),
              ),
            ),
          ),
      ],
    );
  }
}
// fields.dart

// ------------------ FieldState & FieldNotifier ------------------
class FieldState {
  final String value;
  final String? error;

  FieldState({this.value = "", this.error});

  FieldState copyWith({String? value, String? error}) {
    return FieldState(
      value: value ?? this.value,
      error: error,
    );
  }
}

class FieldNotifier extends StateNotifier<FieldState> {
  final int status;
  final Ref? ref;

  FieldNotifier({required this.status, this.ref}) : super(FieldState());

  void updateValue(String val) {
    String? error;

    switch (status) {
      case 12: // OTP
        if (val.isEmpty) {
          error = "OTP is required";
        } else if (!RegExp(r'^[0-9]+$').hasMatch(val)) {
          error = "Only digits allowed";
        } else if (val.length != 4) {
          error = "OTP must be 4 digits";
        }
        break;

    // ... baaki status cases jaise 1=name, 2=mobile etc
    }

    state = state.copyWith(value: val, error: error);
  }

  void reset() {
    state = FieldState();
  }
}

// ------------------ OTP Provider ------------------
final otpFieldProvider =
StateNotifierProvider<FieldNotifier, FieldState>((ref) {
  return FieldNotifier(status: 12, ref: ref);
});
