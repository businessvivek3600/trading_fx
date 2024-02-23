import 'package:flutter/material.dart';
import '/utils/sizedbox_utils.dart';
import '/utils/text.dart';

import '../../database/databases/firebase_database.dart';
import '../../database/functions.dart';
import '../../sl_container.dart';
import '../../utils/picture_utils.dart';

class WhatsNewPage extends StatefulWidget {
  const WhatsNewPage({super.key});

  @override
  State<WhatsNewPage> createState() => _WhatsNewPageState();
}

class _WhatsNewPageState extends State<WhatsNewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: titleLargeText('Changelogs', context, useGradient: true),
      ),
      body: Container(
        height: double.maxFinite,
        width: double.maxFinite,
        decoration: BoxDecoration(
          image: DecorationImage(
              image: userAppBgImageProvider(context),
              fit: BoxFit.cover,
              opacity: 1),
        ),
        child: StreamBuilder(
          stream: sl.get<FirebaseDatabase>().listenWhatsNew(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text('Error'),
              );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Text('Loading...'),
              );
            } else if (snapshot.hasData) {
              var data = snapshot.data as List<WhatsNewModel>;
              return _WhatsNewView(data: data);
            }
            return const Center(
              child: Text('No Data'),
            );
          },
        ),
      ),
    );
  }
}

class _WhatsNewView extends StatelessWidget {
  const _WhatsNewView({
    super.key,
    required this.data,
  });

  final List<WhatsNewModel> data;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: ListView.separated(
      itemCount: data.length,
      itemBuilder: (context, index) {
        var whatsNew = data[index];
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // if (whatsNew.title != null && whatsNew.title != '')
                  //   Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       titleLargeText(
                  //         whatsNew.title ?? '',
                  //         context,
                  //         style: const TextStyle(
                  //             fontSize: 18,
                  //             fontWeight: FontWeight.bold,
                  //             color: Colors.white),
                  //       ),
                  //       const Divider(color: Colors.grey),
                  //     ],
                  //   ),
                  capText(
                    whatsNew.version.toString(),
                    context,
                    fontSize:
                        //  whatsNew.title != null && whatsNew.title != ''
                        //     ? 12
                        //     :
                        18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  // if (whatsNew.title == null || whatsNew.title == '')
                  const Divider(color: Colors.grey),
                  height10(),
                  if (whatsNew.description != null)
                    capText(
                      parseHtmlString(whatsNew.description ?? '')
                          .replaceFirst('(', '')
                          .replaceAll('(', '\n'),
                      context,
                      color: Colors.white70,
                      maxLines: 100,
                    ),
                  if (whatsNew.link != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        height10(),
                        bodyMedText(whatsNew.link ?? '', context),
                      ],
                    ),
                  if (whatsNew.imageUrl != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        height10(),
                        buildCachedNetworkImage(whatsNew.imageUrl ?? '',
                            borderRadius: 10),
                      ],
                    ),
                  height10(),
                  if (whatsNew.createdAt != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        RichText(
                          text: TextSpan(
                            text: 'Updated on ',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white.withOpacity(0.8)),
                            children: <TextSpan>[
                              TextSpan(
                                  text: formatDate(whatsNew.createdAt!,
                                      'dd MMM yyyy hh:mm a'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.normal,
                                  )),
                            ],
                          ),
                        ),
                      ],
                    )
                ],
              ),
            ),
          ],
        );
      },
      separatorBuilder: (context, index) {
        return const Divider(color: Colors.transparent, height: 0);
      },
    ));
  }
}
