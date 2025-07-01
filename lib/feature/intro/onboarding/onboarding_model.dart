import 'package:se7ety/core/constants/assets_manager.dart';

class OnboardingModel {
  final String image;
  final String title;
  final String body;

  OnboardingModel({
    required this.image,
    required this.title,
    required this.body,
  });
}

List<OnboardingModel> pages = [
  OnboardingModel(
    image: AssetsManager.onBoarding1,
    title: 'ابحث عن دكتور متخصص',
    body: 'اكتشف مجموعة واسعة من الأطباء الخبراء والمتخصصين في مختلف المجالات.',
  ),
  OnboardingModel(
    image: AssetsManager.onBoarding2,
    title: 'سهولة الحجز',
    body: 'احجز المواعيد بضغطة زرار في أي وقت وفي أي مكان.',
  ),
  OnboardingModel(
    image: AssetsManager.onBoarding3,
    title: 'آمن وسري',
    body: 'كن مطمئنًا لأن خصوصيتك وأمانك هما أهم أولوياتنا.',
  ),
];
