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

class LiveTV extends StatefulWidget {
  const LiveTV({super.key});

  @override
  State<LiveTV> createState() => _LiveTVState();
}

class _LiveTVState extends State<LiveTV> {
  late LiveTvProvider liveTvProvider;

  @override
  void initState() {
    super.initState();
    liveTvProvider = Provider.of<LiveTvProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getData();
    });
  }

  Future<void> _getData() async {
    await liveTvProvider.getLiveTvList();
  }

  @override
  void dispose() {
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
            if (provider.loadingSection && provider.liveTvList!.isEmpty) {
              return ShimmerUtils.responsiveGrid(
                  context, Dimens.heightLand, Dimens.widthLand, 2, 8);
            }

            if (provider.liveTvList != null &&
                provider.liveTvList!.isNotEmpty) {
              return _buildLiveTvGrid(provider);
            } else {
              return const NoData(
                  title: 'nodata', subTitle: 'no_live_tv_available');
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
        await provider.getLiveTvList();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.only(top: 15),
          child: ResponsiveGridList(
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
              provider.liveTvList?.length ?? 0,
              (index) {
                final item = provider.liveTvList![index];
                return InkWell(
                  borderRadius: BorderRadius.circular(4),
                  onTap: () {
                    // Navigate to video player or details
                    // Currently Live TV doesn't have a specific details page, maybe open player directly?
                    Utils.openDetails(
                      context: context,
                      videoId: item.id ?? 0,
                      subVideoType: 0,
                      videoType: 9,
                      typeId: item.categoryId ?? 0,
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
                          imageUrl: item.landscapeThumbnail ?? "",
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
        ),
      ),
    );
  }
}
