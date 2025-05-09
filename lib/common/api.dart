// ignore_for_file: non_constant_identifier_names
class Api {
  static String main_url = "https://pqcscloud.com";
  static String api_url = "$main_url/api/user/";
  static String usr =
      "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiI0IiwianRpIjoiZjdkNDE5NGQyNmJkMzNhNjA3MGQ1NzFmMmIxMTk0OWZiNDU2OWRkNjQ4MzUzODdhYjk2M2ZlOTcyNjdjZGUxMzc2MThkZWVhZWM2NGVkYzciLCJpYXQiOjE3MTk0NzgzNDMuMzM5ODI0LCJuYmYiOjE3MTk0NzgzNDMuMzM5ODI5LCJleHAiOjE3NTEwMTQzNDMuMjQyODUyLCJzdWIiOiIxIiwic2NvcGVzIjpbXX0.OvJLBoPGIWtXH4PPXsTd_A2BuE5i-VubYx-qLK0u_AMiCg8n8sZOBxAFkB3UwwvI8dpg-B04O5c7hH1KYAYwuwlM3ifZV7oFhyinvavOZ5Dh9xKnbhGGHINm7aZA8Y_HtjFX_1HBt9ae2AIoDUyZglQBAd06XXF3Ccxzc9VdwDNKHP818fL9fav64It9IT9LmIAVTwRuvuAGTujLmhFyyWz8AdbmapXg8QVKFvECT472tSPKhKdi7Fvo3OCIm607B8feBk4BKGmcdjeIKEk8PIJofHxpj-UdigTQnO84LQ5zy3PZF0BHZ40ku80df7KyEdMK8HvqlqNGRJ0Fr4J7qLh3QrYk6DbRdw1Ir_hxRVxFGMBprA9G_6ZuWGfhIfXWfBXguVEP0Ak6fwDMm9VBukV06ixGe_lmF_D1v4Zgvu7AHrTiiXfDIC1jj7-zmo8Nswxawlp4CnYoH_DbW37nMA3jTAOsDn-JX55Q1Jgslpi2XJ0rkiQFKpYh4nf6M-nUxdr6zPaj5_7cs9SJB9J_Zcbe9Ufm1u0xPOw7c5jtZv-ADJUhQWkS2XGU7XTe3nx4qeIPIsyYgdo4291M5YQfM4Pn-l2itVy8hduvuvNvELieFZvlDBLWjqvTbatjyucerAok0F42NCgdwZwYvpIb-h37hFb__NIbTILsi0N6UkQ";
  static String progress_image = "$main_url/storage/";
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
