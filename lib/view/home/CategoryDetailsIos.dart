import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:native_in_flutter/models/Movie.dart';
import 'package:native_in_flutter/common/color_extension.dart';
import 'package:native_in_flutter/enviorment_var.dart';
import 'package:native_in_flutter/models/Movie.dart';
import 'package:native_in_flutter/models/Song.dart';
import 'package:native_in_flutter/view/home/action_buttons.dart';
import 'package:native_in_flutter/view/home/movie_player.dart';
import 'package:hive/hive.dart';
import 'package:native_in_flutter/models/User.dart';
import 'package:native_in_flutter/view/login/login_view.dart';

class CategoryDetailsViewIos extends StatefulWidget {
  const CategoryDetailsViewIos({Key? key, required this.categoryContent})
      : super(key: key);

  final Movie? categoryContent;

  @override
  _CategoryDetailsViewIosState createState() => _CategoryDetailsViewIosState();
}

class _CategoryDetailsViewIosState extends State<CategoryDetailsViewIos> {
  bool _isPlaying = false;
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    String? description = widget.categoryContent?.description;
    String displayDescription = (_isExpanded || description!.length <= 200)
        ? description!
        : description!.substring(0, 200) + '...';

    List<String> cast = widget.categoryContent?.casting?.cast ?? [];
    List<String> director = widget.categoryContent?.casting?.director ?? [];
    String castNames = cast.join(', ');
    String directorNames = director.join(', ');

    return Scaffold(
      backgroundColor: ApplicationColor.bgColor,
      body: _isPlaying
          ? MoviePlayer(
              //videoUrl:
              //'${EnvironmentVars.bucketUrl}/${widget.categoryContent?.media?.encodedFilePath}',
              videoUrl:
                  'https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8',
              videoText: widget.categoryContent!.title!,
              videoId: widget.categoryContent!.id!,
              skipRecapStartTime: '50',
              skipRecapEndTime: '65',
              skipIntroStartTime: '20',
              skipIntroEndTime: '35',
              startPlayFromTime: '10')
          : SingleChildScrollView(
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: media.width,
                            height: media.width * 0.8,
                            child: Image.network(
                              '${EnvironmentVars.bucketUrl}/${widget.categoryContent?.images?.img16_9}',
                              width: media.width,
                              height: (media.width * 9) / 16,
                              fit: BoxFit.fill,
                              filterQuality: FilterQuality.high,
                            ),
                          ),
                          Positioned(
                            top: media.width * 0.4,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  userAccountCheck();
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              icon: const Icon(
                                Icons.play_circle_filled,
                                color: Colors.white,
                                size: 60,
                              ),
                              label: Text(''),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.categoryContent!.title ?? '',
                              style: TextStyle(
                                color: ApplicationColor.text,
                                fontSize: 19,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Text(
                              displayDescription,
                              style: TextStyle(
                                color: ApplicationColor.text,
                                fontSize: 15,
                              ),
                            ),
                            if (description.length > 200)
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isExpanded = !_isExpanded;
                                  });
                                },
                                child: Text(_isExpanded ? '▲' : '▼'),
                              ),
                            const SizedBox(height: 20),
                            Text(
                              'Director:',
                              style: TextStyle(
                                color: ApplicationColor.text,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              directorNames,
                              style: TextStyle(
                                color: ApplicationColor.text,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Starring:',
                              style: TextStyle(
                                color: ApplicationColor.text,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              castNames,
                              style: TextStyle(
                                color: ApplicationColor.text,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            userAccountCheck();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ApplicationColor.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Watch Now',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const ActionButtons()
                    ],
                  ),
                  SafeArea(
                    child: Column(
                      children: [
                        AppBar(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          leadingWidth: 100,
                          leading: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    "assets/images/back_btn.png",
                                    width: 13,
                                    height: 13,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  const Text(
                                    "BACK",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> userAccountCheck() async {
    var box = await Hive.openBox<User>('userBox');
    var user = box.get('user');
    if (user != null) {
      _isPlaying = true;
    } else {
      _isPlaying = false;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginView(),
        ),
      );
    }
  }
}
