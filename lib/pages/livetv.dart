import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/livetvprovider.dart';
import '../utils/color.dart';
import '../utils/constant.dart';
import '../utils/dimens.dart';
import '../utils/utils.dart';
import '../widget/mytext.dart';
import '../widget/nodata.dart';
import '../shimmer/shimmerutils.dart';
import '../routes/routes_constant.dart';
import '../widget/content_section_widget.dart';
import '../model/sectionlistmodel.dart' as list;

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
            if (provider.loadingSection && provider.sectionList!.isEmpty) {
              return ListView.builder(
                itemCount: 5,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  return ShimmerUtils.setHomeSections(context, "landscape");
                },
              );
            }

            if (provider.sectionList != null &&
                provider.sectionList!.isNotEmpty) {
              return _buildSections(provider);
            } else {
              return const NoData(
                  title: 'nodata', subTitle: 'no_live_tv_available');
            }
          },
        ),
      ),
    );
  }

  Widget _buildSections(LiveTvProvider provider) {
    return RefreshIndicator(
      backgroundColor: white,
      color: colorPrimary,
      displacement: 80,
      onRefresh: () async {
        await provider.getLiveTvList();
      },
      child: ListView.builder(
        itemCount: provider.sectionList?.length ?? 0,
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
        physics: const AlwaysScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          final section = provider.sectionList![index];
          if (section.data != null && (section.data?.length ?? 0) > 0) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitle(section),
                const SizedBox(height: 12),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: getRemainingDataHeight(section.screenLayout ?? ""),
                  child: setSectionData(section),
                ),
                const SizedBox(height: 25),
              ],
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }

  Widget _buildTitle(list.Result section) {
    return FittedBox(
      child: Container(
        padding: const EdgeInsets.only(left: 13, right: 13),
        child: MyText(
          color: white,
          text: section.title ?? "",
          textalign: TextAlign.center,
          fontsizeNormal: 15,
          fontweight: FontWeight.w600,
          fontsizeWeb: 16,
          multilanguage: false,
          maxline: 1,
          overflow: TextOverflow.ellipsis,
          fontstyle: FontStyle.normal,
        ),
      ),
    );
  }

  double getRemainingDataHeight(String layoutType) {
    if (layoutType == "landscape" || layoutType == "index_landscape") {
      return Dimens.heightLand;
    } else if (layoutType == "big_landscape") {
      return Dimens.heightLandBig;
    } else if (layoutType == "portrait" || layoutType == "index_portrait") {
      return Dimens.heightPort;
    } else if (layoutType == "big_portrait") {
      return Dimens.heightPortBig;
    } else if (layoutType == "square") {
      return Dimens.heightSquare;
    } else {
      return Dimens.heightLand;
    }
  }

  Widget setSectionData(list.Result section) {
    final layoutType = section.screenLayout ?? "";
    ContentCardLayout layout = ContentCardLayout.landscape;
    if (layoutType == "big_landscape") layout = ContentCardLayout.bigLandscape;
    if (layoutType == "index_landscape") layout = ContentCardLayout.indexLandscape;
    if (layoutType == "portrait") layout = ContentCardLayout.portrait;
    if (layoutType == "big_portrait") layout = ContentCardLayout.bigPortrait;
    if (layoutType == "index_portrait") layout = ContentCardLayout.indexPortrait;
    if (layoutType == "square") layout = ContentCardLayout.square;

    return ContentSectionWidget(
      items: section.data,
      layout: layout,
      showScrollArrows: false,
      horizontalPadding: 14,
      onItemTap: (datum, index) {
        Utils.openDetails(
          context: context,
          videoId: datum.id ?? 0,
          subVideoType: datum.subVideoType ?? 0,
          videoType: datum.videoType ?? 0,
          typeId: section.typeId ?? 0,
          newPage: RoutesConstant.contentDetailsPage,
          oldPage: "LiveTV",
          reqText: "",
        );
      },
    );
  }
}
