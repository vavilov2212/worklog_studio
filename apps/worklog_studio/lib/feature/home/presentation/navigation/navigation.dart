import 'package:flutter/material.dart';

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int _selectedIndex = 0;
  NavigationRailLabelType labelType = NavigationRailLabelType.all;
  final bool _showLeading = false;
  final bool _showTrailing = false;
  double groupAlignment = -1.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: _selectedIndex,
      groupAlignment: groupAlignment,
      onDestinationSelected: (int index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      labelType: labelType,
      leading: _showLeading
          ? FloatingActionButton(
              elevation: 0,
              onPressed: () {
                // Add your onPressed code here!
              },
              child: const Icon(Icons.add),
            )
          : const SizedBox(),
      trailing: _showTrailing
          ? IconButton(
              onPressed: () {
                // Add your onPressed code here!
              },
              icon: const Icon(Icons.more_horiz_rounded),
            )
          : const SizedBox(),
      destinations: const <NavigationRailDestination>[
        NavigationRailDestination(
          icon: Icon(Icons.favorite_border),
          selectedIcon: Icon(Icons.favorite),
          label: Text('First'),
        ),
        NavigationRailDestination(
          icon: Badge(child: Icon(Icons.bookmark_border)),
          selectedIcon: Badge(child: Icon(Icons.book)),
          label: Text('Second'),
        ),
        NavigationRailDestination(
          icon: Badge(label: Text('4'), child: Icon(Icons.star_border)),
          selectedIcon: Badge(label: Text('4'), child: Icon(Icons.star)),
          label: Text('Third'),
        ),
      ],
    );
  }
}
