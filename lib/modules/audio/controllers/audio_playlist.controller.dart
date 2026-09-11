import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/design/design.dart';
import 'package:rexone_mobile/models/models.dart';
import 'package:rexone_mobile/routes/app.routes.dart';
import 'package:rexone_mobile/services/media.service.dart';

import '../audio.dart';

class AudioPlaylistController extends GetxController {
  late final MediaService _media;
  final AudioPlayerService player = Get.find<AudioPlayerService>();

  final RxList<AssetModel> assets = <AssetModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = false.obs;
  final Rxn<PaginationMeta> pagination = Rxn<PaginationMeta>();

  static const int _pageLimit = 10;
  int _currentPage = 1;

  @override
  void onInit() {
    super.onInit();
    _media = Get.find<MediaService>();
    fetchAssets(refresh: true);
  }

  Future<void> fetchAssets({bool refresh = false}) async {
    if (isLoading.value && !refresh) return;

    isLoading.value = true;
    try {
      await _loadAudio(1, append: false);
    } catch (e) {
      debugPrint('❌ [AudioPlaylistController] Fetch error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value || isLoading.value) return;

    isLoadingMore.value = true;
    final nextPage = (pagination.value?.currentPage ?? _currentPage) + 1;
    try {
      await _loadAudio(nextPage, append: true);
    } catch (e) {
      debugPrint('❌ [AudioPlaylistController] Load more error: $e');
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> _loadAudio(int page, {required bool append}) async {
    final res = await _media.getAssets(
      type: AssetKeys.typeAudio,
      page: page,
      limit: _pageLimit,
    );

    if (!res.success) {
      AppSnackbar.error(res.message);
      return;
    }

    final ready = res.records.where((asset) => asset.isReady);
    if (append) {
      assets.addAll(ready);
    } else {
      assets.assignAll(ready);
    }

    pagination.value = res.pagination;
    hasMore.value = res.pagination?.hasNextPage ?? false;
    _currentPage = page;
    await player.setAssets(assets.toList());
  }

  Future<void> playAll() => player.play(0);

  Future<void> playAt(int index) async {
    if (player.hasSession.value && player.currentIndex.value == index) {
      AppRoutes.toAudioPlayer();
      return;
    }
    await player.play(index);
  }
}
