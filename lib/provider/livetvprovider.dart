import 'package:flutter/material.dart';
import '../model/livetvmodel.dart' as livetv;
import '../webservice/apiservices.dart';
import '../utils/utils.dart';

class LiveTvProvider extends ChangeNotifier {
  livetv.LiveTvModel liveTvModel = livetv.LiveTvModel();
  List<livetv.Result>? liveTvList = [];

  bool loadingSection = false;

  Future<void> getLiveTvList() async {
    loadingSection = true;
    liveTvModel = livetv.LiveTvModel();
    try {
      liveTvModel = await ApiService().getLiveTv();
      printLog("getLiveTvList message :==> ${liveTvModel.message}");

      liveTvList?.clear();
      liveTvList = [];
      if (liveTvModel.status == 200) {
        if (liveTvModel.result != null &&
            (liveTvModel.result?.length ?? 0) > 0) {
          for (var i = 0; i < (liveTvModel.result?.length ?? 0); i++) {
            liveTvList?.add(liveTvModel.result?[i] ?? livetv.Result());
          }
          final Map<String, livetv.Result> postMap = {};
          liveTvList?.forEach((item) {
            final key = '${item.id}-${item.categoryId}';
            postMap[key] = item;
          });
          liveTvList = postMap.values.toList();
        }
      }
    } catch (e) {
      printLog("Exception in getLiveTvList: $e");
    }

    loadingSection = false;
    notifyListeners();
  }

  void clearProvider() {
    liveTvModel = livetv.LiveTvModel();
    liveTvList?.clear();
    liveTvList = [];
    loadingSection = false;
  }
}
