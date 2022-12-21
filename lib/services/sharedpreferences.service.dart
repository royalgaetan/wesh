import 'package:shared_preferences/shared_preferences.dart';

class UserSimplePreferences {
  static late SharedPreferences _preferences;

  static const _currentActivePageKey = 'currentActivePage';
  static const _showIntroductionPagesKey = 'showIntroductionPages';
  static const _lastHappyBirthdayDateTimeWishKey = 'happyBirthdayDateTimeWish';
  static const _usernameKey = 'username';
  static const _emailKey = 'email';
  static const _facebookID = 'facabookID';
  static const _googleID = 'googleID';
  static const _phoneKey = 'phone';
  static const _phoneCodeVerificationKey = 'phoneCodeVerificationKey';
  static const _countryKey = 'country';
  static const _nameKey = 'name';
  static const _birthday = 'birthday';
  //
  static const _redirectToAddEmailandPasswordPage = 'redirectToAddEmailandPasswordPage';
  static const _redirectToAddEmailPagekey = '_redirectToAddEmailPageValue';
  static const _redirectToUpdatePasswordPagekey = '_redirectToUpdatePasswordPageValue';

  static Future init() async => _preferences = await SharedPreferences.getInstance();

  // Current Active Page : Handler
  static Future setCurrentActivePageHandler(String value) async {
    _preferences.setString(_currentActivePageKey, value);
  }

  static String? getCurrentActivePageHandler() => _preferences.getString(_currentActivePageKey);

  // Introduction Pages : Handler
  static Future setShowIntroductionPagesHandler(bool value) async {
    _preferences.setBool(_showIntroductionPagesKey, value);
  }

  static bool? getShowIntroductionPagesHandler() => _preferences.getBool(_showIntroductionPagesKey);

  // Birthday DateTime Wish : Handler
  static Future setHappyBirthdayDateTimeWish(int yearWished) async {
    _preferences.setInt(_lastHappyBirthdayDateTimeWishKey, yearWished);
  }

  static int? getHappyBirthdayDateTimeWish() => _preferences.getInt(_lastHappyBirthdayDateTimeWishKey);

  // Username
  static Future setUsername(String username) async {
    _preferences.setString(_usernameKey, username);
  }

  static String? getUsername() => _preferences.getString(_usernameKey);

  // Email
  static Future setEmail(String email) async {
    _preferences.setString(_emailKey, email);
  }

  static String? getEmail() => _preferences.getString(_emailKey);

  // Google ID
  static Future setGoogleID(String googleID) async {
    _preferences.setString(_googleID, googleID);
  }

  static String? getGoogleID() => _preferences.getString(_googleID);

  // Facebook ID
  static Future setFacebookId(String fbId) async {
    _preferences.setString(_facebookID, fbId);
  }

  static String? getFacebookId() => _preferences.getString(_facebookID);

  // Phone
  static Future setPhone(String phone) async {
    _preferences.setString(_phoneKey, phone);
  }

  static String? getPhone() => _preferences.getString(_phoneKey);

  // Phone Code Verification
  static Future setPhoneCodeVerification(String code) async {
    _preferences.setString(_phoneCodeVerificationKey, code);
  }

  static String? getPhoneCodeVerification() => _preferences.getString(_phoneCodeVerificationKey);

  // Set country
  static Future setCountry(String country) async {
    _preferences.setString(_countryKey, country);
  }

  static String? getCountry() => _preferences.getString(_countryKey);

  // Name
  static Future setName(String name) async {
    _preferences.setString(_nameKey, name);
  }

  static String? getName() => _preferences.getString(_nameKey);

  // Birthday
  static Future setBirthday(String birthday) async {
    _preferences.setString(_birthday, birthday);
  }

  static String? getBirthday() => _preferences.getString(_birthday);

  // Redirect To Add Email and Password Page
  static Future setRedirectToAddEmailandPasswordPageValue(bool value) async {
    _preferences.setBool(_redirectToAddEmailandPasswordPage, value);
  }

  static bool? getRedirectToAddEmailandPasswordPageValue() => _preferences.getBool(_redirectToAddEmailandPasswordPage);

  // Redirect To Add Email Page
  static Future setRedirectToAddEmailPageValue(bool value) async {
    _preferences.setBool(_redirectToAddEmailPagekey, value);
  }

  static bool? getRedirectToAddEmailPageValue() => _preferences.getBool(_redirectToAddEmailPagekey);

  // Redirect To Update Password Page
  static Future setRedirectToUpdatePasswordPageValue(bool value) async {
    _preferences.setBool(_redirectToUpdatePasswordPagekey, value);
  }

  static bool? getRedirectToUpdatePasswordPageValue() => _preferences.getBool(_redirectToUpdatePasswordPagekey);
}
