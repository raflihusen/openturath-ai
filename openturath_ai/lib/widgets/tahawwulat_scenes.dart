import 'tahawwulat_scene.dart';
import 'tahawwulat_scenes_mengenal.dart';

final Map<String, SceneDef> _registry = scenesMengenal();

/// Adegan untuk kunci [id] (mis. `m07`), atau null bila slide hanya tipografi.
SceneDef? sceneFor(String id) => _registry[id];
