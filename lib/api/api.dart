import 'dart:convert';
import 'package:ott_code_frontend/enviorment_var.dart';
import 'package:ott_code_frontend/models/Categories.dart';
import 'package:http/http.dart' as http;
import 'package:ott_code_frontend/models/Movie.dart';
import 'package:ott_code_frontend/models/OTTModel.dart';
import 'package:ott_code_frontend/models/Settings.dart';
import 'package:ott_code_frontend/models/Song.dart';

class Api {
  // static const _usersSignUpUrl = '${EnvironmentVars.apiUrl}/api/v1/user/signup';
  // static const _usersLoginUrl = '${EnvironmentVars.apiUrl}/api/v1/user/login';
  // static const _otpVerfifyUrl = '${EnvironmentVars.apiUrl}/api/v1/user/verify_otp';
  // static const _categoriesUrl = '${EnvironmentVars.apiUrl}/api/v1/admin/content/category';

  Future<http.Response> registerUserData(Map<String, dynamic> userData) async {
    final response = await http.post(
      // Uri.parse(_usersSignUpUrl),
      Uri.parse('${EnvironmentVars.kanchaLankaUrl}/user/signup'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(userData),
    );
    print("inside API response ==> $response");
    return response;
  }

  Future<http.Response> loginUserData(Map<String, dynamic> userData) async {
    final response = await http.post(
      // Uri.parse(_usersLoginUrl),
      Uri.parse('${EnvironmentVars.kanchaLankaUrl}/user/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(userData),
    );
    return response;
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
    // try {
    //   final response = await http.get(Uri.parse(_categoriesUrl));
    //   if (response.statusCode == 200) {
    //     final jsonData = json.decode(response.body);
    //     final List<dynamic> categoryList = jsonData['list'];
    //     List<Categories> categories = categoryList.map((json) {
    //       return Categories.fromJson(json);
    //     }).toList();

    //     if (searchString != null && searchString.isNotEmpty) {
    //       // Filter categories based on search criteria
    //       categories = categories.where((category) {
    //         // Check if any song title contains the searchString
    //         return category.songs.any((song) =>
    //             song.title.toLowerCase().contains(searchString.toLowerCase()));
    //       }).map((category) {
    //         // Filter songs within each category based on search criteria
    //         final List<Song> filteredSongs = category.songs
    //             .where((song) => song.title
    //                 .toLowerCase()
    //                 .contains(searchString.toLowerCase()))
    //             .toList();
    //         return Categories(
    //           id: category.id,
    //           title: category.title,
    //           description: category.description,
    //           type: category.type,
    //           genre: category.genre,
    //           portraitKey: category.portraitKey,
    //           thumbnailKey: category.thumbnailKey,
    //           createdAt: category.createdAt,
    //           songs: filteredSongs,
    //         );
    //       }).toList();
    //     }

    //     return categories;
    //   } else {
    //     throw Exception('Failed to load categories');
    //   }
    // } catch (error) {
    //   throw Exception('Failed to load categories: $error');
    // }

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
