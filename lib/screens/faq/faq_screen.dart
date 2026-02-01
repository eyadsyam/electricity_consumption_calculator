import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'complaint_screen.dart';
import 'faq_controller.dart';

class FAQPage extends StatelessWidget {
  const FAQPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(FAQController());

    return Scaffold(
      appBar: AppBar(title: const Text("الأسئلة الشائعة")),
      body: Obx(
        () => ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: c.faqs.length + 1,
          itemBuilder: (context, index) {
            if (index == c.faqs.length) {
              // زر الذهاب للشكوى
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: ElevatedButton(
                  onPressed: () => Get.to(() => const ComplaintPage()),
                  child: const Text("هل لديك شكوى؟ اضغط هنا"),
                ),
              );
            }

            final item = c.faqs[index];
            final isOpen = c.openedIndex.value == index;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(blurRadius: 4, color: Colors.black12),
                ],
              ),
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      item.question,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.right,
                    ),
                    trailing: Icon(
                      isOpen ? Icons.remove : Icons.add,
                      color: Colors.blue,
                    ),
                    onTap: () => c.toggle(index),
                  ),

                  // الإجابة عند الفتح
                  if (isOpen)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: Text(
                        item.answer,
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
