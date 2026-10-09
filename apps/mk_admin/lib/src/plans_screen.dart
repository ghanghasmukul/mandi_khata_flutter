import 'package:flutter/material.dart';
import 'package:mk_admin/src/resources.dart';

/// Plans and add-ons: everything commercial is data edited here.
class PlansScreen extends StatelessWidget {
  const PlansScreen({super.key});

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 2,
    child: Column(
      children: [
        const TabBar(
          tabs: [
            Tab(text: 'Plans'),
            Tab(text: 'Add-ons'),
          ],
        ),
        Expanded(
          child: TabBarView(
            children: [
              ResourceScreen(config: plansResource),
              ResourceScreen(config: addonsResource),
            ],
          ),
        ),
      ],
    ),
  );
}
