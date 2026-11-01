import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:easy_localization/easy_localization.dart';
import 'package:tele/Models/doctors_list_nodel.dart';
import 'package:tele/controllers/HospitalController.dart';
import 'package:tele/controllers/specialist_controller.dart';
import 'package:tele/views/screens/components/config.dart';
import 'package:tele/views/screens/components/doctor_card.dart';
import 'package:tele/views/screens/loading_message_screen.dart';

class HospitalListScreen extends StatefulWidget {
  const HospitalListScreen({super.key});

  @override
  _HospitalListScreenState createState() => _HospitalListScreenState();
}

class _HospitalListScreenState extends State<HospitalListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final hospitalController = Get.put(HospitalController());
  final specialistController = Get.put(SpecialistController());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _searchController.addListener(() {
      final searchText = _searchController.text;
      final tabIndex = _tabController.index;

      if (tabIndex == 0) {
        hospitalController.filterHospitals(searchText);
      } else {
        specialistController.filterSpecialist(searchText);
      }
    });

    _tabController.addListener(() {
      final searchText = _searchController.text;
      if (_tabController.index == 0) {
        hospitalController.filterHospitals(searchText);
      } else if (_tabController.index == 1) {
        specialistController.filterSpecialist(searchText);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    hospitalController.filterHospitals('');
    specialistController.filterSpecialist('');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'search_hint'.tr(),
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Colors.black, fontSize: 18),
              )
            : Text('search_hospitals'.tr(),
                style: const TextStyle(color: Colors.black)),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search,
                size: 28, color: Colors.black),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  hospitalController.filterHospitals('');
                  specialistController.filterSpecialist('');
                }
              });
            },
          ),
        ],
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.blueAccent,
          labelColor: Colors.blueAccent,
          unselectedLabelColor: Colors.black54,
          tabs: [
            Tab(text: 'hospitals'.tr()),
            Tab(text: 'specialist'.tr()),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Hospitals Tab
          Obx(() {
            if (hospitalController.isLoading.value) {
              return const LoadingMessage();
            }
            if (hospitalController.filteredHospitals.isEmpty) {
              return const LoadingMessage(
                  animationAsset: 'assets/animations/no_hospital.json');
            }
            return _buildHospitalGrid();
          }),

          // Specialist Tab
          Obx(() {
            if (specialistController.isLoading.value) {
              return const LoadingMessage();
            }
            if (specialistController.filteredSpecialist.isEmpty) {
              return const LoadingMessage(
                  animationAsset: 'assets/animations/no_hospital.json');
            }
            return _buildSpecialistGrid();
          }),
        ],
      ),
    );
  }

  Widget _buildHospitalGrid() {
  final screenWidth = MediaQuery.of(context).size.width;
  final cardWidth = (screenWidth / 2) * 0.95; // match SpecialistCard width percentage

  return GridView.builder(
    padding: const EdgeInsets.only(top: 8),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: cardWidth / (cardWidth * 1), // same aspect ratio as SpecialistCard
    ),
    itemCount: hospitalController.filteredHospitals.length,
    itemBuilder: (context, index) {
      final hospital = hospitalController.filteredHospitals[index];
      return Center(
        child: SizedBox(
          width: cardWidth,
          child: HospitalCard(
            name: hospital.name,
            picture: hospital.picture,
            hospitalId: hospital.id,
          ),
        ),
      );
    },
  );
}

  Widget _buildSpecialistGrid() {
    final screenWidth = MediaQuery.of(context).size.width;
  final cardWidth = (screenWidth / 2) * 0.95; // 85% of half screen width
    return GridView.builder(
      padding: const EdgeInsets.only(top: 8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: cardWidth / (cardWidth * 1), // height ~1.2x width
      ),
      itemCount: specialistController.filteredSpecialist.length,
      itemBuilder: (context, index) {
        final specialist = specialistController.filteredSpecialist[index];
        return SpecialistCard(
          name: specialist.name,
          picture: specialist.picture,
          specialistid: specialist.id,
        );
      },
    );
  }
}

class SpecialistCard extends StatelessWidget {
  final String name;
  final String picture;
  final String specialistid;
  const SpecialistCard({
    super.key,
    required this.name,
    required this.picture,
    required this.specialistid,
  });

  @override
  Widget build(BuildContext context) {
    final url = Config.baseUrl;
    return GestureDetector(
      onTap: () async {
        final specialistController = Get.find<SpecialistController>();
        await specialistController.fetchDoctorsList(specialistid);
        print("✅✅✅✅");
        // print(specialistController.doctorsList.first);
        // Get.to(() =>DoctorsListScreen(doctors:specialistController.doctorsList));
        Get.to(() =>DoctorsListScreen(doctors:specialistController.doctorsList));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 45,
              backgroundImage: (picture.isNotEmpty && picture != "N/A")
                  ? NetworkImage("$url/$picture")
                  : const AssetImage('assets/default_image.png')
                      as ImageProvider,
              backgroundColor: Colors.white,
            ),
            const SizedBox(height: 10),
            Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HospitalCard extends StatelessWidget {
  final String name;
  final String picture;
  final String hospitalId;
  const HospitalCard({
    super.key,
    required this.name,
    required this.picture,
    required this.hospitalId,
  });

  @override
  Widget build(BuildContext context) {
    final url = Config.baseUrl;
    return GestureDetector(
      onTap: () async {
        final hospitalController = Get.find<HospitalController>();
        await hospitalController.fetchDoctorsList(hospitalId);
        print("✅✅✅✅");
        // print(hospitalController.doctorsList.first);

        Get.to(() =>DoctorsListScreen(doctors:hospitalController.doctorsList));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 45,
              backgroundImage: (picture.isNotEmpty && picture != "N/A")
                  ? NetworkImage("$url/$picture")
                  : const AssetImage('assets/default_image.png')
                      as ImageProvider,
              backgroundColor: Colors.white,
            ),
            const SizedBox(height: 10),
            Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class DoctorsListScreen extends StatefulWidget {
  final List<DoctorList> doctors;

  const DoctorsListScreen({super.key, required this.doctors});

  @override
  _DoctorsListScreenState createState() => _DoctorsListScreenState();
}

class _DoctorsListScreenState extends State<DoctorsListScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  late List<DoctorList> _filteredDoctors;

  @override
  void initState() {
    super.initState();
    _filteredDoctors = widget.doctors;

    _searchController.addListener(() {
      final query = _searchController.text.toLowerCase().trim();
      setState(() {
        if (query.isEmpty) {
          _filteredDoctors = widget.doctors;
        } else {
          _filteredDoctors = widget.doctors.where((doc) {
            return doc.name.toLowerCase().contains(query) ||
                   doc.speciality.toLowerCase().contains(query);
          }).toList();
        }
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                                  decoration: InputDecoration(
                    hintText: 'search_hint'.tr(),
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(color: Colors.black, fontSize: 18),
                )
              : Text('search_hospitals'.tr(),
                  style: const TextStyle(color: Colors.black)),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              size: 28,
              color: Colors.black,
            ),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _filteredDoctors = widget.doctors;
                }
              });
            },
          ),
        ],
      ),
      body: _filteredDoctors.isEmpty
          ? const Center(
              child: Text(
                "No doctors found.",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            )
          : ListView.builder(
              itemCount: _filteredDoctors.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: DoctorCard(doctor: _filteredDoctors[index]),
                );
              },
            ),
    );
  }
}

// class DoctorsListScreen extends StatefulWidget {
//   final List<DoctorList> doctors;
//   const DoctorsListScreen({super.key, required this.doctors});

//   @override
//   _DoctorsListScreenState createState() => _DoctorsListScreenState();
// }

// class _DoctorsListScreenState extends State<DoctorsListScreen> {
//   bool _isSearching = false;
//   final TextEditingController _searchController = TextEditingController();
//   final doctorListController = Get.put(DoctorListController());

//   @override
//   void initState() {
//     super.initState();
//     _searchController.addListener(() {
//       doctorListController.filterDoctors(_searchController.text);
//     });
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         centerTitle: true,
//         backgroundColor: Colors.white,
//         title: _isSearching
//             ? TextField(
//                 controller: _searchController,
//                 autofocus: true,
//                 decoration: const InputDecoration(
//                   hintText: "Search doctor...",
//                   border: InputBorder.none,
//                 ),
//                 style: const TextStyle(color: Colors.black, fontSize: 18),
//               )
//             : const Text("Search Doctor"),
//         actions: [
//           IconButton(
//             icon: Icon(_isSearching ? Icons.close : Icons.search, size: 30),
//             onPressed: () {
//               setState(() {
//                 _isSearching = !_isSearching;
//                 if (!_isSearching) _searchController.clear();
//               });
//             },
//           ),
//           const SizedBox(width: 10),
//         ],
//       ),
//       body: ListView.builder(
//         itemCount: widget.doctors.length,
//         itemBuilder: (context, index) {
//           return Padding(
//               padding: const EdgeInsets.only(bottom: 10),
//               child: DoctorCard(doctor: widget.doctors[index]));
//         },
//       ),
//     );
//   }
// }
