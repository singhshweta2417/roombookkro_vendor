import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:room_book_kro_vendor/core/theme/app_colors.dart';
import 'package:room_book_kro_vendor/core/utils/context_extensions.dart';
import '../../core/constants/app_fonts.dart';
import '../../core/widgets/app_text.dart';
import '../../core/widgets/custom_scaffold.dart';
import '../../core/widgets/primary_button.dart';
import '../bookings/booking_screen.dart';
import '../home/home_screen.dart';
import '../profile/profile_Screen.dart';
import '../property/added_property_list.dart';


// =================== State ===================
class BottomNavState {
  final int currentIndex;
  BottomNavState({this.currentIndex = 0});

  BottomNavState copyWith({int? currentIndex}) {
    return BottomNavState(currentIndex: currentIndex ?? this.currentIndex);
  }
}

// =================== Notifier ===================
class BottomNavNotifier extends StateNotifier<BottomNavState> {
  BottomNavNotifier() : super(BottomNavState());
  final screens = [
    HomeScreen(),
    BookingScreen(),
    PropertyScreen(),
    ProfileScreen()
  ];
  void setIndex(int index) {
    state = state.copyWith(currentIndex: index);
  }
}

// =================== Provider ===================
final bottomNavProvider =
    StateNotifierProvider<BottomNavNotifier, BottomNavState>((ref) {
      return BottomNavNotifier();
    });

// =================== Widget ===================
class BottomNavigationPage extends ConsumerStatefulWidget {
  final String? phone;

  const BottomNavigationPage({super.key, this.phone});

  @override
  ConsumerState<BottomNavigationPage> createState() =>
      _BottomNavigationPageState();
}

class _BottomNavigationPageState extends ConsumerState<BottomNavigationPage> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bottomNavProvider);
    final notifier = ref.read(bottomNavProvider.notifier);
    final safeIndex = state.currentIndex;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;
        if (state.currentIndex != 0) {
          notifier.setIndex(0);
        } else {
          final shouldExit = await _showLogoutDialog(context, ref);
          if (shouldExit == true) {
            await HapticFeedback.vibrate();
            SystemNavigator.pop();
          }
        }
      },
      child: CustomScaffold(
        padding: EdgeInsets.zero,
        backgroundColor: AppColors.background(ref),
        bottomNavigationBar: CustomNavigationBar(
          selectedIndex: safeIndex,
          onItemSelected: (val) {
            HapticFeedback.vibrate();
            notifier.setIndex(val);
          },
          backgroundColor: AppColors.background(ref),
          selectedColor: Colors.green,
          unselectedColor: Colors.grey,
        ),
        child: notifier.screens[safeIndex],
      ),
    );
  }
}

// =================== Logout Dialog ===================

Future<bool?> _showLogoutDialog(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<bool>(
    backgroundColor: AppColors.background(ref),
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: context.sh * 0.02),
            AppText(
              text: "Want to Exit?",
              fontSize: 20,
              color: Colors.red,
              fontType: FontType.bold,
            ),
            const SizedBox(height: 15),
            AppText(
              text: "Are you sure you want to Exit?",
              fontSize: 16,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    onTap: () => Navigator.pop(context, false),
                    color: Colors.transparent,
                    border: Border.all(color: AppColors.secondary(ref)),
                    label: "Cancel",
                    textColor: AppColors.secondary(ref),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: PrimaryButton(
                    onTap: () async {
                      SystemNavigator.pop();
                    },
                    label: "Yes, Exit",
                  ),
                ),
              ],
            ),
            SizedBox(height: context.sh * 0.03),
          ],
        ),
      );
    },
  );
}

class CustomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final Color backgroundColor;
  final Color selectedColor;
  final Color unselectedColor;

  const CustomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.backgroundColor,
    required this.selectedColor,
    required this.unselectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.08;
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_outlined, Icons.home, "Home", 0),
          _buildNavItem(
            Icons.library_books_outlined,
            Icons.library_books,
            "Bookings",
            1,
          ),
          _buildNavItem(
            Icons.hotel_class_outlined,
            Icons.hotel_class,
            "Rooms",
            2,
          ),
          _buildNavItem(Icons.person_2_outlined, Icons.person, "Profile", 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    IconData selectedIcon,
    String label,
    int index,
  ) {
    final isSelected = index == selectedIndex;
    final color = isSelected ? selectedColor : unselectedColor;

    return GestureDetector(
      onTap: () {
        HapticFeedback.vibrate();
        onItemSelected(index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isSelected ? selectedIcon : icon, color: color, size: 26),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
