import 'dart:async';

import 'package:chat_bubbles/bubbles/bubble_normal.dart';
import 'package:chat_bubbles/bubbles/bubble_special_three.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '/constants/assets_constants.dart';
import '/database/model/response/base/user_model.dart';
import '/database/model/response/ticket_modal.dart';
import '/database/model/response/ticket_reply.dart';
import '/providers/auth_provider.dart';
import '/providers/support_provider.dart';
import '/sl_container.dart';
import '/utils/color.dart';
import '/utils/picture_utils.dart';
import '/utils/sizedbox_utils.dart';
import '/utils/skeleton.dart';
import '/utils/text.dart';
import 'package:provider/provider.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

import '../../../database/functions.dart';
import '../../../widgets/GalleryImagesPreviewDilaog.dart';

class SupportChatPage extends StatefulWidget {
  const SupportChatPage({Key? key, required this.ticketModel})
      : super(key: key);
  final TicketModel ticketModel;
  @override
  State<SupportChatPage> createState() => SupportChatPageState();
}

class SupportChatPageState extends State<SupportChatPage> {
  late StreamSubscription<List<TicketReply>> subscription;

  StreamController<List<TicketReply>> replyController =
      StreamController.broadcast();
  Timer? replyTimer;
  getPeriodicTicketDetail() async {
    replyTimer?.cancel();
    replyController.add(await sl
        .get<SupportProvider>()
        .getTicketDetail(widget.ticketModel.ticketid ?? ''));
    setState(() {});
    Future.delayed(
        const Duration(seconds: 1),
        () => scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut));
    replyTimer = Timer.periodic(const Duration(seconds: 20), (timer) async {
      print(timer.tick);
      replyController.add(await sl
          .get<SupportProvider>()
          .getTicketDetail(widget.ticketModel.ticketid ?? ''));
    });
  }

  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    scrollController.addListener(() {
      setState(() {});
    });
    subscription = replyController.stream.listen((event) {
      if(scrollController.hasClients) {
        scrollController.animateTo(scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
      }
    });
    getPeriodicTicketDetail();
    super.initState();
  }

  @override
  void dispose() {
    subscription.cancel();
    replyController.close();
    replyTimer!.cancel();

    sl.get<SupportProvider>().sendingMessage = false;
    sl.get<SupportProvider>().loadingFirst = true;
    sl.get<SupportProvider>().loadingTicketDetails = false;
    sl.get<SupportProvider>().currentTicket = null;
    sl.get<SupportProvider>().replies.clear();

    super.dispose();
  }

  var userData = sl.get<AuthProvider>().userData;

  @override
  Widget build(BuildContext context) {
    // sl
    //     .get<SupportProvider>()
    //     .getTicketDetail(widget.ticketModel.ticketid ?? '');

    return Consumer<SupportProvider>(
      builder: (context, supportProvider, child) {
        return GestureDetector(
          onTap: () {
            primaryFocus?.unfocus();
          },
          child: Scaffold(
            backgroundColor: mainColor,
            appBar: buildAppBar(context, supportProvider),
            body: buildBody(context, supportProvider),
          ),
        );
      },
    );
  }

  Container buildBody(BuildContext context, SupportProvider supportProvider) {
    bool chatClosed = supportProvider.currentTicket != null &&
        supportProvider.currentTicket?.status == '5';

    return Container(
      child: Column(
        children: [
          Expanded(
              child: StreamBuilder(
                  stream: replyController.stream,
                  builder: (context, AsyncSnapshot<List<TicketReply>> snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child:
                              CircularProgressIndicator(color: Colors.white));
                    } else if (snap.connectionState == ConnectionState.active &&
                        snap.hasData) {
                      if (snap.data != null) {
                        // print('snap data chat ${snap.data!.length}');
                        // return Container(height: 100,width: 200,color: Colors.red,);
                        return ListView(
                            // shrinkWrap: true,
                            controller: scrollController,
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.only(top: 16, bottom: 20),
                            children: [
                              ...snap.data!.map((reply) {
                                var chatLength = supportProvider.replies.length;
                                var i = supportProvider.replies.indexOf(reply);
                                bool sameDay = false;
                                if (i != 0) {
                                  sameDay = DateFormat().add_yMMMEd().format(
                                          DateTime.parse(reply.date ?? '')) ==
                                      DateFormat().add_yMMMEd().format(
                                          DateTime.parse(supportProvider
                                                  .replies[i - 1].date ??
                                              ''));
                                }
                                // if(!_repilies.contains(reply)) {
                                //   return supportProvider.replies.where((element) =>
                                //    DateFormat().add_yMMMEd().format(
                                //        DateTime.parse(element.date ?? '')) ==
                                //        DateFormat().add_yMMMEd().format(
                                //            DateTime.parse(reply.date ?? ''))).map((e) => null).toList()
                                // };
                                return !sameDay
                                    ? BuildReply(
                                        scrollController: scrollController,
                                        sameDay: sameDay,
                                        userData: userData,
                                        chatLength: chatLength,
                                        supportProvider: supportProvider,
                                        ticketReply: reply,
                                      )
                                    : const SizedBox();
                                return buildChatTile(
                                  context,
                                  isSender:
                                      reply.submitter == userData.username,
                                  hasPrevious: i < 1 &&
                                          reply.submitter == userData.username
                                      ? true
                                      : supportProvider
                                              .replies[
                                                  i - (chatLength > 1 ? 1 : 0)]
                                              .submitter ==
                                          userData.username,
                                  // hasPrevious: true,
                                  reply: reply,
                                  seen: ((i <= chatLength - 2
                                              ? supportProvider.replies.any(
                                                  (element) =>
                                                      element.submitter !=
                                                          userData.username &&
                                                      supportProvider.replies
                                                              .indexOf(
                                                                  element) >
                                                          i)
                                              : false) &&
                                          reply.submitter == userData.username)
                                      ? true
                                      : false,
                                  index: i,
                                  chatList: supportProvider.replies,
                                  scrollController: scrollController,
                                );
                              }),
                              if (chatClosed) buildChatClosed(context),
                              if (snap.data!.isEmpty)
                                Center(
                                  child: bodyLargeText(
                                    'We don\'t have any conversation yet.\nLeave your queries here.',
                                    context,
                                    textAlign: TextAlign.center,
                                  ),
                                )
                            ]);
                      } else {
                        return Center(
                          child: bodyLargeText("Don't have data", context),
                        );
                      }
                    } else {
                      return bodyLargeText('Some thing went wrong', context);
                    }
                  })),
          _buildTextComposer(supportProvider, chatClosed),
        ],
      ),
    );
  }

  Row buildChatClosed(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white24,
            ),
            child:
                capText('Chat has been closed', context, color: Colors.amber))
      ],
    );
  }

  Container _buildTextComposer(
      SupportProvider supportProvider, bool chatClosed) {
    return Container(
      // height: 70,
      color: Colors.white10,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: TextField(
                  readOnly: chatClosed,
                  controller: supportProvider.messageController,
                  style: const TextStyle(color: Colors.white),
                  textInputAction: TextInputAction.send,
                  cursorColor: Colors.white,
                  decoration: const InputDecoration(
                      hintStyle: TextStyle(color: Colors.white70),
                      hintText: 'Tell us your query'),
                  onEditingComplete: () {
                    supportProvider
                        .reply()
                        .then((value) async => value
                            ? replyController.add(await sl
                                .get<SupportProvider>()
                                .getTicketDetail(sl
                                        .get<SupportProvider>()
                                        .currentTicket
                                        ?.ticketid ??
                                    ''))
                            : null)
                        .then((value) => scrollController.animateTo(
                            scrollController.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut));
                  }),
            ),
          ),
          GestureDetector(
              onTap: !chatClosed
                  ? () {
                      supportProvider
                          .reply()
                          .then((value) async => value
                              ? replyController.add(await sl
                                  .get<SupportProvider>()
                                  .getTicketDetail(sl
                                          .get<SupportProvider>()
                                          .currentTicket
                                          ?.ticketid ??
                                      ''))
                              : null)
                          .then((value) => scrollController.animateTo(
                              scrollController.position.maxScrollExtent,
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut));
                    }
                  : null,
              child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: chatClosed ? Colors.grey : Colors.blueAccent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                      child: !supportProvider.sendingMessage
                          ? const Icon(Icons.send_rounded, color: Colors.white)
                          : const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )))),
        ],
      ),
    );
  }

  Widget buildChatTile(BuildContext context,
      {required bool isSender,
      required bool hasPrevious,
      required TicketReply reply,
      required bool seen,
      required int index,
      required List<TicketReply> chatList,
      required ScrollController scrollController}) {
    bool sameDay = false;
    if (index != 0) {
      sameDay =
          DateFormat().add_yMMMEd().format(DateTime.parse(reply.date ?? '')) ==
              DateFormat()
                  .add_yMMMEd()
                  .format(DateTime.parse(chatList[index - 1].date ?? ''));
    }
    return StickyHeader(
      controller: scrollController, // Optional
      header: sameDay
          ? const SizedBox()
          : Container(
              height: 50.0,
              color: Colors.blueGrey[700],
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              alignment: Alignment.centerLeft,
              child: Text(
                'Header #$index',
                style: const TextStyle(color: Colors.white),
              ),
            ),
      content: Column(
        crossAxisAlignment:
            !isSender ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          BubbleSpecialThree(
            text: parseHtmlString(reply.message ?? ''),
            color: isSender ? const Color(0x8C7CAEEF) : const Color(0x27FFFFFF),
            // color: Color(0x8C7CAEEF),
            tail: !hasPrevious,
            isSender: isSender,
            sent: isSender,
            seen: seen,
            delivered: isSender && true,
            textStyle: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: capText(
                DateFormat()
                    .add_yMMMEd()
                    .add_jm()
                    .format(DateTime.parse(reply.date ?? '')),
                context),
          ),
          height5(),
        ],
      ),
    );
  }

  PreferredSize buildAppBar(
      BuildContext context, SupportProvider supportProvider) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(100),
      child: Container(
        height: 100,
        width: double.maxFinite,
        decoration: const BoxDecoration(color: Colors.white10),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: GestureDetector(
                    onTap: () => Get.back(),
                    child: const Icon(Icons.arrow_back_rounded, color: Colors.white)),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  // radius: 15,
                  backgroundColor: Colors.transparent,
                  child: assetSvg(Assets.ticket, fit: BoxFit.cover),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    supportProvider.loadingTicketDetails
                        ? Skeleton(
                            height: 10,
                            width: 150,
                            textColor: Colors.grey,
                            borderRadius: BorderRadius.circular(3))
                        : Row(
                            children: [
                              Expanded(
                                  child: bodyLargeText(
                                      supportProvider.currentTicket?.subject ??
                                          '',
                                      context,
                                      maxLines: 2)),
                            ],
                          ),
                    height5(),
                    supportProvider.loadingTicketDetails
                        ? Skeleton(
                            height: 10,
                            width: 100,
                            textColor: Colors.grey,
                            borderRadius: BorderRadius.circular(3),
                          )
                        : Row(
                            children: [
                              if (supportProvider.currentTicket?.lastreply ==
                                  null)
                                capText('Created at', context),
                              Expanded(
                                child: capText(
                                  DateFormat().add_yMMMd().add_jm().format(
                                      DateTime.parse(supportProvider
                                              .currentTicket?.lastreply ??
                                          supportProvider.currentTicket?.date ??
                                          DateTime.now().toString())),
                                  context,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BuildReply extends StatelessWidget {
  const BuildReply({
    super.key,
    required this.scrollController,
    required this.supportProvider,
    required this.ticketReply,
    required this.sameDay,
    required this.userData,
    required this.chatLength,
  });

  final ScrollController scrollController;
  final SupportProvider supportProvider;
  final TicketReply ticketReply;
  final bool sameDay;

  final UserData userData;
  final int chatLength;

  @override
  Widget build(BuildContext context) {
    List<TicketReply> _replies = supportProvider.replies
        .where((element) =>
            DateFormat()
                .add_yMMMEd()
                .format(DateTime.parse(element.date ?? '')) ==
            DateFormat()
                .add_yMMMEd()
                .format(DateTime.parse(ticketReply.date ?? '')))
        .toList();
    return StickyHeader(
      controller: scrollController, // Optional
      header: sameDay
          ? const SizedBox()
          : Container(
              padding: const EdgeInsets.only(bottom: 8.0),
              // color: mainColor,
              child: Row(
                children: [
                  // Expanded(child: Divider(color: Colors.blueGrey)),
                  // width10(),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 3),
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                        color: Colors.blueGrey[700],
                        borderRadius: BorderRadius.circular(10)),
                    child: capText(
                        DateFormat()
                            .add_yMMMEd()
                            .format(DateTime.parse(ticketReply.date ?? '')),
                        context),
                  ),
                  const Spacer(),
                  // width10(),
                  // Expanded(child: Divider(color: Colors.blueGrey)),
                ],
              ),
            ),
      content: Column(
        children: [
          ..._replies.map(
            (reply) => Builder(builder: (context) {
              var newIndex = _replies.indexOf(reply);
              var i = supportProvider.replies.indexOf(reply);
              // print(
              //     '$newIndex $i i - (chatLength > 2 ? 1 : 0) ${i - (chatLength > 2 ? 1 : 0)}');
              var isSender = reply.submitter == userData.username;
              var hasPrevious = i < 1 && reply.submitter == userData.username
                  ? false
                  : supportProvider
                          .replies[i - (chatLength > 2 ? 1 : 0)].submitter ==
                      userData.username;
              var seen = ((i <= chatLength - 2
                          ? supportProvider.replies.any((element) =>
                              element.submitter != userData.username &&
                              supportProvider.replies.indexOf(element) > i)
                          : false) &&
                      reply.submitter == userData.username)
                  ? true
                  : false;

              return Column(
                crossAxisAlignment: !isSender
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.end,
                children: [
                  if (reply.attachments != null &&
                      reply.attachments!.isNotEmpty)
                    buildAttachments(supportProvider, reply, isSender),
                  BubbleSpecialThree(
                    text: parseHtmlString((reply.message ?? '')),
                    color: isSender ? const Color(0x8C7CAEEF) : const Color(0x27FFFFFF),
                    // color: Color(0x8C7CAEEF),
                    tail: !hasPrevious,
                    isSender: isSender,
                    sent: isSender,
                    seen: seen,
                    delivered: isSender && true,
                    textStyle: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: capText(
                        DateFormat()
                            .add_jm()
                            .format(DateTime.parse(reply.date ?? '')),
                        context),
                  ),
                  height5(),
                ],
              );
            }),
          ),
          height10(),
        ],
      ),
    );
  }

  buildAttachments(
      SupportProvider supportProvider, TicketReply reply, bool isSender) {
    print(reply.attachments?.map((e) => e.fileName));
    List<Attachment> attachments = reply.attachments!;
    double padding = 10;
    int count = attachments.length;
    int more = count > 4 ? count - 4 : 0;
    double width = count <= 1 ? Get.width / 2 : (Get.width) / 4 - 5 - padding;
    double runSpacing = count < 3 ? 0 : 10;
    double spacing = count <= 1 ? 0 : 10;
    Widget parent(Widget child) => Container(
          constraints: BoxConstraints(
              maxWidth: Get.width / 2,
              maxHeight: count > 2 ? Get.width / 2 : double.infinity),
          padding: EdgeInsets.only(
              left: padding,
              top: padding,
              bottom: padding,
              right: count >= 2 ? 0 : padding),
          margin: EdgeInsets.only(
              left: isSender ? 0 : 20, right: isSender ? 20 : 0, bottom: 10),
          height: count > 2 ? Get.width / 2 : null,
          width: Get.width / 2,
          decoration: BoxDecoration(
              color: isSender ? const Color(0x8C7CAEEF) : const Color(0x27FFFFFF),
              borderRadius: BorderRadius.circular(15)),
          child: child,
        );
    Widget child(String image) => Container(
          constraints: BoxConstraints(maxWidth: width, maxHeight: width),
          width: width,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(width: 0.5),
              color: Colors.white70),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: buildCachedNetworkImage(
                (supportProvider.attachment_url ?? "") + image,
                pw: width,
                ph: width),
          ),
        );
    Widget stack(int count) => Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          top: 0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  height: 45,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Colors.grey[600]),
                  child: Center(child: titleLargeText('+$more', Get.context!))),
            ],
          ),
        );

    return GestureDetector(
      onTap: () => showDialog(
          context: Get.context!,
          builder: (context) => GalleryDetailsImagePopup(
              currentIndex: 0,
              images: attachments
                  .map((e) =>
                      (supportProvider.attachment_url ?? "") +
                      (e.fileName ?? ''))
                  .toList())),
      child: parent(Stack(
        children: [
          Wrap(
            runSpacing: runSpacing,
            spacing: spacing,
            children: [
              ...attachments
                  .sublist(0, count > 4 ? 4 : count)
                  .map((e) => child(e.fileName ?? ''))
            ],
          ),
          if (more > 0) stack(more)
        ],
      )),
    );
  }
}
