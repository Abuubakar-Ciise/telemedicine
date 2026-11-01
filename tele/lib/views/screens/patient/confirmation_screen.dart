import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart' hide Trans;
import 'package:easy_localization/easy_localization.dart';
import 'package:tele/Models/doctors_list_nodel.dart';
import 'package:tele/controllers/appoinments_controller.dart';
import 'package:tele/controllers/payment_controller.dart';
import 'package:tele/services/new_firebase_send_message.dart';
import 'package:tele/services/post_api_services.dart';
import 'package:tele/views/screens/PaymentStatusScreen.dart';
import 'package:tele/views/screens/components/config.dart';
import 'package:tele/views/screens/loading_message_screen.dart';
import 'package:tele/views/screens/main_screen.dart';

class ConfirmationScreen extends StatelessWidget {
  final Map<String, String> patientData;
  final DoctorList doctor;
  final String selectedDay;
  final String selectedDate;
  final String? selectedTime;
  final String? shifId;
  final String patientId;
  final Map<String, dynamic>? selectedPackage;

  ConfirmationScreen({
    super.key,
    required this.patientData,
    required this.doctor,
    required this.selectedDay,
    required this.patientId,
    required this.selectedDate,
    required this.selectedTime,
    required this.shifId,
    this.selectedPackage,
  });
  final paymentController = Get.put(PaymentController());
  final url = Config.baseUrl;
  static final String maer = dotenv.env['MERCHANTUID'] ?? '';
  static final String api = dotenv.env['APIUSERID'] ?? '';
  static final String apikey = dotenv.env['APIKEY'] ?? '';
  // int doctorFee =  d
  // You get doctor token by doctor.doctorToken

  @override
  Widget build(BuildContext context) {
    // doctor.consultationfee = 0.01;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Payment Method'.tr(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Obx(() {
        if (paymentController.isLoading.value) {
          return LoadingMessage();
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDoctorCard(),
              const SizedBox(height: 16),
              _sectionTitle('Scheduled Appointment'.tr()),
              _infoRow('Date'.tr(), selectedDate),
              // _infoRow('Time', shifId ?? 'N/A'),
              _infoRow('Time'.tr(), selectedTime ?? 'N/A'),
              _infoRow('Duration'.tr(), '30 Minutes'.tr()),
              const SizedBox(height: 16),
              _sectionTitle('Patient Information'.tr()),
              _infoRow('Name'.tr(), patientData['name'] ?? 'N/A'),
              _infoRow('phone'.tr(), patientData['phone'] ?? 'N/A'),
              _infoRow('Gender'.tr(), patientData['gender'] ?? 'N/A'),
              _infoRow('Age'.tr(), patientData['age'] ?? 'N/A'),
              _infoRow('problem'.tr(), patientData['problem'] ?? 'N/A'),
              const SizedBox(height: 16),
              _buildSelectedPackageCard(),
              const SizedBox(height: 24),
              _buildPayButton(context),
            ],
          ),
        );
      }),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title,
        style: const TextStyle(
            fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black));
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.black54)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDoctorCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F2FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: (doctor.picture.isNotEmpty && doctor.picture != 'N/A')
                ? Image.network(
                    '$url/${doctor.picture}',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    'assets/default_image.png',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doctor.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                Text(
                    '${doctor.speciality} • ${doctor.experienceyears} Years of Experience',
                    style:
                        const TextStyle(fontSize: 12, color: Colors.black54)),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.orange, size: 16),
                    const SizedBox(width: 4),
                    Text(doctor.rating.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          // const Icon(Icons.location_on, color: Colors.purple),
        ],
      ),
    );
  }

  Widget _buildSelectedPackageCard() {
    if (selectedPackage == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: selectedPackage!['color'],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(selectedPackage!['icon'], color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(selectedPackage!['title'],
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(selectedPackage!['price'],
                    style:
                        const TextStyle(fontSize: 14, color: Colors.black54)),
              ],
            ),
          ),
          Radio(
            value: true,
            groupValue: true,
            onChanged: (value) {},
            activeColor: Color.fromARGB(255, 9, 130, 13),
          )
        ],
      ),
    );
  }

  void _showResult(bool success, String message) {
    Get.to(
      () => PaymentStatusScreen(
        isSuccess: success,
        paymentStatus: success ? message : '',
        errorMessage: success ? '' : message,
      ),
      transition: Transition.fadeIn,
    );
  }

  Widget _buildPayButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color.fromARGB(255, 9, 130, 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onPressed: () async {
          // 1. A time slot is required
          final shiftId = shifId ?? '';
          if (shiftId.isEmpty) {
            _showResult(false, 'Please choose a time slot before paying.');
            return;
          }
          try {
            // 2. Payment (mock until real WaafiPay keys are configured)
            await paymentController.pay(
                phone: patientData['phone'] ?? '',
                amount: doctor.consultationfee,
                merchantUid: maer,
                apiUserId: api,
                apiKey: apikey);
            if (!paymentController.isPaymentSuccessful.value) {
              _showResult(false, paymentController.errorMessage.value);
              return;
            }

            // 3. Save the payment + appointment on the server
            final booking = await paymentController.bookAndPayController(
                doctor.id,
                patientId,
                shiftId,
                patientData['phone'] ?? '',
                doctor.phone,
                doctor.consultationfee,
                selectedDate,
                patientData['problem'] ?? '');
            if (booking['success'] != true) {
              _showResult(false, 'Payment went through but the appointment was not saved: ${booking['message']}');
              return;
            }

            // 4. Tell the doctor (a failed notification must not undo the booking)
            final String title = 'New Appointment'.tr();
            final String body = "You have a new booking from ${patientData['name']} on $selectedDate at $selectedTime.".tr();
            try {
              await NewFirebaseSendMessage().sendAppointmentNotificationToDoctor(
                doctor.doctorToken,
                title: title,
                body: body,
              );
              await ApiPostServices().saveNotifcation(title, body, doctor.id, '');
            } catch (e) {
              debugPrint('⚠️ Booking saved, but notifying the doctor failed: $e');
            }

            // 5. Refresh the patient's appointment list and show the result
            if (Get.isRegistered<AppoinmentsController>()) {
              Get.find<AppoinmentsController>().fechtAppointments(patientId);
            }
            Get.offAll(() => MainScreen());
            _showResult(true, paymentController.paymentStatus.value);
          } catch (e) {
            _showResult(false, 'Booking failed: $e');
          }
        },
        child: Text(
          'Payment \$${doctor.consultationfee}'.tr(),
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }
}
