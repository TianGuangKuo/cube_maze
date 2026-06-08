import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/game_level.dart';

class LevelLoader {
  Future<List<GameLevel>> loadAll() async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final paths = manifest.listAssets()
        .where((k) => k.startsWith('assets/levels/') && k.endsWith('.json'))
        .toList()
      ..sort();

    final levels = await Future.wait(paths.map(_loadOne));
    levels.sort((a, b) => a.id.compareTo(b.id));
    return levels;
  }

  Future<GameLevel> _loadOne(String path) async {
    final raw = await rootBundle.loadString(path);
    return GameLevel.fromJson(json.decode(raw) as Map<String, dynamic>);
  }
}
