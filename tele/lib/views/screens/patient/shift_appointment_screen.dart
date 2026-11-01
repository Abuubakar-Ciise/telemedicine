import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';
import 'package:tele/Models/doctors_list_nodel.dart';
import 'package:tele/Models/shift_model.dart';
import 'package:tele/controllers/shift_controller.dart';
import 'package:tele/services/get_api_services.dart';
import 'package:tele/views/screens/components/config.dart';
import 'package:tele/views/screens/loading_message_screen.dart';
import 'package:tele/views/screens/patient/PatientDetailsScreen.dart';
import 'package:toastification/toastification.dart';

class ShiftAppointmentScreen extends StatefulWidget {
  final DoctorList doctor;

  const ShiftAppointmentScreen({super.key, required this.doctor});

  @override
  _ShiftAppointmentScreenState createState() => _ShiftAppointmentScreenState();
}

class _ShiftAppointmentScreenState extends State<ShiftAppointmentScreen> {
  final url = Config.baseUrl;
  final shiftController = Get.put(ShiftController());
  // final shiftcheckController = Get.put(ShiftcheckController());
  late List<String> dayList;
  int? selectedDayIndex = 0;
  String? selectedTime;
  String? selectedShiftId;
  String? selectedTimeAsAppointemnt;
  String? currentDate;
  late List<String> daysOfWeek;
  late List<String> daysOfWeekList;
  Map<String, bool> shiftAvailability = {};
  String? dayName;
  String? dayNameCurrent;

  @override
  void initState() {
    super.initState();
    daysOfWeek = getNextWeekDays();
    daysOfWeekList = getNextWeekDays();
    daysOfWeekList[0] = 'Today'.tr();
    daysOfWeekList[1] = 'Tommorrow'.tr();
    dayNameCurrent = daysOfWeek[selectedDayIndex!];
    // updateDayName();
    shiftController.currentDay.value = daysOfWeek[selectedDayIndex!];
    currentDate = getFormattedDate(selectedDayIndex!);
    dayName = '${daysOfWeek[selectedDayIndex!]}_Shifts';
    shiftController.fetchShifts(widget.doctor.id, currentDate!, daysOfWeek[selectedDayIndex!]);
  }

  void updateDayName() {
    dayName = {
      'Saturday': 'Saturday_Shifts',
      'Sunday': 'Sunday_Shifts',
      'Monday': 'Monday_Shifts',
      'Tuesday': 'Tuesday_Shifts',
      'Wednesday': 'Wednesday_Shifts',
      'Thursday': 'Thursday_Shifts',
      'Friday': 'Friday_Shifts'
    }[daysOfWeek[selectedDayIndex!]];
  }

  Future<void> checkShiftAvailability(String shiftId) async {
    final test = await ApiGetServices.checkShifts(shiftId, currentDate!);
    
    setState(() {
      shiftAvailability[shiftId] = test['success']; // Store success/failure
    });
    if(!test['success']){
      toastification.show(
      // type: test['success']
          // ? ToastificationType.success
          // : ToastificationType.error,
      type: ToastificationType.error,
      style: ToastificationStyle.flat,
      title: Text('Error'.tr() ),
      description: Text(test['message']),
      autoCloseDuration: const Duration(seconds: 3),
      // animationDuration: const Duration(milliseconds: 300),
      alignment: Alignment.topRight,
      showProgressBar: true,
    );
    }
    // toastification.show(
    //   // type: test['success']
    //       // ? ToastificationType.success
    //       // : ToastificationType.error,
    //   type: ToastificationType.error,
    //   style: ToastificationStyle.flat,
    //   title: Text(test['success'] ? 'Success' : 'Hmmmmm'),
    //   description: Text(test['message']),
    //   autoCloseDuration: const Duration(seconds: 3),
    //   // animationDuration: const Duration(milliseconds: 300),
    //   alignment: Alignment.topRight,
    //   showProgressBar: true,
    // );
  }

  String getFormattedDate(int index) {
    DateTime now = DateTime.now().add(Duration(days: index));
    return DateFormat('d MMMM yyyy').format(now);
  }

  Map<String, List<Map<String, String>>> categorizeTimes(
      List<Map<String, String>> shifts) {
    List<Map<String, String>> morning = [], afternoon = [], evening = [];

    for (var shift in shifts) {
      String time = shift['time']!;
      String shiftId = shift['shiftId']!;
      DateTime parsedTime = DateFormat('h:mm a').parse(time);

      int hour = parsedTime.hour;

      if (hour >= 5 && hour < 12) {
        morning.add({'shiftId': shiftId, 'time': time});
      } else if (hour >= 12 && hour < 17) {
        afternoon.add({'shiftId': shiftId, 'time': time});
      // } else if (hour >= 17 && hour < 21) {
      } else {
        evening.add({'shiftId': shiftId, 'time': time});
      }
    }

    return {
      'morning': morning,
      'afternoon': afternoon,
      'evening': evening,
    };
  }

  List<String> getNextWeekDays() {
    DateTime now = DateTime.now(); // Get the current date
    List<String> weekDays = [];

    for (int i = 0; i < 7; i++) {
      DateTime day = now.add(Duration(days: i));
      String formattedDay =
          DateFormat('EEEE').format(day); // Example: "26 March Wednesday"
      weekDays.add(formattedDay);
    }
    return weekDays;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Book Appointment".tr(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
  if (shiftController.isLoading.value) {
    return LoadingMessage();
  }

  // List<Map<String, String>> shifts = [];
  List<Map<String, String>> shifts = [];
  if (selectedDayIndex != null && 
      selectedDayIndex! < daysOfWeek.length &&
      shiftController.shiftsByDay.isNotEmpty) {
    
    // Get the current day name (e.g., "Saturday")
    String currentDay = daysOfWeek[selectedDayIndex!];

    // Get shifts for this day from the controller
    List<Shift>? dayShifts = shiftController.shiftsByDay[currentDay];
    
    if (dayShifts != null) {
      shifts = dayShifts.map((shift) => {
        'time': shift.time,
        'shiftId': shift.id,
      }).toList();
    }
  }

  // Categorize the times into morning, afternoon, and evening
  Map<String, List<Map<String, String>>> categorizedTimes = categorizeTimes(shifts);

  return Column(
    children: [
      const SizedBox(height: 30),
      Align(
        alignment: Alignment.topCenter,
        child: CircleAvatar(
          radius: 48,
          backgroundImage: (widget.doctor.picture?.isNotEmpty ?? false) &&
                  widget.doctor.picture != "N/A"
              ? NetworkImage('$url/${widget.doctor.picture}')
              : AssetImage('assets/default_image.png') as ImageProvider,
          backgroundColor: Colors.white,
        ),
      ),
      const SizedBox(height: 15),
      Text(
        widget.doctor.name,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 20),
      // Day selection
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: daysOfWeek.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDayIndex = index;
                      currentDate = getFormattedDate(selectedDayIndex!); // Update the current date
                      // updateDayName();
                      shiftController.fetchShifts(widget.doctor.id, currentDate!, daysOfWeek[selectedDayIndex!]);
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    decoration: BoxDecoration(
                      color: selectedDayIndex == index
                          ? Color.fromARGB(255, 9, 130, 13)
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      daysOfWeekList[index],
                      style: TextStyle(
                        fontSize: 16,
                        color: selectedDayIndex == index
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),

      const SizedBox(height: 20),

      // Time Slots Section
      Flexible(
        child: ListView(
          shrinkWrap: true,
          children: ['morning', 'afternoon', 'evening'].map((timePeriod) {
            List<Map<String, dynamic>> shifts = categorizedTimes[timePeriod] ?? [];

            return Card(
              color: Colors.white,
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          timePeriod.capitalize!,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${categorizedTimes[timePeriod]?.length ?? 0} Slots',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (shifts.isEmpty)
                       Center(
                          child: Text("no_slots_available".tr(),
                              style: TextStyle(color: Colors.grey)))
                    else
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: shifts.map((shift) {
                            String time = shift['time'] ?? '';
                            String shiftId = shift['shiftId'] ?? '';
                            return Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    selectedTime = shift['shiftId'];
                                    selectedShiftId = shift['shiftId'];
                                    selectedTimeAsAppointemnt = shift['time'];
                                    shiftController.errorMessage.value = "";
                                  });
                                  shiftAvailability.clear();
                                  checkShiftAvailability(selectedShiftId!);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      shiftAvailability[shiftId] == true
                                          ? Color.fromARGB(255, 9, 130, 13)
                                          : Colors.blueGrey,
                                ),
                                child: Row(
                                  children: [
                                    Text(time,
                                        style: const TextStyle(
                                            color: Colors.white)),
                                    if (selectedTime == time &&
                                        shiftAvailability[shift['shiftId']] ==
                                            true) ...[
                                      const SizedBox(width: 5),
                                      const Icon(Icons.check,
                                          size: 18, color: Colors.white),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if (selectedShiftId == null || selectedTime == null) {
                toastification.show(
                  type: ToastificationType.error,
                  style: ToastificationStyle.flat,
                  title: Text('Error'.tr()),
                  description: Text('Please select an available time slot'.tr()),
                  autoCloseDuration: const Duration(seconds: 3),
                  alignment: Alignment.topRight,
                  showProgressBar: true,
                );
              } else if (shiftAvailability[selectedShiftId] != true) {
                toastification.show(
                  type: ToastificationType.error,
                  style: ToastificationStyle.flat,
                  title: Text('Error'.tr()),
                  description: Text(
                      'Please check the availability of your selected time'.tr()),
                  autoCloseDuration: const Duration(seconds: 3),
                  alignment: Alignment.topRight,
                  showProgressBar: true,
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PatientDetailsScreen(
                      doctor: widget.doctor,
                      selectedDate: currentDate!,
                      shiftId: selectedShiftId!,
                      selectedTime: selectedTimeAsAppointemnt,
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 9, 130, 13),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ), 
            child: Text(
              "Set Appointment".tr(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    ],
  );
}),

    );
  }
}
