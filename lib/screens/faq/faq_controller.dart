import 'package:get/get.dart';

class FAQItem {
  final String question;
  final String answer;
  FAQItem({required this.question, required this.answer});
}

class FAQController extends GetxController {
  final faqs = <FAQItem>[].obs;
  final openedIndex = (-1).obs; // -1 = ولا سؤال مفتوح

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
        question: "ما معنى العداد الكودي ؟",
        answer:
            "عداد يتم تقديم طلب الحصول عليه للاشخاص الذين يستمدون تيار كهربائي بصورة غير قانونية ... وهو عداد مؤقت.",
      ),
      FAQItem(
        question: "ما معنى عداد مؤقت ؟",
        answer:
            "بصورة مؤقتة لحين أقرب الأجلين ... ويتم بناء على ذلك استبدال العداد الكودي.",
      ),
      FAQItem(
        question: "طريقة تقديم طلب تركيب عداد كودي",
        answer:
            "من خلال موقع الشركة القابضة لكهرباء مصر، منصة خدمات المواطنين.",
      ),
      FAQItem(
        question: "اجراءات التقدم بطلب العداد الكودي",
        answer:
            "• الدخول على موقع الشركة\n• اختيار خدمة طلب تركيب عداد كودي\n• استكمال البيانات...",
      ),
      FAQItem(
        question: "طريقة متابعة الطلب المقدم",
        answer: "سيتم إرسال إشعارات بموقف الطلب من خلال الموقع والإيميل و SMS.",
      ),
      FAQItem(
        question: "هل يوجد تقسيط لقيمة المقايسة ؟",
        answer: "سيتم الإعلان عنها فى حالة تحديد الضوابط من اللجنة التجارية.",
      ),
      FAQItem(
        question: "هل تختلف تعريفة الحساب للعداد الكودي ؟",
        answer: "لا ... يتم حساب الاستهلاك بنفس التعريفة.",
      ),
      FAQItem(
        question: "هل العداد الكودي اثبات ملكية ؟",
        answer:
            "لا ... العداد الكودي لا يعتبر سند ملكية أو حيازة وإنما برقم كودي فقط.",
      ),
      FAQItem(
        question: "ما هو سعر العداد – المقايسة ؟",
        answer:
            "تختلف بإختلاف المعاينة ووفقا لأوامر التوريد لكل شركة من شركات التوزيع.",
      ),
      FAQItem(
        question: "فى حالة الرغبة فى تقديم شكوى",
        answer: "• المنصة الإلكترونية\n• رقم خدمة العملاء الموحد 121",
      ),
    ]);
  }
}
