import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:easy_localization/easy_localization.dart';
import 'package:tele/controllers/adds_controller.dart';
import 'package:tele/controllers/doctor_appointment_controller.dart';
import 'package:tele/services/StorageService.dart';
import 'package:tele/views/screens/DoctorScreens/conseltaion_screen.dart';
import 'package:tele/views/screens/DoctorScreens/doctor_appointment_screen.dart';
import 'package:tele/views/screens/DoctorScreens/doctor_profile_Screen.dart';
import 'package:tele/views/screens/components/adds_screen.dart';
import 'package:tele/views/screens/components/config.dart';
import 'package:tele/views/screens/components/reusable.card.dart';
import 'package:tele/views/screens/loading_message_screen.dart';
import 'package:tele/views/screens/selfManagement.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});
  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  final url = Config.baseUrl;
  final DoctorAppointmentController doctorAppointmentController =
      Get.put(DoctorAppointmentController());
  final addsController = Get.put(AddsController());
  String username = "Loading...";
  String userId = "Loading...";
  String? picture;
  int _currentIndex = 0;
  ScrollController _scrollController = ScrollController();
  Timer? _timer;
  int hadda = 0;

  void _startAutoScroll() {
    _timer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
      if (!mounted ||
          addsController.adds.isEmpty ||
          !_scrollController.hasClients) return;
      final screenWidth = MediaQuery.of(context).size.width;
      final itemWidth = screenWidth * 0.87;
      final margin = 10.0;

      // final singleItemWidth = 350.0; // Adjust this to match AddsScreen width + margin
      final singleItemWidth =
          itemWidth + margin; // Adjust this to match AddsScreen width + margin
      final targetPosition = _currentIndex * singleItemWidth;

      _scrollController.animateTo(
        targetPosition,
        duration: Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
      setState(() {
        hadda = _currentIndex;
      });
      _currentIndex++;
      // print("haddda $hadda --- waqtiga hadda ${DateTime.now().microsecondsSinceEpoch}");
      // print("waqtiga hadda ${DateTime.now().microsecondsSinceEpoch}");

      if (_currentIndex >= addsController.adds.length) {
        _currentIndex = 0; // Loop back to start
      }
    });
  }

  @override
  void initState() {
    super.initState();
    loadUserData();
    addsController.allAdds();
    // _timer = Timer(Duration(seconds: 3),_scrollToPosition);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> loadUserData() async {
    Map<String, String?> userData = await StorageService.getUserData();
    String fullName = userData["username"] ?? "Unknown";
    String firstName = fullName.split(" ").first; // Extract first name
    setState(() {
      username = firstName;
      userId = userData["userId"] ?? "Unknown";
      picture = userData['picture'] ?? "N/A";
      doctorAppointmentController.fechtAppointments(userId);
    });
  }

  List<Map<String, dynamic>> get doctorCategories => [
    {
      "icon": Icons.healing,
      "text": "appointments".tr(),
      "route": DoctorAppointmentScreen(),
      "color": Colors.blue,
    },
    // {
    //   "icon": Icons.healing,
    //   "text": "prescription".tr(),
    //   "route": DoctorPrescriptionScreen(),
    //   "color": Colors.green,
    // },
    // {
    //   "icon": Icons.local_hospital,
    //   "text": "hospital".tr(),
    //   "route": HospitalListScreen(),
    //   "color": Colors.purple,
    // },
    {
      "icon": Icons.medical_services,
      "text": "consultation".tr(),
      "route": ConseltaionScreen(),
      "color": Colors.pink,
    },
    {
      "icon": Icons.self_improvement,
      "text": "self_management".tr(),
      "route": Selfmanagement(),
      "color": Colors.red,
    },
    // {
    //   "icon": Icons.child_care,
    //   "text": "pediatrician".tr(),
    //   "route": PrescriptionScreen(patientId: '', doctorId: '', appointmentId: '',),
    //   "color": Colors.orange,
    // },
  ];

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'good_morning'.tr();
    } else if (hour < 17) {
      return 'good_afternoon'.tr();
    } else {
      return 'good_evening'.tr();
    }
  }
  final List<String> quotes = [
    "Keep pushing forward 💪",
    "You're doing great today! 🌟",
    "Success is just around the corner 🚀",
    "Stay positive, work hard, and make it happen 🧠",
    "Make today count! 💯",
  ];

  String getRandomQuote() {
    quotes.shuffle(); // Randomize
    return quotes.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 65.0, horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        getGreeting(),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[900],
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                        width: 10,
                      ),
                      Text(
                        'Dr $username',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DoctorProfileScreenInmainScreen()));
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 28,
                        backgroundImage:
                            (picture?.isNotEmpty ?? false) && picture != "N/A"
                                ? NetworkImage('$url/$picture')
                                : AssetImage('assets/default_image.png')
                                    as ImageProvider,
                        backgroundColor: Colors.white,
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),
              // ADDS Row - Only Pictures in Horizontal Scrollable Containers
              // Obx(() {
              //   if (addsController.isLoading.value) {
              //     return LoadingMessage();
              //   }
              //   if (addsController.adds.isEmpty) {
              //     return AddsScreen(imageUri: '');
              //   }

              //   return CarouselSlider.builder(
              //     itemCount: addsController.adds.length,
              //     itemBuilder:
              //         (BuildContext context, int itemIndex, int pageViewIndex) {
              //       final add = addsController.adds[itemIndex];
              //       return SizedBox(
              //         width: double.infinity, // or a fixed value like 300
              //         height: 200, // match CarouselOptions height
              //         child: ClipRRect(
              //           borderRadius: BorderRadius.circular(12),
              //           child: Image.network(
              //             '$url/${add.picture}',
              //             fit: BoxFit.cover, // or BoxFit.fill / BoxFit.contain
              //           ),
              //         ),
              //       );
              //     },
              //     options: CarouselOptions(
              //       // height: 400,
              //       aspectRatio: 16 / 9,
              //       viewportFraction: 0.8,
              //       initialPage: 0,
              //       enableInfiniteScroll: true,
              //       reverse: false,
              //       autoPlay: true,
              //       autoPlayInterval: Duration(seconds: 3),
              //       autoPlayAnimationDuration: Duration(milliseconds: 800),
              //       autoPlayCurve: Curves.fastOutSlowIn,
              //       enlargeCenterPage: true,
              //       enlargeFactor: 0.3,
              //       scrollDirection: Axis.horizontal,
              //     ),
              //   );
              // }),
              Obx(() {
                if (addsController.isLoading.value) {
                  return LoadingMessage();
                }
                if (addsController.adds.isEmpty) {
                  return AddsScreen(imageUri: '');
                }
                return Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          controller: _scrollController,
                          child: Row(
                            children: addsController.adds.map((adds) {
                              return AddsScreen(imageUri: adds.picture);
                            }).toList(),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        // children: addsController.adds.map((adds) {
                        children:
                            addsController.adds.asMap().entries.map((entry) {
                          int index = entry.key;
                          // var adds = entry.value;

                          return Padding(
                            padding:
                                const EdgeInsets.only(left: 10.0, bottom: 5),
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: index == hadda
                                    ? Colors.green
                                    : Colors.blueGrey[100],
                                shape: BoxShape.circle,
                              ),
                            ),
                          );
                        }).toList(),
                      )
                    ],
                  ),
                );
              }),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: doctorCategories.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.2,
                  ),
                  itemBuilder: (context, index) {
                    final category = doctorCategories[index];
                    return ReusableCard(
                      icon: category["icon"],
                      text: category["text"],
                      iconColor: category["color"],
                      onTap: () {
                        if (category['route'] != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => category['route'],
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    "no_screen_available".tr())),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
