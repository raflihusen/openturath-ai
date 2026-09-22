import '../core/localization.dart';
import '../widgets/native_theme.dart';
import 'dart:async';
import '../core/arabic_utils.dart';
import '../core/design/native_design.dart';
import '../models/field_model.dart';
import '../models/bookmark_model.dart';
import '../services/bookmark_service.dart';
import '../widgets/native_components.dart';
import '../widgets/native_study_surfaces.dart';
import 'note_reader_screen.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_copy.dart';
import '../core/routes.dart';

import '../core/app_snackbar.dart';
import '../core/hijri_date_utils.dart';
import '../models/agent_model.dart';
import '../models/user_model.dart';
import '../services/agent_service.dart';
import '../services/agent_session_manager.dart';
import '../services/auth_service.dart';
import '../services/update_service.dart';
import '../core/navigation_guard.dart';
import '../widgets/update_ready_banner.dart';
import '../widgets/update_ready_dialog.dart';
import '../widgets/specialist_card.dart';
import 'native_library_page.dart';

import 'main_shell_screen.dart';

/// Beranda OpenTurath AI (Tactile Scholarly Research Desk)
/// Dilengkapi animasi Apple Interactive micro-compression, pantulan pegas halus,
/// penanggalan ganda Hijriah, pencarian naskah seketika, dan portal keilmuan interaktif.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AuthService _authService = AuthService();
  final AgentService _agentService = AgentService();
  final TextEditingController _searchController = TextEditingController();
  late final UpdateService _updateService;
  bool _hasShownUpdateDialog = false;

  UserModel? _initialUser;
  List<AgentModel> _agents = AgentModel.defaultAgents;
  String _searchQuery = '';
  String? _lastOpenedAgentId;

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadLastOpenedAgent();
    _updateService = UpdateService();
    _updateService.addListener(_onUpdateServiceChanged);
    _updateService.checkForUpdatesSilently();
  }

  void _onUpdateServiceChanged() {
    if (!mounted) return;
    if (_updateService.isUpdateReady && !_hasShownUpdateDialog) {
      _hasShownUpdateDialog = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          UpdateReadyDialog.show(context, _updateService);
        }
      });
    }
  }

  Future<void> _loadLastOpenedAgent() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() =>
            _lastOpenedAgentId = prefs.getString('last_opened_notebook_id'));
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _updateService.removeListener(_onUpdateServiceChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      if (_authService.currentUser == null) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, AppRoutes.login);
        return;
      }

      final results = await Future.wait([
        _authService.getCurrentUserModel(),
        _agentService.getAgents(),
      ]).timeout(
        const Duration(seconds: 4),
        onTimeout: () => [null, AgentModel.defaultAgents],
      );

      if (!mounted) return;
      setState(() {
        _initialUser = results[0] as UserModel?;
        _agents = results[1] as List<AgentModel>;
      });
    } catch (_) {}
  }

  void _openNotebook(AgentModel agent, UserModel? user) {
    if (agent.kind == CorpusKind.scholar) {
      AppSnackBar.warning(context, Loc.tr('scholarPreparingBody'));
      return;
    }
    if (agent.isComingSoon) {
      AppSnackBar.warning(
        context,
        Loc.tr('collectionPreparing', [agent.title]),
      );
      return;
    }

    // Rekam riwayat pembukaan terakhir secara asynchronous di background
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('last_opened_notebook_id', agent.id);
      if (mounted) setState(() => _lastOpenedAgentId = agent.id);
    }).catchError((_) {});

    // Cek akses pengguna ke agent (paywall)
    if (user == null || !user.hasAccessToAgent(agent.id)) {
      NavigationGuard.safePushNamed(
        context,
        AppRoutes.subscription,
        arguments: {'user': user, 'agent': agent},
      );
      return;
    }

    // Buka ruang kajian multi-tab secara seketika (0ms delay)
    AgentSessionManager.instance.openAgent(agent, user: user);
  }

  void _browse({String? fieldId}) {
    final shell = MainShellController.of(context);
    if (shell != null) {
      shell.switchTab(1, fieldId: fieldId);
    } else {
      NavigationGuard.safePushNamed(context, AppRoutes.specialistList,
          arguments: {'fieldId': fieldId});
    }
  }

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    return StreamBuilder<UserModel?>(
      stream: _authService.userStream,
      initialData: _initialUser,
      builder: (context, snapshot) {
        final user = snapshot.data ?? _initialUser;
        return NativeDashboardPage(user: user, agents: _agents, lastOpenedAgentId: _lastOpenedAgentId,
          searchController: _searchController, searchQuery: _searchQuery,
          onSearch: (value) => setState(() => _searchQuery = value.trim()),
          onBrowse: _browse, onOpen: (agent) => _openNotebook(agent, user), onRefresh: _loadData);
      },
    );
  }
}

class _RecentNotes extends StatefulWidget {
  const _RecentNotes({this.userId});
  final String? userId;
  @override
  State<_RecentNotes> createState() => _RecentNotesState();
}

class _RecentNotesState extends State<_RecentNotes> {
  final _service = BookmarkService();
  late Future<List<BookmarkModel>> _notes;
  @override
  void initState() {
    super.initState();
    _reload();
    _service.addListener(_changed);
  }

  void _reload() {
    _notes = _service.getBookmarks(userId: widget.userId);
  }

  void _changed() {
    if (mounted) setState(_reload);
  }

  @override
  void didUpdateWidget(covariant _RecentNotes oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId) _reload();
  }

  @override
  void dispose() {
    _service.removeListener(_changed);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return FutureBuilder<List<BookmarkModel>>(
        future: _notes,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return NativeEmpty(
                title: NativeCopy.text('error'), onAction: _changed);
          }
          if (!snapshot.hasData) return const NativeLoading();
          final notes = [...snapshot.data!]
            ..sort((a, b) => b.effectiveTime.compareTo(a.effectiveTime));
          if (notes.isEmpty) {
            return NativeEmpty(
                title: NativeCopy.text('notesEmpty'),
                detail: NativeCopy.text('notesHint'),
                action: AppCopy.navSaved,
                onAction: () => MainShellController.of(context)?.switchTab(2));
          }
          return NativeSection(
              padding: EdgeInsets.zero,
              child: Column(children: [
                for (final note in notes.take(2))
                  NativePress(
                      onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                              builder: (_) => NativeTheme(
                                  child: NoteReaderScreen(item: note)))),
                      child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(children: [
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  Text(note.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: NativeType.body(dark)),
                                  if (note.agentTitle.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(Loc.text(note.agentTitle),
                                        style: NativeType.meta(dark))
                                  ],
                                ])),
                            const SizedBox(width: 12),
                            const Icon(Icons.chevron_right_rounded, size: 20),
                          ]))),
              ]));
        });
  }
}

/// Same presentation used in production and offline visual regression tests.
class NativeDashboardPage extends StatelessWidget {
  const NativeDashboardPage({super.key, required this.user, required this.agents,
    required this.searchController, required this.searchQuery, required this.onSearch,
    required this.onBrowse, required this.onOpen, required this.onRefresh, this.lastOpenedAgentId});
  final UserModel? user;
  final List<AgentModel> agents;
  final String? lastOpenedAgentId;
  final TextEditingController searchController;
  final String searchQuery;
  final ValueChanged<String> onSearch;
  final void Function({String? fieldId}) onBrowse;
  final ValueChanged<AgentModel> onOpen;
  final Future<void> Function() onRefresh;
  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final matches = agents
            .where((a) =>
                a.kind == CorpusKind.discipline &&
                (ArabicUtils.matches(a.title, searchQuery) ||
                    ArabicUtils.matches(a.titleArabic, searchQuery) ||
                    ArabicUtils.matches(a.subtitleAcademic, searchQuery)))
            .toList();
        return Scaffold(
          backgroundColor: NativeColors.canvas(dark),
          body: SafeArea(
              bottom: false,
              child: RefreshIndicator(
                onRefresh: onRefresh,
                child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 760),
                      child: ListView(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 104),
                          children: [
                            Text('OpenTurath', style: NativeType.title(dark, size: 26)),
                            const SizedBox(height: 8),
                            Text(user == null ? AppCopy.ahlanDefault : AppCopy.ahlanWithName(user.name), style: NativeType.body(dark, size: 15)),
                            const SizedBox(height: 4),
                            Text(HijriDateUtils.formatHijriOnly(), style: NativeType.meta(dark)),
                            const SizedBox(height: 20),
                            const UpdateReadyBanner(),
                            ListenableBuilder(
                                listenable: AgentSessionManager.instance,
                                builder: (context, _) {
                                  AgentModel? target = AgentSessionManager
                                      .instance.activeTab?.agent;
                                  for (final agent in agents) {
                                    if (target == null &&
                                        agent.id == lastOpenedAgentId) {
                                      target = agent;
                                    }
                                  }
                                  final selected = target;
                                  return NativeResumeCard(
                                    title: selected == null ? AppCopy.studyEntryDefaultTitle : Loc.text(selected.title),
                                    action: selected == null ? AppCopy.startStudy : AppCopy.continueStudy,
                                    onOpen: () => selected == null ? onBrowse() : onOpen(selected),
                                    onLibrary: selected?.catalogId == null ? null : () => openNativeLibrary(context, agent: selected!),
                                  );
                                }),
                            const SizedBox(height: 24),
                            NativeSearch(
                                controller: searchController,
                                hint: NativeCopy.text('searchAssistants'),
                                onChanged: onSearch),
                            const SizedBox(height: 24),
                            if (searchQuery.isNotEmpty) ...[
                              Text(AppCopy.searchResults,
                                  style: NativeType.title(dark, size: 22)),
                              const SizedBox(height: 16),
                              if (matches.isEmpty)
                                NativeEmpty(
                                    title: AppCopy.noAssistantsFound,
                                    icon: Icons.search_off_rounded),
                              for (final agent in matches)
                                SpecialistCard(
                                    title: agent.title,
                                    titleArabic: agent.titleArabic,
                                    scopeLabel: agent.subtitleAcademic,
                                    statusLabel: agent.isComingSoon
                                        ? AppCopy.comingSoon
                                        : null,
                                    onOpen: () => onOpen(agent),
                                    onOpenLibrary: agent.catalogId == null
                                        ? null
                                        : () => openNativeLibrary(context,
                                            agent: agent)),
                            ] else ...[
                              Row(children: [
                                Expanded(
                                    child: Text(AppCopy.chooseField,
                                        style:
                                            NativeType.title(dark, size: 22))),
                                TextButton(
                                    onPressed: () => onBrowse(),
                                    child: Text(AppCopy.seeAll)),
                              ]),
                              const SizedBox(height: 12),
                              NativeSection(
                                  padding: EdgeInsets.zero,
                                  child: Column(children: [
                                    for (final field in FieldModel.defaultFields
                                        .where((f) =>
                                            f.id != 'fiqh_tahawwulat')) ...[
                                      NativePress(
                                          onTap: () =>
                                              onBrowse(fieldId: field.id),
                                          child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 12),
                                              child: Row(children: [
                                                Expanded(
                                                    child: Text(
                                                        Loc.text(field.name),
                                                        style: NativeType.body(
                                                            dark))),
                                                const Icon(
                                                    Icons.chevron_right_rounded,
                                                    size: 20),
                                              ]))),
                                    ],
                                  ])),
                              const SizedBox(height: 20),
                              NativePress(
                                  onTap: () =>
                                      onBrowse(fieldId: 'fiqh_tahawwulat'),
                                  child: NativeSection(
                                      collection: true,
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(NativeCopy.text('exclusive'),
                                                style: NativeType.meta(dark)
                                                    .copyWith(
                                                        color:
                                                            NativeColors.brass(
                                                                dark))),
                                            const SizedBox(height: 8),
                                            Text(AppCopy.planTahawwulat,
                                                style: NativeType.title(dark,
                                                    size: 22)),
                                            const SizedBox(height: 6),
                                            Text(NativeCopy.text('fivePaths'),
                                                style: NativeType.meta(dark)),
                                          ]))),
                              const SizedBox(height: 28),
                              Text(NativeCopy.text('recentNotes'),
                                  style: NativeType.title(dark, size: 22)),
                              const SizedBox(height: 12),
                              _RecentNotes(userId: user?.uid),
                            ],
                          ]),
                    )),
              )),
        );
  }
}
