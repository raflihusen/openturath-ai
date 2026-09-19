import 'package:flutter/material.dart';
import '../core/l10n/app_dictionary.dart';
import '../core/app_snackbar.dart';
import '../core/design/ot_colors.dart';
import '../models/agent_model.dart';
import '../models/field_model.dart';
import '../services/agent_session_manager.dart';
import '../widgets/agent_multi_tab_room.dart';
import '../widgets/apple_interactive_wrapper.dart';
import '../widgets/editorial.dart';
import 'bookmark_screen.dart';
import 'dashboard_screen.dart';
import 'profile_screen.dart';
import 'specialist_list_screen.dart';

class MainShellController extends InheritedWidget {
  final void Function(int index, {String? fieldId, CorpusKind? kind}) switchTab;
  const MainShellController({super.key, required this.switchTab, required super.child});
  static MainShellController? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MainShellController>();
  @override
  bool updateShouldNotify(MainShellController oldWidget) => false;
}

class MainShellScreen extends StatefulWidget {
  final int initialTab;
  const MainShellScreen({super.key, this.initialTab = 0});
  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  late int _currentIndex;
  final _roomKey = GlobalKey<AgentMultiTabRoomState>();
  String? _selectedFieldId;
  CorpusKind? _selectedKind;
  List<String> get _labels => [context.tr('shell.home'), context.tr('shell.assistants'),
    context.tr('shell.notes'), context.tr('shell.settings')];
  static const _icons = [Icons.home_outlined, Icons.auto_stories_outlined,
    Icons.edit_note_outlined, Icons.tune_outlined];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab.clamp(0, 3).toInt();
  }

  void _onTabSelected(int index, {String? fieldId, CorpusKind? kind}) {
    if (index < 0 || index > 3) return;
    AppSnackBar.clear(context);
    setState(() {
      _currentIndex = index;
      if (index == 1) {
        _selectedFieldId = fieldId;
        _selectedKind = kind;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final wide = MediaQuery.sizeOf(context).width >= 1000;
    final field = _selectedFieldId == null ? null : FieldModel.findById(_selectedFieldId!);
    final screens = <Widget>[
      const DashboardScreen(),
      SpecialistListScreen(key: ValueKey('${_selectedFieldId}_${_selectedKind?.name}'), field: field,
        initialKind: _selectedKind ?? CorpusKind.discipline),
      const BookmarkScreen(),
      const ProfileScreen(),
    ];
    return MainShellController(
      switchTab: _onTabSelected,
      child: ListenableBuilder(
        listenable: AgentSessionManager.instance,
        child: AgentMultiTabRoom(key: _roomKey),
        builder: (context, room) {
          final roomOpen = AgentSessionManager.instance.isOpen;
          final content = IndexedStack(
            index: _currentIndex,
            children: List.generate(screens.length, (index) => TickerMode(
              enabled: !roomOpen && _currentIndex == index,
              child: screens[index],
            )),
          );
          return PopScope(
            canPop: !roomOpen && _currentIndex == 0,
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) return;
              if (roomOpen) {
                if (_roomKey.currentState?.exitFocusMode() == true) return;
                AppSnackBar.clear(context);
                AgentSessionManager.instance.closeRoom();
              } else {
                _onTabSelected(0);
              }
            },
            child: Stack(children: [
              Scaffold(
                body: wide ? Row(children: [
                  Container(
                    width: 224,
                    decoration: BoxDecoration(border: BorderDirectional(end: BorderSide(color: OTColors.border(isDark)))),
                    child: SafeArea(child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Padding(padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Text('OpenTurath', style: Theme.of(context).textTheme.headlineSmall)),
                        const SizedBox(height: 24),
                        for (var index = 0; index < _labels.length; index++)
                          EditorialRow(title: _labels[index], leading: Icon(_icons[index], size: 20),
                            selected: index == _currentIndex, onTap: () => _onTabSelected(index)),
                        const SizedBox(height: 32),
                        Text(context.tr('shell.study_space'), style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(height: 12),
                      ]),
                    )),
                  ),
                  Expanded(child: content),
                ]) : content,
                bottomNavigationBar: wide ? null : Container(
                  decoration: BoxDecoration(color: OTColors.canvas(isDark),
                    border: Border(top: BorderSide(color: OTColors.border(isDark)))),
                  child: SafeArea(top: false, child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: Row(children: List.generate(_labels.length, (index) => Expanded(
                      child: Semantics(selected: index == _currentIndex,
                        child: AppleInteractiveWrapper(onTap: () => _onTabSelected(index),
                          child: ConstrainedBox(constraints: const BoxConstraints(minHeight: 54),
                            child: Padding(padding: const EdgeInsets.symmetric(vertical: 7),
                              child: Column(mainAxisSize: MainAxisSize.min, children: [
                                Icon(_icons[index], size: 22,
                                  color: index == _currentIndex ? OTColors.textPrimary(isDark) : OTColors.textSecondary(isDark)),
                                const SizedBox(height: 5),
                                Text(_labels[index], textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    fontWeight: index == _currentIndex ? FontWeight.w600 : FontWeight.w400)),
                              ])),
                          )),
                      ),
                    ))),
                  )),
                ),
              ),
              Positioned.fill(child: Offstage(offstage: !roomOpen,
                child: TickerMode(enabled: roomOpen, child: room!))),
            ]),
          );
        },
      ),
    );
  }
}
