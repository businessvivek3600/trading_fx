import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graphview/GraphView.dart';
import '../trem_view_page.dart';
import '/constants/assets_constants.dart';
import '/database/functions.dart';
import '/database/model/response/team_downline_user_model.dart';
import '/database/repositories/team_view_repo.dart';
import '/providers/auth_provider.dart';
import '/providers/team_view_provider.dart';
import '/sl_container.dart';
import '/utils/color.dart';
import '/utils/no_internet_widget.dart';
import '/utils/picture_utils.dart';
import '/utils/sizedbox_utils.dart';
import '/utils/text.dart';
import '/widgets/Custom_BottomSheetDialog.dart';
import 'package:provider/provider.dart';

import '../../../../database/model/response/base/api_response.dart';
import '../../../../widgets/MultiStageButton.dart';

class MyTreeViewPage extends StatefulWidget {
  @override
  _MyTreeViewPageState createState() => _MyTreeViewPageState();
}

class _MyTreeViewPageState extends State<MyTreeViewPage> {
  var auth = sl.get<AuthProvider>();

  @override
  void initState() {
    super.initState();
    init();
    builder
      // ..nodeSeparation = (5)
      ..siblingSeparation = 5
      ..levelSeparation = 20
      ..orientation = SugiyamaConfiguration.DEFAULT_ORIENTATION;
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor:
            isOnline && !loadingInitial && childrenMap.entries.isEmpty
                ? Colors.white
                : mainColor,
        appBar: AppBar(
            title: titleLargeText('Generation Tree View', context,
                useGradient: true),
            shadowColor: Colors.white24),
        body: isOnline
            ? Stack(
                children: [
                  Container(
                      height: double.maxFinite,
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: userAppBgImageProvider(context),
                              fit: BoxFit.cover,
                              opacity: 0.9))),
                  !loadingInitial
                      ? childrenMap.entries.isNotEmpty
                          ? Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Expanded(
                                  child: InteractiveViewer(
                                      constrained: false,
                                      boundaryMargin: const EdgeInsets.all(100),
                                      minScale: 0.5,
                                      maxScale: 10.6,
                                      child: GraphView(
                                        graph: graph,
                                        algorithm: BuchheimWalkerAlgorithm(
                                            builder, TreeEdgeRenderer(builder)),
                                        paint: Paint()
                                          ..color = Colors.grey
                                          ..strokeWidth = 0.5
                                          ..style = PaintingStyle.stroke,
                                        builder: (Node node) {
                                          // I can decide what widget should be shown here based on the id
                                          var a = node.key!.value as int?;
                                          TeamDownlineUser source =
                                              TeamDownlineUser();
                                          return rectangleWidget(a, source);
                                        },
                                      )),
                                ),
                              ],
                            )
                          : buildEmptyList(context)
                      : const Center(
                          child:
                              CircularProgressIndicator(color: appLogoColor)),
                ],
              )
            : const NoInternetWidget());
  }

  Random r = Random();

  Widget rectangleWidget(int? a, TeamDownlineUser source) {
    TeamDownlineUser user = a == 1 ? rooTUser! : TeamDownlineUser();
    childrenMap.entries.forEach((element) {
      if (element.value.any((element) => element.nodeVal == a)) {
        user = element.value.firstWhere((element) => element.nodeVal == a);
      }
    });
    return GestureDetector(
      // onTap: (user.downline ?? 0) > 0 ? () => loadChildren(user) : null,
      child: TeamViewUserIconWidget(
        rootUser: a == 1,
        user: user,
        loadingNodeId: loadingNodeId,
        context: context,
        callBack: (user.downline ?? 0) > 0 ? () => loadChildren(user) : null,
      ),
    );
  }

  final Graph graph = Graph()..isTree = true;
  BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration();

  int nodeVal = 1;
  int loadingNodeId = 1;
  bool loadingInitial = false;
  bool loadingChildren = false;

  Future<void> loadChildren(TeamDownlineUser data) async {
    // final List<TeamDownlineUser>? children = childrenMap[data.username!];
    // if (children != null) return;
    setState(() {
      loadingNodeId = data.nodeVal!;
      loadingChildren = true;
    });
    await Future.delayed(const Duration(milliseconds: 750));
    var users = await getDownLines(data.newLevel!, data.username!);
    final source = Node.Id(data.nodeVal);
    data.expanded = true;
    print('users.length   ${users.length}');
    print('source   ${data.nodeVal}  ${data.toJson()}');
    users.forEach((element) {
      var user = element;
      nodeVal++;
      print('nodeVal ${nodeVal}');
      user.nodeVal = nodeVal;
      print(childrenMap);
      print(
          'contain in children map ${childrenMap.entries.any((entry) => entry.key == data.nodeVal!)}');
      if (!childrenMap.entries.any((entry) => entry.key == data.nodeVal!)) {
        childrenMap.addEntries([MapEntry(data.nodeVal!, <TeamDownlineUser>[])]);
        // childrenMap.addAll({data.nodeVal!: []});
        print(childrenMap);
        print(
            'children map is blank ${childrenMap.entries.length} ${user.toJson()}');
      }
      print(
          'now contain in children map ${childrenMap.entries.any((entry) => entry.key == data.nodeVal!)}');
      var nodeArray = childrenMap.entries
          .firstWhere((element) => element.key == data.nodeVal!)
          .value;
      if (!nodeArray.any((ele) => ele.username == user.username)) {
        childrenMap.entries
            .firstWhere((element) => element.key == data.nodeVal!)
            .value
            .add(user);
        final destination = Node.Id(user.nodeVal);
        graph.addEdge(source, destination);
      } else {
        print('user already contains');
      }

      print('children map is not empty ${childrenMap.entries.length}');
    });
    setState(() {
      loadingNodeId = 0;
      loadingChildren = false;
    });
  }

  Future<List<TeamDownlineUser>> getDownLines(int level, String id) async {
    List<TeamDownlineUser> levelArray = [];
    if (isOnline) {
      try {
        ApiResponse apiResponse = await sl
            .get<TeamViewRepo>()
            .getDownLines({'level': level.toString(), 'sponser_username': id});
        if (apiResponse.response != null &&
            apiResponse.response!.statusCode == 200) {
          Map map = apiResponse.response!.data;
          bool status = false;
          try {
            status = map["status"];
            if (map['is_logged_in'] == 0) {
              logOut('getDownLines');
            }
            if (status) {
              try {
                map['customer_child'].forEach(
                    (e) => levelArray.add(TeamDownlineUser.fromJson(e)));
                print(levelArray.length);
              } catch (e) {
                print('could not generate the level array $e');
              }
            }
          } catch (e) {}
        }
      } catch (e) {}
    } else {
      Fluttertoast.showToast(msg: 'No internet connection');
    }
    return levelArray;
  }

  final Map<int, List<TeamDownlineUser>> childrenMap = {};
  TeamDownlineUser? rooTUser;

  void init() async {
    setState(() {
      loadingInitial = true;
    });
    try {
      rooTUser = TeamDownlineUser(
          username: auth.userData.username, nodeVal: nodeVal, newLevel: 1);
      print('------- user ${rooTUser!.toJson()} ----------- ux');
      await loadChildren(rooTUser!);
    } catch (e) {
      print('-------e $e ----------- e');
    }
    setState(() {
      loadingInitial = false;
    });
  }

  Padding buildEmptyList(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //TODO: teamViewLottie
          Expanded(child: assetLottie(Assets.teamViewLottie, width: 200)),
          width10(),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                titleLargeText(
                    'Create team & join more people to enlarge the system.',
                    context,
                    color: Colors.white,
                    textAlign: TextAlign.center),
                height20(),
                buildTeamBuildingReferralLink(context, linkColor: Colors.white),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class TeamViewUserIconWidget extends StatefulWidget {
  const TeamViewUserIconWidget({
    super.key,
    required this.user,
    required this.loadingNodeId,
    required this.context,
    this.callBack,
    required this.rootUser,
    this.showMessage = false,
  });

  final TeamDownlineUser user;
  final bool rootUser;
  final int loadingNodeId;
  final BuildContext context;
  final VoidCallback? callBack;
  final bool showMessage;

  @override
  State<TeamViewUserIconWidget> createState() => _TeamViewUserIconWidgetState();
}

class _TeamViewUserIconWidgetState extends State<TeamViewUserIconWidget>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    animation =
        CurveTween(curve: Curves.bounceInOut).animate(animationController!);
    // countryOverlayFocus.addListener(() {
    //   ('countryOverlayFocus.hasFocus ${countryOverlayFocus.hasFocus}');

    // if (!countryOverlayFocus.hasFocus) {
    //   this.countryOverlay = _showOverLay();
    //   Overlay.of(context).insert(this.countryOverlay!);
    // } else {
    //   this.countryOverlay?.remove();
    //   this.countryOverlay = null;
    // }
    setState(() {});
    // });
  }

  @override
  void dispose() {
    animationController?.dispose();
    // removeCountryOverlay();
    super.dispose();
  }

  AnimationController? animationController;
  Animation<double>? animation;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.callBack,
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            border: Border.all(
                width: 0.5,
                color: widget.user.status == '1'
                    ? Colors.green
                    : widget.user.status == '2'
                        ? Colors.red
                        : Colors.grey)),
        child: Column(
          children: [
            Stack(
              children: [
                GestureDetector(
                  onTap: widget.callBack,
                  child: Stack(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.cyan.shade50,
                        ),
                        child: Icon(Icons.person,
                            size: 6,
                            color: widget.user.status == '1'
                                ? Colors.green
                                : widget.user.status == '2'
                                    ? Colors.red
                                    : Colors.grey),
                      ),

                      /* if (widget.loadingNodeId == widget.user.nodeVal)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          top: 0,
                          child: appLoadingDots(width: 5, height: 6),
                        ),
                      if ((widget.user.downline ?? 0) > 0 &&
                          widget.loadingNodeId != widget.user.nodeVal)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          top: 0,
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white, shape: BoxShape.circle),
                            width: 8,
                            height: 8,
                            child: Center(
                                child: assetSvg(Assets.teamView,
                                    width: 5, color: Colors.white)),
                          ),
                        ),*/
                    ],
                  ),
                ),
                if (!widget.rootUser && widget.showMessage)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: () => _showChatDialog(widget.user),
                      child: Container(
                          width: 5,
                          height: 5,
                          padding: const EdgeInsets.all(0.3),
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle, color: Colors.white),
                          child: assetImages(Assets.chatIconImage)),
                    ),
                  ),
              ],
            ),
            height5(2),
            Row(
              key: countryOverlayKey,
              children: [
                if ((widget.user.downline ?? 0) > 0 &&
                    widget.loadingNodeId != widget.user.nodeVal)
                  Padding(
                    padding: const EdgeInsets.only(right: 2.0),
                    child: assetSvg(Assets.teamMember,
                        width: 4, color: Colors.white),
                  ),
                if (widget.loadingNodeId == widget.user.nodeVal)
                  Container(
                      width: 5,
                      height: 5,
                      margin: const EdgeInsets.only(right: 2),
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 0.5,
                      )),
                capText((widget.user.username ?? '').toUpperCase(), context,
                    color: Colors.white, fontSize: 3),
              ],
            ),
            if (widget.user.activeDate != null)
              Column(
                children: [
                  height5(2),
                  capText(
                      '${int.tryParse(widget.user.totalMember ?? '') ?? '0'} Members',
                      context,
                      color: Colors.white,
                      fontSize: 3),
                  height5(2),
                  capText(
                      '${int.tryParse(widget.user.activeMember ?? '') ?? '0'} Active Members',
                      context,
                      color: Colors.white,
                      fontSize: 2),
                ],
              ),
          ],
        ),
      ),
    );
  }

  OverlayEntry? countryOverlay;

  final LayerLink _layerLink = LayerLink();

  GlobalKey countryOverlayKey = GlobalKey();

  _showOverLay() async {
    RenderBox? renderBox =
        countryOverlayKey.currentContext!.findRenderObject() as RenderBox?;
    Offset offset = renderBox!.localToGlobal(Offset.zero);
    print('offset is $offset');
    OverlayState? overlayState = Overlay.of(widget.context);
    var size = renderBox.size;

    // primaryFocus?.requestFocus( countryOverlayFocus);
    print('offset is $offset');
    countryOverlay?.remove();
    countryOverlay = null;
    countryOverlay = OverlayEntry(
        builder: (context) => Positioned(
              left: offset.dx + 1,
              top: offset.dy + 1,
              child: CompositedTransformFollower(
                link: this._layerLink,
                showWhenUnlinked: false,
                offset: Offset(size.width + 1, -1.0),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(1),
                      color: Colors.white70),
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Container(
                        height: 2,
                        color: Colors.red,
                        width: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ));
    animationController!.addListener(() {
      overlayState.setState(() {});
    });
    animationController!.forward();
    overlayState.insert(countryOverlay!);
  }

  _showChatDialog(TeamDownlineUser user) {
    showBottomSheet(
        context: context,
        // transitionAnimationController: animationController,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return _MessageDialog(user: user);
        });
  }
}

class _MessageDialog extends StatefulWidget {
  const _MessageDialog({super.key, required this.user});

  final TeamDownlineUser user;
  @override
  State<_MessageDialog> createState() => _MessageDialogState();
}

class _MessageDialogState extends State<_MessageDialog> {
  final _formKey = GlobalKey<FormState>();
  var subject = TextEditingController();
  var message = TextEditingController();
  RegExp regExp = RegExp(r'^[a-zA-Z0-9,.\s]+$');
  @override
  Widget build(BuildContext context) {
    Color tColor = Colors.black;
    return AnimatedBottomSheetDialogWidget(
      child: WillPopScope(
        onWillPop: () async =>
            subject.text.isNotEmpty || message.text.isNotEmpty
                ? await _willPopScope()
                : true,
        child: Consumer<TeamViewProvider>(
          builder: (context, provider, child) {
            return Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 55,
                            height: 55,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.cyan.shade50),
                            child: Icon(Icons.person,
                                color: widget.user.status == '1'
                                    ? Colors.green
                                    : widget.user.status == '2'
                                        ? Colors.red
                                        : Colors.grey),
                          ),
                          width10(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              bodyLargeText(
                                  (widget.user.username ?? '').toUpperCase(),
                                  context,
                                  color: tColor),
                              height5(2),
                              if (widget.user.activeDate != null)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    capText(
                                        'Total M: ${widget.user.totalMember}',
                                        context,
                                        color: tColor),
                                    height5(2),
                                    capText(
                                        'Active M: ${widget.user.activeMember}',
                                        context,
                                        color: tColor),
                                  ],
                                ),
                            ],
                          )
                        ],
                      ),
                      Row(
                        children: [
                          const Spacer(flex: 3),
                          Expanded(
                            flex: 1,
                            child: MultiStageButton(
                                buttonLoadingState: ButtonLoadingState.values
                                    .firstWhere((element) =>
                                        element.name ==
                                        provider.sendingStatus.name),
                                // idleColor: Colors.transparent,
                                iconMode: true,
                                idleColor: Colors.green,
                                idleIcon: const Padding(
                                    padding: EdgeInsets.only(left: 8.0),
                                    child:
                                        Icon(Icons.send, color: Colors.white)),
                                failColor: Colors.red,
                                failedIcon: const Padding(
                                    padding: EdgeInsets.only(left: 5.0),
                                    child:
                                        Icon(Icons.error, color: Colors.white)),
                                completedColor: Colors.green,
                                completedIcon: const Padding(
                                    padding: EdgeInsets.only(left: 5.0),
                                    child: Icon(Icons.done_all,
                                        color: Colors.white)),
                                onPressed: () => _formKey.currentState
                                            ?.validate() ??
                                        false
                                    ? provider
                                        .sendMessage(
                                          onError: () {
                                            print(provider.errorText);
                                            _formKey.currentState?.validate();
                                          },
                                          userId: widget.user.username ?? '',
                                          title: subject.text,
                                          subject: message.text,
                                        )
                                        .then((value) => value
                                            ? setState(() {
                                                subject.clear();
                                                message.clear();
                                                Navigator.pop(context);
                                              })
                                            : null)
                                    : () {}),
                          ),
                        ],
                      )
                    ],
                  ),
                  height10(),
                  TextFormField(
                    maxLength: 50,
                    controller: subject,
                    onEditingComplete: () => primaryFocus?.unfocus(),
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: 'Subject',
                      errorMaxLines: 2,
                      hintStyle: GoogleFonts.ubuntu(
                          textStyle: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(
                                  color: Colors.black38,
                                  fontWeight: FontWeight.bold)),
                      filled: true,
                      fillColor: Colors.grey.withOpacity(
                          0.1), /*                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(5),borderSide: BorderSide(color: tColor)),
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(5),borderSide: BorderSide(color: tColor)),

                                  errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(5),borderSide: BorderSide(color: Colors.red)),*/
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Subject is required';
                      } else if (val.length < 5 || val.length > 20) {
                        return 'Subject should be at least 5 and max 20 characters.';
                      } else if (!regExp.hasMatch(val)) {
                        return 'Special characters are not allowed';
                      }
                      // else if (provider.errorText != null) {
                      //   return provider.errorText;
                      // }
                      return null;
                    },
                  ),
                  height10(),
                  TextFormField(
                    maxLines: 5,
                    maxLength: 100,
                    controller: message,
                    onEditingComplete: () => primaryFocus?.unfocus(),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(10),
                      counterText: '',
                      filled: true,
                      fillColor: Colors.grey.withOpacity(0.1),
                      hintText: 'Enter your message',
                      errorMaxLines: 2,
                      hintStyle: GoogleFonts.ubuntu(
                          textStyle: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(
                                  color: Colors.black38,
                                  fontWeight: FontWeight.bold)),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Please enter your message';
                      } else if (val.length < 5 || val.length > 100) {
                        return 'Subject should be at least 5 and max 100 characters.';
                      } else if (!regExp.hasMatch(val)) {
                        return 'Special characters are not allowed e.g.(.;*@)';
                      }
                      // else if (provider.errorText != null) {
                      //   return provider.errorText;
                      // }
                      return null;
                    },
                  ),
                  if (provider.errorText != null)
                    capText(provider.errorText!, context,
                        color: provider.sendingStatus ==
                                ButtonLoadingState.completed
                            ? Colors.green
                            : Colors.red)
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<bool> _willPopScope() async {
    // Completer to handle the result of the Future<bool>
    Completer<bool> completer = Completer<bool>();
    primaryFocus?.unfocus();
    // Show the BottomSheet
    await showModalBottomSheet(
        context: context,
        // transitionAnimationController: animationController,
        backgroundColor: Colors.transparent,
        builder: (context) => AnimatedBottomSheetDialogWidget(
            bgColor: Colors.transparent,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10))),
                          onPressed: () {
                            // Complete the Future<bool> with false and close the BottomSheet
                            completer.complete(true);
                            Navigator.pop(context);
                          },
                          child: titleLargeText('Confirm', context)),
                    ),
                  ],
                ),
                height5(),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10))),
                          onPressed: () {
                            // Complete the Future<bool> with false and close the BottomSheet
                            completer.complete(false);
                            Navigator.pop(context);
                          },
                          child: titleLargeText('Cancel', context)),
                    ),
                  ],
                ),
              ],
            )));
    // Return the Future<bool> from the Completer
    return completer.future;
  }
}

class LayeredGraphProvider extends ChangeNotifier {}

class MyTooltip extends StatelessWidget {
  final Widget child;
  final String message;

  MyTooltip({required this.message, required this.child});

  @override
  Widget build(BuildContext context) {
    final key = GlobalKey<State<Tooltip>>();
    return Tooltip(
      key: key,
      message: message,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onTap(key),
        child: child,
      ),
    );
  }

  void _onTap(GlobalKey key) {
    final dynamic tooltip = key.currentState;
    tooltip?.ensureTooltipVisible();
  }
}
