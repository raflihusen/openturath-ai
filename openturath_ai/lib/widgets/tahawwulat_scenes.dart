import 'tahawwulat_scene.dart';
import 'tahawwulat_scenes_a.dart';
import 'tahawwulat_scenes_b.dart';
import 'tahawwulat_scenes_c.dart';
import 'tahawwulat_scenes_d.dart';

final Map<String, SceneDef> _registry = {
  ...scenesA(),
  ...scenesB(),
  ...scenesC(),
  ...scenesD()
};

/// Adegan untuk kunci [id] (mis. `s7`), atau null bila slide hanya tipografi.
SceneDef? sceneFor(String id) => _registry[id];
