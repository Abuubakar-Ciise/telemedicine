import 'package:flutter/material.dart';
import 'package:tele/services/call_session.dart';
import 'package:tele/theme/app_theme.dart';
import 'package:get/get.dart' hide Trans;
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';
import 'package:tele/DoctorPrescriptionDetailScreen.dart';
import 'package:tele/DoctorPrescriptionScreen.dart';
import 'package:tele/PrescriptionDetailScreen.dart';
import 'package:tele/controllers/doctor_prescription_controller.dart';
import 'package:tele/controllers/labs_report_controller.dart';
import 'package:tele/controllers/labs_requested_controller.dart';
import 'package:tele/services/StorageService.dart';
import 'package:tele/services/firebase_api.dart';
import 'package:tele/views/screens/CallPage/call_page.dart';
import 'package:tele/views/screens/components/config.dart';
import 'package:tele/views/screens/components/doctor_lab_request.dart';
import 'package:tele/views/screens/loading_message_screen.dart';
import 'package:tele/views/screens/patient/LabReportViewerScreen.dart';

class DoctorAppointmentChatScreen extends StatefulWidget {
  final String doctorName;
  final String patientName;
  final String patientProfile;
  final String doctorToken;
  final String patientToken;
  final String doctorPhone;
  final String patientPhone;
  final String doctorId;
  final String patientId;
  final String id;

  const DoctorAppointmentChatScreen({
    super.key,
    required this.doctorName,
    required this.patientName,
    required this.patientProfile,
    required this.doctorToken,
    required this.patientToken,
    required this.doctorPhone,
    required this.patientPhone,
    required this.doctorId,
    required this.patientId,
    required this.id,
  });

  @override
  State<DoctorAppointmentChatScreen> createState() =>
      _DoctorAppointmentChatScreenState();
}

class _DoctorAppointmentChatScreenState
    extends State<DoctorAppointmentChatScreen> {
  final url = Config.baseUrl;
  final ScrollController _scrollController = ScrollController();
  final ScrollController _prescriptionScrollController = ScrollController();
  final ScrollController _labsScrollController = ScrollController();

  double _avatarSize = 40;
  bool _showFullAppBar = true;
  String? picture;
  String? userId;
  final DoctorPrescriptionController controller =
      Get.put(DoctorPrescriptionController());
  final LabsReportController labs = Get.put(LabsReportController());
  final LabsRequestedController labsRequested =
      Get.put(LabsRequestedController());

  @override
  void initState() {
    super.initState();
    loadUserData();
    initAsync();
    _scrollController.addListener(_handleScroll);
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    // });
  }

  Future<void> initAsync() async {
    await controller.getPrescriptions(widget.doctorId, widget.patientId, widget.id,);
    await labsRequested.getDoctorLabsRequest(
        patientId: widget.patientId,
        doctorId: widget.doctorId,
        appointmentId: widget.id);
    print("ddddddd ${widget.doctorId}");
    await labs.labsReports(widget.patientId, widget.doctorId, widget.id);
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  Future<void> loadUserData() async {
    Map<String, String?> userData = await StorageService.getUserData();
    userId = userData["userId"] ?? "Unknown";
    print("User ID: $userId");
    setState(() {
      picture = userData['picture'] ?? "N/A";
      userId = userId;
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    final offset = _scrollController.offset;
    if (offset > 0 && offset < 100) {
      setState(() {
        _avatarSize = 40 - (offset * 0.3).clamp(0, 16);
        _showFullAppBar = offset < 30;
      });
    } else if (offset <= 0) {
      setState(() {
        _avatarSize = 40;
        _showFullAppBar = true;
      });
    }
  }

  void _addPrescriptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.75,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: DoctorPrescriptionScreen(
              patientId: widget.patientId,
              doctorId: widget.doctorId,
              appointmentId: widget.id,
              doctorToken: widget.doctorToken,
              patientToken: widget.patientToken,
            ),
          ),
        );
      },
    );
  }

  void _addLabRequest() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (context) {
          return FractionallySizedBox(
            heightFactor: 0.75,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: DoctorLabRequest(
                doctorId: widget.doctorId, 
                patientId: widget.patientId, 
                appointmentId: widget.id, 
                doctorToken: widget.doctorToken, 
                patientToken: widget.patientToken),
            ),
          );
        });
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.brand),
            onPressed: () => Navigator.pop(context),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: _avatarSize,
            height: _avatarSize,
            child: CircleAvatar(
              backgroundColor: Colors.grey.shade200,
              backgroundImage: (widget.patientProfile.isNotEmpty &&
                      widget.patientProfile != "N/A")
                  ? NetworkImage('$url/${widget.patientProfile}')
                  : const AssetImage('assets/default_image.png')
                      as ImageProvider,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.patientName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (_showFullAppBar) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: const [
                      CircleAvatar(
                        radius: 4,
                        backgroundColor: Colors.green,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Online',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.call, color: AppColors.brand),
            onPressed: () => _startCall('0'),
          ),
          IconButton(
            icon: const Icon(Icons.videocam, color: AppColors.brand),
            onPressed: () => _startCall('1'),
          ),
        ],
      ),
    );
  }

  Widget _buildLabRequestTab() {
    return Column(
      children: [
        Expanded(child: Obx(() {
          if (labsRequested.isLoading.value) {
            return const Center(
              child: LoadingMessage(),
            );
          }
          if (labsRequested.doctorLabsRequest.isEmpty) {
                          return Center(
                child: Text("No Lab Requested Found".tr()),
              );
          }
          return ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(15),
              itemCount: labsRequested.doctorLabsRequest.length,
              itemBuilder: (context, index) {
                final item = labsRequested.doctorLabsRequest[index];
                final date =
                    DateFormat.yMMMMd().add_jm().format(item.createDate);
                final labRequestCount = item.requestTests?.length ?? 0;
                final summary = labRequestCount > 0
                                         ? "${labRequestCount} lab request${labRequestCount > 1 ? 's' : ''} requested"
                     : "No lab requests listed";

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            LabRequestDetailScreen(labRequest: item),
                      ),
                    );
                  },
                  child: Card(
                    color: Colors.white,
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// Header row: Icon + Doctor name + Arrow
                          Row(
                            children: [
                              const Icon(
                                Icons.medical_services,
                                color: Colors.blue,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text("${widget.doctorName}",
                                    overflow: TextOverflow.ellipsis),
                              )
                            ],
                          ),
                          const SizedBox(height: 10),

                          /// Patient
                          Row(
                            children: [
                              const Icon(Icons.person,
                                  size: 18, color: Colors.green),
                              const SizedBox(width: 6),
                              Text("${'patient'.tr()}: ${item.patientName}",
                                  style: const TextStyle(fontSize: 14)),
                            ],
                          ),

                          /// Date
                          Row(
                            children: [
                              const Icon(Icons.calendar_today,
                                  size: 18, color: Colors.orange),
                              const SizedBox(width: 6),
                              Text("${'date'.tr()}: $date",
                                  style: const TextStyle(fontSize: 14)),
                            ],
                          ),

                          /// Medicine Summary
                          Row(
                            children: [
                              const Icon(Icons.list_alt,
                                  size: 18, color: Colors.purple),
                              const SizedBox(width: 6),
                              Text(summary,
                                  style: const TextStyle(fontSize: 14)),
                            ],
                          ),

                          const SizedBox(height: 12),

                          /// Call-to-action
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Center(
                              child: Text(
                                "Tap to view full prescription",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              });
        })),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Implement add prescription logic
                print("appointmentId ${widget.id}");
                print("pateintId ${widget.patientId}");
                print("doctorId ${widget.doctorId}");
                _addLabRequest();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text("Add_Lab_Request".tr(),
                  style: const TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrescriptionTab() {
    return Column(
      children: [
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return  Center(child: LoadingMessage());
            }

            if (controller.prescriptions.isEmpty) {
              return  Center(child: Text("No_prescriptions_found.".tr()));
            }

            return ListView.builder(
              controller: _prescriptionScrollController,
              padding: const EdgeInsets.all(16),
              itemCount: controller.prescriptions.length,
              itemBuilder: (context, index) {
                final item = controller.prescriptions[index];
                final date =
                    DateFormat.yMMMMd().add_jm().format(item.createDate);
                final medicineCount = item.medicines?.length ?? 0;
                final summary = medicineCount > 0
                    ? "${medicineCount} ${'medicine'.tr()}${medicineCount > 1 ? 's'.tr() : ''} ${'prescribed'.tr()}"
                    : 'no_medicines_listed'.tr();

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            PrescriptionDetailScreen(prescription: item),
                      ),
                    );
                  },
                  child: Card(
                    color: Colors.white,
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// Header row: Icon + Doctor name + Arrow
                          Row(
                            children: [
                              const Icon(Icons.medical_services,
                                  color: Colors.blue, size: 24),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Dr. ${item.doctorName}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              // const Icon(Icons.arrow_forward_ios,
                              //     size: 16, color: Colors.grey),
                            ],
                          ),

                          const SizedBox(height: 10),

                          /// Patient
                          Row(
                            children: [
                              const Icon(Icons.person,
                                  size: 18, color: Colors.green),
                              const SizedBox(width: 6),
                              Text("${'patient'.tr()}: ${item.patientName}",
                                  style: const TextStyle(fontSize: 14)),
                            ],
                          ),

                          /// Date
                          Row(
                            children: [
                              const Icon(Icons.calendar_today,
                                  size: 18, color: Colors.orange),
                              const SizedBox(width: 6),
                              Text("${'date'.tr()}: $date",
                                  style: const TextStyle(fontSize: 14)),
                            ],
                          ),

                          /// Medicine Summary
                          Row(
                            children: [
                              const Icon(Icons.list_alt,
                                  size: 18, color: Colors.purple),
                              const SizedBox(width: 6),
                              Text(summary,
                                  style: const TextStyle(fontSize: 14)),
                            ],
                          ),

                          const SizedBox(height: 12),

                          /// Call-to-action
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Center(
                              child: Text(
                                "Tap to view full prescription",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Implement add prescription logic
                print("appointmentId ${widget.id}");
                print("pateintId ${widget.patientId}");
                print("doctorId ${widget.doctorId}");
                _addPrescriptions();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text("Add_Prescription".tr(),
                  style: const TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabsTab() {
    return Column(
      children: [
        Expanded(
          child: Obx(() {
            if (labs.isLoading.value) {
              return const Center(child: LoadingMessage());
            }
            if (labs.labsReport.isEmpty) {
              return  Center(child: Text("No_lab_reports_found.".tr()));
            }

            return ListView.builder(
              // controller: _scrollController,
              controller: _labsScrollController,
              padding: const EdgeInsets.all(16),
              itemCount: labs.labsReport.length,
              itemBuilder: (context, index) {
                final report = labs.labsReport[index];
                final date =
                    DateFormat.yMMMMd().add_jm().format(report.createDate);
                final reportUrl = '$url/${report.reportUrl}';

                return Card(
                  color: Colors.white,
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.biotech, color: Colors.red),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Dr. ${report.doctorName}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios,
                                size: 16, color: Colors.grey),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.person,
                                size: 18, color: Colors.green),
                            const SizedBox(width: 6),
                            Text("${'patient'.tr()}: ${report.patientName}",
                                style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today,
                                size: 18, color: Colors.orange),
                            const SizedBox(width: 6),
                            Text("${'date'.tr}: $date",
                                style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.insert_drive_file,
                                size: 18, color: Colors.blue),
                            const SizedBox(width: 6),
                            Text("${'report_id'.tr()}: ${report.sequenceId}",
                                style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () async {
                            final uri = Uri.parse(reportUrl);
                            // if (await canLaunchUrl(uri)) {
                            //   await launchUrl(uri,
                            //       mode: LaunchMode.externalApplication);
                            // } else {
                            //   ScaffoldMessenger.of(context).showSnackBar(
                            //     const SnackBar(
                            //         content: Text("Could not open report")),
                            //   );
                            // }
                            // Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    LabReportViewerScreen(reportUrl: reportUrl),
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Center(
                              child: Text(
                                "Tap to view lab report",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ),
        // Padding(
        //   padding: const EdgeInsets.all(16.0),
        //   child: SizedBox(
        //     width: double.infinity,
        //     child: ElevatedButton(
        //       onPressed: () {
        //         print("appointmentId ${widget.id}");
        //         print("pateintId ${widget.patientId}");
        //         print("doctorId ${widget.doctorId}");
        //         // _addLabs();
        //       },
        //       style: ElevatedButton.styleFrom(
        //         backgroundColor: AppColors.brand,
        //         padding: const EdgeInsets.symmetric(vertical: 14),
        //         shape: RoundedRectangleBorder(
        //           borderRadius: BorderRadius.circular(12),
        //         ),
        //       ),
        //       child: const Text("Add Lab Report",
        //           style: TextStyle(fontSize: 16, color: Colors.white)),
        //     ),
        //   ),
        // ),
      ],
    );
  }

  /// Rings the patient, then opens the call. If the patient's phone can't be
  /// reached, explain why instead of opening an empty call.
  Future<void> _startCall(String callType) async {
    final roomId = "call_${DateTime.now().millisecondsSinceEpoch}";
    // Track the call on the server first (decline / cancel / missed work even without push)
    await CallSession.start(
      roomId: roomId,
      doctorId: widget.doctorId,
      patientId: widget.patientId,
      callType: callType,
      callerType: 'doctor',
    );
    final result = await FirebaseApis().sendCallFCM(
      widget.patientToken,
      widget.doctorName,
      roomId,
      widget.doctorPhone,
      widget.patientProfile,
      callType,
      widget.doctorToken,
      widget.patientToken,
      widget.doctorId,
      widget.patientId,
      calleeType: 'patient',
      calleeId: widget.patientId,
    );
    if (!mounted) return;
    if (!result.delivered) {
      // Push can't reach the patient's phone right now (closed app / no Google
      // services). Still call: the patient's app shows the call when it's open.
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("The patient's phone can't get notifications right now. "
            "They will see your call if the Tayo app is open."),
        duration: Duration(seconds: 5),
      ));
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CallPage(
          callId: roomId,
          callType: callType,
          peerName: widget.patientName,
          peerPicture: widget.patientProfile,
          isCaller: true,
          calleeType: 'patient',
          calleeId: widget.patientId,
          doctorId: widget.doctorId,
          patientId: widget.patientId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
               TabBar(
                labelColor: AppColors.brand,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.green,
                tabs: [
                  Tab(text: "Lab_Request".tr()),
                  Tab(text: "Prescription".tr()),
                  Tab(text: "Labs".tr()),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildLabRequestTab(),
                    _buildPrescriptionTab(),
                    _buildLabsTab()
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

  // Helper method to create Row widgets that handle text overflow
  Widget _buildInfoRow(IconData icon, Color iconColor, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }