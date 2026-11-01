import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';
import 'package:tele/Models/shift_model.dart';
import 'package:tele/controllers/re_appointment_controller.dart';
import 'package:tele/controllers/shift_controller.dart';
import 'package:tele/services/get_api_services.dart';
import 'package:tele/views/screens/loading_message_screen.dart';
import 'package:toastification/toastification.dart';
import 'package:tele/services/StorageService.dart';

class ReAppointmentScreen extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final String patientId;
  final String appointmentDate;
  final String appointmentTime;
  final String appointmentId;
  final String patientToken;
  final String doctorToken;

  const ReAppointmentScreen({
    super.key,
    required this.doctorId,
    required this.doctorName,
    required this.patientId,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.appointmentId,
    required this.patientToken,
    required this.doctorToken,
  });

  @override
  _ReAppointmentScreenState createState() => _ReAppointmentScreenState();
}

class _ReAppointmentScreenState extends State<ReAppointmentScreen> {
  final shiftController = Get.put(ShiftController());
  final reAppointmentController = Get.put(ReAppointmentController());
  late List<String> daysOfWeek;
  late List<String> daysOfWeekList;
  int? selectedDayIndex = 0;
  String? selectedTime;
  String? selectedShiftId;
  String? selectedTimeAsAppointment;
  String? currentDate;
  String? selectedTimeAsAppointemnt;
  String? token;
  Map<String, bool> shiftAvailability = {};

  @override
  void initState() {
    super.initState();
    loadUserData();
    daysOfWeek = getNextWeekDays();
    daysOfWeekList = getNextWeekDays();
    daysOfWeekList[0] = 'Today'.tr();
    daysOfWeekList[1] = 'Tomorrow'.tr();

    shiftController.currentDay.value = daysOfWeek[selectedDayIndex!];
    currentDate = getFormattedDate(selectedDayIndex!);
    shiftController.fetchShifts(
        widget.doctorId, currentDate!, daysOfWeek[selectedDayIndex!]);
  }
  Future<void> loadUserData() async {
    Map<String, String?> userData = await StorageService.getUserData();
    setState(() {
      token = userData['auth_token'] ?? '';
      
    });
  }

  String getFormattedDate(int index) {
    DateTime now = DateTime.now().add(Duration(days: index));
    return DateFormat('d MMMM yyyy').format(now);
  }

  List<String> getNextWeekDays() {
    DateTime now = DateTime.now();
    List<String> weekDays = [];

    for (int i = 0; i < 7; i++) {
      DateTime day = now.add(Duration(days: i));
      String formattedDay = DateFormat('EEEE').format(day);
      weekDays.add(formattedDay);
    }
    return weekDays;
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
      } else if (hour >= 17 && hour < 21) {
        evening.add({'shiftId': shiftId, 'time': time});
      }
    }

    return {
      'morning': morning,
      'afternoon': afternoon,
      'evening': evening,
    };
  }

  Future<void> checkShiftAvailability(String shiftId) async {
    final test = await ApiGetServices.checkShifts(shiftId, currentDate!);

    setState(() {
      shiftAvailability[shiftId] = test['success']; // Store success/failure
    });
    if (!test['success']) {
      toastification.show(
        // type: test['success']
        // ? ToastificationType.success
        // : ToastificationType.error,
        type: ToastificationType.error,
        style: ToastificationStyle.flat,
        title: Text('Error'.tr()),
        description: Text(test['message']),
        autoCloseDuration: const Duration(seconds: 3),
        // animationDuration: const Duration(milliseconds: 300),
        alignment: Alignment.topRight,
        showProgressBar: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        if (shiftController.isLoading.value) {
          return LoadingMessage();
        }

        List<Map<String, String>> shifts = [];
        if (selectedDayIndex != null &&
            selectedDayIndex! < daysOfWeek.length &&
            shiftController.shiftsByDay.isNotEmpty) {
          String currentDay = daysOfWeek[selectedDayIndex!];
          List<Shift>? dayShifts = shiftController.shiftsByDay[currentDay];
          if (dayShifts != null) {
            shifts = dayShifts
                .map((shift) => {
                      'time': shift.time,
                      'shiftId': shift.id,
                    })
                .toList();
          }
        }

        Map<String, List<Map<String, String>>> categorizedTimes =
            categorizeTimes(shifts);

        return Column(
          children: [
            const SizedBox(height: 30),
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
                            currentDate = getFormattedDate(selectedDayIndex!);
                            shiftController.fetchShifts(widget.doctorId,
                                currentDate!, daysOfWeek[selectedDayIndex!]);
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
                  List<Map<String, dynamic>> shifts =
                      categorizedTimes[timePeriod] ?? [];

                  return Card(
                    color: Colors.white,
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                            const Center(
                                child: Text("No slots available",
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
                                          selectedTimeAsAppointemnt =
                                              shift['time'];
                                          shiftController.errorMessage.value =
                                              "";
                                        });
                                        shiftAvailability.clear();
                                        checkShiftAvailability(
                                            selectedShiftId!);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            shiftAvailability[shiftId] == true
                                                ? Color.fromARGB(
                                                    255, 9, 130, 13)
                                                : Colors.blueGrey,
                                      ),
                                      child: Row(
                                        children: [
                                          Text(time,
                                              style: const TextStyle(
                                                  color: Colors.white)),
                                          if (selectedTime == time &&
                                              shiftAvailability[
                                                      shift['shiftId']] ==
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
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (selectedShiftId == null || selectedTime == null) {
                      toastification.show(
                        type: ToastificationType.error,
                        style: ToastificationStyle.flat,
                        title: Text('Error'.tr()),
                        description:
                            Text('Please select an available time slot'.tr()),
                        autoCloseDuration: const Duration(seconds: 3),
                        alignment: Alignment.topRight,
                        showProgressBar: true,
                      );
                    } else {
                      DateTime appointmentDateTime;
                      try {
                        appointmentDateTime =
                            DateTime.parse(widget.appointmentDate);
                      } catch (e) {
                        appointmentDateTime = DateFormat('dd MMMM yyyy')
                            .parse(widget.appointmentDate);
                      }

                      // Now define a function that formats a DateTime, not a string
                      String formatAppointmentDate(DateTime date) {
                        return DateFormat('d MMMM yyyy').format(date);
                      }

                      print('Calling reAppointment with:');
                      print('Doctor ID: ${widget.doctorId}');
                      print('Patient ID: ${widget.patientId}');
                      print(
                          'Appointment Date: ${formatAppointmentDate(appointmentDateTime)}');
                      print('Selected Shift ID: $selectedShiftId');
                      print('Appointment ID: ${widget.appointmentId}');
                      print('Current Date: $currentDate');
                      print('Status Code: 4');
                      await reAppointmentController.reAppointment(
                        currentDate!, // format the already parsed DateTime
                        selectedShiftId!,
                        widget.appointmentId,
                        4,
                        widget.doctorName,
                       widget.appointmentTime,
                       widget.patientToken,
                       widget.doctorToken,
                       widget.doctorId,
                       widget.patientId
                      );
                     
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 9, 130, 13),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    "Set Appointment".tr(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
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
