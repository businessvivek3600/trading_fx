import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import '/utils/default_logger.dart';
import 'package:swipeable_tile/swipeable_tile.dart';
import '../../database/functions.dart';
import '../../database/model/response/base/user_model.dart';
import '../../utils/color.dart';
import '/constants/assets_constants.dart';
import '/providers/team_view_provider.dart';
import '/utils/picture_utils.dart';
import '/utils/sizedbox_utils.dart';
import '/utils/text.dart';
import 'package:provider/provider.dart';

import '../../sl_container.dart';

class HoldingTankPage extends StatefulWidget {
  const HoldingTankPage({super.key});

  @override
  State<HoldingTankPage> createState() => _HoldingTankPageState();
}

class _HoldingTankPageState extends State<HoldingTankPage> {
  var provider = sl.get<TeamViewProvider>();
  List<UserData> liquidUsers = [];
  @override
  void initState() {
    super.initState();
    provider.getLiquidUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TeamViewProvider>(builder: (context, provider, _) {
      return Scaffold(
        appBar: AppBar(
          title: titleLargeText('Holding Tank', context, useGradient: true),
        ),
        body: Container(
          height: double.maxFinite,
          width: double.maxFinite,
          decoration: BoxDecoration(
            image: DecorationImage(
                image: userAppBgImageProvider(context), fit: BoxFit.cover),
          ),
          child: provider.loadingLoquidUser
              ? Center(child: CircularProgressIndicator(color: Colors.white))
              : provider.liquidUsers.isNotEmpty
                  ? Column(
                      children: [
                        Container(
                          width: double.maxFinite,
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                          decoration: BoxDecoration(
                            color: bColor().withOpacity(0.4),
                          ),
                          child: capText('Swipe to place', context,
                              textAlign: TextAlign.center),
                        ),
                        height5(),
                        Expanded(child: buildListView(provider)),
                      ],
                    )
                  : buildNoActiveWidget(context),
        ),
      );
    });
  }

  ListView buildListView(TeamViewProvider provider) {
    return ListView.builder(
      itemCount: provider.liquidUsers.length,
      itemBuilder: (context, index) {
        var liquidUser = provider.liquidUsers[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: SwipeableTile(
            color: Colors.transparent,
            swipeThreshold: 0.2,
            direction: SwipeDirection.horizontal,
            isElevated: false,
            borderRadius: 10,
            confirmSwipe: (_) {
              print('Liquid Users confirmSwipe');
              setState(() {});
              _showBottomSheet(context, 'liquidUser.id');
              return Future.value(false);
            },
            onSwiped: (_) async {
              print('Liquid Users confirmSwipe');
              // _showBottomSheet(context, 'liquidUser.id');
            },
            backgroundBuilder: (
              _,
              SwipeDirection direction,
              AnimationController progress,
            ) {
              if (direction == SwipeDirection.endToStart) {
                return Container(color: Colors.red.withOpacity(progress.value));
              } else if (direction == SwipeDirection.startToEnd) {
                return Container(
                    color: Colors.blue.withOpacity(progress.value));
              }
              return Container();
            },
            key: UniqueKey(),
            child: _MemberTile(user: liquidUser),
          ),
        );
      },
    );
  }

  // create bottom sheet to select team number through 3 radio button and then submit and call api
  void _showBottomSheet(BuildContext context, String id) {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16), topRight: Radius.circular(16)),
        ),
        builder: (BuildContext context) {
          return _PlaceUserSubmitWidget(
              id: id,
              onSuccess: () {
                liquidUsers.removeLast();
              });
        });
  }

  Padding buildNoActiveWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          assetImages(Assets.mlm),
          height20(),
          bodyMedText(
              'You are not placed in matrix, request your upline or wait for 24 hours for autoplacment.',
              context,
              textAlign: TextAlign.center,
              lineHeight: 1.5,
              maxLines: 5),
        ],
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({super.key, required this.user});
  final UserData user;

  @override
  Widget build(BuildContext context) {
    bool active = user.salesActive == '1';
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: bColor(), borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: bodyLargeText(
                              (user.customerName ?? '').capitalize!, context,
                              color: Colors.black),
                        ),
                        width5(),
                        capText(
                          '(${user.username ?? ''})',
                          context,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ],
                    ),
                    height5(),
                    Row(
                      children: [
                        Container(
                          height: 5,
                          width: 5,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.5)),
                        ),
                        width5(),
                        capText(!active ? 'De-active' : 'Active', context,
                            color: active ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w500),
                        width5(),
                        if (active && user.first_active_date != null)
                          capText(
                            '( ${formatDate(DateTime.parse(user.first_active_date!), 'dd MMM yyyy h:m a')} )',
                            context,
                            color: fadeTextColor,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          //refered by

          Column(
            children: [
              height10(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  capText('Email Id:', context,
                      color: fadeTextColor, fontWeight: FontWeight.w500),
                  capText(
                    user.customerEmail ?? '',
                    context,
                    color: fadeTextColor,
                  ),
                ],
              ),
            ],
          ),

          //joined on
          Column(
            children: [
              height10(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  capText('Joined On:', context,
                      color: fadeTextColor, fontWeight: FontWeight.w500),
                  if (user.createdAt != null)
                    capText(
                      '${formatDate(DateTime.parse(user.createdAt!), 'dd MMM yyyy hh:mm a')}',
                      context,
                      color: fadeTextColor,
                    ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _PlaceUserSubmitWidget extends StatefulWidget {
  const _PlaceUserSubmitWidget({super.key, required this.id, this.onSuccess});
  final String id;
  final Function? onSuccess;

  @override
  State<_PlaceUserSubmitWidget> createState() => _PlaceUserSubmitWidgetState();
}

class _PlaceUserSubmitWidgetState extends State<_PlaceUserSubmitWidget> {
  final _formKey = GlobalKey<FormState>();
  final _placementIdController = TextEditingController();
  final _placemeentFocusNode = FocusNode();
  int? _value;

  void _selectedTeam(int? value) {
    FocusScope.of(context).unfocus();
    setState(() => _value = value);
  }

  @override
  Widget build(BuildContext context) {
    print('build _PlaceUserSubmitWidget');
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Container(
        height: 300,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16), topRight: Radius.circular(16)),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleLargeText('Select Preferred Leg For Placement', context,
                  useGradient: true),
              height5(),
              capText(
                  'Select the leg where you want to place the user.', context,
                  color: Colors.black54),
              height20(),
              Row(
                children: [
                  bodyLargeText('Place To:', context,
                      useGradient: false, color: Colors.black54),
                  width20(),
                  // text field for enter placement id
                  Expanded(
                    child: TextFormField(
                      focusNode: _placemeentFocusNode,
                      controller: _placementIdController,
                      style: TextStyle(color: Colors.black, fontSize: 14),
                      cursorHeight: 14,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        hintText: 'Enter Placement Id',
                        hintStyle:
                            TextStyle(color: Colors.black54, fontSize: 14),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide(color: Colors.black54)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide(color: Colors.black54)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide(color: Colors.black54)),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter placement id';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              height10(),
              // radio button for select team
              bodyLargeText('Select Team', context,
                  useGradient: false, color: Colors.black54),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Radio(
                        value: 1,
                        groupValue: _value,
                        onChanged: _selectedTeam,
                      ),
                      bodyLargeText('Team 1', context),
                    ],
                  ),
                  //
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Radio(
                        value: 2,
                        groupValue: _value,
                        onChanged: _selectedTeam,
                      ),
                      bodyLargeText('Team 2', context),
                    ],
                  ),

                  //
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Radio(
                        value: 3,
                        groupValue: _value,
                        onChanged: _selectedTeam,
                      ),
                      bodyLargeText('Team 3', context),
                    ],
                  ),
                ],
              ),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _value != null
                        ? () {
                            FocusScope.of(context).unfocus();
                            if (!(_formKey.currentState?.validate() ?? true)) {
                              return;
                            }
                            sl.get<TeamViewProvider>().placeUser(
                                  customerId: widget.id,
                                  placementId: _placementIdController.text,
                                  leg: _value.toString(),
                                  onSuccess: (msg) {
                                    if (widget.onSuccess != null)
                                      widget.onSuccess!();
                                    Navigator.pop(context);
                                  },
                                  onError: (message) {
                                    if (message != null) {
                                      Fluttertoast.showToast(msg: message);
                                    }
                                  },
                                );
                          }
                        : null,
                    child: Text('Submit'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Cancel'),
                  ),
                ],
              ),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
