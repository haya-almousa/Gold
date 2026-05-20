//
//  EducationView.swift
//  Gold
//
//  Created by Haya Almousa on 27/11/1447 AH.
//

internal import SwiftUI

struct EducationArticle: Identifiable {
    let id = UUID()
    let title: String
    let summary: String
    let detail: String
    let source: String
}

private let articles: [EducationArticle] = [
    EducationArticle(
        title: "فهم عيارات الذهب",
        summary: "تعرف على الفرق بين عيارات 24، 22، 21، و18 قيراط وكيف تؤثر درجة النقاء على القيمة.",
        detail: """
        عيار الذهب هو مقياس نقاء الذهب ويُحدَّد من أصل 24 جزءاً:

        • عيار 24: ذهب خالص بنسبة 99.9%، وهو الأنقى لكنه ليّن ولا يُستخدم عادةً في المجوهرات اليومية.

        • عيار 22: يحتوي على 91.7% ذهب خالص والباقي معادن أخرى لزيادة الصلابة، ويُستخدم في بعض المشغولات الذهبية.

        • عيار 21: يحتوي على 87.5% ذهب خالص، وهو الأكثر شيوعاً في المملكة العربية السعودية والخليج لصناعة المجوهرات لتوازنه بين النقاء والمتانة.

        • عيار 18: يحتوي على 75% ذهب خالص، ويتميز بصلابته العالية مما يجعله مناسباً للمجوهرات المرصّعة بالأحجار الكريمة.

        كلما ارتفع العيار زادت نسبة الذهب الخالص وارتفع السعر، بينما يوفر العيار الأقل متانة أكبر وسعراً أقل.
        """,
        source: "سعوديبيديا - الموسوعة السعودية"
    ),
    EducationArticle(
        title: "كيف تعمل زكاة الذهب",
        summary: "دليل كامل حول نصاب الذهب، والتزام نسبة 2.5%، ومتى يجب تطبيقها.",
        detail: """
        زكاة الذهب فريضة إسلامية تجب على كل مسلم يملك ذهباً بلغ النصاب وحال عليه الحول:

        • النصاب: 85 غراماً من الذهب الخالص (عيار 24). إذا كان الذهب من عيار أقل، يُحسب ما يعادل 85 غراماً ذهباً خالصاً.

        • نسبة الزكاة: 2.5% من إجمالي قيمة الذهب الذي بلغ النصاب.

        • حولان الحول: يجب أن يمر عام هجري كامل على امتلاك الذهب البالغ النصاب.

        • ذهب الزينة: اختلف العلماء في زكاة الحُلي المُعَدّ للاستعمال الشخصي، والأحوط إخراج زكاته.

        • طريقة الحساب: قيمة الذهب بسعر السوق الحالي × 2.5%.

        مثال: إذا كنتِ تملكين 100 غرام ذهب عيار 21، فإن ما يعادله من الذهب الخالص = 87.5 غرام (أكثر من النصاب)، وتُحسب الزكاة على قيمته السوقية.
        """,
        source: "سعوديبيديا - الموسوعة السعودية"
    ),
    EducationArticle(
        title: "الذهب كاستثمار",
        summary: "لماذا يظل الذهب أصلاً ملاذاً آمناً وكيف تخطط لاستراتيجية امتلاك طويلة المدى.",
        detail: """
        يُعتبر الذهب من أقدم وسائل حفظ الثروة وأكثرها موثوقية عبر التاريخ:

        • ملاذ آمن: يلجأ المستثمرون إلى الذهب في أوقات عدم الاستقرار الاقتصادي والتضخم، حيث يحافظ على قيمته مقارنة بالعملات الورقية.

        • التنويع: يُنصح بتخصيص 10-15% من المحفظة الاستثمارية للذهب لتقليل المخاطر.

        • أشكال الاستثمار: سبائك ذهبية، عملات ذهبية، صناديق المؤشرات المتداولة (ETFs)، أو حتى المجوهرات الذهبية.

        • السوق السعودي: تتوفر في المملكة العربية السعودية خيارات متعددة للاستثمار في الذهب عبر البنوك المحلية والأسواق المالية.

        • نصائح للمستثمرين: الشراء التدريجي على فترات مختلفة لتقليل تأثير تقلبات الأسعار، والاحتفاظ لفترات طويلة للاستفادة من ارتفاع القيمة.

        الذهب ليس مجرد معدن ثمين، بل أداة مالية استراتيجية لحماية الثروة على المدى الطويل.
        """,
        source: "سعوديبيديا - الموسوعة السعودية"
    ),
    EducationArticle(
        title: "شراء مجوهرات الذهب بذكاء",
        summary: "كيفية تقييم رسوم المصنعية، والدمغات، وتجنب دفع مبالغ زائدة عند الصائغ.",
        detail: """
        عند شراء المجوهرات الذهبية، هناك عدة عوامل يجب مراعاتها للحصول على أفضل قيمة:

        • المصنعية: هي تكلفة تصنيع القطعة وتختلف حسب تعقيد التصميم والصائغ. قارن أسعار المصنعية بين عدة محلات قبل الشراء.

        • الدمغة: تأكد من وجود دمغة رسمية على كل قطعة تُبيّن العيار والمصدر. في السعودية، تُشرف الهيئة السعودية للمواصفات والمقاييس على دمغ الذهب.

        • وزن القطعة: اطلب وزن القطعة أمامك بميزان دقيق واحسب سعر الغرام حسب سعر السوق اليومي.

        • الفاتورة: احرص على الحصول على فاتورة تفصيلية تتضمن العيار، الوزن، سعر الغرام، والمصنعية.

        • سياسة الاستبدال: اسأل عن سياسة الاستبدال والاسترجاع قبل الشراء، فبعض المحلات تخصم المصنعية عند الاستبدال.

        • التوقيت: تميل أسعار الذهب للانخفاض في فترات الاستقرار الاقتصادي وبعد المواسم والأعياد.
        """,
        source: "سعوديبيديا - الموسوعة السعودية"
    )
]

struct EducationView: View {
    @Binding var selectedTab: AppTab
    @State private var selectedArticle: EducationArticle?

    var body: some View {
        ZStack(alignment: .bottom) {
            Color("background").ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Text("تعلّم عن الذهب")
                        .font(.appTitle2(.bold))
                        .foregroundColor(Color("Dark gold"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                        .padding(.bottom, 20)

                    VStack(spacing: 16) {
                        ForEach(articles) { article in
                            articleCard(article)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 120)
                }
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
        .sheet(item: $selectedArticle) { article in
            articleDetailView(article)
        }
    }

    private func articleCard(_ article: EducationArticle) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(article.title)
                .font(.appTitle3(.bold))
                .foregroundColor(Color("Gold"))
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(article.summary)
                .font(.appSubheadline(.regular))
                .foregroundColor(Color("Dark grey"))
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                selectedArticle = article
            } label: {
                HStack(spacing: 4) {
                    Text("اقرأ المزيد")
                        .font(.appSubheadline(.semibold))
                    Image(systemName: "arrow.forward")
                        .font(.appFootnote(.semibold))
                }
                .foregroundColor(Color("maincolor"))
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.top, 4)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color("Lightest blue"))
        )
    }

    private func articleDetailView(_ article: EducationArticle) -> some View {
        NavigationStack {
            ZStack {
                Color("background").ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(article.title)
                            .font(.appTitle2(.bold))
                            .foregroundColor(Color("Dark gold"))
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text(article.detail)
                            .font(.appBody(.regular))
                            .foregroundColor(Color("Dark grey"))
                            .multilineTextAlignment(.leading)
                            .lineSpacing(6)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Divider()
                            .padding(.vertical, 8)

                        Text("المصدر: \(article.source)")
                            .font(.appFootnote(.regular))
                            .foregroundColor(Color("Grey"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(20)
                }
            }
            .environment(\.layoutDirection, .rightToLeft)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        selectedArticle = nil
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundColor(Color("Grey"))
                    }
                }
            }
        }
    }
}
#Preview {
    EducationView(selectedTab: .constant(.education))
}

