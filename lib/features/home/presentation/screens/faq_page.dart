import 'package:flutter/material.dart';

class FAQPage extends StatelessWidget {
  const FAQPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness ==
        Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark
              ? const Color(0xFF0F1115)
              : const Color(0xFFF7F8FC),

      appBar: AppBar(
        centerTitle: true,

        backgroundColor: const Color(0xFF1670FF),

        foregroundColor: Colors.white,

        elevation: 0,

        title: const Text(
          'الأسئلة الشائعة',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),

        children: const [
          FAQItem(
            question:
                'كيف أحجز خدمة غسيل؟',
            answer:
                'اختر الباقة المناسبة ثم حدد موقعك واضغط تأكيد الحجز.',
          ),

          FAQItem(
            question:
                'ما هي طرق الدفع المتوفرة؟',
            answer:
                'يمكنك الدفع نقداً أو عبر المحفظة الإلكترونية.',
          ),

          FAQItem(
            question:
                'كم تستغرق مدة الغسيل؟',
            answer:
                'تستغرق الخدمة عادة من 30 إلى 60 دقيقة حسب نوع الباقة.',
          ),

          FAQItem(
            question:
                'هل يمكن إلغاء الحجز؟',
            answer:
                'نعم يمكنك إلغاء الحجز قبل موعد الخدمة بسهولة.',
          ),

          FAQItem(
            question:
                'هل يوجد خصومات وعروض؟',
            answer:
                'نعم يتم إضافة عروض وخصومات بشكل مستمر داخل التطبيق.',
          ),

          FAQItem(
            question:
                'هل يمكن تغيير موعد الحجز؟',
            answer:
                'نعم يمكنك تعديل موعد الحجز قبل بدء الخدمة.',
          ),

          FAQItem(
            question:
                'كيف أتواصل مع الدعم؟',
            answer:
                'يمكنك التواصل عبر صفحة الدعم أو الاتصال على الرقم 77739412.',
          ),

          FAQItem(
            question:
                'هل الخدمة متوفرة طوال اليوم؟',
            answer:
                'الخدمة متوفرة يومياً من الساعة 8 صباحاً حتى 11 مساءً.',
          ),

          FAQItem(
            question:
                'هل يمكن تحديد الموقع على الخريطة؟',
            answer:
                'نعم يمكنك تحديد موقعك بدقة أثناء عملية الحجز.',
          ),

          FAQItem(
            question:
                'ما أنواع السيارات المدعومة؟',
            answer:
                'جميع أنواع السيارات الصغيرة والمتوسطة والكبيرة مدعومة.',
          ),

          FAQItem(
            question:
                'هل يوجد تنظيف داخلي للسيارة؟',
            answer:
                'نعم توجد خدمات تنظيف داخلي وتلميع وغسيل كامل.',
          ),

          FAQItem(
            question:
                'ماذا أفعل إذا تأخر العامل؟',
            answer:
                'يمكنك التواصل مباشرة مع الدعم وسيتم مساعدتك فوراً.',
          ),
        ],
      ),
    );
  }
}

class FAQItem extends StatelessWidget {
  final String question;
  final String answer;

  const FAQItem({
    super.key,
    required this.question,
    required this.answer,
  });

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness ==
        Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(
        bottom: 14,
      ),

      decoration: BoxDecoration(
        color:
            isDark
                ? const Color(0xFF1A1D24)
                : Colors.white,

        borderRadius: BorderRadius.circular(20),

        border: Border.all(
          color:
              isDark
                  ? Colors.white10
                  : const Color(0xFFE8EDFF),
        ),

        boxShadow: [
          BoxShadow(
            color:
                isDark
                    ? Colors.black26
                    : Colors.black12,

            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: ExpansionTile(
        collapsedIconColor:
            const Color(0xFF1670FF),

        iconColor:
            const Color(0xFF1670FF),

        title: Text(
          question,

          textAlign: TextAlign.right,

          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,

            color:
                isDark
                    ? Colors.white
                    : const Color(0xFF151B4A),
          ),
        ),

        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              0,
              16,
              16,
            ),

            child: Text(
              answer,

              textAlign: TextAlign.right,

              style: TextStyle(
                fontSize: 14,

                height: 1.6,

                color:
                    isDark
                        ? Colors.white70
                        : const Color(0xFF5F677B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}