import 'package:flutter/material.dart';
import 'package:flutter_cashfree_pg_sdk/api/cferrorresponse/cferrorresponse.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfwebcheckoutpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:room_book_kro_vendor/features/auth/data/user_view.dart';
import 'package:room_book_kro_vendor/features/auth/model/create_session_model.dart';
import 'package:room_book_kro_vendor/features/home/dialog_widget.dart';
import 'package:room_book_kro_vendor/features/home/repo/top_up_session_repo.dart';
import '../../../core/network/app_exception.dart';

class TopUpCreateSessionViewModel extends StateNotifier<CreateSessionState> {
  final CreateSessionRepository _createSessionRepo;
  final Ref ref;
  final CFPaymentGatewayService cfPaymentGatewayService =
      CFPaymentGatewayService();

  TopUpCreateSessionViewModel(this._createSessionRepo, this.ref)
    : super(const CreateSessionInitial());

  void _setupCashfreeCallbacks(dynamic finalPrice, BuildContext context) {
    cfPaymentGatewayService.setCallback(
      (String? orderId) async {
        debugPrint("✅ Cashfree payment verified: $orderId");
        showDialog(
          context: context,
          builder: (ctx) => PaymentSuccessDialog(
            message: "You have successfully made a payment",
          ),
        );
        // await ref
        //     .read(topUpEWalletProvider.notifier)
        //     .profileUpdateApi(
        //       walletBalance: finalPrice.toString(),
        //       context: context,
        //     );
      },
      (CFErrorResponse errorResponse, String? orderId) {
        debugPrint(
          "❌ Cashfree payment failed: orderId=$orderId, "
          "error=${errorResponse.getMessage()}",
        );
      },
    );
  }

  Future<void> topUpSessionApi(dynamic finalPrice, BuildContext context) async {
    final userPref = ref.read(userViewModelProvider);
    final userID = await userPref.getUserId();

    state = const CreateSessionLoading();
    final Map<String, dynamic> data = {
      "userId": userID.toString(),
      "amount": finalPrice,
    };

    try {
      final value = await _createSessionRepo.getCreateSessionApi(data);
      state = CreateSessionSuccess(createSessionList: value);

      final String orderId = value.data?.orderId.toString()??'';
      final String paymentSessionId = value.data?.paymentSessionId.toString()??'';
      _setupCashfreeCallbacks(finalPrice, context);

      await startPayment(orderId, paymentSessionId);
    } on FetchDataException catch (e) {
      state = CreateSessionError(e.message.toString());
    } catch (e, stackTrace) {
      debugPrint("Error in topUpSessionApi: $e");
      debugPrintStack(stackTrace: stackTrace);
      state = CreateSessionError("Unexpected error occurred");
    }
  }

  Future<void> startPayment(String orderId, String paymentSessionId) async {
    try {
      final session = CFSessionBuilder()
          .setEnvironment(CFEnvironment.SANDBOX)
          .setOrderId(orderId)
          .setPaymentSessionId(paymentSessionId)
          .build();

      final cfWebCheckout = CFWebCheckoutPaymentBuilder()
          .setSession(session)
          .build();

      await cfPaymentGatewayService.doPayment(cfWebCheckout);
    } catch (e) {
      debugPrint("Error while starting payment: $e");
    }
  }
}

abstract class CreateSessionState {
  final bool isLoading;
  const CreateSessionState({this.isLoading = false});
}

class CreateSessionInitial extends CreateSessionState {
  const CreateSessionInitial() : super(isLoading: false);
}

class CreateSessionLoading extends CreateSessionState {
  const CreateSessionLoading() : super(isLoading: true);
}

class CreateSessionSuccess extends CreateSessionState {
  final CreateSessionModel createSessionList;

  const CreateSessionSuccess({required this.createSessionList})
    : super(isLoading: false);
}

class CreateSessionError extends CreateSessionState {
  final String error;
  const CreateSessionError(this.error) : super(isLoading: false);
}

/// --------------------
/// CreateSession Provider
/// --------------------
final topUpSessionCreatePro =
    StateNotifierProvider<TopUpCreateSessionViewModel, CreateSessionState>((
      ref,
    ) {
      final sessionRepo = ref.read(createSessionProvider);
      return TopUpCreateSessionViewModel(sessionRepo, ref);
    });
