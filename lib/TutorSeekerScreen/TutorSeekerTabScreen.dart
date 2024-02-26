
import 'package:edumateapp/TutorSeekerScreen/TutorSeekerHomeChat.dart';
import 'package:edumateapp/TutorSeekerScreen/TutorSeekerProfile.dart';
import 'package:edumateapp/TutorSeekerScreen/TutorSeekerHome.dart';
import 'package:edumateapp/TutorSeekerScreen/TutorSeekerNotification.dart';
import 'package:edumateapp/Widgets/CustomNavigationBar.dart';
import 'package:flutter/material.dart';

// tab at the bottom

class TutorSeekerTabScreen extends StatefulWidget {
  final int initialPageIndex;

  const TutorSeekerTabScreen({Key? key, this.initialPageIndex = 0}) : super(key: key);

  @override
  _TutorSeekerTabScreenState createState() => _TutorSeekerTabScreenState();
}

class _TutorSeekerTabScreenState extends State<TutorSeekerTabScreen> {
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
      const TutorSeekerHome(),
      const TutorSeekerHomeChat(),
      const TutorSeekerNotification(),
      const TutorSeekerProfile(),
    ];

    return Scaffold(
      body: pages[_selectedPageIndex], 
      bottomNavigationBar: CustomNavigationBar(
        selectedIndex: _selectedPageIndex,
        onItemTapped: _selectPage,
      ),
    );
  }
}

