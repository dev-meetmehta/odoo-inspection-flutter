import 'dart:convert';

import 'package:dio/dio.dart';


class ApiHelper {
  final Reader? reader;

  ApiHelper({this.reader});

  Future<bool> postDefaultRequest(
      String endPoint, Map<String, dynamic> formData) async {
    String? token = reader!(userCredentialProvider.notifier).token;
    final responsData = await NetworkClient.request(
        type: RequestType.post,
        endPoint: endPoint,
        token: token,
        body: formData);
    logger.v(responsData);
    final response = DefaultResponse.fromJson(
      responsData,
      create: null,
    );
    toast(text: response.message ?? '');
    return response.success;
  }

  Future<RegistrationResponseData?> postRegistration(
    Map<String, dynamic> formData,
  ) async {
    final responseJson = await NetworkClient.request(
      type: RequestType.post,
      endPoint: '/auth/register',
      body: formData,
    );
    final response = DefaultResponse<RegistrationResponseData>.fromJson(
      responseJson,
      create: (data) =>
          data == null ? null : RegistrationResponseData.fromJson(data),
    );

    if (response.success) {
      return response.data;
    } else {
      String errorMessage = response.message ?? 'Some Error Occured';
      if (errorMessage.contains('Mobile number already exists')) {
        errorMessage += '\nPlease try sign in using above number!';
      }
      toast(text: errorMessage);
      return null;
    }
  }

  Future<bool?> generateOtp(
    Map<String, dynamic> formData,
  ) async {
    final token = reader!(userCredentialProvider).token;
    final responseJson = await NetworkClient.request(
      type: RequestType.post,
      endPoint: '/auth/otp/generate',
      body: formData,
      token: token,
    );
    final response = DefaultResponse.fromJson(responseJson, create: null);

    if (response.success) {
      toast(text: response.message ?? "Success");
      return true;
    } else {
      toast(text: response.message ?? "Some Error Occured");
      return null;
    }
  }

  Future<bool?> verifyOtp(
    Map<String, dynamic> formData,
  ) async {
    final token = reader!(userCredentialProvider).token;
    final responseJson = await NetworkClient.request(
      type: RequestType.post,
      endPoint: '/auth/otp/verify',
      body: formData,
      token: token,
    );
    final response = DefaultResponse.fromJson(responseJson, create: null);

    if (response.success) {
      toast(text: response.message ?? "Success");
      return true;
    } else {
      toast(text: response.message ?? "Some Error Occured");
      return null;
    }
  }

  Future<DefaultResponse> uploadProfileImage(
    String filePath,
  ) async {
    final token = reader!(userCredentialProvider).token;
    final responseJson = await NetworkClient.request(
      type: RequestType.postFormData,
      endPoint: 'upload-profile-image',
      body: {"image": await MultipartFile.fromFile(filePath)},
      token: token!,
    );
    return DefaultResponse.fromJson(responseJson, create: null);
  }

  Future<RegisterDetailResponse> postRegistrationDetail(
    Map<String, dynamic> formData,
  ) async {
    final token = reader!(userCredentialProvider).token;
    final responseJson = await NetworkClient.request(
      type: RequestType.post,
      endPoint: 'register/detail',
      body: formData,
      token: token!,
    );
    RegisterDetailResponse registerDetailResponse =
        RegisterDetailResponse.fromJson(responseJson);
    if (!registerDetailResponse.success) {
      if (registerDetailResponse.message.contains('birthtime')) {
        formData.remove('birthtime');
        registerDetailResponse = await postRegistrationDetail(formData);
      }
    }
    return registerDetailResponse;
  }

  Future<DefaultResponse> postResetPassword(
    Map<String, dynamic> formData,
  ) async {
    final token = reader!(userCredentialProvider).token;
    final responseJson = await NetworkClient.request(
      type: RequestType.post,
      endPoint: 'change-password',
      body: formData,
      token: token!,
    );
    return DefaultResponse.fromJson(responseJson, create: null);
  }

  Future<DefaultResponse> postContactUs(
    Map<String, dynamic> formData,
  ) async {
    final token = reader!(userCredentialProvider).token;
    final responseJson = await NetworkClient.request(
      type: RequestType.post,
      endPoint: '/contact-us-with',
      body: formData,
      token: token!,
    );
    return DefaultResponse.fromJson(responseJson, create: null);
  }

  Future<MembershipResponse?> getMembership() async {
    final token = reader!(userCredentialProvider).token;
    final responseJson = await NetworkClient.request(
      type: RequestType.get,
      endPoint: 'get-plans',
      token: token!,
    );

    final response = DefaultResponse<MembershipResponse>.fromJson(
      responseJson,
      create: null,
      createCustom: (data) =>
          data == null ? null : MembershipResponse.fromJson(data),
    );

    if (response.success) {
      return response.data!;
    } else {
      toast(
          text: response.message ??
              "Some Error Occured while fetching membership");
      return null;
    }
  }

  Future<CcAvenueData?> getCcAvenueData(Map<String, dynamic> formData) async {
    final token = reader!(userCredentialProvider).token;
    final responseJson = await NetworkClient.request(
      type: RequestType.post,
      endPoint: '/payment',
      token: token!,
      body: formData,
    );

    final response = DefaultResponse<CcAvenueData>.fromJson(
      responseJson,
      create: (data) => data == null ? null : CcAvenueData.fromJson(data),
    );

    if (response.success) {
      return response.data;
    } else {
      toast(text: response.message ?? "Some Error Occured!");
      return null;
    }
  }

  Future<MyOrderHistoryResponse?> getMyOrderHistory() async {
    final token = reader!(userCredentialProvider).token;
    final responseJson = await NetworkClient.request(
      type: RequestType.get,
      endPoint: 'my-history',
      token: token!,
    );

    final response = DefaultResponse<MyOrderHistoryResponse>.fromJson(
      responseJson,
      create: null,
      createCustom: (data) =>
          data == null ? null : MyOrderHistoryResponse.fromJson(data),
    );

    if (response.success) {
      return response.data!;
    } else {
      toast(
          text: response.message ??
              "Some Error Occured while fetching order history");
      return null;
    }
  }

  Future<DefaultResponse> postSubmitStory(Map<String, dynamic> formData) async {
    final token = reader!(userCredentialProvider).token;
    final responseJson = await NetworkClient.request(
      type: RequestType.postFormData,
      endPoint: '/stories',
      body: formData,
      token: token!,
    );
    return DefaultResponse.fromJson(responseJson, create: null);
  }

  Future<void> sendPushNotification(PushNotification pushNotification) async {
    await NetworkClient.request(
      type: RequestType.postChat,
      endPoint: '/sendNotificationToUser',
      body: pushNotification.toJson(),
    );
  }

  Future<OtherMatchesData?> getOtherMatches() async {
    final token = reader!(userCredentialProvider).token;
    final responseJson = await NetworkClient.request(
      type: RequestType.get,
      endPoint: 'getSpinnerData',
      token: token!,
    );

    final response = DefaultResponse<OtherMatchesData>.fromJson(
      responseJson,
      create: null,
      createCustom: (data) =>
          data == null ? null : OtherMatchesData.fromJson(data),
    );

    if (response.success) {
      return response.data!;
    } else {
      toast(
          text: response.message ??
              "Some Error Occured While Fetching Other Matches");
      return null;
    }
  }



  Future<DefaultResponse> postEducationOccupation(
      Map<String, dynamic> body) async {
    final token = reader!(userCredentialProvider).token;
    final responseJson = await NetworkClient.request(
      type: RequestType.post,
      endPoint: '/education-and-occupation-info',
      body: body,
      token: token!,
    );
    return DefaultResponse.fromJson(responseJson, create: null);
  }

  Future<DefaultResponse> postSocialReligious(Map<String, dynamic> body) async {
    final token = reader!(userCredentialProvider).token;
    final responseJson = await NetworkClient.request(
      type: RequestType.post,
      endPoint: '/my-profile',
      body: body,
      token: token!,
    );
    return DefaultResponse.fromJson(responseJson, create: null);
  }
}
