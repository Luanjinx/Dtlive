import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

import '../provider/livetvprovider.dart';
import '../utils/color.dart';
import '../utils/constant.dart';
import '../utils/dimens.dart';
import '../utils/utils.dart';
import '../widget/mynetworkimg.dart';
import '../widget/mytext.dart';
import '../widget/nodata.dart';
import '../shimmer/shimmerutils.dart';
import '../routes/routes_constant.dart';
import '../model/sectionlistmodel.dart' as section;

class LiveTV extends StatefulWidget {
  const LiveTV({super.key});

  @override
  State<LiveTV> createState() => _LiveTVState();
}

class _LiveTVState extends State<LiveTV> {
  late LiveTvProvider liveTvProvider;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    liveTvProvider = Provider.of<LiveTvProvider>(context, listen: false);
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getData();
    });
  }

  Future<void> _getData() async {
    await liveTvProvider.getSectionList(Constant.liveTvContentType, 2, 1);
  }

  void _scrollListener() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        (liveTvProvider.isMorePage ?? false)) {
      liveTvProvider.setLoadMore(true);
      _fetchNewPageData(liveTvProvider.currentPage ?? 0);
    }
  }

  Future<void> _fetchNewPageData(int? nextPage) async {
    await liveTvProvider.getSectionList(
        Constant.liveTvContentType, 2, (nextPage ?? 0) + 1);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    liveTvProvider.clearProvider();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      appBar: Utils.myAppBar(context, "Live TV", false),
      body: SafeArea(
        child: Consumer<LiveTvProvider>(
          builder: (context, provider, child) {
            if (provider.loadingSection && provider.sectionList!.isEmpty) {
              return ShimmerUtils.responsiveGrid(
                  context, Dimens.heightLand, Dimens.widthLand, 2, 8);
            }

            if (provider.sectionList != null &&
                provider.sectionList!.isNotEmpty) {
              return _buildLiveTvGrid(provider);
            } else {
              return const NoData(
                  title: 'nodata', subTitle: 'No Live TV available');
            }
          },
        ),
      ),
    );
  }

  Widget _buildLiveTvGrid(LiveTvProvider provider) {
    return RefreshIndicator(
      backgroundColor: white,
      color: colorPrimary,
      displacement: 80,
      onRefresh: () async {
        await provider.getSectionList(Constant.liveTvContentType, 2, 1);
      },
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.sectionList?.length ?? 0,
              itemBuilder: (context, sectionIndex) {
                final sectionItem = provider.sectionList?[sectionIndex];
                final dataList = sectionItem?.data ?? [];
                
                if (dataList.isEmpty) return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if ((sectionItem?.title ?? "").isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(15, 20, 15, 10),
                        child: MyText(
                          color: white,
                          text: sectionItem?.title ?? "",
                          textalign: TextAlign.start,
                          fontsizeNormal: 15,
                          fontweight: FontWeight.w600,
                          fontsizeWeb: 17,
                          multilanguage: false,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        ),
                      ),
                    ResponsiveGridList(
                      minItemWidth: Dimens.widthLand,
                      verticalGridSpacing: 8,
                      horizontalGridSpacing: 8,
                      minItemsPerRow: Dimens.isBigScreen(context) ? 4 : 2,
                      maxItemsPerRow: 8,
                      listViewBuilderOptions: ListViewBuilderOptions(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                      ),
                      children: List.generate(
                        dataList.length,
                        (index) {
                          final item = dataList[index];
                          return InkWell(
                            borderRadius: BorderRadius.circular(4),
                            onTap: () {
                              Utils.openDetails(
                                context: context,
                                videoId: item.id ?? 0,
                                subVideoType: item.subVideoType ?? 0,
                                videoType: item.videoType ?? 0,
                                typeId: item.typeId ?? 0,
                                newPage: RoutesConstant.contentDetailsPage,
                                oldPage: "LiveTV",
                                reqText: "",
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: MyNetworkImage(
                                    imageUrl: item.landscape ?? "",
                                    fit: BoxFit.cover,
                                    height: Dimens.heightLand,
                                    width: MediaQuery.of(context).size.width,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                MyText(
                                  color: white,
                                  text: item.name ?? "",
                                  textalign: TextAlign.start,
                                  fontsizeNormal: 14,
                                  fontweight: FontWeight.w500,
                                  fontsizeWeb: 15,
                                  maxline: 1,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
            if (provider.loadMore)
              Container(
                height: 50,
                margin: const EdgeInsets.fromLTRB(5, 5, 5, 10),
                child: Utils.pageLoader(),
              )
            else
              const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
