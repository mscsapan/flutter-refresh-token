import 'package:shared_preferences/shared_preferences.dart';

import '../../core/exceptions/exceptions.dart';
import '../../presentation/utils/k_string.dart';
import '../models/auth/user_response_model.dart';

abstract class LocalDataSource {
  bool checkOnBoarding();

  Future<bool> cachedOnBoarding();

  Future<bool> cacheUserResponse(UserResponseModel userResponseModel);

  UserResponseModel getExistingUserInfo();

  Future<bool> clearUserResponse();
  
  Future<void> saveCredentials({required String email, required String password});
  
  Future<void> removeCredentials();
}

class LocalDataSourceImpl implements LocalDataSource {
  final SharedPreferences sharedPreferences;

  LocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<bool> cachedOnBoarding() async {
    return sharedPreferences.setBool(KString.cachedOnBoardingKey, true);
  }

  @override
  bool checkOnBoarding() {
    final jsonString = sharedPreferences.getBool(KString.cachedOnBoardingKey);
    if (jsonString != null) {
      return true;
    } else {
      throw const DatabaseException('Not cached yet');
    }
  }

  @override
  Future<bool> cacheUserResponse(UserResponseModel userResponseModel) {
    return sharedPreferences.setString(
        KString.getExistingUserResponseKey, userResponseModel.toJson());
  }

  @override
  UserResponseModel getExistingUserInfo() {
    final jsonData =
        sharedPreferences.getString(KString.getExistingUserResponseKey);
    if (jsonData != null) {
      return UserResponseModel.fromJson(jsonData);
    } else {
      throw const DatabaseException('Not save users');
    }
  }

  @override
  Future<bool> clearUserResponse() {
    return sharedPreferences.remove(KString.getExistingUserResponseKey);
  }

  @override
  Future<void> saveCredentials({required String email, required String password}) async {
    await sharedPreferences.setString('email', email);
    await sharedPreferences.setString('password', password);
  }

  @override
  Future<void> removeCredentials() async {
    await sharedPreferences.remove('email');
    await sharedPreferences.remove('password');
  }
}
