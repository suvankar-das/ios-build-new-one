import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:native_in_flutter/common/color_extension.dart';
import 'package:native_in_flutter/enviorment_var.dart';
import 'package:native_in_flutter/models/Categories.dart';
import 'package:native_in_flutter/models/Settings.dart';
import 'package:native_in_flutter/view/home/CategoryDetailsIos.dart';
import 'package:native_in_flutter/view/home/CategoryDetailsView.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';

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

    double heightForIndexThree = media.height * 0.30;
    double marginBetweenSliders = 2.0;

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
            width: isIndexTwo ? media.width : media.width,
            height: isIndexTwo
                ? heightForIndexThree
                : index == 0
                    ? media.height * firstCarouselHeight
                    : media.width * 0.3,
            child: Container(
              margin: EdgeInsets.only(
                bottom: marginBetweenSliders,
                top: index == 0
                    ? 0.0
                    : marginBetweenSliders, // Conditionally add top margin
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

                  Widget itemChild;
                  switch (index) {
                    case 0:
                      itemChild = ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl:
                              '${EnvironmentVars.bucketUrl}/${category.movies?[index].images?.img16_9}',
                          fit: BoxFit.fill,
                          width: media.width,
                          height: (media.width * 9) / 16,
                          placeholder: (context, url) =>
                              const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      );
                      break;
                    case 1:
                      itemChild = ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl:
                              '${EnvironmentVars.bucketUrl}/${category.movies?[index].images?.img9_16}',
                          fit: BoxFit.fill,
                          width: media.width / 3,
                          height: (media.width / 3) * 16 / 9,
                          placeholder: (context, url) =>
                              const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      );
                      break;
                    case 2:
                      itemChild = ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl:
                              '${EnvironmentVars.bucketUrl}/${category.movies?[index].images?.img16_9}',
                          fit: BoxFit.fill,
                          width: (media.width) / 1.5,
                          height: (((media.width) / 1.5) * 9) / 16,
                          placeholder: (context, url) =>
                              const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                        ),
                      );
                      break;
                    case 3:
                      itemChild = ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl:
                              '${EnvironmentVars.bucketUrl}/${category.movies?[index].images?.img1_1}',
                          fit: BoxFit.fill,
                          width: (media.width) / 2,
                          height: (media.width) / 2,
                          placeholder: (context, url) =>
                              const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      );
                      break;
                    default:
                      itemChild = ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl:
                              '${EnvironmentVars.bucketUrl}/${category.movies?[index].images?.img16_9}',
                          fit: BoxFit.fill,
                          width: (media.width) / 1.5,
                          height: (((media.width) / 1.5) * 9) / 16,
                          placeholder: (context, url) =>
                              const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      );
                  }

                  return GestureDetector(
                    onTap: () {
                      if (Platform.isIOS) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CategoryDetailsViewIos(
                              categoryContent: category.movies?[index],
                            ),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CategoryDetailsView(
                              categoryContent: category.movies?[index],
                            ),
                          ),
                        );
                      }
                    },
                    child: itemChild,
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
