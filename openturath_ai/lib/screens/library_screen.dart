import 'package:flutter/material.dart';
import '../models/agent_model.dart';
import 'book_catalog_screen.dart';

/// The library and catalogue share the same browsing and edition-detail flow.
class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key, this.agent});
  final AgentModel? agent;

  @override
  Widget build(BuildContext context) => BookCatalogScreen(agent: agent);
}
