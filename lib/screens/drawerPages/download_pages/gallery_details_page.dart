import 'package:flutter/material.dart';
import '/constants/assets_constants.dart';
import '/database/model/response/gallery_thumbnail_model.dart';
import '/providers/GalleryProvider.dart';
import '/sl_container.dart';
import '/utils/app_default_loading.dart';
import '/utils/picture_utils.dart';
import '/utils/text.dart';
import 'package:provider/provider.dart';

import '../../../utils/color.dart';
import '../../../widgets/GalleryImagesPreviewDilaog.dart';

class GalleryDetailsPage extends StatefulWidget {
  const GalleryDetailsPage({Key? key, required this.thumbnail})
      : super(key: key);
  final GalleryThumbnailModel thumbnail;

  @override
  State<GalleryDetailsPage> createState() => _GalleryDetailsPageState();
}

class _GalleryDetailsPageState extends State<GalleryDetailsPage> {
  @override
  void dispose() {
    sl.get<GalleryProvider>().images.clear();
    sl.get<GalleryProvider>().loadingGalleryDetails = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GalleryProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: mainColor,
          appBar: AppBar(
              title: bodyLargeText(widget.thumbnail.header ?? '', context),
              elevation: 0),
          body: GridView.builder(
            padding: EdgeInsets.all(10),
            itemCount:
                provider.loadingGalleryDetails ? 15 : provider.images.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (context, index) {
              var image = '';
              if (!provider.loadingGalleryDetails) {
                image = provider.images[index];
              }
              return LayoutBuilder(builder: (context, size) {
                return GestureDetector(
                  onTap: !provider.loadingGalleryDetails
                      ? () {
                          showDialog(
                              context: context,
                              builder: (context) => GalleryDetailsImagePopup(
                                  currentIndex: index,
                                  images: provider.images));
                        }
                      : null,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: !provider.loadingGalleryDetails
                        ? buildCachedNetworkImage(
                            image,
                            // pw: 80,
                            // ph: 80,
                            fit: BoxFit.cover,
                            placeholderImg: Assets.whiteNoImageIcon,
                          )
                        : Center(
                            child: SizedBox(
                                height: 50, width: 50, child: appLoadingDots()),
                          ),
                  ),
                );
              });
            },
          ),
        );
      },
    );
  }

  // Future<Image> calculateSize(String image) async {
  //   final ByteData data = await NetworkAssetBundle(Uri.parse(image)).load(image);
  //   final Uint8List bytes = data.buffer.asUint8List();
  //
  //   var decodedImage = await decodeImageFromList(bytes);
  //   print(decodedImage.width);
  //   print(decodedImage.height);
  //   return  decodedImage;
  // }
}

const _defaultColor = Color(0xFF34568B);

class Tile extends StatelessWidget {
  const Tile({
    Key? key,
    required this.index,
    this.extent,
    this.backgroundColor,
    this.bottomSpace,
  }) : super(key: key);

  final dynamic index;
  final double? extent;
  final double? bottomSpace;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      color: backgroundColor ?? _defaultColor,
      height: extent,
      child: Center(
        child: CircleAvatar(
          minRadius: 20,
          maxRadius: 20,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          child: Text('$index', style: const TextStyle(fontSize: 20)),
        ),
      ),
    );

    if (bottomSpace == null) {
      return child;
    }

    return Column(
      children: [
        Expanded(child: child),
        Container(
          height: bottomSpace,
          color: Colors.green,
        )
      ],
    );
  }
}

// class ImageTile extends StatelessWidget {
//   const ImageTile({
//     Key? key,
//     required this.index,
//     required this.width,
//     required this.height,
//   }) : super(key: key);
//
//   final int index;
//   final int width;
//   final int height;
//
//   @override
//   Widget build(BuildContext context) {
//     return Image.network(
//       'https://picsum.photos/$width/$height?random=$index',
//       width: width.toDouble(),
//       height: height.toDouble(),
//       fit: BoxFit.cover,
//     );
//   }
// }

class InteractiveTile extends StatefulWidget {
  const InteractiveTile({
    Key? key,
    required this.index,
    this.extent,
    this.bottomSpace,
  }) : super(key: key);

  final int index;
  final double? extent;
  final double? bottomSpace;

  @override
  _InteractiveTileState createState() => _InteractiveTileState();
}

class _InteractiveTileState extends State<InteractiveTile> {
  Color color = _defaultColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (color == _defaultColor) {
            color = Colors.red;
          } else {
            color = _defaultColor;
          }
        });
      },
      child: Tile(
        index: widget.index,
        extent: widget.extent,
        backgroundColor: color,
        bottomSpace: widget.bottomSpace,
      ),
    );
  }
}
