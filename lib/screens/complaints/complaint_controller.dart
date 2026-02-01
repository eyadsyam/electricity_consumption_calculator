import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:finalproject/services/complaint_service.dart';

class ComplaintController extends GetxController {
  final name = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final date = TextEditingController();
  final message = TextEditingController();

  final isLoading = false.obs;

  Future<void> send() async {
    if (!email.text.endsWith("@gmail.com")) {
      Get.snackbar("ERROR".tr, "Email must be a Gmail address".tr);
      return;
    }

    if (message.text.trim().isEmpty) {
      Get.snackbar(
        'MESSAGE_VALIDATION'.tr,
        'Please write the complaint content'.tr,
      );
      return;
    }

    isLoading.value = true;

    final ok = await ComplaintService.sendComplaint(
      name: name.text,
      email: email.text,
      phone: phone.text,
      date: date.text,
      message: message.text,
    );

    isLoading.value = false;

    if (ok) {
      Get.snackbar('SENT_SUCCESS_TITLE'.tr, 'Sent Successfully'.tr);
      clearForm();
    } else {
      Get.snackbar('SENT_FAILURE_BODY'.tr, 'Failed to send the complaint'.tr);
    }
  }

  void clearForm() {
    name.clear();
    email.clear();
    phone.clear();
    date.clear();
    message.clear();
  }
}
