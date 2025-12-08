import 'package:flutter_riverpod/flutter_riverpod.dart';

class ApiUrl {
  String? baseUrl;
  String? signUpUrl;
  String? profileUpdateUrl;
  String? search;
  String? createCoupon;
  String? getAmenities;
  String? addProperty;
  String? notification;
  String? orderedPropertyDetails;
  String? vendorStatics;
  String? getOnboardPage;
  String? vendorOrderHistory;
  String? getVendorProperty;
  String? updateProperty;
  String? create;
  String? policyUrl;
  String? sendOtp;
  String? verifyOtp;

  ApiUrl({
    this.baseUrl,
    this.signUpUrl,
    this.profileUpdateUrl,
    this.search,
    this.createCoupon,
    this.getAmenities,
    this.addProperty,
    this.notification,
    this.vendorOrderHistory,
    this.orderedPropertyDetails,
    this.vendorStatics,
    this.getOnboardPage,
    this.policyUrl,
    this.create,
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
    vendorOrderHistory: "${base}vendorOrderHistory?vendorId=",
    notification: "${base}notification",
    orderedPropertyDetails: "${base}orderedProperty?userId=",
    getOnboardPage: "${base}getonboardpage",
    getVendorProperty: "${base}getvendorproperty?userId=",
    policyUrl: "${base}policy?key=",
    create: "${base}create",
    updateProperty: "${base}updateproperty/",
    sendOtp: 'https://otp.fctechteam.org/send_otp.php?',
    verifyOtp: 'https://otp.fctechteam.org/verifyotp.php?mobile=',
  );
});
