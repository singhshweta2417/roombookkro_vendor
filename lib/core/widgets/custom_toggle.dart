import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomSlidingToggleButton extends ConsumerStatefulWidget {
  final double width;
  final double height;
  final Color activeColor;
  final Color inactiveColor;
  final Color circleColor;
  final Duration duration;
  final bool initialValue;
  final Function(bool)? onToggle;

  const CustomSlidingToggleButton({
    super.key,
    this.width = 60,
    this.height = 30,
    this.activeColor = Colors.green,
    this.inactiveColor = Colors.grey,
    this.circleColor = Colors.white,
    this.duration = const Duration(milliseconds: 200),
    this.initialValue = false,
    this.onToggle,
  });

  @override
  ConsumerState<CustomSlidingToggleButton> createState() =>
      _CustomSlidingToggleButtonState();
}

class _CustomSlidingToggleButtonState
    extends ConsumerState<CustomSlidingToggleButton> {
  late bool isToggled;

  @override
  void initState() {
    super.initState();
    isToggled = widget.initialValue;
  }

  // ✅ This ensures external changes (like themeModeProvider) update UI
  @override
  void didUpdateWidget(CustomSlidingToggleButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      setState(() {
        isToggled = widget.initialValue;
      });
    }
  }

  void _toggle() {
    setState(() => isToggled = !isToggled);
    if (widget.onToggle != null) widget.onToggle!(isToggled);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: AnimatedContainer(
        duration: widget.duration,
        width: widget.width,
        height: widget.height,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: isToggled ? widget.activeColor : widget.inactiveColor,
          borderRadius: BorderRadius.circular(widget.height / 2),
        ),
        child: Align(
          alignment:
          isToggled ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: widget.height - 6,
            height: widget.height - 6,
            decoration: BoxDecoration(
              color: widget.circleColor,
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 3,
                  offset: Offset(0, 1),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
