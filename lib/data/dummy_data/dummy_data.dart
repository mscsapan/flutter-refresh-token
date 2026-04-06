import 'package:equatable/equatable.dart';

import '../../presentation/utils/k_images.dart';

class DummyDashboardModel extends Equatable {
  final String image;
  final String name;

  const DummyDashboardModel({required this.name, required this.image});

  @override
  List<Object?> get props => [image, name];
}

class CategoryNameId extends Equatable {
  final int id;
  final String name;

  const CategoryNameId({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}

final List<CategoryNameId> categoryId = [
  const CategoryNameId(id: 1, name: 'Electronics'),
  const CategoryNameId(id: 2, name: 'Game'),
  const CategoryNameId(id: 3, name: 'Mobile'),
  const CategoryNameId(id: 4, name: 'Life Style'),
  const CategoryNameId(id: 5, name: 'Babies & Toys'),
  const CategoryNameId(id: 6, name: 'Bike'),
  const CategoryNameId(id: 7, name: "Men's Fasion"),
  const CategoryNameId(id: 8, name: 'Woman Fasion'),
  const CategoryNameId(id: 9, name: 'Talevision'),
  const CategoryNameId(id: 10, name: 'Accessories'),
  const CategoryNameId(id: 11, name: 'John Doe'),
];

class ProductStatusModel extends Equatable {
  final String title;
  final String id;

  const ProductStatusModel({required this.id, required this.title});

  @override
  List<Object?> get props => [id, title];
}

final List<ProductStatusModel> productStatusModel = [
  const ProductStatusModel(id: '1', title: 'Active'),
  const ProductStatusModel(id: '0', title: 'Inactive'),
];

class OnBoardingData extends Equatable {
  final String image;
  final String title;
  final String subTitle;

  const OnBoardingData({required this.title, required this.image, required this.subTitle});

  @override
  List<Object?> get props => [image, title,subTitle];
}

final onBoardingData = <OnBoardingData>[
  OnBoardingData(
    image: KImages.defaultImg,
    // image: 'assets/images/onboarding-01.png',
    title: 'Welcome to Your Store',
    subTitle: 'Discover a curated selection of products we know you\'ll love.',
  ),
  OnBoardingData(
    image: KImages.defaultImg,
    // image: 'assets/images/onboarding-05.jpg',
    title: 'Fast Delivered Your Product',
    subTitle: 'Choose a delivery location and get product at your door step',
  ),
  OnBoardingData(
    image: KImages.defaultImg,
    // image: 'assets/images/onboarding-03.jpg',
    title: 'Exclusive Deals',
    subTitle: 'Enjoy member-only discounts and early access to sales.',
  ),
  OnBoardingData(
    image: KImages.defaultImg,
    // image: 'assets/images/onboarding-04.png',
    title: 'Discover Your Style',
    subTitle:
    'Explore curated collections tailored to your unique taste. Find the perfect pieces to express yourself.',
  ),
];

