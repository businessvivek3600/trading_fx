import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '/constants/assets_constants.dart';
import '/utils/default_logger.dart';
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

class GenerationAnalyzerPage extends StatefulWidget {
  const GenerationAnalyzerPage({super.key});

  @override
  State<GenerationAnalyzerPage> createState() => _GenerationAnalyzerPageState();
}

class _GenerationAnalyzerPageState extends State<GenerationAnalyzerPage> {
  var provider = sl.get<TeamViewProvider>();
  var authProvider = sl.get<AuthProvider>();
  late ScrollController _scrollController;

  final ScrollController generationScoll = ScrollController();
  List<GlobalKey> generationKeys =
      List.generate(10, (index) => GlobalKey(debugLabel: 'generation_$index'));
  List<String> generationList = [
    'All',
    'Generation-1',
    'Generation-2',
    'Generation-3',
    'Generation-4',
    'Generation-5',
    'Generation-6',
    'Generation-7',
    'Generation-8',
    'Generation-9'
  ];

  final breadCumbScroll = ScrollController();
  void _animateToLast() {
    breadCumbScroll.animateTo(
      breadCumbScroll.position.maxScrollExtent,
      curve: Curves.fastOutSlowIn,
      duration: const Duration(milliseconds: 300),
    );
  }

  scrollGeneration(int index) {
    try {
      Scrollable.ensureVisible(generationKeys[index].currentContext!,
          duration: const Duration(milliseconds: 700),
          curve: Curves.fastOutSlowIn);
    } catch (e) {
      errorLog(e.toString());
    }
  }

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider.generationAnalyzerSearchController = TextEditingController();
      provider.setSearchingGUsers(false);
      provider.setBreadCrumbContent(
          0,
          BreadCrumbContent(
              index: 0,
              user: GenerationAnalyzerUser(
                  child: authProvider.userData.username,
                  parent: authProvider.userData.username ?? '',
                  // image: Assets.appWebLogo,
                  level: 0)));
      provider.setSelectedGeneration(0);
      provider.generationAnalyzerPage = 0;
      provider.setGenerationUsers(authProvider.userData.username ?? '');
      _scrollController = ScrollController();
      _scrollController
          .addListener(() => _loadMore(sl.get<TeamViewProvider>()));
    });
  }

  @override
  void dispose() {
    provider.breadCrumbContent.clear();
    generationScoll.dispose();
    breadCumbScroll.dispose();
    provider.generationAnalyzerSearchController.dispose();
    provider.selectedGeneration = 0;
    _scrollController
        .removeListener(() => _loadMore(sl.get<TeamViewProvider>()));
    _scrollController.dispose();
    super.dispose();
  }

  Future<bool> _loadMore(TeamViewProvider provider) async {
    print(
        "Generation Analyzer ,onLoadMore ${_scrollController.position.pixels} ${_scrollController.position.maxScrollExtent}");
    if (_scrollController.position.pixels ==
            (_scrollController.position.maxScrollExtent) &&
        _scrollController.position.userScrollDirection ==
            ScrollDirection.reverse &&
        !provider.loadingGenerationAnalyzer) {
      bool isFinished = provider.gUsers.length == provider.totalGUsers;
      if (isFinished) {
        Fluttertoast.showToast(msg: "No more data");
        return false;
      }
      print("Generation Analyzer ,onLoadMore");
      await provider.getGenerationAnalyzer(
          (provider.breadCrumbContent.last.user as GenerationAnalyzerUser)
                  .child ??
              '',
          provider.selectedGeneration);
    }
    return true;
  }

  Future<void> _refresh(TeamViewProvider provider) async {
    print("my Incomes ,onRefresh");
    await Future.delayed(const Duration(seconds: 0, milliseconds: 2000));
    provider.generationAnalyzerPage = 0;
    await provider.getGenerationAnalyzer(
        (provider.breadCrumbContent.last.user as GenerationAnalyzerUser)
                .child ??
            '',
        provider.selectedGeneration);
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
              chipsTile(provider),
              if (provider.breadCrumbContent.length > 1)
                bradcrumRow(provider, context),
              height10(),
              Expanded(
                  child: provider.loadingGUsers.name ==
                          ButtonLoadingState.loading.name
                      ? const Center(
                          child: CircularProgressIndicator(color: appLogoColor))
                      : buildGrid(provider)),
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
              provider.setSearchingGUsers(false);
              provider.generationAnalyzerSearchController.clear();
              provider.setSelectedGeneration(0);
              scrollGeneration(provider.selectedGeneration);
              provider.setBreadCrumbContent(1);
              provider.generationAnalyzerPage = 0;
              provider.setGenerationUsers(authProvider.userData.username ?? '');
              _animateToLast();
            },
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.red,
                  boxShadow: const [
                    BoxShadow(
                        offset: Offset(0, 1),
                        blurRadius: 3,
                        color: Colors.black26)
                  ]),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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

  Widget buildGrid(TeamViewProvider provider) {
    return RefreshIndicator(
      onRefresh: () => _refresh(provider),
      child: !provider.loadingGenerationAnalyzer && provider.gUsers.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  assetImages(Assets.mlm),
                  height30(),
                  titleLargeText('Members not Found', context,
                      color: Colors.white, useGradient: false),
                ],
              ),
            )
          : GridView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(
                  left: 10,
                  right: 10,
                  top: 0,
                  bottom: kBottomNavigationBarHeight),
              itemCount: provider.gUsers.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.8,
              ),
              itemBuilder: (context, index) {
                GenerationAnalyzerUser user = provider.gUsers[index];
                return GestureDetector(
                  onTap: () {
                    provider.setSelectedGeneration(0);
                    scrollGeneration(provider.selectedGeneration);
                    provider.setBreadCrumbContent(
                        provider.breadCrumbContent.length,
                        BreadCrumbContent(
                            index: provider.breadCrumbContent.length,
                            user: GenerationAnalyzerUser(
                              child: user.child,
                              parent: user.parent,
                              level: user.level,
                              salesActive: user.salesActive,
                              salesActiveDate: user.salesActiveDate,
                            )));
                    provider.generationAnalyzerPage = 0;
                    provider.setSearchingGUsers(false);
                    provider.generationAnalyzerSearchController.clear();
                    provider.setGenerationUsers('${user.child}');
                    _animateToLast();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: bColor(),
                        boxShadow: const [
                          BoxShadow(
                              offset: Offset(0, 1),
                              blurRadius: 3,
                              color: Colors.black26)
                        ]),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Icon(Icons.person, color: appLogoColor, size: 40),
                        Column(
                          children: [
                            bodyLargeText(user.child ?? '', context,
                                textAlign: TextAlign.center,
                                useGradient: false),
                          ],
                        ),
                        // Spacer(),
                        Column(
                          // crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            capText('Generation ${user.level}', context,
                                useGradient: false),
                            height5(),
                            capText('Ref: ${user.parent}', context,
                                fontSize: 8, maxLines: 1),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Container buildBreadcrumbs(TeamViewProvider provider) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          // color: Colors.white,
          boxShadow: const [
            BoxShadow(
                offset: Offset(0, 1), blurRadius: 3, color: Colors.black26)
          ]),
      padding: const EdgeInsets.all(8),
      child: BreadCrumb.builder(
        itemCount: provider.breadCrumbContent.length,
        builder: (index) {
          GenerationAnalyzerUser user =
              provider.breadCrumbContent[index].user as GenerationAnalyzerUser;
          return BreadCrumbItem(
            margin: EdgeInsets.only(
                right:
                    index == provider.breadCrumbContent.length - 1 ? 100 : 0),
            content: capText('${user.child}', context, useGradient: true),
            onTap: () {
              provider.setSearchingGUsers(false);
              provider.generationAnalyzerSearchController.clear();
              provider.setSelectedGeneration(0);
              scrollGeneration(provider.selectedGeneration);
              provider.setBreadCrumbContent(index + 1);
              provider.generationAnalyzerPage = 0;
              provider.setGenerationUsers('${user.child}');
              _animateToLast();
            },
          );
        },
        divider: const Icon(Icons.chevron_right, color: Colors.white, size: 20),
        overflow: ScrollableOverflow(
            direction: Axis.horizontal,
            reverse: false,
            keepLastDivider: false,
            controller: breadCumbScroll),
      ),
    );
  }

  ConstrainedBox chipsTile(TeamViewProvider provider) {
    return ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 50),
        child: ListView(
          controller: generationScoll,
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          children: [
            ...generationList.map((gen) => Builder(builder: (context) {
                  int index = generationList.indexOf(gen);
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _GenerationChip(
                        widgetKey: generationKeys[index],
                        title: gen,
                        selected: provider.selectedGeneration == index,
                        index: index,
                        total: provider.loadingGenerationAnalyzer
                            ? null
                            : index == 0
                                ? provider.totalGUsers
                                : provider.selectedGeneration == index
                                    ? provider.levelMemberCount
                                    : null,
                        onCancel: (index) {
                          provider.setSearchingGUsers(false);
                          provider.generationAnalyzerSearchController.clear();
                          provider.setSelectedGeneration(0);
                          provider.generationAnalyzerPage = 0;
                          provider.setGenerationUsers(
                              // index == 0
                              // ? authProvider.userData.username ?? ''
                              // :
                              '${(provider.breadCrumbContent.last.user as GenerationAnalyzerUser).child}');
                          scrollGeneration(provider.selectedGeneration);
                        },
                        onSelect: (index) {
                          provider.setSelectedGeneration(index);
                          provider.generationAnalyzerPage = 0;
                          provider.setGenerationUsers(
                              // index == 0
                              // ? authProvider.userData.username ?? ''
                              // :
                              '${(provider.breadCrumbContent.last.user as GenerationAnalyzerUser).child}');
                          scrollGeneration(provider.selectedGeneration);
                        },
                      ),
                    ],
                  );
                }))
          ],
        ));
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
        title: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: provider.isSearchingGUsers
                ? SizedBox(
                    height: 40,
                    child: TextField(
                      controller: provider.generationAnalyzerSearchController,
                      autofocus: true,
                      cursorColor: Colors.white,
                      textInputAction: TextInputAction.search,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        isDense: true,
                        hintText: 'Search...',
                        hintStyle: const TextStyle(color: fadeTextColor),
                        border: InputBorder.none,
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              provider.generationAnalyzerSearchController
                                  .clear();
                              // isSearching = !isSearching;
                            });
                          },
                          icon: const Icon(CupertinoIcons.clear_circled_solid,
                              color: Colors.white),
                        ),
                      ),
                      onSubmitted: (value) {
                        provider.generationAnalyzerPage = 0;
                        provider.setGenerationUsers((provider.breadCrumbContent
                                    .last.user as GenerationAnalyzerUser)
                                .child ??
                            '');
                      },
                    ),
                  )
                : titleLargeText('Generation Analyzer', context,
                    useGradient: true)),
        actions: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: !provider.isSearchingGUsers
                ? IconButton(
                    onPressed: () {
                      provider.setSearchingGUsers(!provider.isSearchingGUsers);
                    },
                    icon: const Icon(Icons.search))
                : Transform.rotate(
                    angle: pi / 2,
                    child: IconButton(
                        onPressed: () {
                          provider
                              .setSearchingGUsers(!provider.isSearchingGUsers);
                        },
                        icon: const Icon(Icons.u_turn_left)),
                  ),
          ),
        ]);
  }
}

class _GenerationChip extends StatelessWidget {
  const _GenerationChip({
    required this.widgetKey,
    this.selected = false,
    required this.index,
    required this.onCancel,
    required this.onSelect,
    required this.title,
    this.total,
  });
  final GlobalKey widgetKey;
  final bool selected;
  final int index;
  final int? total;
  final Function(int) onSelect;
  final Function(int) onCancel;
  final String title;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: widgetKey,
      onTap: () => onSelect(index),
      child: Container(
        // width: 100,
        constraints: const BoxConstraints(maxHeight: 30),
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: fadeTextColor, width: 1),
          gradient: selected
              ? const LinearGradient(
                  colors: [Color.fromARGB(138, 186, 243, 105), appLogoColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
                child: capText(title, context,
                    color: selected ? Colors.white : fadeTextColor)),
            if (selected && total != null)
              Container(
                margin: const EdgeInsets.only(left: 5),
                padding:
                    const EdgeInsets.symmetric(vertical: 2.0, horizontal: 5),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50), color: Colors.red),
                child: capText(total.toString(), context,
                    color: const Color.fromARGB(255, 255, 255, 255)),
              ),
            if (selected)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: GestureDetector(
                  onTap: () => onCancel(index),
                  child: const Icon(CupertinoIcons.clear_circled_solid,
                      color: Colors.white, size: 15),
                ),
              )
          ],
        ),
      ),
    );
  }
}

class BreadCrumbContent {
  final int index;
  final BreadCrumbData user;
  BreadCrumbContent({required this.index, required this.user});
}

abstract class BreadCrumbData {}

class GenerationAnalyzerUser extends BreadCrumbData {
  String? id;
  String? parent;
  String? parentId;
  String? leg;
  String? salesActiveDate;
  String? child;
  String? childId;
  String? salesActive;
  int? level;
  String? rankId;
  String? fTB;
  String? createdAt;
  String? updatedAt;

  GenerationAnalyzerUser(
      {this.id,
      this.parent,
      this.parentId,
      this.leg,
      this.salesActiveDate,
      this.child,
      this.childId,
      this.salesActive,
      this.level,
      this.rankId,
      this.fTB,
      this.createdAt,
      this.updatedAt});

  GenerationAnalyzerUser.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    parent = json['parent'];
    parentId = json['parent_id'];
    leg = json['leg'];
    salesActiveDate = json['sales_active_date'];
    child = json['child'];
    childId = json['child_id'];
    salesActive = json['sales_active'];
    level = int.parse(json['level'] ?? '0');
    rankId = json['rank_id'];
    fTB = json['f_t_b'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['parent'] = this.parent;
    data['parent_id'] = this.parentId;
    data['leg'] = this.leg;
    data['sales_active_date'] = this.salesActiveDate;
    data['child'] = this.child;
    data['child_id'] = this.childId;
    data['sales_active'] = this.salesActive;
    data['level'] = this.level;
    data['rank_id'] = this.rankId;
    data['f_t_b'] = this.fTB;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
