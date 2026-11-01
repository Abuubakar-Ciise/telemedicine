import 'package:flutter/material.dart';
import 'package:tele/theme/app_theme.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart' hide Trans;
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';
import 'package:tele/DoctorPrescriptionDetailScreen.dart';
import 'package:tele/PrescriptionDetailScreen.dart';
import 'package:tele/controllers/doctor_prescription_controller.dart';
import 'package:tele/controllers/labs_report_controller.dart';
import 'package:tele/controllers/labs_requested_controller.dart';
import 'package:tele/services/StorageService.dart';
import 'package:tele/views/screens/components/config.dart';
import 'package:tele/views/screens/loading_message_screen.dart';
import 'package:tele/views/screens/patient/LabReportViewerScreen.dart';
import 'package:tele/views/screens/patient/ReviewsScreen.dart';
import 'package:tele/views/screens/patient/labs_records_screen.dart';

class PatientAppointmentChatScreen extends StatefulWidget {
  final String id;
  final String doctorName;
  final String patientName;
  final String patientProfile;
  final String doctorToken;
  final String patientToken;
  final String doctorPhone;
  final String patientPhone;
  final String doctorId;
  final String patientId;
  final int status;
  final String isReviewed;

  const PatientAppointmentChatScreen({
    super.key,
    required this.id,
    required this.doctorName,
    required this.patientName,
    required this.patientProfile,
    required this.doctorToken,
    required this.patientToken,
    required this.doctorPhone,
    required this.patientPhone,
    required this.doctorId,
    required this.patientId,
    required this.status,
    required this.isReviewed,
  });

  @override
  State<PatientAppointmentChatScreen> createState() =>
      _PatientAppointmentChatScreenState();
}

class _PatientAppointmentChatScreenState
    extends State<PatientAppointmentChatScreen> {
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
  }

  Future<void> initAsync() async {
    await controller.getPrescriptions(
      widget.doctorId,
      widget.patientId,
      widget.id,
    );
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
    picture = userData['picture'] ?? "N/A";
    userId = userData["userId"] ?? "Unknown";
    await controller.getPatientPrescriptions(
      userId!,
      widget.doctorId,
    );
    await labs.labsReports(widget.patientId, widget.doctorId, widget.id);

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
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

  void _addLabs() {
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
            child: LabsRecordScreen(
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

  // feedback
  void _feeback() {
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
      builder: (context) => ReviewsScreen(
        doctorId: widget.doctorId,
        patientId: widget.patientId,
        appointmentId: widget.id,
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.brand),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Back',
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
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
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.patientName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (_showFullAppBar) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Online'.tr(),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Row(
            children: [
              Tooltip(
                message: "Only the doctor can call you.".tr(),
                child: GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Only the doctor can call you.".tr()),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Icon(
                    Icons.call,
                    size: 28,
                    color: AppColors.brand.withOpacity(0.4),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Tooltip(
                message: "Only the doctor can video call you.".tr(),
                child: GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Only the doctor can video call you.".tr()),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Icon(
                    Icons.videocam,
                    size: 28,
                    color: AppColors.brand.withOpacity(0.4),
                  ),
                ),
              ),
            ],
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
                    ? "${labRequestCount} ${'lab_request'.tr()}${labRequestCount > 1 ? 's' : ''} ${'requested'.tr()}"
                    : "No lab requests listed".tr();

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
                              Text("${widget.doctorName}")
                            ],
                          ),
                          const SizedBox(height: 10),

                          /// Patient
                          Row(
                            children: [
                              const Icon(Icons.person,
                                  size: 18, color: Colors.green),
                              const SizedBox(width: 6),
                              Text("Patient: ${item.patientName}",
                                  style: const TextStyle(fontSize: 14)),
                            ],
                          ),

                          /// Date
                          Row(
                            children: [
                              const Icon(Icons.calendar_today,
                                  size: 18, color: Colors.orange),
                              const SizedBox(width: 6),
                              Text("Date: $date",
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
                            child:  Center(
                              child: Text(
                                "Tap_to_view_full_lab_request".tr(),
                                style: const TextStyle(
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
        // Padding(
        //   padding: const EdgeInsets.all(16.0),
        //   child: SizedBox(
        //     width: double.infinity,
        //     child: ElevatedButton(
        //       onPressed: () {
        //         // TODO: Implement add prescription logic
        //         print("appointmentId ${widget.id}");
        //         print("pateintId ${widget.patientId}");
        //         print("doctorId ${widget.doctorId}");
        //         _addLabRequest();
        //       },
        //       style: ElevatedButton.styleFrom(
        //         backgroundColor: Colors.blueAccent,
        //         padding: const EdgeInsets.symmetric(vertical: 14),
        //         shape: RoundedRectangleBorder(
        //             borderRadius: BorderRadius.circular(12)),
        //       ),
        //       child: const Text("Add Lab Request",
        //           style: TextStyle(fontSize: 16, color: Colors.white)),
        //     ),
        //   ),
        // ),
      ],
    );
  }

  Widget _buildPrescriptionTab() {
    return Column(
      children: [
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.prescriptions.isEmpty) {
              return Center(child: Text("No prescriptions found.".tr()));
            }
            return ListView.builder(
              // controller: _scrollController,
              controller: _prescriptionScrollController,
              padding: const EdgeInsets.all(16),
              itemCount: controller.prescriptions.length,
              itemBuilder: (context, index) {
                final item = controller.prescriptions[index];
                final date =
                    DateFormat.yMMMMd().add_jm().format(item.createDate);
                final medicineCount = item.medicines?.length ?? 0;
                final summary = medicineCount > 0
                    ? "${medicineCount} ${'medicine'.tr()}${medicineCount > 1 ? 's' : ''} ${'prescribed'.tr()}"
                    : "No medicines listed".tr();

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              PrescriptionDetailScreen(prescription: item)),
                    );
                  },
                  child: Card(
                    color: Colors.white,
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.medical_services,
                                  color: Colors.blue),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text("Dr. ${item.doctorName}",
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600)),
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
                              Text("Patient: ${item.patientName}",
                                  style: const TextStyle(fontSize: 14)),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today,
                                  size: 18, color: Colors.orange),
                              const SizedBox(width: 6),
                              Text("Date: $date",
                                  style: const TextStyle(fontSize: 14)),
                            ],
                          ),
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
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child:  Center(
                              child: Text(
                                "Tap_to_view_full_prescription".tr(),
                                style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14),
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
        // if(widget.isReviewed == 'false') _buildFeedbackButton(),

        (widget.status == 2 && widget.isReviewed == 'false')
            ? _buildFeedbackButton()
            : SizedBox.shrink()
        // Padding(
        //   padding: const EdgeInsets.all(16.0),
        //   child: SizedBox(
        //     width: double.infinity,
        //     child: ElevatedButton(
        //       onPressed: () {
        //         // TODO: Implement add prescription logic
        //         print("appointmentId ${widget.id}");
        //         print("pateintId ${widget.patientId}");
        //         print("doctorId ${widget.doctorId}");
        //         _feeback();

        //       },
        //       style: ElevatedButton.styleFrom(
        //         backgroundColor: Colors.green,
        //         padding: const EdgeInsets.symmetric(vertical: 14),
        //         shape: RoundedRectangleBorder(
        //             borderRadius: BorderRadius.circular(12)),
        //       ),
        //       child: const Text("Feedback",
        //           style: TextStyle(fontSize: 16, color: Colors.white)),
        //     ),
        //   ),
        // ),
      ],
    );
  }

  Widget _buildFeedbackButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            print("appointmentId ${widget.id}");
            print("pateintId ${widget.patientId}");
            print("doctorId ${widget.doctorId}");
            _feeback();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            "Feedback".tr(),
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ),
    );
  }

  // Widget _buildLabsTab() {
  //   return Column(
  //     children: [],
  //   );
  // }
  Widget _buildLabsTab() {
    return Column(
      children: [
        Expanded(
          child: Obx(() {
            if (labs.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            if (labs.labsReport.isEmpty) {
              return Center(child: Text("No lab reports found.".tr()));
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
                            Text("Patient: ${report.patientName}",
                                style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today,
                                size: 18, color: Colors.orange),
                            const SizedBox(width: 6),
                            Text("Date: $date",
                                style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.insert_drive_file,
                                size: 18, color: Colors.blue),
                            const SizedBox(width: 6),
                            Text("Report ID: ${report.sequenceId}",
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
                            child:  Center(
                              child: Text(
                                "Tap_to_view_lab_report".tr(),
                                style: const TextStyle(
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
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                print("appointmentId ${widget.id}");
                print("pateintId ${widget.patientId}");
                print("doctorId ${widget.doctorId}");
                _addLabs();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Add Lab Report".tr(),
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    print("appoint id ,${widget.id}");
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
                  Tab(
                    text: "Lab_Request".tr(),
                  ),
                  Tab(text: "Prescription".tr()),
                  Tab(text: "Labs".tr()),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildLabRequestTab(),
                    _buildPrescriptionTab(),
                    _buildLabsTab(),
                    // Center(child: Text("labs")),
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
