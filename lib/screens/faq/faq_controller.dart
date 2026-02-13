import 'package:get/get.dart';

class FAQItem {
  final String question;
  final String answer;
  FAQItem({required this.question, required this.answer});
}

class FAQController extends GetxController {
  final faqs = <FAQItem>[].obs;
  final openedIndex = (-1).obs;

  @override
  void onInit() {
    super.onInit();
    _loadFaqs();
  }

  void toggle(int index) {
    if (openedIndex.value == index) {
      openedIndex.value = -1;
    } else {
      openedIndex.value = index;
    }
  }

  void _loadFaqs() {
    faqs.addAll([
      FAQItem(
        question: "What is a Coded Meter?",
        answer:
            "A meter requested for persons drawing electricity illegally. It is a temporary solution for consumption tracking.",
      ),
      FAQItem(
        question: "What does 'Temporary Meter' mean?",
        answer:
            "It is installed temporarily until permanent legal steps are taken to replace it with a standard meter.",
      ),
      FAQItem(
        question: "How to apply for a coded meter?",
        answer:
            "Applications are submitted through the Egyptian Electricity Holding Company website via the Citizen Services Platform.",
      ),
      FAQItem(
        question: "What are the application procedures?",
        answer:
            "1. Enter the company website.\n2. Select 'Coded Meter Installation Service'.\n3. Complete the required data and documents.",
      ),
      FAQItem(
        question: "How to follow up on my application?",
        answer:
            "Notifications of the application status will be sent through the website, email, and SMS.",
      ),
      FAQItem(
        question: "Is there an installment plan for the assay value?",
        answer:
            "Installment options are subject to the commercial committee's latest regulations and announcements.",
      ),
      FAQItem(
        question: "Does the tariff differ for coded meters?",
        answer:
            "No, consumption is calculated using the same approved electricity distribution tariffs.",
      ),
      FAQItem(
        question: "Is the coded meter proof of ownership?",
        answer:
            "No, a coded meter is not a legal title deed for property. It is only for measuring electricity consumption.",
      ),
      FAQItem(
        question: "What is the price of the meter/assay?",
        answer:
            "Prices vary based on site inspection, meter type, and current distribution company supply orders.",
      ),
      FAQItem(
        question: "How can I submit a complaint?",
        answer:
            "You can use the electronic platform or call the unified customer service center at 121.",
      ),
    ]);
  }
}
