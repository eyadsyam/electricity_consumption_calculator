import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Must import GetX for .tr extension

import 'complaint_controller.dart';

class ComplaintPage extends StatelessWidget {
  const ComplaintPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(ComplaintController());

    return Scaffold(
      appBar: AppBar(title: Text("FAQ".tr)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: c.name,
              decoration: InputDecoration(labelText: "FORM_NAME".tr),
            ),
            TextField(
              controller: c.phone,
              decoration: InputDecoration(labelText: "FORM_PHONE".tr),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: c.email,
              decoration: InputDecoration(
                labelText: "FORM_EMAIL".tr,
                hintText: "example@gmail.com".tr,
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: c.date,
              decoration: InputDecoration(labelText: "FORM_DATE".tr),
            ),
            TextField(
              controller: c.message,
              maxLines: 6,
              decoration: InputDecoration(labelText: "FORM_MESSAGE".tr),
            ),
            const SizedBox(height: 20),

            Obx(
                  () => c.isLoading.value
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: () => c.send(),
                child: Text("FORM_SEND_BUTTON".tr),
              ),
            ),
          ],
        ),
      ),
    );
  }
}