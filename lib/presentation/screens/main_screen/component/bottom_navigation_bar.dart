import 'dart:io';

import 'package:flutter/material.dart';

import '../../../utils/constraints.dart';
import 'main_controller.dart';

class MyBottomNavigationBar extends StatelessWidget {
  const MyBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = MainController();
    return Container(
      height: Platform.isAndroid ? 80 : 100,
      decoration: const BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          )),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: StreamBuilder(
          initialData: 0,
          stream: controller.naveListener.stream,
          builder: (_, AsyncSnapshot<int> index) {
            int selectedIndex = index.data ?? 0;
            return BottomNavigationBar(
              showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedLabelStyle:
                  const TextStyle(fontSize: 14, color: blackColor),
              unselectedLabelStyle:
                  const TextStyle(fontSize: 14, color: grayColor),
              items: const <BottomNavigationBarItem>[
                // BottomNavigationBarItem(
                //   tooltip: Language.home,
                //   icon: _navIcon(KImages.home),
                //   activeIcon: SvgPicture.asset(KImages.homeActive),
                //   label: Language.home,
                // ),
                // BottomNavigationBarItem(
                //   tooltip: Language.shop,
                //   icon: _navIcon(KImages.shop),
                //   activeIcon: SvgPicture.asset(KImages.shopActive),
                //   label: Language.shop,
                // ),
                // BottomNavigationBarItem(
                //   tooltip: Language.orders,
                //   icon: _navIcon(KImages.order),
                //   activeIcon: SvgPicture.asset(KImages.orderActive),
                //   label: Language.orders,
                // ),
                // BottomNavigationBarItem(
                //   tooltip: Language.wallet,
                //   activeIcon: SvgPicture.asset(KImages.walletActive),
                //   icon: _navIcon(KImages.wallet),
                //   label: Language.wallet,
                // ),
              ],
              // type: BottomNavigationBarType.fixed,
              currentIndex: selectedIndex,
              onTap: (int index) {
                controller.naveListener.sink.add(index);
              },
            );
          },
        ),
      ),
    );
  }

  // Widget _navIcon(String path) => Padding(
  //     padding: Utils.symmetric(v: 8.0, h: 0.0), child: SvgPicture.asset(path));
}
