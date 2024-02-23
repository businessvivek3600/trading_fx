import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '/utils/color.dart';
import '/utils/default_logger.dart';
import '/utils/text.dart';

enum LoadMoreStatus { idle, loading, error, done, noMore }

class LoadMoreContainer extends StatefulWidget {
  const LoadMoreContainer(
      {super.key,
      required this.builder,
      required this.finishWhen,
      required this.onLoadMore,
      this.onRefresh,
      this.loadingWidget,
      this.showLoading = true,
      this.showNoMore = false,
      this.showToast = true,
      this.toastMessage,
      this.height});
  final Widget Function(
      ScrollController scrollController, LoadMoreStatus status) builder;
  final bool finishWhen;
  final Future<void> Function() onLoadMore;
  final Future<void> Function()? onRefresh;
  final Widget Function(BuildContext context, LoadMoreStatus status)?
      loadingWidget;
  final bool showLoading;
  final bool showNoMore;
  final bool showToast;
  final String? toastMessage;
  final double? height;
  @override
  State<LoadMoreContainer> createState() => _LoadMoreContainerState();
}

class _LoadMoreContainerState extends State<LoadMoreContainer> {
  final ScrollController _scrollController = ScrollController();
  bool _hasMoreItems = false;
  LoadMoreStatus _loadMoreStatus = LoadMoreStatus.idle;

  @override
  void initState() {
    _scrollController.addListener(() async {
      // infoLog(
      // 'LoadMoreContainer scrollController called: ${_scrollController.position.pixels} ${_scrollController.position.maxScrollExtent}');
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        infoLog('LoadMoreContainer initState called: ${widget.finishWhen}');
        _hasMoreItems = !widget.finishWhen;

        infoLog('LoadMoreContainer scrollController called: $_hasMoreItems');
        if (_loadMoreStatus != LoadMoreStatus.loading && _hasMoreItems) {
          setState(() {
            _loadMoreStatus = LoadMoreStatus.loading;
          });
          await widget.onLoadMore();
          setState(() {
            _loadMoreStatus = LoadMoreStatus.idle;
          });
        } else if (_hasMoreItems == false) {
          setState(() {
            _loadMoreStatus = LoadMoreStatus.noMore;
          });
          if (widget.showToast) {
            Fluttertoast.showToast(msg: widget.toastMessage ?? 'No more items');
          }
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    infoLog(
        'LoadMoreContainer build called: $_loadMoreStatus hasmore: $_hasMoreItems');
    var child = Container(
      height: widget.height,
      child: Column(
        children: [
          Expanded(child: widget.builder(_scrollController, _loadMoreStatus)),
          if (_loadMoreStatus == LoadMoreStatus.loading && widget.showLoading)
            widget.loadingWidget != null
                ? widget.loadingWidget!(context, _loadMoreStatus)
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
          if (_loadMoreStatus == LoadMoreStatus.noMore && widget.showNoMore)
            Padding(
              padding: EdgeInsets.all(8.0),
              child: capText('No more items', context),
            ),
        ],
      ),
    );
    if (widget.onRefresh == null) return child;
    return RefreshIndicator(
      onRefresh: widget.onRefresh!,
      triggerMode: RefreshIndicatorTriggerMode.anywhere,
      child: child,
    );
  }
}
