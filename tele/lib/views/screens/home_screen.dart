import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:easy_localization/easy_localization.dart';
import 'package:tele/controllers/adds_controller.dart';
import 'package:tele/controllers/appoinments_controller.dart';
import 'package:tele/services/StorageService.dart';
import 'package:tele/views/screens/Hospitals/HospitalListScreen.dart';
import 'package:tele/views/screens/components/adds_screen.dart';
import 'package:tele/views/screens/components/appointment_card.dart';
import 'package:tele/views/screens/components/config.dart';
import 'package:tele/views/screens/components/reusable_card_for_patient.dart';
import 'package:tele/views/screens/loading_message_screen.dart';
import 'package:tele/views/screens/patient/Video_Consultation_Screen.dart';
import 'package:tele/views/screens/patient/chats_list_screen_appointment.dart';
import 'package:tele/views/screens/patient/user_profile.dart';
import 'package:tele/views/screens/selfManagement.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final url = Config.baseUrl;
  final appoinmentsController = Get.put(AppoinmentsController());
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
      appoinmentsController.fechtAppointments(userId);
    });
  }

  List<Map<String, dynamic>> get services => [
    {
      "icon": Icons.video_call,
      "text": "consultation".tr(),
      'route': VideoConsultationScreen()
    },
    {
      "icon": Icons.apartment,
      "text": "hospital".tr(),
      'route': HospitalListScreen()
    },
    {
      "icon": Icons.person_pin,
      "text": "self_manage".tr(),
      'route': Selfmanagement()
    },
    {
      "icon": Icons.health_and_safety,
      "text": "my_treatment".tr(),
      'route': ChatsListScreenAppointment(),
    },
    // {"icon": Icons.science_outlined, "text": "laboratory".tr(), 'route': LabsRecordScreen(),},
  ];

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
                        "welcome_back".tr(),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[900],
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        username,
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
                              builder: (context) => ProfileScreen()));
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
              //         height: 100, // match CarouselOptions height
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
              //ADDS Row - Only Pictures in Horizontal Scrollable Containers
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
                          var adds = entry.value;

                          return Padding(
                            padding:
                                const EdgeInsets.only(left: 10.0, bottom: 10),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 0,
                ),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: services.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 18,
                    mainAxisSpacing: 18,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    return ReusableCardP(
                      icon: services[index]["icon"],
                      text: services[index]["text"],
                      iconColor: Color.fromARGB(255, 9, 130, 13),
                      onTap: () {
                        if (services[index]['route'] != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => services[index]['route']),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    "No screen available for this service")),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding:
                    EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 0),
                child: Text(
                  'appointments'.tr(),
                  style: TextStyle(fontSize: 20),
                ),
              ),

              SizedBox(
                height: 220,
                child: Obx(() {
                  if (appoinmentsController.isLoading.value) {
                    return LoadingMessage();
                  }
                  if (appoinmentsController.appointments.isEmpty) {
                    return Center(child: Text("no_appointments_found".tr()));
                  }
                  return SingleChildScrollView(
                    child: Column(
                      children:
                          appoinmentsController.appointments.map((appointment) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: AppointmentCard(
                            appointmentTime: appointment.shiftTime,
                            appointmentDate: appointment.appointmentDate,
                            doctorName: appointment.doctorName,
                            doctorImageUrl: appointment.doctorProfile,
                            status: appointment.status,
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
