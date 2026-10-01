import 'package:flutter/material.dart';
import '../model/sectionlistmodel.dart' as list;
import '../webservice/apiservices.dart';
import '../utils/utils.dart';

class LiveTvProvider extends ChangeNotifier {
  list.SectionListModel sectionListModel = list.SectionListModel();
  List<list.Result>? sectionList = [];

  bool loadingSection = false;
  int? cSectionIndex = 0;

  Future<void> getLiveTvList() async {
    loadingSection = true;
    sectionListModel = list.SectionListModel();
    try {
      sectionListModel = await ApiService().sectionList(9, 2, 1);
      printLog("getLiveTvList message :==> ${sectionListModel.message}");

      if (sectionListModel.status == 200) {
        if (sectionListModel.result != null &&
            (sectionListModel.result?.length ?? 0) > 0) {
          if (sectionList != null && sectionList!.isNotEmpty) {
            sectionList?.clear();
            sectionList = [];
          }
          for (var i = 0; i < (sectionListModel.result?.length ?? 0); i++) {
            sectionList?.add(sectionListModel.result?[i] ?? list.Result());
          }

          final Map<String, list.Result> postMap = {};
          sectionList?.forEach((item) {
            postMap[item.id.toString()] = item;
          });
          sectionList = postMap.values.toList();
        }
      }
    } catch (e) {
      printLog("Exception in getLiveTvList: $e");
    }

    loadingSection = false;
    notifyListeners();
  }

  void clearProvider() {
    sectionListModel = list.SectionListModel();
    sectionList?.clear();
    sectionList = [];
    loadingSection = false;
  }
}
