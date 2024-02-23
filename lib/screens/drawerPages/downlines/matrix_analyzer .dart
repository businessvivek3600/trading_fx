import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';
import 'package:graphview/GraphView.dart';
import '/utils/default_logger.dart';
import '/database/model/response/abstract_user_model.dart';
import '../../../constants/assets_constants.dart';
import '/providers/auth_provider.dart';
import '/providers/dashboard_provider.dart';
import '/providers/team_view_provider.dart';
import '/utils/color.dart';
import '/utils/sizedbox_utils.dart';
import 'package:provider/provider.dart';
import '../../../sl_container.dart';
import '../../../utils/MyClippers.dart';
import '../../../utils/picture_utils.dart';
import '../../../utils/text.dart';
import 'generation_analyzer.dart';

class MatrixAnalyzerPage extends StatefulWidget {
  const MatrixAnalyzerPage({super.key});

  @override
  State<MatrixAnalyzerPage> createState() => _MatrixAnalyzerPageState();
}

class _MatrixAnalyzerPageState extends State<MatrixAnalyzerPage> {
  var provider = sl.get<TeamViewProvider>();
  var authProvider = sl.get<AuthProvider>();

  int selectedIndex = 0;

  final breadCumbScroll = ScrollController();
  void _animateToLast() {
    breadCumbScroll.animateTo(
      breadCumbScroll.position.maxScrollExtent,
      curve: Curves.fastOutSlowIn,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider.setBreadCrumbContent(
          0,
          BreadCrumbContent(
              index: 0,
              user: MatrixUser(username: authProvider.userData.username)));
      SystemChrome.setPreferredOrientations(
          [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    });
  }

  @override
  void dispose() {
    provider.breadCrumbContent.clear();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TeamViewProvider>(builder: (context, provider, _) {
      return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          appBar: buildAppBar(context),
          body: Container(
            height: double.maxFinite,
            width: double.maxFinite,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: userAppBgImageProvider(context),
                    fit: BoxFit.cover,
                    opacity: 1)),
            child: Column(children: [
              if (provider.breadCrumbContent.length > 0)
                bradcrumRow(provider, context),
              height10(),
              Expanded(
                  child: provider.loadingGUsers.name ==
                          ButtonLoadingState.loading.name
                      ? Center(
                          child: CircularProgressIndicator(color: appLogoColor))
                      : _MatrixTree(
                          username: (provider.breadCrumbContent.last.user
                                      as MatrixUser)
                                  .username ??
                              "",
                          onTap: (MatrixUser user) {
                            print('user ${user.toJson()}');
                            if (!provider.breadCrumbContent.any((element) =>
                                (element.user as MatrixUser).username ==
                                user.username)) {
                              provider.setBreadCrumbContent(
                                  provider.breadCrumbContent.length,
                                  BreadCrumbContent(
                                      index: provider.breadCrumbContent.length,
                                      user: user));
                            } else {
                              provider.setBreadCrumbContent(
                                  provider.breadCrumbContent.indexWhere(
                                      (element) =>
                                          (element.user as MatrixUser)
                                              .username ==
                                          user.username),
                                  BreadCrumbContent(
                                      index: provider.breadCrumbContent.length,
                                      user: user));
                            }
                          })),
            ]),
          ),
        ),
      );
    });
  }

  Row bradcrumRow(TeamViewProvider provider, BuildContext context) {
    return Row(
      children: [
        Expanded(child: buildBreadcrumbs(provider)),
        width5(),
        ClipPath(
          clipper: OvalLeftBorderClipper(),
          child: GestureDetector(
            onTap: () {
              if (provider.breadCrumbContent.length == 1) return;
              provider.setBreadCrumbContent(1);
              _animateToLast();
              setState(() {});
            },
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.red,
                  boxShadow: [
                    BoxShadow(
                        offset: Offset(0, 1),
                        blurRadius: 3,
                        color: Colors.black26)
                  ]),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Icon(Icons.arrow_back_rounded,
                  //     color: Colors.white, size: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: capText('Root', context,
                        color: Colors.white, useGradient: false),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Container buildBreadcrumbs(TeamViewProvider provider) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          // color: Colors.white,
          boxShadow: [
            BoxShadow(
                offset: Offset(0, 1), blurRadius: 3, color: Colors.black26)
          ]),
      padding: EdgeInsets.all(8),
      child: BreadCrumb.builder(
        itemCount: provider.breadCrumbContent.length,
        builder: (index) {
          MatrixUser user =
              provider.breadCrumbContent[index].user as MatrixUser;
          return BreadCrumbItem(
            margin: EdgeInsets.only(
                right:
                    index == provider.breadCrumbContent.length - 1 ? 100 : 0),
            content: capText('${user.username}', context, useGradient: true),
            onTap: () {
              provider.setBreadCrumbContent(index + 1);
              // provider.setGenerationUsers(user.generation);
              _animateToLast();
              setState(() {});
            },
          );
        },
        divider: Icon(Icons.chevron_right, color: Colors.white, size: 20),
        overflow: ScrollableOverflow(
            direction: Axis.horizontal,
            reverse: false,
            keepLastDivider: false,
            controller: breadCumbScroll),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      title: AnimatedSwitcher(
          duration: Duration(milliseconds: 500),
          child: titleLargeText('Matrix Analyzer', context, useGradient: true)),
      actions: [],
    );
  }
}

class _MatrixTree extends StatefulWidget {
  _MatrixTree({super.key, required this.username, required this.onTap});
  final String username;
  final Function(MatrixUser user) onTap;
  @override
  _MatrixTreeState createState() => _MatrixTreeState();
}

class _MatrixTreeState extends State<_MatrixTree> {
  double s = 5;
  var provider = sl.get<TeamViewProvider>();

  @override
  void initState() {
    super.initState();
    init();
    builder
      ..siblingSeparation = (25).toInt()
      ..levelSeparation = (25).toInt()
      ..subtreeSeparation = (25).toInt()
      ..orientation = SugiyamaConfiguration.DEFAULT_ORIENTATION;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TeamViewProvider>(builder: (context, provider, _) {
      infoLog(
          'getMatrixUsers provider.matrixUserErrorText ${provider.matrixUserErrorText}');
      return !loadingInitial
          ? provider.matrixUserErrorText == null
              ? (childrenMap.entries.isNotEmpty
                  ? LayoutBuilder(builder: (context, b) {
                      print('b bound ${b.maxHeight} ${b.maxWidth}');
                      return OrientationBuilder(
                          builder: (context, orientation) {
                        double margin =
                            orientation == Orientation.landscape ? 50 : 0;
                        return InteractiveViewer(
                          constrained: false,
                          boundaryMargin: EdgeInsets.only(
                              left: margin, right: margin, bottom: margin),
                          minScale: 1,
                          maxScale: 10.6,
                          scaleFactor: 100,
                          onInteractionEnd: (details) {
                            print('details ${details}');
                          },
                          panAxis: PanAxis.free,
                          child: GraphView(
                            graph: graph,
                            algorithm: BuchheimWalkerAlgorithm(
                                builder, TreeEdgeRenderer(builder)),
                            paint: Paint()
                              ..color = Colors.red
                              ..strokeWidth = 0.5
                              ..style = PaintingStyle.stroke,
                            builder: (Node node) {
                              // I can decide what widget should be shown here based on the id
                              var a = node.key!.value as int?;
                              MatrixUser source = MatrixUser();
                              return LayoutBuilder(builder: (context, c) {
                                print('c ${c.maxHeight} ${c.maxWidth}');
                                return rectangleWidget(a, source);
                              });
                            },
                          ),
                        );
                      });
                    })
                  : buildEmptyList(context))
              : Column(
                  children: [
                    Expanded(child: assetImages(Assets.mlm)),
                    height20(),
                    capText(provider.matrixUserErrorText ?? '', context),
                    height20(),
                  ],
                )
          : Center(child: CircularProgressIndicator(color: appLogoColor));
    });
  }

  Random r = Random();

  Widget rectangleWidget(int? a, MatrixUser source) {
    MatrixUser user = a == 1 ? rooTUser! : MatrixUser();
    childrenMap.entries.forEach((element) {
      if (element.value.any((element) => element.nodeValue == a)) {
        user = element.value.firstWhere((element) => element.nodeValue == a);
      }
    });
    return _TeamViewUserIconWidget(
      rootUser: a == 1,
      user: user,
      loadingNodeId: loadingNodeId,
      context: context,
      callBack: user.username != null ? () => widget.onTap(user) : null,
      showMessage: false,
    );
  }

  final Graph graph = Graph()..isTree = true;
  BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration();

  int nodeValue = 1;
  int loadingNodeId = 1;
  bool loadingInitial = false;
  bool loadingChildren = false;

  Future<void> loadChildren(MatrixUser data, {String? username}) async {
    setState(() {
      loadingNodeId = data.nodeValue!;
      loadingChildren = true;
    });
    await Future.delayed(const Duration(milliseconds: 750));
    var users = await getDownLines(data.newLevel!, username);
    final mSource = Node.Id(data.nodeValue);
    // print('users.length   ${users.length}');
    // print('source   ${data.nodeValue}  ${data.toJson()}');

    // loop for mUsers
    users.forEach((element) {
      var mUser = element;
      if (!childrenMap.entries.any((entry) => entry.key == data.nodeValue!)) {
        childrenMap.addEntries([MapEntry(data.nodeValue!, <MatrixUser>[])]);
      }
      var nodeArray = childrenMap.entries
          .firstWhere((element) => element.key == data.nodeValue!)
          .value;
      // if (!nodeArray.any((ele) => ele.username == mUser.username)) {
      nodeArray.add(mUser);
      final destination = Node.Id(mUser.nodeValue);
      // print('loadChildren m nodeArray  ${nodeArray.map((e) => e.toJson())}');
      print('m destination  ${destination.key}');
      graph.addEdge(mSource, destination);
      var dUsers = mUser.team ?? [];
      print('loadChildren d users.length   ${dUsers.length}');
      final dSource = Node.Id(mUser.nodeValue);

      // loop for dUsers
      dUsers.forEach((element) {
        var dUser = element;
        print(
            'loadChildren d childrenMap  ${childrenMap.entries.any((element) => element.key == mUser.nodeValue!)}');

        // add first time
        if (!childrenMap.entries
            .any((entry) => entry.key == mUser.nodeValue!)) {
          childrenMap.addEntries([MapEntry(mUser.nodeValue!, <MatrixUser>[])]);
        }
        var nodeArray = childrenMap.entries
            .firstWhere((element) => element.key == mUser.nodeValue!)
            .value;

        print('loadChildren d nodeArray  ${nodeArray.length}');

        // add first dUser
        // if (!nodeArray.any((ele) => ele.username == dUser.username)) {
        nodeArray.add(dUser);
        final destination = Node.Id(dUser.nodeValue);
        graph.addEdge(dSource, destination);
        // } else {
        //   print('duser already contains');
        // }
      });
      // } else {
      //   print('user already contains');
      // }
      print('loadChildren m children map ${childrenMap.length}');
    });
    print('children map is not empty ${childrenMap.entries.length}');
    setState(() {
      loadingNodeId = 0;
      loadingChildren = false;
    });
  }

  Future<List<MatrixUser>> getDownLines(int level, String? id) async {
    //dummy mUsers
    List<MatrixUser> mUsers = [MatrixUser(), MatrixUser(), MatrixUser()];

    //api result
    List<MatrixUser> levelArray =
        await provider.getMatrixUsers({'customer_id': id ?? ''});

    // for loop to manipulate dummy mUsers
    for (int mIndex = 0; mIndex < 3; mIndex++) {
      print('****dummy mUser $mIndex started ****');
      nodeValue++;
      MatrixUser mUser = mUsers[mIndex];

      if (levelArray.isNotEmpty) {
        if (levelArray.any((element) =>
            element.position != null &&
            element.position!.isNotEmpty &&
            int.parse(element.position!) == mIndex + 1)) {
          mUser = levelArray.firstWhere((element) =>
              element.position != null &&
              element.position!.isNotEmpty &&
              int.parse(element.position!) == mIndex + 1);
        }
      }
      mUser.nodeValue = nodeValue;
      mUser.newLevel = level + 1;

      List<MatrixUser> dUsers = [MatrixUser(), MatrixUser(), MatrixUser()];
      // for loop for dummy dUsers
      try {
        for (int dIndex = 0; dIndex < 3; dIndex++) {
          nodeValue++;
          print('------> dummy mUser$mIndex  <----- $dIndex dUser started');
          // manipulating dummy dUser
          MatrixUser dUser = dUsers[dIndex];
          var levelArray = mUser.team ?? [];
          if (levelArray.isNotEmpty) {
            if (levelArray.any((element) =>
                element.position != null &&
                element.position!.isNotEmpty &&
                int.parse(element.position!) == dIndex + 1)) {
              dUser = levelArray.firstWhere((element) =>
                  element.position != null &&
                  element.position!.isNotEmpty &&
                  int.parse(element.position!) == dIndex + 1);
            }
          }
          dUser.nodeValue = nodeValue;
          dUser.newLevel = level + 2;
          dUsers[dIndex] = dUser;
        }
      } catch (e) {
        print('e $e');
      }
      mUser.team = dUsers;
      mUsers[mIndex] = mUser;
      print(
          '****dummy mUser$mIndex $mIndex finished **** ${mUser.toJson()}\n\n ----');
    }
    print('_ mUsers.length ${mUsers.length}');
    return mUsers;
  }

  final Map<int, List<MatrixUser>> childrenMap = {};
  MatrixUser? rooTUser;
  void init() async {
    setState(() {
      loadingInitial = true;
    });
    try {
      rooTUser = MatrixUser(
          username: widget.username, nodeValue: nodeValue, newLevel: 1);
      print('------- user ${rooTUser!.toJson()} ----------- ux');
      await loadChildren(rooTUser!,
          username: sl.get<TeamViewProvider>().breadCrumbContent.length == 1
              ? null
              : rooTUser!.username);
    } catch (e) {
      print('-------e $e ----------- e');
    }
    setState(() {
      loadingInitial = false;
    });
  }

  Padding buildEmptyList(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          width50(),
          Expanded(
              flex: 2,
              child: Container(
                  decoration: BoxDecoration(
                    color: appLogoColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: assetLottie(Assets.teamViewLottie))),
          Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  bodyLargeText('No Data Found', context, useGradient: false),
                  height20(),
                  bodyLargeText('Please try again later', context,
                      useGradient: false),
                ],
              )),
        ],
      ),
    );
  }

  Widget buildUser(MatrixUser user) {
    return Container(
      height: 20,
      width: 20,
      color: bColor(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [titleLargeText(user.username ?? '', context, fontSize: s)],
      ),
    );
  }
}

class _TeamViewUserIconWidget extends StatefulWidget {
  const _TeamViewUserIconWidget({
    super.key,
    required this.user,
    required this.loadingNodeId,
    required this.context,
    this.callBack,
    required this.rootUser,
    this.showMessage = false,
  });

  final MatrixUser user;
  final bool rootUser;
  final int loadingNodeId;
  final BuildContext context;
  final VoidCallback? callBack;
  final bool showMessage;

  @override
  State<_TeamViewUserIconWidget> createState() =>
      _TeamViewUserIconWidgetState();
}

class _TeamViewUserIconWidgetState extends State<_TeamViewUserIconWidget>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  AnimationController? animationController;
  Animation<double>? animation;
  @override
  Widget build(BuildContext context) {
    bool dummy = widget.user.username == null;
    return GestureDetector(
      onTap: widget.callBack,
      child: Container(
        padding: EdgeInsets.all(dummy ? 0 : 2),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            border: dummy
                ? null
                : Border.all(
                    width: 0.5,
                    color: widget.user.status == '1'
                        ? Colors.green
                        : widget.user.status == '2'
                            ? Colors.red
                            : Colors.grey)),
        child: Column(
          children: [
            Column(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Colors.cyan.shade50),
                  child: Icon(Icons.person,
                      size: 6,
                      color: widget.user.status == '1'
                          ? Colors.green
                          : widget.user.status == '2'
                              ? Colors.red
                              : Colors.grey),
                ),
                if (!dummy) height5(1),
                if (!dummy)
                  capText(widget.user.username ?? '', context, fontSize: 3)
              ],
            ),
            if (!dummy) height5(2),
          ],
        ),
      ),
    );
  }
}
