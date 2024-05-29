import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:ott_code_frontend/common/color_extension.dart';
import 'package:ott_code_frontend/enviorment_var.dart';
import 'package:ott_code_frontend/models/Categories.dart';
import 'package:ott_code_frontend/models/Settings.dart';
import 'package:ott_code_frontend/view/home/CategoryDetailsView.dart';

class CategorySlider extends StatelessWidget {
  const CategorySlider({
    Key? key,
    required this.category,
    required this.media,
    required this.index,
  }) : super(key: key);

  final Settings category;
  final Size media;
  final int index;

  @override
  Widget build(BuildContext context) {
    double firstCarouselHeight = 0.3;
    double aspectRatio = media.aspectRatio;
    bool isIndexTwo = index == 1;

    double heightForIndexThree = media.height * 0.25;
    double marginBetweenSliders = 1.0;

    // Increase width for the third slider
    double widthForIndexThree = media.width * 0.6;

    return Container(
      alignment: Alignment.topCenter,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (index != 0)
            Padding(
              padding: const EdgeInsets.only(top: 5.0), // Add top padding
              child: Text(
                category.title ?? 'Default Title',
                style: TextStyle(
                  fontFamily: "Roboto",
                  fontWeight: FontWeight.w500,
                  color: ApplicationColor.text,
                  fontSize: 16,
                ),
              ),
            ),
          SizedBox(
            width: media.width,
            height: isIndexTwo
                ? heightForIndexThree
                : index == 0
                    ? media.height * firstCarouselHeight
                    : media.width * 0.3,
            child: Container(
              margin: EdgeInsets.only(
                bottom: index == 0 ? 0 : marginBetweenSliders,
                top: index == 0 ? 0.0 : marginBetweenSliders,
              ),
              child: CarouselSlider.builder(
                itemCount: category.movies?.length,
                itemBuilder: (context, index, realIndex) {
                  String? permalink = category.movies?[index].permalink;
                  String lastElement = '';
                  if (permalink != null) {
                    List<String> elements = permalink.split('/');
                    lastElement = elements.isNotEmpty ? elements.last : '';
                  }
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CategoryDetailsView(
                            categoryContent: category.movies?[index],
                          ),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        '${EnvironmentVars.bucketUrl}/${category.movies?[index].images?.img16_9}',
                        fit: isIndexTwo
                            ? BoxFit.cover
                            : aspectRatio > 1
                                ? BoxFit.fitHeight
                                : BoxFit.fitWidth,
                        width: index == 2 ? widthForIndexThree : media.width,
                        height: isIndexTwo
                            ? heightForIndexThree
                            : index == 0
                                ? media.height * firstCarouselHeight
                                : media.width * 0.8,
                        filterQuality: FilterQuality.low,
                      ),
                    ),
                  );
                },
                options: CarouselOptions(
                  height: isIndexTwo
                      ? heightForIndexThree
                      : index == 0
                          ? media.height * firstCarouselHeight
                          : media.width * 0.6,
                  autoPlay: index != 0,
                  initialPage: 0,
                  viewportFraction: index == 2 ? 0.6 : (index == 0 ? 1.0 : 0.4),
                  enlargeCenterPage: true,
                  pageSnapping: true,
                  autoPlayCurve: Curves.fastOutSlowIn,
                  autoPlayAnimationDuration: const Duration(seconds: 2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

