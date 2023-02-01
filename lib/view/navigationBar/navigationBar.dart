import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_learning_seminar_2023/view/dashboard/dashboard.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';

import '../../constants/colors.dart';

class navigationBar extends StatefulWidget {
  String uid;

  navigationBar(required, {Key? key, required this.uid}) : super(key: key);
  @override
  _navigationBar createState() => _navigationBar(uid);
}

class _navigationBar extends State<navigationBar>
    with SingleTickerProviderStateMixin {
  String uid = "";

  _navigationBar(uid);
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    User? user = FirebaseAuth.instance.currentUser;
    final userid = user?.uid.toString();
    uid = userid!;
  }

  @override
  void dispose() {
    super.dispose();
    _tabController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        children: <Widget>[
          atDashboardScreen(required, uid: uid),
          atDashboardScreen(required, uid: uid),
          atDashboardScreen(required, uid: uid),
          atDashboardScreen(required, uid: uid),
        ],
        controller: _tabController,
        //onPageChanged: whenPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
      extendBody: true,
      bottomNavigationBar: Container(
        height: 56,
        width: 375 + 24,
        // decoration: BoxDecoration(
        //   border: Border.all(color: white, width: 1),
        // ),
        // padding: EdgeInsets.only(
        //     left: (MediaQuery.of(context).size.width - 375 + 24) / 2,
        //     right: (MediaQuery.of(context).size.width - 375 + 24) / 2),
        child: ClipRRect(
          child: Container(
            color: black,
            child: TabBar(
              labelColor: white,
              unselectedLabelColor: white,
              indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(color: white, width: 1)),
              //For Indicator Show and Customization
              indicatorColor: black,
              tabs: <Widget>[
                Tab(
                    // icon: SvgPicture.asset(
                    //   nbDashboard,
                    //   height: 24, width: 24
                    // )
                    icon: Icon(Iconsax.home, size: 24)),
                Tab(
                    // icon: SvgPicture.asset(
                    //   nbIncidentReport,
                    //   height: 24, width: 24
                    // )
                    icon: Icon(Iconsax.message, size: 24)),
                Tab(
                    // icon: SvgPicture.asset(
                    //   nbIncidentReport,
                    //   height: 24, width: 24
                    // )
                    icon: Icon(Iconsax.global, size: 24)),
                Tab(
                    // icon: SvgPicture.asset(
                    //   nbIncidentReport,
                    //   height: 24, width: 24
                    // )
                    icon: Icon(Iconsax.profile, size: 24)),
              ],
              controller: _tabController,
            ),
          ),
        ),
      ),
    );
  }
}
