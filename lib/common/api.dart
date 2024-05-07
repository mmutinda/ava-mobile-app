// ignore_for_file: non_constant_identifier_names
class Api {
  static String main_url = "https://hal.hanspaulerp.net";
  static String api_url = "$main_url/api/";


  // response codes
  static int codeOK = 200;
  static int codeValidationFailed = 400;
  static int codeUnauthorized = 401;
  static int codeUnverifiedNumber = 402;
  static int codeAuthenticationFailed = 403;
  static int codeOTPCheckFailed = 403;
  static int codeOTPAuthTokenFailed = 401;
  static int codeOTPValidationFailed = 401;
  static int codeUserNotFound = 404;
  static int codeSignUpFailed = 405;
  static int codePhoneExists = 409;
  static int codeError = 500;
}
