import 'package:flutter/material.dart';
import 'package:native_in_flutter/models/Settings.dart';
import 'package:native_in_flutter/view/home/Category_slider.dart';

class HomeView extends StatefulWidget {
  final List<Settings> settings;

  const HomeView({Key? key, required this.settings}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int selectedNavItem = 0;

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    final settingsWithMovies = widget.settings
        .where(
            (setting) => setting.movies != null && setting.movies!.isNotEmpty)
        .toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < settingsWithMovies.length; i++)
                  Padding(
                    padding: EdgeInsets.only(
                      top: i == 0 ? 0.0 : 10.0,
                    ),
                    child: CategorySlider(
                      category: settingsWithMovies[i],
                      media: media,
                      index: i,
                    ),
                  ),
                const SizedBox(
                  height: 10,
                ),
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
      color: Colors.transparent,
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
        // Handle click event for each navigation item here
        switch (index) {
          case 0:
            // Handle All click event
            break;
          case 1:
            // Handle Special click event
            break;
          case 2:
            // Handle Emotional click event
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
