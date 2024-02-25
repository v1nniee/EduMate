import 'package:edumateapp/TutorScreen/TutorChat.dart';
import 'package:edumateapp/TutorScreen/TutorHome.dart';
import 'package:edumateapp/TutorScreen/TutorHomeChat.dart';
import 'package:edumateapp/TutorScreen/TutorNotification.dart';
import 'package:edumateapp/TutorScreen/TutorProfile.dart';
import 'package:edumateapp/Widgets/CustomNavigationBar.dart';
import 'package:flutter/material.dart';

// tab at the bottom

class TutorTabScreen extends StatefulWidget {
  final int initialPageIndex;

  const TutorTabScreen({Key? key, this.initialPageIndex = 0}) : super(key: key);
  @override
  _TutorTabScreenState createState() => _TutorTabScreenState();
}

class _TutorTabScreenState extends State<TutorTabScreen> {
  late int _selectedPageIndex;

  @override
  void initState() {
    super.initState();
    _selectedPageIndex = widget.initialPageIndex; 
  }


  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      const TutorHome(),
      const TutorHomeChat(
        ReceiverUserId: 'cPRr4BsibZUWnrsbwQDeltaZQcK2',
      ),
      const TutorNotification(),
      const TutorProfile(),
    ];

    return Scaffold(
      body: pages[_selectedPageIndex],
      bottomNavigationBar: CustomNavigationBar(
          selectedIndex: _selectedPageIndex,
          onItemTapped: _selectPage,
          selectedIconColor: const Color.fromARGB(255, 255, 116, 36),
          color: const Color.fromARGB(255, 255, 203, 173)),
          
    );
  }
}
