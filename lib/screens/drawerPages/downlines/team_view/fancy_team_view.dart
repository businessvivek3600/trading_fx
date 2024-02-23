import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_drawing/path_drawing.dart';

import '../../../../constants/assets_constants.dart';
import '../../../../database/functions.dart';
import '../../../../database/model/response/base/api_response.dart';
import '../../../../database/model/response/team_downline_user_model.dart';
import '../../../../database/repositories/team_view_repo.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../sl_container.dart';
import '../../../../utils/picture_utils.dart';
import '../../../../utils/sizedbox_utils.dart';
import '../../../../utils/text.dart';

import 'dart:math' show Random;

import '../trem_view_page.dart';

class FancyTreeView extends StatelessWidget {
  const FancyTreeView({super.key});

  @override
  Widget build(BuildContext context) {
    return const FancyTeamViewUI();
  }
}

class FancyTeamViewUI extends StatefulWidget {
  const FancyTeamViewUI({super.key});

  @override
  State<FancyTeamViewUI> createState() => _FancyTeamViewUIState();
}

class _FancyTeamViewUIState extends State<FancyTeamViewUI> {
  @override
  Widget build(BuildContext context) {
    double indent = 40;
    final guide = IndentGuide.connectingLines(
      indent: indent,
      color: Theme.of(context).colorScheme.outline,
      thickness: 2,
      origin: 0.5,
      roundCorners: true,
    );
    return  Scaffold(
        appBar: AppBar(
            title: titleLargeText('Team View', context, useGradient: true)),
        body: Container(
          height: double.maxFinite,
          width: double.maxFinite,
          decoration: BoxDecoration(
            image: DecorationImage(
                image: userAppBgImageProvider(context), fit: BoxFit.cover),
          ),
          child: DefaultIndentGuide(
            guide: guide,
            child: LazyLoadingTreeView(indent: indent),
          ),
        ),
      );
   
  }
}

class LazyLoadingTreeView extends StatefulWidget {
  const LazyLoadingTreeView({super.key, this.indent = 40});
  final double indent;
  @override
  State<LazyLoadingTreeView> createState() => _LazyLoadingTreeViewState();
}

class _LazyLoadingTreeViewState extends State<LazyLoadingTreeView> {
  late final Random rng = Random();
  late final TreeController<TeamDownlineUser> treeController;

  Iterable<TeamDownlineUser> childrenProvider(TeamDownlineUser data) {
    return childrenMap[data.username] ?? const Iterable.empty();
  }

  final Map<String, List<TeamDownlineUser>> childrenMap = {
    sl.get<AuthProvider>().userData.username!: [],
  };

  final Set<String> loadingIds = {};
  final Set<int> levels = {};
  int curMaxLevel = 1;
  bool loading = false;
  Future<void> loadChildren(TeamDownlineUser data) async {
    final List<TeamDownlineUser>? children = childrenMap[data.username!];
    if (children != null) return;

    setState(() {
      loadingIds.add(data.username!);
    });
    //
    await Future.delayed(const Duration(milliseconds: 750));
    var users = await getDownLines(data.newLevel!, data.username!);
    childrenMap[data.username!] = users;
    if (users.isNotEmpty) {
      toggleLevel(data.newLevel!);
    }
    // log(childrenMap[data.username!]!.map((e) => e.nameWithUsername));
    loadingIds.remove(data.username!);
    if (mounted) setState(() {});
    treeController.expand(data);
  }

  Widget getLeadingFor(TeamDownlineUser data) {
    if (loadingIds.contains(data.username!)) {
      return const Center(
          child: SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white)));
    }

    late final VoidCallback? onPressed;
    late final bool? isOpen;

    final List<TeamDownlineUser>? children = childrenMap[data.username!];
    if (children == null) {
      isOpen = false;
      onPressed = () => loadChildren(data);
    } else if (children.isEmpty) {
      isOpen = null;
      onPressed = null;
    } else {
      isOpen = treeController.getExpansionState(data);
      onPressed = () {
        treeController.toggleExpansion(data);
      };
    }

    return FolderButton(
      key: GlobalObjectKey(data.username!),
      isOpen: isOpen,
      onPressed: onPressed,
      icon: const Icon(Icons.person, color: Colors.white),
      openedIcon:
          const Icon(Icons.keyboard_arrow_up_rounded, color: Colors.white),
      closedIcon:
          const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70),
    );
  }

  init() async {
    // debugPaintSizeEnabled = true;
    // debugPaintBaselinesEnabled = true;

    setState(() {
      loading = true;
    });
    var user = sl.get<AuthProvider>().userData;
    childrenMap[user.username!] = await getDownLines(1, user.username!);
    log(childrenMap[user.username!]!.map((e) => e.nameWithUsername).toString());
    treeController = TreeController<TeamDownlineUser>(
        roots: childrenProvider(TeamDownlineUser(username: user.username!)),
        childrenProvider: childrenProvider);
    setState(() {
      loading = false;
    });
  }

  toggleLevel(int val) {
    setState(() {
      if (levels.contains(val)) {
        // levels.remove(val);
      } else {
        levels.add(val);
      }
    });
    log('leveles $levels');
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    treeController.dispose();
    super.dispose();
  }

  Future<List<TeamDownlineUser>> getDownLines(int level, String id) async {
    List<TeamDownlineUser> levelArray = [];
    if (isOnline) {
      try {
        ApiResponse apiResponse = await sl
            .get<TeamViewRepo>()
            .getDownLines({'level': level.toString(), 'sponser_username': id});
        log('team-view <getDownLines> $level');
        log('team-view <getDownLines> ${apiResponse.response?.data}');
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
                map['levelArray'].forEach(
                    (e) => levelArray.add(TeamDownlineUser.fromJson(e)));
                log(levelArray.length.toString());
              } catch (e) {
                log('could not generate the level array $e');
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

  @override
  Widget build(BuildContext context) {
    int max = 1;
    if (levels.isNotEmpty) {
      max =
          levels.reduce((value, element) => value > element ? value : element);
    }
    bool noChildren =
        childrenMap[sl.get<AuthProvider>().userData.username ?? '']!.isEmpty;
    log('max is $max');
    return Column(
      children: [
        Expanded(
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              SizedBox(
                  height: Get.height,
                  width: Get.width + ((noChildren ? 0 : max) * 40),
                  child: !loading
                      ? !noChildren
                          ? buildAnimatedTreeView(context)
                          : buildEmptyList(context)
                      : const Center(
                          child:
                              CircularProgressIndicator(color: Colors.white))),
            ],
          ),
        ),
      ],
    );
  }

  AnimatedTreeView<TeamDownlineUser> buildAnimatedTreeView(
      BuildContext context) {
    return AnimatedTreeView<TeamDownlineUser>(
      treeController: treeController,
      nodeBuilder: (_, TreeEntry<TeamDownlineUser> entry) {
        return TreeIndentation(
          entry: entry,
          child: Row(
            children: [
              SizedBox(
                width: 300,
                child: Row(
                  children: [
                    SizedBox.square(
                      dimension: (entry.node.downline != null &&
                                  entry.node.downline! > 0) ||
                              entry.node.newLevel == 2
                          ? 40
                          : 0,
                      child: (entry.node.downline != null &&
                              entry.node.downline! > 0)
                          ? getLeadingFor(entry.node)
                          : null,
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white70)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: capText(
                                      (entry.node.nameWithUsername ?? '')
                                          .capitalize!,
                                      context,
                                      fontWeight: FontWeight.bold),
                                ),
                                width20(),
                                if (entry.node.status == '1' ||
                                    entry.node.status == '2')
                                  Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: entry.node.status == '1'
                                            ? Colors.green
                                            : Colors.red),
                                    child: capText(
                                        entry.node.status == '1'
                                            ? 'Active'
                                            : 'Deactive',
                                        context,
                                        color: Colors.white),
                                  )
                              ],
                            ),
                            if (entry.node.activeDate != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 5.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    capText(
                                        'Active date:- ${DateFormat().add_yMMMd().add_jm().format(DateTime.parse(entry.node.activeDate!))}',
                                        context,
                                        fontWeight: FontWeight.w500),
                                    capText(
                                        'Total Members:- ${entry.node.totalMember}',
                                        context),
                                    capText(
                                        'Active Members:- ${entry.node.activeMember}',
                                        context),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      padding: const EdgeInsets.all(0),
      duration: const Duration(milliseconds: 300),
    );
  }

  Padding buildEmptyList(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //TODO: teamViewLottie
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              assetLottie(Assets.teamViewLottie, width: 200),
            ],
          ),
          titleLargeText(
              'Create team & join more people to enlarge the system.', context,
              color: Colors.black, textAlign: TextAlign.center),
          height20(),
          buildTeamBuildingReferralLink(context)
        ],
      ),
    );
  }
}

enum IndentType {
  connectingLines('Connecting Lines'),
  scopingLines('Scoping Lines'),
  blank('Blank');

  final String title;

  const IndentType(this.title);

  static Iterable<IndentType> allExcept(IndentType type) {
    return values.where((element) => element != type);
  }
}

enum LineStyle {
  dashed('Dashed'),
  dotted('Dotted'),
  solid('Solid');

  final String title;
  const LineStyle(this.title);

  Path Function(Path)? toPathModifier() {
    switch (this) {
      case LineStyle.dashed:
        return (Path path) => dashPath(
              path,
              dashArray: CircularIntervalList(const [6, 4]),
              dashOffset: const DashOffset.absolute(6 / 4),
            );
      case LineStyle.dotted:
        return (Path path) => dashPath(
              path,
              dashArray: CircularIntervalList(const [0.5, 3.5]),
              dashOffset: const DashOffset.absolute(0.5 * 3.5),
            );
      case LineStyle.solid:
        return null;
    }
    ;
  }
}

class SettingsState {
  const SettingsState({
    this.animateExpansions = true,
    this.brightness = Brightness.light,
    this.color = Colors.blue,
    this.indent = 40.0,
    this.indentType = IndentType.connectingLines,
    this.lineOrigin = 0.5,
    this.lineThickness = 2.0,
    this.roundedCorners = false,
    this.textDirection = TextDirection.LTR,
    this.lineStyle = LineStyle.solid,
    this.connectBranches = false,
  });

  final bool animateExpansions;
  final Brightness brightness;
  final Color color;
  final double indent;
  final IndentType indentType;
  final double lineOrigin;
  final double lineThickness;
  final bool roundedCorners;
  final TextDirection textDirection;
  final LineStyle lineStyle;
  final bool connectBranches;

  SettingsState copyWith({
    bool? animateExpansions,
    Brightness? brightness,
    Color? color,
    double? indent,
    IndentType? indentType,
    double? lineOrigin,
    double? lineThickness,
    bool? roundedCorners,
    TextDirection? textDirection,
    LineStyle? lineStyle,
    bool? connectBranches,
  }) {
    return SettingsState(
      animateExpansions: animateExpansions ?? this.animateExpansions,
      brightness: brightness ?? this.brightness,
      color: color ?? this.color,
      indent: indent ?? this.indent,
      indentType: indentType ?? this.indentType,
      lineOrigin: lineOrigin ?? this.lineOrigin,
      lineThickness: lineThickness ?? this.lineThickness,
      roundedCorners: roundedCorners ?? this.roundedCorners,
      textDirection: textDirection ?? this.textDirection,
      lineStyle: lineStyle ?? this.lineStyle,
      connectBranches: connectBranches ?? this.connectBranches,
    );
  }
}

class SettingsController with ChangeNotifier {
  SettingsController({
    SettingsState state = const SettingsState(),
  }) : _state = state;

  SettingsState get state => _state;
  late SettingsState _state;
  @protected
  set state(SettingsState state) {
    _state = state;
    notifyListeners();
  }

  void restoreAll() {
    state = const SettingsState();
  }

  void updateAnimateExpansions(bool value) {
    if (value == state.animateExpansions) return;
    state = state.copyWith(animateExpansions: value);
  }

  void updateBrightness(Brightness value) {
    if (state.brightness == value) return;
    state = state.copyWith(brightness: value);
  }

  void updateColor(Color value) {
    if (state.color == value) return;
    state = state.copyWith(color: value);
  }

  void updateIndent(double value) {
    if (state.indent == value) return;
    state = state.copyWith(indent: value);
  }

  void updateIndentType(IndentType value) {
    if (state.indentType == value) return;
    state = state.copyWith(indentType: value);
  }

  void updateLineOrigin(double value) {
    if (state.lineOrigin == value) return;
    state = state.copyWith(lineOrigin: value);
  }

  void updateLineThickness(double value) {
    if (state.lineThickness == value) return;
    state = state.copyWith(lineThickness: value);
  }

  void updateRoundedCorners(bool value) {
    if (state.roundedCorners == value) return;
    state = state.copyWith(roundedCorners: value);
  }

  void updateTextDirection(TextDirection value) {
    if (state.textDirection == value) return;
    state = state.copyWith(textDirection: value);
  }

  void updateLineStyle(LineStyle value) {
    if (state.lineStyle == value) return;
    state = state.copyWith(lineStyle: value);
  }

  void updateConnectBranches(bool value) {
    if (state.connectBranches == value) return;
    state = state.copyWith(connectBranches: value);
  }
}
