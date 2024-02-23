import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import '../../../constants/app_constants.dart';
import '/constants/assets_constants.dart';
import '/database/model/response/gallery_thumbnail_model.dart';
import '/providers/GalleryProvider.dart';
import '/screens/drawerPages/download_pages/gallery_details_page.dart';
import '/sl_container.dart';
import '/utils/app_default_loading.dart';
import '/utils/color.dart';
import '/utils/picture_utils.dart';
import '/utils/sizedbox_utils.dart';
import '/utils/skeleton.dart';
import '/utils/text.dart';
import 'package:provider/provider.dart';

class GalleryMainPage extends StatefulWidget {
  const GalleryMainPage({Key? key}) : super(key: key);

  @override
  State<GalleryMainPage> createState() => _GalleryMainPageState();
}

class _GalleryMainPageState extends State<GalleryMainPage> {
  @override
  void initState() {
    sl.get<GalleryProvider>().getGalleryData(true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // sl.get<GalleryProvider>().getGalleryData(false);

    return Consumer<GalleryProvider>(
      builder: (context, provider, child) {
        print(provider.loadingThumbnails);
        return Scaffold(
          appBar: AppBar(
              title: titleLargeText('Gallery', context, useGradient: true),
              elevation: 0),
          body: (provider.loadingThumbnails && provider.thumbnails.isNotEmpty)
              ? GridView.builder(
                  padding: EdgeInsets.all(10),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.1),
                  itemCount: provider.loadingThumbnails
                      ? 13
                      : provider.thumbnails.length,
                  itemBuilder: (context, index) {
                    var thumbnail = GalleryThumbnailModel();
                    if (!provider.loadingThumbnails) {
                      thumbnail = provider.thumbnails[index];
                    }
                    return LayoutBuilder(builder: (context, size) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          // color: Colors.grey[100],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: !provider.loadingThumbnails
                                  ? () {
                                      provider.getGalleryDetails(thumbnail
                                          .header!
                                          .split(' ')
                                          .join('-'));
                                      Get.to(GalleryDetailsPage(
                                          thumbnail: thumbnail));
                                    }
                                  : null,
                              child: Container(
                                height: size.maxHeight * 0.6,
                                width: double.maxFinite,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: !provider.loadingThumbnails
                                      ? CachedNetworkImage(
                                          imageUrl:
                                              thumbnail.defaultImage ?? '',
                                          fit: BoxFit.fill,
                                          placeholder: (context, url) =>
                                              SizedBox(
                                            height: 50,
                                            width: 100,
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                color: appLogoColor
                                                    .withOpacity(0.5),
                                              ),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Center(
                                            child: SizedBox(
                                              height: 60,
                                              width: 60,
                                              child: assetImages(
                                                  Assets.blackNoImageIcon,
                                                  color: Colors.grey),
                                            ),
                                          ),
                                          cacheManager: CacheManager(Config(
                                            "${AppConstants.packageID}_${thumbnail.defaultImage}",
                                            stalePeriod:
                                                const Duration(days: 7),
                                            //one week cache period
                                          )),
                                        )
                                      : SizedBox(
                                          height: Get.height * 0.4,
                                          child: Center(
                                            child: appLoadingDots(
                                                height: size.maxHeight * 0.3),
                                          )),
                                ),
                              ),
                            ),
                            height5(),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Column(
                                children: [
                                  !provider.loadingThumbnails
                                      ? Hero(
                                          tag: thumbnail.header ??
                                              thumbnail.defaultImage ??
                                              '',
                                          child: bodyMedText(
                                              thumbnail.header ?? '', context,
                                              color: Colors.black,
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center),
                                        )
                                      : Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Skeleton(
                                              height: 15,
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                              textColor:
                                                  appLogoColor.withOpacity(0.3),
                                            ),
                                            height5(),
                                            Skeleton(
                                              height: 15,
                                              width: 50,
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                              textColor:
                                                  appLogoColor.withOpacity(0.3),
                                            ),
                                          ],
                                        ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    });
                  },
                )
              : buildEmptyPage(context),
        );
      },
    );
  }

  buildEmptyPage(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          assetImages(Assets.noImage, width: 200),
          height30(),
          bodyLargeText('Gallary data not found', context,
              useGradient: false, color: Colors.black),
        ],
      ),
    );
  }
}
