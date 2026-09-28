import '../model/sectionlistmodel.dart' as section;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

import '../provider/homeprovider.dart';
import '../provider/sectionbytypeprovider.dart';
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
  late SectionByTypeProvider sectionByTypeProvider;
  
  List<section.Datum> allLiveTvVideos = [];

  @override
  void initState() {
    super.initState();
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    sectionByTypeProvider = Provider.of<SectionByTypeProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getData();
    });
  }

  Future<void> _getData() async {
    final typeId = Constant.liveTvContentType;
    if (typeId != 0) {
      await sectionByTypeProvider.getSectionList(typeId.toString(), "2", 1);
      
      allLiveTvVideos.clear();
      if (sectionByTypeProvider.sectionListModel.status == 200 && sectionByTypeProvider.sectionListModel.result != null) {
        for (var sec in sectionByTypeProvider.sectionListModel.result!) {
          if (sec.data != null) {
            allLiveTvVideos.addAll(sec.data!);
          }
        }
      }
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      appBar: Utils.myAppBar(context, "Live TV", false),
      body: SafeArea(
        child: Consumer<SectionByTypeProvider>(
          builder: (context, sectionProvider, child) {
            if (sectionProvider.loadingSection) {
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
              if (allLiveTvVideos.isNotEmpty) {
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
                        allLiveTvVideos.length,
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
                                    videoId: allLiveTvVideos[position].id ?? 0,
                                    subVideoType: allLiveTvVideos[position].subVideoType ?? 0,
                                    videoType: allLiveTvVideos[position].videoType ?? 0,
                                    typeId: allLiveTvVideos[position].typeId ?? 0,
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
                                      imageUrl: allLiveTvVideos[position].portrait ?? "",
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

