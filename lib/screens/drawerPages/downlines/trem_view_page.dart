import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../constants/assets_constants.dart';
import '../../../database/functions.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../utils/color.dart';
import '../../../utils/picture_utils.dart';
import '../../../utils/sizedbox_utils.dart';
import '../../../utils/skeleton.dart';
import '../../../utils/text.dart';

Widget buildTeamBuildingReferralLink(BuildContext context,
    {Color linkColor = Colors.blue}) {
  return Consumer<DashBoardProvider>(
    builder: (context, dashBoardProvider, child) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
                child: titleLargeText('Refer and invite: ', context,
                    color: appLogoColor))
          ]),
          height10(),
          Row(children: [
            Expanded(
              child: Container(
                height: 40,
                padding: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(5)),
                child: Row(
                  children: [
                    Expanded(
                      child: dashBoardProvider.loadingDash
                          ? Skeleton(
                              height: 16,
                              style: SkeletonStyle.text,
                              textColor: Colors.white38)
                          : capText(dashBoardProvider.teamBuildingUrl, context,
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              color: linkColor),
                    ),
                    IconButton(
                      onPressed: () async => await Clipboard.setData(
                              ClipboardData(
                                  text: dashBoardProvider.teamBuildingUrl))
                          .then((_) => ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(
                                  content: Text('Link copied  to clipboard.'),
                                  backgroundColor: appLogoColor))),
                      icon: Icon(Icons.copy, color: Colors.cyan, size: 15),
                    )
                  ],
                ),
              ),
            )
          ]),
          height20(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                  onTap: () {
                    sendWhatsapp(text: dashBoardProvider.teamBuildingUrl);
                  },
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: assetSvg(Assets.whatsappColored, fit: BoxFit.cover),
                  )),
              width30(),
              GestureDetector(
                  onTap: () {
                    sendTelegram(text: dashBoardProvider.teamBuildingUrl);
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(7),
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child:
                          assetSvg(Assets.telegramColored, fit: BoxFit.cover),
                    ),
                  )),
            ],
          ),
        ],
      );
    },
  );
}
