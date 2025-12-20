import 'package:flutter/material.dart';
import 'package:room_book_kro_vendor/features/home/bank/add_bank_screen.dart';
import 'package:room_book_kro_vendor/features/home/bank/bank_list_screen.dart';
import 'package:room_book_kro_vendor/features/home/bank/edit_bank_screen.dart';
import 'package:room_book_kro_vendor/features/home/wallet_screen/ticket_screen.dart';
import 'package:room_book_kro_vendor/features/home/wallet_screen/withdraw_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/otp_view.dart';
import '../../features/auth/register_screen.dart';
import '../../features/bookings/booking_details.dart';
import '../../features/bottom/bottom_screen.dart';
import '../../features/home/wallet_screen/walllet_screen.dart';
import '../../features/map/map_screen_view.dart';
import '../../features/no_internet_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/profile/notification_screen.dart';
import '../../features/profile/personal_profile.dart';
import '../../features/property/edit_property_room/edit_property_room1.dart';
import '../../features/property/edit_property_room/edit_property_room2.dart';
import '../../features/property/edit_property_room/edit_room_property.dart';
import '../../features/property/offer_screen.dart';
import '../../features/property/property_details.dart';
import '../../features/property/property_room/add_property_room1.dart';
import '../../features/property/property_room/add_property_room2.dart';
import '../../features/property/property_room/add_room_property.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../routes/app_routes.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    // ---------- Splash / Auth ----------
    case AppRoutes.splash:
      return MaterialPageRoute(builder: (_) => const SplashScreen());
    // ---------- Bottom Navigation ----------
    case AppRoutes.bottomNavigationPage:
      return MaterialPageRoute(builder: (_) => const BottomNavigationPage(),settings: settings);
    case AppRoutes.onboarding:
      return MaterialPageRoute(builder: (_) => const OnboardingScreen());
    case AppRoutes.login:
      return MaterialPageRoute(
        builder: (_) => const LoginScreen(),
        settings: settings,
      );
    case AppRoutes.registerScreen:
      return MaterialPageRoute(
        builder: (_) => const RegisterScreen(),
        settings: settings,
      );
    case AppRoutes.oTPFields:return MaterialPageRoute(
        builder: (_) => const OTPFields(),
        settings: settings,
      );
    case AppRoutes.addRoomProperty:return MaterialPageRoute(
        builder: (_) => const AddRoomProperty(),
        settings: settings,
      );
    case AppRoutes.bookingDetailsScreen:return MaterialPageRoute(
        builder: (_) => const BookingDetailsScreen(),
        settings: settings,
      );
    case AppRoutes.propertyDetailsScreen:
      return MaterialPageRoute(
        builder: (_) =>  PropertyDetailsScreen(),
        settings: settings,
      );
    case AppRoutes.chooseLocation:return MaterialPageRoute(
        builder: (_) => const ChooseLocation(),
        settings: settings,
      );
    case AppRoutes.topUpWalletPage:return MaterialPageRoute(
        builder: (_) => const TopUpWalletPage(),
        settings: settings,
      );

    case AppRoutes.walletScreen:return MaterialPageRoute(
        builder: (_) => const WalletScreen(),
        settings: settings,
      );
    case AppRoutes.addRoom:return MaterialPageRoute(
        builder: (_) => AddPropertyScreen1(),
        settings: settings,
      );
    case AppRoutes.editBankAccountScreen:return MaterialPageRoute(
        builder: (_) => EditBankAccountScreen(),
        settings: settings,
      );
    case AppRoutes.withdrawScreen:return MaterialPageRoute(
        builder: (_) => WithdrawScreen(),
        settings: settings,
      );
    case AppRoutes.addPropertyRoom2:return MaterialPageRoute(
        builder: (_) => AddPropertyRoom2(),
        settings: settings,
      );
    case AppRoutes.addBankAccountScreen:return MaterialPageRoute(
        builder: (_) => AddBankAccountScreen(),
        settings: settings,
      );
    case AppRoutes.bankListScreen:return MaterialPageRoute(
        builder: (_) => BankListScreen(),
        settings: settings,
      );
    case AppRoutes.notificationScreen:
      return MaterialPageRoute(
        builder: (_) => const NotificationScreen(),
        settings: settings,
      );
    case AppRoutes.personalProfileScreen:
      return MaterialPageRoute(
        builder: (_) => const PersonalProfileScreen(),
        settings: settings,
      );
    case AppRoutes.offerScreen:return MaterialPageRoute(
        builder: (_) => const OffersScreen(),
        settings: settings,
      );
    //edit
    case AppRoutes.editPropertyScreen1:return MaterialPageRoute(
        builder: (_) => const EditPropertyScreen1(),
        settings: settings,
      );
    case AppRoutes.editPropertyScreen2:return MaterialPageRoute(
        builder: (_) => const EditPropertyScreen2(),
        settings: settings,
      );
    case AppRoutes.finalEditScreenProperty:return MaterialPageRoute(
        builder: (_) => const FinalEditScreenProperty(),
        settings: settings,
      );
    case AppRoutes.noInternetConnection:return MaterialPageRoute(
        builder: (_) => const NoInternetConnection(),
        settings: settings,
      );


    default:
      return MaterialPageRoute(
        builder: (_) => const SplashScreen(),
        settings: settings,
      );
  }
}
