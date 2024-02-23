import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/database/model/response/dashboard_wallet_activity_model.dart';
import 'package:timelines/timelines.dart';

import '../../database/functions.dart';
import '../../utils/color.dart';
import '../../utils/sizedbox_utils.dart';
import '../../utils/picture_utils.dart';
import '../../utils/text.dart';

class CommissionActivityDetailsPage extends StatefulWidget {
  const CommissionActivityDetailsPage({Key? key, required this.activities})
      : super(key: key);
  final List<DashboardWalletActivity> activities;
  @override
  State<CommissionActivityDetailsPage> createState() =>
      _CommissionActivityDetailsPageState();
}

class _CommissionActivityDetailsPageState
    extends State<CommissionActivityDetailsPage> {
/*  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: mainColor,
      body: Stack(
        children: [
          Container(
            height: double.maxFinite,
            width: double.maxFinite,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: userAppBgImageProvider(context),
                fit: BoxFit.cover,
                opacity: 0.5,
              ),
            ),
            child: CustomScrollView(
              slivers: <Widget>[
                buildSliverAppBar(size),
                // buildSliverList(),
              ],
            ),
          ),
        ],
      ),
    );
  }*/
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: mainColor,
      body: Stack(
        children: [
          Container(
            height: double.maxFinite,
            width: double.maxFinite,
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: userAppBgImageProvider(context),
                  fit: BoxFit.cover,
                  opacity: 1),
            ),
            child: Column(
              children: <Widget>[
                AppBar(
                    title: Text('Activities'),
                    elevation: 1,
                    shadowColor: Colors.white),
                Expanded(
                    child: SingleChildScrollView(
                        child:
                            CommissionActivityHistoryList(activities: widget.activities)))
              ],
            ),
          ),
        ],
      ),
    );
  }

  SliverPadding buildSliverList() {
    Size size = MediaQuery.of(context).size;
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            var activity = widget.activities[index];
            return Container(
              height: size.height * 0.2,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 45,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: appLogoColor.withOpacity(0.2)),
                        child: Row(
                          children: [
                            Expanded(
                              child: capText(
                                  '${DateFormat('MMM dd yyyy').format(DateTime.parse(activity.createdAt ?? ''))}',
                                  context,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  textAlign: TextAlign.center),
                            ),
                          ],
                        ),
                      ),
                      if ((index + 1) != widget.activities.length)
                        Expanded(
                          child: LayoutBuilder(builder: (context, constraints) {
                            var dh = 3.0;
                            var dg = 1.0;
                            var count = constraints.maxHeight ~/ (dh);
                            print(constraints.maxHeight);
                            print(count);
                            return Column(
                              children: [
                                for (int i = 0; i < count; i++)
                                  Container(
                                    height: dh,
                                    width: 3,
                                    color: i % 2 == 0
                                        ? Colors.transparent
                                        : Colors.red,
                                  ),
                              ],
                            );
                          }),
                        ),
                    ],
                  ),
                  width10(),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        height5(),
                        Expanded(
                          child: bodyLargeText(
                            parseHtmlString(activity.note ?? ''),
                            context,
                            // fontSize: 12,
                            // color: Colors.black,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 20,
                            fontWeight: FontWeight.normal,
                            textAlign: TextAlign.justify,
                          ),
                        ),
                        height20(),
                      ],
                    ),
                  ),
                  width10(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      height10(),
                      Builder(builder: (context) {
                        bool credited = double.parse(activity.credit ?? '0') >
                            double.parse(activity.debit ?? '0');
                        return Container(
                          decoration: BoxDecoration(
                            color:
                                credited ? Colors.green[500] : Colors.red[500]!,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          child: bodyMedText(
                            credited ? 'Credit' : 'Debit',
                            context,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        );
                      }),
                      height10(),
                      capText(
                          '${DateFormat().add_jm().format(DateTime.parse(activity.createdAt ?? ''))}',
                          context,
                          fontSize: 8,
                          color: Colors.white),
                    ],
                  ),
                ],
              ),
            );
          },
          childCount: widget.activities.length,
        ), //SliverChildBuildDelegate
      ),
    );
  }

  SliverAppBar buildSliverAppBar(Size size) {
    return SliverAppBar(
      snap: false,
      pinned: true,
      floating: false,
      backgroundColor: mainColor,
      expandedHeight: size.height * 0.15,
      collapsedHeight: size.height * 0.08,
      flexibleSpace: const FlexibleSpaceBar(
        centerTitle: true,
        title: Text("Activities",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold) //TextStyle
            ), //Text
        //Images.network
      ),
    );
  }
}

class CommissionActivityHistoryList extends StatelessWidget {
  const CommissionActivityHistoryList({Key? key, required this.activities})
      : super(key: key);

  final List<DashboardWalletActivity> activities;
  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: const TextStyle(color: Color(0xff9b9b9b), fontSize: 12.5),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: FixedTimeline.tileBuilder(
          theme: TimelineThemeData(
            nodePosition: 0,
            color: const Color(0xff989898),
            indicatorTheme: const IndicatorThemeData(position: 0, size: 20.0),
            connectorTheme: const ConnectorThemeData(thickness: 2.5),
          ),
          builder: TimelineTileBuilder.connected(
            connectionDirection: ConnectionDirection.before,
            itemCount: activities.length,
            contentsBuilder: (_, index) {
              return Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          bodyLargeText(
                              '${DateFormat('MMM dd yyyy').format(DateTime.parse(activities[index].createdAt ?? ''))}',
                              context,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              textAlign: TextAlign.center),
                          height5(),
                          capText(parseHtmlString(activities[index].note ?? ''),
                              context),
                          if(index<activities.length-1)
                          height50(),
                        ],
                      ),
                    ),
                    Builder(builder: (context) {
                      bool credited =
                          double.parse(activities[index].credit ?? '0') >
                              double.parse(activities[index].debit ?? '0');
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: credited
                                  ? Colors.green[500]
                                  : Colors.red[500]!,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            child: bodyMedText(
                              credited ? 'Credit' : 'Debit',
                              context,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          height10(),
                          capText(
                              '${DateFormat().add_jm().format(DateTime.parse(activities[index].createdAt ?? ''))}',
                              context,
                              fontSize: 8,
                              color: Colors.white),
                        ],
                      );
                    }),
                  ],
                ),
              );
            },
            indicatorBuilder: (_, index) {
              bool credited = double.parse(activities[index].credit ?? '0') >
                  double.parse(activities[index].debit ?? '0');
              if (credited) {
                return const OutlinedDotIndicator(
                  color: Color(0xff66c97f),
                  // child: Icon(Icons.check, color: Colors.white, size: 12.0),
                );
              } else {
                return OutlinedDotIndicator(
                  color: Colors.red,
                  // child: Icon(Icons.check, color: Colors.white, size: 12.0),
                );
                ;
              }
            },
            connectorBuilder: (_, index, ___) {
              bool credited = double.parse(activities[index].credit ?? '0') >
                  double.parse(activities[index].debit ?? '0');
              return SolidLineConnector(
                color: Colors.white,
                thickness: 1,
                // color: credited
                //     ? const Color(0xff66c97f)
                //     : const Color(0xff6676c9),
              );
            },
          ),
        ),
      ),
    );
  }
}
