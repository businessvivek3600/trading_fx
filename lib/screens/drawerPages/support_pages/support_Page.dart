import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../widgets/load_more_container.dart';
import '/constants/app_constants.dart';
import '/constants/assets_constants.dart';
import '/database/functions.dart';
import '/database/model/response/ticket_modal.dart';
import '/providers/support_provider.dart';
import '/screens/drawerPages/support_pages/create_new_ticket.dart';
import '/screens/drawerPages/support_pages/support_chat_page.dart';
import '/sl_container.dart';
import '/utils/color.dart';
import '/utils/picture_utils.dart';
import '/utils/sizedbox_utils.dart';
import '/utils/text.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rive/rive.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({Key? key}) : super(key: key);
  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  var provider = sl.get<SupportProvider>();
  @override
  void initState() {
    provider.getTickets();
    super.initState();
  }

  @override
  void dispose() {
    provider.supportPage = 0;
    provider.tickets.clear();
    super.dispose();
  }

  Future<void> _loadMore() async {
    await provider.getTickets();
  }

  Future<void> _refresh() async {
    provider.supportPage = 0;
    await provider.getTickets(true);
  }

  @override
  Widget build(BuildContext context) {
    // sl.get<SupportProvider>().getTickets();
    return Consumer<SupportProvider>(
      builder: (context, supportProvider, child) {
        return Scaffold(
          backgroundColor: mainColor,
          extendBody: true,
          appBar: AppBar(
            title: titleLargeText('Support', context, useGradient: true),
            centerTitle: true,
            actions: [
              if (supportProvider.tickets.isNotEmpty)
                IconButton(
                    onPressed: () => checkServiceEnableORDisable(
                        'mobile_chat_disabled',
                        () => Get.to(const CreateSupportTicketPage())),
                    icon: const Icon(Icons.add)),
            ],
          ),
          body: !supportProvider.loadingTickets
              ? supportProvider.tickets.isNotEmpty
                  ? buildListView(supportProvider, context)
                  : buildNoActivity(context)
              : const Center(
                  child: CircularProgressIndicator(color: Colors.white)),
          // bottomNavigationBar: Container(height: 50),
          // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          // floatingActionButton: FloatingActionButton(
          //   backgroundColor: appLogoColor,
          //   onPressed: () {},
          //   child: Icon(Icons.add),
          //   // label: bodyLargeText('Create New Ticket', context),
          // ),
        );
      },
    );
  }

  Center buildLoading() {
    return Center(
      child: Container(
        color: Colors.transparent,
        margin: EdgeInsets.symmetric(
            horizontal: Get.width * 0.2, vertical: Get.height * 0.3),
        child: const Center(
          child: RiveAnimation.asset(
            'assets/rive/square_jumping_loading.riv',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Column buildNoActivity(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
                height: 200,
                width: 100,
                child:
                    RiveAnimation.asset('assets/rive/${Assets.emptyMessage}')),
          ],
        ),
        height5(),
        titleLargeText('No activity found', context),
        height5(),
        bodyMedText('Create a ticket to raise any issues', context),
        height20(),
        GestureDetector(
          onTap: () => Get.to(const CreateSupportTicketPage()),
          child: Container(
              width: Get.width * 0.25,
              height: Get.width * 0.25,
              child: assetLottie(Assets.addItemLottie, fit: BoxFit.cover)),
        ),
      ],
    );
  }

  Widget buildListView(SupportProvider supportProvider, BuildContext context) {
    return LoadMoreContainer(
        finishWhen: provider.tickets.length >= provider.totalTickets,
        onLoadMore: _loadMore,
        onRefresh: _refresh,
        builder: (scrollController, status) {
          return ListView(
            controller: scrollController,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              ...supportProvider.tickets.map((ticket) {
                return buildTicketTile(ticket, context);
              })
            ],
          );
        });
  }

  GestureDetector buildTicketTile(TicketModel ticket, BuildContext context) {
    Color color = fromHex(sl
        .get<SupportProvider>()
        .ticket_status_list
        .firstWhere((element) => element.ticketstatusid == ticket.status)
        .statuscolor!);
    return GestureDetector(
      onTap: () {
        sl.get<SupportProvider>().getTicketDetail(ticket.ticketid ?? '');
        Get.to(SupportChatPage(ticketModel: ticket));
      },
      child: Container(
        height: 80,
        margin: const EdgeInsets.only(bottom: 10),
        width: double.maxFinite,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          // color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.transparent,
                      child: Stack(
                        children: [
                          assetSvg(Assets.ticket, color: color),
                          Positioned(
                            top: 0,
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: capText(
                                  ticket.ticketid ?? '',
                                  context,
                                  fontWeight: FontWeight.bold,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )),
                ),
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(bottom: 16.0, top: 16, right: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Expanded(
                                child: bodyLargeText(
                                    ticket.subject ?? '', context,
                                    maxLines: 1)),
                            width100(),
                          ],
                        ),
                        height10(),
                        Row(
                          children: [
                            Expanded(
                              child: capText(
                                ticket.message ?? ticket.lastreply ?? '',
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
                ),
              ],
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  capText(
                      '${DateFormat().add_MMMEd().format(DateTime.parse(ticket.lastreply ?? ticket.date ?? ''))}',
                      context,
                      maxLines: 1),
                  capText(
                      '${DateFormat().add_jm().format(DateTime.parse(ticket.lastreply ?? ticket.date ?? ''))}',
                      context,
                      maxLines: 1),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
