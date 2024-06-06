import 'dart:convert';
import 'package:native_in_flutter/enviorment_var.dart';
import 'package:native_in_flutter/models/Categories.dart';
import 'package:http/http.dart' as http;
import 'package:native_in_flutter/models/Movie.dart';
import 'package:native_in_flutter/models/OTTModel.dart';
import 'package:native_in_flutter/models/Settings.dart';

class Api {
  Future<http.Response> userDataOperation(Map<String, dynamic> userData,
      String registerType, String operationType) async {
    String apiUrl;
    if (operationType == 'signup') {
      apiUrl = registerType == 'phone'
          ? '/user/signup/phone/sendotp'
          : '/user/signup/email';
    } else if (operationType == 'login') {
      apiUrl = registerType == 'phone'
          ? '/user/login/phone/sendotp'
          : '/user/login/email';
    } else {
      throw ArgumentError('Invalid operationType');
    }

    String fullUrl = '${EnvironmentVars.kanchaLankaUrl}$apiUrl';
    String requestBody = jsonEncode(userData);

    print("Sending request to URL: $fullUrl");
    print("Request payload: $requestBody");

    try {
      final response = await http.post(
        Uri.parse(fullUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(userData),
      );
      print("Inside API response ==> Status code: ${response.statusCode}");
      print("Inside API response ==> Body: ${response.body}");
      return response;
    } catch (e) {
      print("Error in API call: $e");
      rethrow; // Re-throw the error to handle it in the calling code
    }
  }

  Future<http.Response> verifyOtp(
      Map<String, dynamic> otpData, String actionType) async {
    final String apiUrl = actionType == 'login'
        ? '/user/login/phone/verifyotp'
        : '/user/signup/phone/verifyotp';

    String fullUrl = '${EnvironmentVars.kanchaLankaUrl}$apiUrl';
    String requestBody = jsonEncode(otpData);

    print("Sending request to URL: $fullUrl");
    print("Request payload: $requestBody");

    try {
      final response = await http.post(
        Uri.parse(fullUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: requestBody,
      );
      print("Inside API response ==> Status code: ${response.statusCode}");
      print("Inside API response ==> Body: ${response.body}");
      return response;
    } catch (e) {
      print("Error in API call: $e");
      rethrow;
    }
  }

  Future<http.Response> otpVerfify(Map<String, dynamic> otpData) async {
    final response = await http.post(
      // Uri.parse(_otpVerfifyUrl),
      Uri.parse('${EnvironmentVars.kanchaLankaUrl}/user/verify_otp'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(otpData),
    );
    return response;
  }

  Future<List<Categories>> getCategories({String? searchString}) async {
    return [];
  }

  Future<List<OTTModel>> parseOTTs(String responseBody) async {
    String res = '''
  [
    {
      "ott_name": "Indimuse",
      "website_name": "indimuse.in",
      "logo_url": "/assets/images/app_logo_new.png",
      "apiUrl": "dummy_url_here",
      "bucket_url": "dummy_url_here"
    },
    {
      "ott_name": "Flutflix",
      "website_name": "flutflix.in",
      "logo_url": "/assets/images/app_logo_old.png",
      "apiUrl": "dummy_url_here",
      "bucket_url": "dummy_url_here"
    }
  ]
  ''';

    final parsed = jsonDecode(res).cast<Map<String, dynamic>>();
    return parsed.map<OTTModel>((json) => OTTModel.fromJson(json)).toList();
  }

  Future<List<Settings>> fetchSettingsAndMovies() async {
    List<Settings> settingsList = [];
    Set<String> uniqueContentIds = {};

    try {
      const homeTemplateUrl =
          '${EnvironmentVars.kanchaLankaUrl}/admin/template/home';
      const contentUrl = '${EnvironmentVars.kanchaLankaUrl}/components';
      final settingsResponse = await http.get(
        Uri.parse(
          homeTemplateUrl,
        ),
      );
      final settingsJson = jsonDecode(settingsResponse.body);

      if (settingsJson['error_code'] == 0) {
        final settingsData = settingsJson['result'];

        for (var settingData in settingsData['page_settings']) {
          final settings = Settings.fromJson(settingData['settings']);

          // Add the content IDs to the set
          uniqueContentIds.addAll(settings.content ?? []);

          settingsList.add(settings);
        }

        final moviesResponse = await http.post(
          Uri.parse(
            contentUrl,
          ),
          body: jsonEncode({'content': uniqueContentIds.toList()}),
          headers: {'Content-Type': 'application/json'},
        );
        final moviesJson = jsonDecode(moviesResponse.body);

        if (moviesJson['error_code'] == 0) {
          final List<dynamic> movieData = moviesJson['result'];
          final List<Movie> movies =
              movieData.map((data) => Movie.fromJson(data)).toList();

          // Assign the movies to each settings object
          for (var settings in settingsList) {
            settings.movies = movies
                .where((movie) => settings.content?.contains(movie.id) ?? false)
                .toList();
          }
        } else {}
      } else {}
    } catch (e) {
      print('Error: $e');
    }

    return settingsList;
  }
}
