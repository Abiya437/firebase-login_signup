import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class SliderDesign extends StatefulWidget {
  const SliderDesign({super.key});

  @override
  State<SliderDesign> createState() => _SliderDesignState();
}

class _SliderDesignState extends State<SliderDesign> {
  int currentIndex = 0;
  List imageList = [
    {"id": 1, "image_path": 'images/slider1.png'},
    {"id": 2, "image_path": 'images/slider2.png'},
    {"id": 3, "image_path": 'images/slider3.png'},
    {"id": 4, "image_path": 'images/slider4.png'}
  ];
  final CarouselController carouselController = CarouselController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InkWell(
          onTap: () {
            debugPrint('$currentIndex');
          },
          child: CarouselSlider(
            items: imageList
                .map(
                  (item) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  item['image_path'],
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            )
                .toList(),
            carouselController: carouselController,
            options: CarouselOptions(
              scrollPhysics: const BouncingScrollPhysics(),
              autoPlay: true,
              aspectRatio: 2.0,
              viewportFraction: 1,
              onPageChanged: (index, reason) {
                setState(() {
                  currentIndex = index;
                });
              },
            ),
          ),
        ),
        Positioned(
          bottom: 10,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: imageList.asMap().entries.map((entry) {
              return GestureDetector(
                onTap: () => carouselController.animateToPage(entry.key),
                child: Container(
                  width: currentIndex == entry.key ? 17 : 7,
                  height: 9.0,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 3.0,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
