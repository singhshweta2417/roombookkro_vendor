import 'package:flutter_riverpod/flutter_riverpod.dart';

class ApiUrl {
  String? baseUrl;
  String? signUpUrl;
  String? profileUpdateUrl;
  String? search;
  String? createCoupon;
  String? getAmenities;
  String? topUp;
  String? getAmenitiesRoom;
  String? addProperty;
  String? notification;
  String? orderedPropertyDetails;
  String? vendorStatics;
  String? getOnboardPage;
  String? depositHistory;
  String? vendorOrderHistory;
  String? roomType;
  String? createSession;
  String? getVendorProperty;
  String? bankUpdate;
  String? updateProperty;
  String? create;
  String? addBank;
  String? bankDelete;
  String? propertyType;
  String? bankDetailsUser;
  String? policyUrl;
  String? sendOtp;
  String? verifyOtp;

  ApiUrl({
    this.baseUrl,
    this.signUpUrl,
    this.profileUpdateUrl,
    this.bankDelete,
    this.search,
    this.createCoupon,
    this.getAmenities,
    this.bankUpdate,
    this.getAmenitiesRoom,
    this.addProperty,
    this.notification,
    this.vendorOrderHistory,
    this.createSession,
    this.orderedPropertyDetails,
    this.vendorStatics,
    this.getOnboardPage,
    this.roomType,
    this.policyUrl,
    this.addBank,
    this.depositHistory,
    this.create,
    this.topUp,
    this.propertyType,
    this.bankDetailsUser,
    this.updateProperty,
    this.getVendorProperty,
    this.sendOtp,
    this.verifyOtp,
  });
}

final apiUrlProvider = Provider<ApiUrl>((ref) {
  const base = "https://root.roombookkro.com/api/";
  return ApiUrl(
    baseUrl: base,
    signUpUrl: "${base}authentication",
    profileUpdateUrl: "${base}profile/",
    search: "${base}search?",
    createCoupon: "${base}vendor/create-coupon",
    addProperty: "${base}addproperty",
    vendorStatics: "${base}vendorStatics?vendorId=",
    getAmenities: "${base}get-amenities/property",
    getAmenitiesRoom: "${base}get-amenities/room",
    vendorOrderHistory: "${base}vendorOrderHistory?vendorId=",
    notification: "${base}notification",
    orderedPropertyDetails: "${base}orderedProperty?userId=",
    getOnboardPage: "${base}getonboardpage",
    getVendorProperty: "${base}getvendorproperty?userId=",
    propertyType: "${base}getenum",
    roomType: "${base}getenum?roomType=",
    policyUrl: "${base}policy?key=",
    addBank: "${base}add/bank",
    bankDetailsUser: "${base}bankdetails/user/",
    create: "${base}create",
    createSession: "${base}initiate",
    bankUpdate: "${base}bank/update/",
    bankDelete: "${base}bank/delete/",
    topUp: "${base}list/topup",
    depositHistory: "${base}history/",
    updateProperty: "${base}updateproperty/",
    sendOtp: 'https://otp.fctechteam.org/send_otp.php?',
    verifyOtp: 'https://otp.fctechteam.org/verifyotp.php?mobile=',
  );
});
