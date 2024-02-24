// this is to make tha bar at the bottom looks better
// change the color of bar when necessary by calling CustomNavigationBar(selectedIndex: , onItemTapped: , color: )
//call this constructor at ...TabScreen.dart.

import 'package:flutter/material.dart';

class CustomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final Color color;
  final Color selectedIconColor;
  final int numofIcon;

  const CustomNavigationBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
    this.color = const Color.fromARGB(255, 255, 255, 207),
    this.selectedIconColor = Colors.yellow,
    this.numofIcon = 4,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(10),
        topLeft: Radius.circular(10),
      ),
      child: BottomAppBar(
        color: color,
        shape: CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(numofIcon, (index) {
            return InkWell(
              onTap: () => onItemTapped(index),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: Duration(milliseconds: 100),
                      decoration: BoxDecoration(
                        color: selectedIndex == index
                            ? selectedIconColor
                            : Colors.transparent,
                        shape: BoxShape.rectangle,
                        borderRadius: selectedIndex == index
                            ? BorderRadius.circular(8)
                            : BorderRadius.zero,
                        boxShadow: [
                          if (selectedIndex == index)
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            ),
                        ],
                      ),
                      padding: selectedIndex == index
                          ? EdgeInsets.all(8)
                          : EdgeInsets.all(4),
                      child: Icon(
                        getIconForIndex(index),
                        color:
                            selectedIndex == index ? Colors.white : Colors.grey,
                        size: 30.0,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  IconData getIconForIndex(int index) {
    if (numofIcon == 4) {
      switch (index) {
        case 0:
          return Icons.home;
        case 1:
          return Icons.chat;
        case 2:
          return Icons.notifications;
        case 3:
          return Icons.person;
        default:
          return Icons.error;
      }
    } else {
      switch (index) {
        case 0:
          return Icons.home;
        case 1:
          return Icons.notifications;
        case 2:
          return Icons.person;
        default:
          return Icons.error;
      }
    }
  }
}
