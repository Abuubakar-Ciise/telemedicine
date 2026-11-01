import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:easy_localization/easy_localization.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tele/controllers/labs_controller.dart';
import 'package:toastification/toastification.dart';

class LabsRecordScreen extends StatefulWidget {
  final String appointmentId;
  final String patientId;
  final String doctorId;
  final String doctorToken;
  final String patientToken;

  const LabsRecordScreen({
    super.key,
    required this.appointmentId,
    required this.patientId,
    required this.doctorId,
    required this.doctorToken,
    required this.patientToken,
  });

  @override
  _LabsRecordScreenState createState() => _LabsRecordScreenState();
}

class _LabsRecordScreenState extends State<LabsRecordScreen> {
  // final AppoinmentsController _appointmentController = Get.find();
  final LabsController _labsController = Get.put(LabsController());

  File? _selectedImage;
  late String _selectedPatientId;
  late String _selectedDoctorId;
  late String _selectedAppointmentId;

  @override
  void initState() {
    super.initState();
    _selectedAppointmentId = widget.appointmentId;
    _selectedDoctorId = widget.doctorId;
    _selectedPatientId = widget.patientId;
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: Text('Take a photo'.tr()),
            onTap: () async {
              Navigator.pop(context);
              final picked =
                  await ImagePicker().pickImage(source: ImageSource.camera);
              if (picked != null) {
                setState(() {
                  _selectedImage = File(picked.path);
                });
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: Text('Choose from gallery'.tr()),
            onTap: () async {
              Navigator.pop(context);
              final picked =
                  await ImagePicker().pickImage(source: ImageSource.gallery);
              if (picked != null) {
                setState(() {
                  _selectedImage = File(picked.path);
                });
              }
            },
          ),
        ],
      ),
    );
  }

  void _uploadRecord() async {
    if (_selectedImage == null) {
      toastification.show(
        context: context,
        title: Text("Missing Image".tr()),
        description: Text("Please select a lab image.".tr()),
        type: ToastificationType.warning,
        autoCloseDuration: const Duration(seconds: 3),
      );
      return;
    }

    await _labsController.uploadLabRecord(
      imageFile: _selectedImage!,
      patientId: _selectedPatientId,
      doctorId: _selectedDoctorId,
      appointmentId: _selectedAppointmentId,
      doctorToken: widget.doctorToken,
      patientToken: widget.patientToken
    );

    setState(() {
      _selectedImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Upload Lab Record".tr()),
      ),
      body: Obx(() {
        if (_labsController.isUploading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Lab Report Image".tr(),
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              InkWell(
                onTap: _pickImage,
                child: _selectedImage != null
                    ? Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.file(
                          _selectedImage!,
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const DottedBorderPlaceholder(),
              ),
              const SizedBox(height: 10),
              Center(
                child: TextButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image_outlined, color: Colors.white),
                  label: Text("Pick / Change Image".tr(),
                      style: TextStyle(color: Colors.white)),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.cloud_upload_outlined,
                      color: Colors.white),
                  label: Text("Upload & Save Record".tr(),
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size(double.infinity, 50),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 5,
                  ),
                  onPressed:
                      _labsController.isUploading.value ? null : _uploadRecord,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class DottedBorderPlaceholder extends StatelessWidget {
  const DottedBorderPlaceholder({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, style: BorderStyle.solid),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child:  Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_photo_alternate_outlined,
              size: 50, color: Colors.grey),
          SizedBox(height: 10),
          Text("Tap_to_add_lab_image".tr(), style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
