import 'package:fbroadcast/fbroadcast.dart';
import 'package:flutter/material.dart';
import 'package:ott_code_frontend/api/api.dart';
import 'package:ott_code_frontend/models/Categories.dart';
import 'package:ott_code_frontend/models/Settings.dart';
import 'package:ott_code_frontend/view/home/Category_slider.dart';
import 'package:ott_code_frontend/view/home/WebSeries.dart';
import 'dart:io' show Platform;

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);
  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late Future<List<Settings>> settings;
  int selectedNavItem = 0;
  @override
  void initState() {
    super.initState();
    settings = Api().fetchSettingsAndMovies();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(
              top: selectedNavItem == 0
                  ? 0
                  : 10.0, // Remove top padding for the first item
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder(
                  future: settings,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      final settingsWithMovies = snapshot.data!
                          .where((setting) =>
                              setting.movies != null &&
                              setting.movies!.isNotEmpty)
                          .toList();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (int i = 0; i < settingsWithMovies.length; i++)
                            Padding(
                              padding: EdgeInsets.only(
                                top: i == 0
                                    ? 0.0
                                    : 4, // No top padding for index 0
                              ),
                              child: CategorySlider(
                                category: settingsWithMovies[i],
                                media: media,
                                index: i, // Pass the index to CategorySlider
                              ),
                            ),
                        ],
                      );
                    }
                  },
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(child: buildNavBar()),
          ),
        ],
      ),
    );
  }

  Widget buildNavBar() {
    return Container(
      color: Colors.transparent, // Adjust color as needed
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          buildNavItem('All', 0),
          buildNavItem('Special', 1),
          buildNavItem('Emotional', 2),
          buildNavItem('Traditional', 3),
        ],
      ),
    );
  }

  Widget buildNavItem(String title, int index) {
    return TextButton(
      onPressed: () {
        setState(() {
          selectedNavItem = index;
        });
        switch (index) {
          case 0:
            break;
          case 1:
            break;
          case 2:
            break;
          case 3:
            // Handle Traditional click event
            break;
          default:
            break;
        }
      },
      child: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          decoration: selectedNavItem == index
              ? TextDecoration.underline
              : TextDecoration.none,
          decorationColor: Colors.red,
          decorationThickness: 5.0,
          color: Colors.white,
        ),
      ),
    );
  }
}

