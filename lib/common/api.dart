// ignore_for_file: non_constant_identifier_names
class Api {
  static String main_url = "http://172.16.16.57:80";
  static String api_url = "$main_url/api/user/";

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
  static String token =
      'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIzIiwianRpIjoiYmQzZjRlZTU2YzIyODkyN2FhYTkzYzQ1ODI3OTBmNzZhNjhhNGFhNTdjZDc0OGY5MjdhMzRjMTNmYmVkMGY2NThhZWM2NjNlNGI4ZjJkM2UiLCJpYXQiOjE3MDY2ODU1NDcuOTU2NDMyLCJuYmYiOjE3MDY2ODU1NDcuOTU2NDM3LCJleHAiOjE3MzgzMDc5NDcuOTQzMTIsInN1YiI6IjEiLCJzY29wZXMiOltdfQ.Pupa1dMXuNN5jDZgiDSo7y-7OvpaUWAdT5UepLpQDcmxSKiEYMTf4B_2VzCIAvXH90NsafmxqiK5hv1g34LZ9e1h6jCfeO5OAMRmhOc83xGP3oM9AXcQW-HIWcQGk09tE2LcDrxRL1kpoN66OsSWuH6Z8wj1LgcEGLOqRMBqaxGkTUSAhcCCr3YZXZdbDt-HKr-hAd9Y-Txio9GHMnHsDQrXGtA3kabmQ__3SrphT4C7srEcmvmtrvjwawcFgWwNznsJJ9kiWFzNyLMXqkvRdfTVET14y65RpB_eQint5W4NYvdC9IBtQBlFvFL-BeYEVCh2l0gpLGM47G-A8aPhVh-1Ivtx8HdC1IMWW2O9Ms6c5HxFfyYPKkYtBj_2ep64K1xYyatmggo7B9DYVBRVGEVWAjb_2Y93gyhe7Viw8SQkaYc93G0W7LlI7hpUQ7wV1F5KsKchAChCvYvTFlGQV6JfNqNKWTy8ZRvlfYxSo1_BmF2VimZr6m1NJj3KMLpqKkymtdVH9eXSMgf_lgB2AMTqwo3Cy6wzDdZ9vxjdNw8sbWPk2yi1-I5Q-JRVsmFAwVG5TjdgOw-76njat_qd92gHJ2vg9xld7d9tKJQ-6ZJlVOe71H8JikR9rW3jPFqSSdeqSS_ML2eRqRwRW4wnEaYRyBqVPkvPpIqJRM3iimk';
}
