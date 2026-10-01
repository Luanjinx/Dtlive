import 'package:flutter/material.dart';
import '../model/sectionlistmodel.dart' as section;
import '../webservice/apiservices.dart';
import '../utils/utils.dart';

class LiveTvProvider extends ChangeNotifier {
  section.SectionListModel sectionListModel = section.SectionListModel();
  List<section.Result>? sectionList = [];

  bool loadingSection = false;

  /* Pagination */
  bool loadMore = false;
  int? totalRows, totalPage, currentPage;
  bool? isMorePage;

  Future<void> getSectionList(dynamic typeId, isHomePage, pageNo) async {
    printLog("getSectionList typeId :======> $typeId");
    printLog("getSectionList isHomePage :==> $isHomePage");
    printLog("getSectionList pageNo :======> $pageNo");
    if (pageNo == 1) {
      sectionList?.clear();
      sectionList = [];
    }
    loadingSection = true;
    sectionListModel = section.SectionListModel();
    try {
        sectionListModel =
            await ApiService().sectionList(typeId, isHomePage, pageNo);
        printLog("getSectionList message :==> ${sectionListModel.message}");
        
        if (pageNo == 1) {
          sectionList?.clear();
          sectionList = [];
        }
        if (sectionListModel.status == 200) {
          setPagination(sectionListModel.totalRows, sectionListModel.totalPage,
              sectionListModel.currentPage, sectionListModel.morePage);
          if (sectionListModel.result != null &&
              (sectionListModel.result?.length ?? 0) > 0) {
            for (var i = 0; i < (sectionListModel.result?.length ?? 0); i++) {
              sectionListModel.result?[i].scrollController = ScrollController();
              sectionList?.add(sectionListModel.result?[i] ?? section.Result());
            }
            final Map<String, section.Result> postMap = {};
            sectionList?.forEach((item) {
              final key =
                  '${item.id}-${item.typeId}-${item.videoType}-${item.subVideoType}';
              postMap[key] = item;
            });
            sectionList = postMap.values.toList();
            setLoadMore(false);
          } else {
            setLoadMore(false);
          }
        } else {
          setLoadMore(false);
        }
    } catch(e) {
        printLog("Exception in getSectionList: $e");
        setLoadMore(false);
    }
    
    loadingSection = false;
    notifyListeners();
  }

  void setLoadMore(bool loadMore) {
    this.loadMore = loadMore;
    notifyListeners();
  }

  void setPagination(
      int? totalRows, int? totalPage, int? currentPage, bool? morePage) {
    this.currentPage = currentPage;
    this.totalRows = totalRows;
    this.totalPage = totalPage;
    this.isMorePage = morePage;
    notifyListeners();
  }

  void clearProvider() {
    sectionListModel = section.SectionListModel();
    sectionList?.clear();
    sectionList = [];
    loadingSection = false;
    loadMore = false;
    totalRows = null;
    totalPage = null;
    currentPage = null;
    isMorePage = null;
  }
}
