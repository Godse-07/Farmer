

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sih/Onboarding/Onboadring_items.dart';
import 'package:sih/page/demo_page.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final controller = OnboadringItems();
  final pagecontroller = PageController();

  bool isLastpage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: Container(
        padding: EdgeInsets.symmetric(vertical: 20),
        color: Colors.white,
        child: isLastpage
            ? getStarted()
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  //skip button
                  TextButton(
                      onPressed: () => pagecontroller.previousPage(
                          duration: Duration(milliseconds: 500),
                          curve: Curves.ease),
                      child: Text("SKIP")),

                  //Indicator
                  SmoothPageIndicator(
                    controller: pagecontroller,
                    count: controller.list.length,
                    onDotClicked: (index) => {
                      pagecontroller.animateToPage(index,
                          duration: Duration(milliseconds: 500),
                          curve: Curves.ease)
                    },
                    effect: WormEffect(
                      activeDotColor: Colors.deepPurple,
                    ),
                  ),

                  //next button
                  TextButton(
                      onPressed: () => pagecontroller.nextPage(
                          duration: Duration(milliseconds: 500),
                          curve: Curves.ease),
                      child: Text("NEXT")),
                ],
              ),
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: PageView.builder(
          onPageChanged: (index) => {
            if (index == controller.list.length - 1)
              {
                setState(() {
                  isLastpage = true;
                })
              }
            else
              {
                setState(() {
                  isLastpage = false;
                })
              }
          },
          itemCount: controller.list.length,
          controller: pagecontroller,
          itemBuilder: (context, index) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipOval(
                  child: Image.asset(
                    controller.list[index].image,
                    fit: BoxFit.cover,
                    width: 400,
                    height: 400,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  controller.list[index].title,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Text(
                  controller.list[index].description,
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: 18,
                      fontWeight: FontWeight.normal),
                  textAlign: TextAlign.center,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  //Get started button

  Widget getStarted() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: 55,
      decoration: BoxDecoration(
        color: Colors.deepPurple,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextButton(
          onPressed: () async {
            final press = await SharedPreferences.getInstance();
            press.setBool("onboarding", true);

            if(!mounted){
              return;
            }

            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => DemoPage()));
          },
          child: Text(
            "Get Started",
            style: TextStyle(
              color: Colors.white,
            ),
          )),
    );
  }
}
