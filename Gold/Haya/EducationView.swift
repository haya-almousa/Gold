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
    let sourceURL: URL
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
        source: "سعوديبيديا - الموسوعة السعودية",
        sourceURL: URL(string: "https://saudipedia.com/article/14924")!
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
        """,
        source: "سعوديبيديا - الموسوعة السعودية",
        sourceURL: URL(string: "https://saudipedia.com/article/16430")!
    ),
    EducationArticle(
        title: "الذهب كاستثمار",
        summary: "لماذا يظل الذهب أصلاً ملاذاً آمناً وكيف تخطط لاستراتيجية امتلاك طويلة المدى.",
        detail: """
        يُعتبر الذهب من أقدم وسائل حفظ الثروة وأكثرها موثوقية عبر التاريخ:

        • ملاذ آمن: يلجأ المستثمرون إلى الذهب في أوقات عدم الاستقرار الاقتصادي والتضخم.

        • التنويع: يُنصح بتخصيص 10-15% من المحفظة الاستثمارية للذهب لتقليل المخاطر.

        • أشكال الاستثمار: سبائك، عملات، صناديق مؤشرات، مجوهرات.

        الذهب ليس مجرد معدن ثمين، بل أداة مالية استراتيجية لحماية الثروة على المدى الطويل.
        """,
        source: "سعوديبيديا - الموسوعة السعودية",
        sourceURL: URL(string: "https://saudipedia.com/article/14463")!
    ),
    EducationArticle(
        title: "شراء مجوهرات الذهب بذكاء",
        summary: "كيفية تقييم رسوم المصنعية، والدمغات، وتجنب دفع مبالغ زائدة عند الصائغ.",
        detail: """
        عند شراء المجوهرات الذهبية، هناك عدة عوامل يجب مراعاتها للحصول على أفضل قيمة:

        • المصنعية  
        • الدمغة  
        • وزن القطعة  
        • الفاتورة  
        • سياسة الاستبدال  
        • التوقيت  
        """,
        source: "سعوديبيديا - الموسوعة السعودية",
        sourceURL: URL(string: "https://saudipedia.com/article/10581")!
    )
]

struct EducationView: View {
    @State private var selectedArticle: EducationArticle?

    var body: some View {
        ZStack {
            Color("background").ignoresSafeArea()

            VStack(spacing: 0) {

                // MARK: - العنوان ثابت مثل صفحة المقارنة
                headerBar

                // MARK: - المحتوى المتحرك فقط
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        ForEach(articles) { article in
                            articleCard(article)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 120)
                }
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
        .sheet(item: $selectedArticle) { article in
            articleDetailView(article)
        }
    }

    // MARK: - Header ثابت
    private var headerBar: some View {
        VStack(spacing: 0) {
            Text("تعلّم عن الذهب")
                .font(.appTitle2(.bold))
                .foregroundColor(Color(.black))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 35)
                .padding(.bottom, 20)
                .background(Color("background"))
        }
    }

    // MARK: - Article Card
    private func articleCard(_ article: EducationArticle) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(article.title)
                .font(.appTitle3(.bold))
                .foregroundColor(Color("Gold"))

            Text(article.summary)
                .font(.appSubheadline(.medium))
                .foregroundColor(Color("Dark grey"))
                .multilineTextAlignment(.leading)

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
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("Lightest blue"))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.maincolor), lineWidth: 0.2)
        )
    }

    // MARK: - Detail Sheet
    private func articleDetailView(_ article: EducationArticle) -> some View {
        NavigationStack {
            ZStack {
                Color("background").ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(article.title)
                            .font(.appTitle2(.bold))
                            .foregroundColor(Color("Dark gold"))

                        Text(article.detail)
                            .font(.appBody(.regular))
                            .foregroundColor(Color("Dark grey"))
                            .lineSpacing(6)

                        Divider().padding(.vertical, 8)

                        Link(destination: article.sourceURL) {
                            HStack(spacing: 4) {
                                Text("المصدر: \(article.source)")
                                Image(systemName: "arrow.up.left.square")
                            }
                            .font(.appFootnote(.regular))
                            .foregroundColor(Color("maincolor"))
                        }
                    }
                    .padding(20)
                }
            }
            .environment(\.layoutDirection, .rightToLeft)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { selectedArticle = nil } label: {
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
    EducationView()
}
