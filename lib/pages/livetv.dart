import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

import '../provider/homeprovider.dart';
import '../routes/routes_constant.dart';
import '../shimmer/shimmerutils.dart';
import '../utils/color.dart';
import '../utils/constant.dart';
import '../utils/dimens.dart';
import '../utils/utils.dart';
import '../widget/mynetworkimg.dart';
import '../widget/nodata.dart';

class LiveTv extends StatefulWidget {
  const LiveTv({super.key});

  @override
  State<LiveTv> createState() => LiveTvState();
}

class LiveTvState extends State<LiveTv> {
  late HomeProvider homeProvider;

  @override
  void initState() {
    super.initState();
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getData();
    });
  }

  Future<void> _getData() async {
    await homeProvider.getChannel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      appBar: Utils.myAppBar(context, "Live TV", false),
      body: SafeArea(
        child: Consumer<HomeProvider>(
          builder: (context, homeProvider, child) {
            if (homeProvider.loading) {
              return ShimmerUtils.responsiveGrid2(
                context,
                Dimens.heightPortOther,
                Dimens.widthPortOther,
                3,
                3,
                3,
                12,
              );
            } else {
              if (homeProvider.channelModel.status == 200 &&
                  homeProvider.channelModel.result != null &&
                  (homeProvider.channelModel.result?.length ?? 0) > 0) {
                return RefreshIndicator(
                  backgroundColor: white,
                  color: complimentryColor,
                  displacement: 80,
                  onRefresh: () async {
                    await _getData();
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(8),
                    child: ResponsiveGridList(
                      minItemWidth: Dimens.widthPortOther,
                      verticalGridSpacing: 8,
                      horizontalGridSpacing: 8,
                      minItemsPerRow: 3,
                      maxItemsPerRow: 8,
                      listViewBuilderOptions: ListViewBuilderOptions(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                      ),
                      children: List.generate(
                        homeProvider.channelModel.result?.length ?? 0,
                        (position) {
                          return Material(
                            type: MaterialType.transparency,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                Dimens.cardRadiusSmall,
                              ),
                              child: InkWell(
                                focusColor: white,
                                onTap: () {
                                  Utils.openDetails(
                                    context: context,
                                    videoId: homeProvider.channelModel.result?[position].id ?? 0,
                                    subVideoType: 0,
                                    videoType: Constant.liveTvContentType,
                                    typeId: Constant.liveTvContentType,
                                    newPage: RoutesConstant.liveTvDetailsPage,
                                    oldPage: "",
                                    reqText: "",
                                  );
                                },
                                child: Container(
                                  padding: Dimens.isBigScreen(context)
                                      ? const EdgeInsets.all(2.0)
                                      : const EdgeInsets.all(0),
                                  child: Container(
                                    width: Dimens.widthPortOther,
                                    height: Dimens.heightPortOther,
                                    alignment: Alignment.center,
                                    child: MyNetworkImage(
                                      imageUrl: homeProvider.channelModel.result?[position].portraitImg ?? "",
                                      fit: BoxFit.cover,
                                      height: MediaQuery.of(context).size.height,
                                      width: MediaQuery.of(context).size.width,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              } else {
                return const Center(
                  child: NoData(title: 'no_data', subTitle: 'no_video_show'),
                );
              }
            }
          },
        ),
      ),
    );
  }
}
