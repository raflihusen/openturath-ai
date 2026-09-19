import '../core/l10n/app_dictionary.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/app_snackbar.dart';
import '../core/routes.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_typography.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_motion.dart';
import '../core/design/ot_spacing.dart';
import '../core/goakal_catalog_registry.dart';
import '../models/agent_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/subscription_service.dart';
import '../widgets/doku_checkout_sheet.dart';
import '../widgets/redeem_code_sheet.dart';
import '../widgets/editorial.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});
  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final SubscriptionService _subService = SubscriptionService();
  final AuthService _authService = AuthService();
  StreamSubscription<UserModel?>? _userChanges;
  UserModel? _user;
  AgentModel? _agent;
  bool _initialized = false;
  bool _isProcessing = false;
  bool _isSyncingGoAkal = false;
  int _selectedSegment = 0;
  final Map<String, int> _bundleDurationIndices = {};
  final Map<String, int> _agentDurationIndices = {};
  AgentModel? _selectedOtherAgent;
  String? _checkoutMessage;
  String? _pendingAgentId;
  bool _pendingGoAkal = false;

  AgentModel get _tahawwulatAgent => AgentModel.defaultAgents.firstWhere((a) => a.id == 'fiqh_tahawwulat');
  List<AgentModel> get _otherAgents => AgentModel.defaultAgents.where((a) => a.isActive && a.id != 'fiqh_tahawwulat').toList();

  @override
  void initState() {
    super.initState();
    _userChanges = _authService.userStream.listen((user) {
      if (!mounted) return;
      setState(() {
        if (_user?.uid != user?.uid) {
          _checkoutMessage = null;
          _pendingAgentId = null;
          _pendingGoAkal = false;
        }
        _user = user;
      });
    }, onError: (Object error, StackTrace stack) {
      if (mounted) setState(() => _checkoutMessage = 'membership.access_sync_prompt');
    });
  }

  @override
  void dispose() { _userChanges?.cancel(); super.dispose(); }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    _user = _authService.cachedCurrentUser;
    if (args is UserModel && args.uid == FirebaseAuth.instance.currentUser?.uid) _user = args;
    if (args is Map<String, dynamic>) {
      _agent = args['agent'] as AgentModel?;
      final passed = args['user'] as UserModel?;
      if (passed?.uid == FirebaseAuth.instance.currentUser?.uid) _user = passed;
    }
    final others = _otherAgents;
    if (others.isNotEmpty) _selectedOtherAgent = others.firstWhere(
      (a) => a.id == _agent?.id, orElse: () => others.first);
    if (_agent != null) _selectedSegment = 1;
  }

  static const List<Map<String, dynamic>> _tahawwulatTiers = [
    {
      'name': '1 Bulan',
      'price': 1000000,
      'label': 'Rp 1.000.000',
      'period': '/ bulan',
      'planId': 'tahawwulat_1m',
      'applyUrl':
          'https://goakal.com/openturath-ai/ai-fikih-tahawwulat/1js2e/apply',
    },
    {
      'name': '6 Bulan',
      'price': 2995000,
      'label': 'Rp 2.995.000',
      'period': '/ 6 bulan',
      'planId': 'tahawwulat_6m',
      'applyUrl':
          'https://goakal.com/openturath-ai/ai-fikih-tahawwulat/sp6zh/apply',
    },
    {
      'name': '1 Tahun',
      'price': 4995000,
      'label': 'Rp 4.995.000',
      'period': '/ tahun',
      'planId': 'tahawwulat_1y',
      'applyUrl':
          'https://goakal.com/openturath-ai/ai-fikih-tahawwulat/8yt9m/apply',
    },
  ];

  Future<String?> _getOrPromptPhone() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    final phoneKey = 'openturath_${uid}_user_phone';
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(phoneKey) ?? '';
      if (RegExp(r'^\+?[0-9]{8,15}$').hasMatch(saved)) {
        return saved;
      }
    } catch (_) {}

    if (!mounted) return null;
    final textController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = OTColors.surface(isDark);
    final border = OTColors.border(isDark);
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);

    String? phone;
    try {
      phone = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: surface,
          shape: RoundedRectangleBorder(
            borderRadius: OTRadius.dialogBorder,
            side: BorderSide(color: border, width: 0.8),
          ),
          title: Text(
            ctx.tr('membership.whatsapp_number'),
            style: OTTypography.cardTitle(color: textPrimary)
                .copyWith(fontSize: 17),
          ),
          content: SingleChildScrollView(child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ctx.tr('membership.phone_explanation'),
                style: OTTypography.body(color: textSecondary)
                    .copyWith(fontSize: 13),
              ),
              const SizedBox(height: OTSpacing.base),
              TextField(
                controller: textController,
                keyboardType: TextInputType.phone,
                textDirection: TextDirection.ltr,
                autofocus: true,
                style: OTTypography.body(color: textPrimary),
                decoration: InputDecoration(
                  hintText: ctx.tr('membership.phone_hint'),
                  hintStyle: OTTypography.body(color: textSecondary),
                  prefixIcon: const Icon(Icons.phone_iphone_rounded, size: 20),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: OTRadius.inputBorder,
                    borderSide: BorderSide(color: border),
                  ),
                ),
              ),
            ],
          )),
          actions: [
            TextButton(
              onPressed: () {
                OTMotion.light();
                Navigator.pop(ctx, null);
              },
              child: Text(ctx.tr('membership.cancel'),
                  style: OTTypography.button(color: textSecondary)),
            ),
            FilledButton(
              onPressed: () {
                final val = textController.text.trim().replaceAll(RegExp(r'[\s()-]'), '');
                if (!RegExp(r'^\+?[0-9]{8,15}$').hasMatch(val)) {
                  AppSnackBar.warning(
                      ctx, ctx.tr('membership.invalid_phone'));
                  return;
                }
                Navigator.pop(ctx, val);
              },
              style: FilledButton.styleFrom(
                backgroundColor: textPrimary,
                foregroundColor: OTColors.surface(isDark),
                shape:
                    RoundedRectangleBorder(borderRadius: OTRadius.buttonBorder),
              ),
              child: Text(ctx.tr('membership.continue_payment'), style: OTTypography.button()),
            ),
          ],
        ),
      );
    } finally {
      textController.dispose();
    }

    if (phone != null && phone.isNotEmpty) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(phoneKey, phone);
      } catch (_) {}
    }
    return phone;
  }

  bool _requireAccount() {
    if (FirebaseAuth.instance.currentUser != null) return true;
    AppSnackBar.warning(context, context.tr('membership.login_purchase'));
    return false;
  }

  Future<void> _syncAkalPurchases() async {
    if (_isSyncingGoAkal || _isProcessing || !_requireAccount()) return;
    final uid = FirebaseAuth.instance.currentUser!.uid;
    setState(() => _isSyncingGoAkal = true);
    try {
      final result = await _subService.syncAkalPurchases();
      if (!mounted || FirebaseAuth.instance.currentUser?.uid != uid) return;
      if (result['success'] != true) {
        setState(() => _checkoutMessage = 'membership.sync_failed');
        return;
      }
      final fresh = await _authService.getFreshCurrentUserModel();
      if (!mounted || FirebaseAuth.instance.currentUser?.uid != uid) return;
      if (fresh == null) {
        setState(() => _checkoutMessage = 'membership.account_access_missing');
        return;
      }
      final active = _pendingAgentId != null && fresh.hasAccessToAgent(_pendingAgentId!);
      setState(() {
        _user = fresh;
        _checkoutMessage = active
            ? 'membership.access_updated'
            : 'membership.sync_email_guidance';
        if (active) _pendingGoAkal = false;
      });
    } catch (_) {
      if (mounted) setState(() => _checkoutMessage = 'membership.sync_connection_failed');
    } finally {
      if (mounted) setState(() => _isSyncingGoAkal = false);
    }
  }

  Future<void> _refreshAccess() async {
    if (_isProcessing || _isSyncingGoAkal || !_requireAccount()) return;
    setState(() => _isSyncingGoAkal = true);
    try {
      final fresh = await _authService.getFreshCurrentUserModel();
      if (!mounted) return;
      setState(() {
        _user = fresh;
        _checkoutMessage = fresh == null
            ? 'membership.access_missing_retry'
            : _pendingAgentId == null
                ? (fresh.hasAccess
                    ? 'membership.account_updated_directory'
                    : 'membership.account_no_access')
                : fresh.hasAccessToAgent(_pendingAgentId!)
                    ? 'membership.study_available'
                    : 'membership.access_pending';
      });
    } catch (_) {
      if (mounted) setState(() => _checkoutMessage = 'membership.access_connection_failed');
    } finally {
      if (mounted) setState(() => _isSyncingGoAkal = false);
    }
  }

  Future<void> _openGoAkal({required String url, required String title,
    required int amount, String? agentId}) async {
    if (_isProcessing || !_requireAccount()) return;
    setState(() { _isProcessing = true; _pendingAgentId = agentId; });
    try {
      final ownerUid = FirebaseAuth.instance.currentUser?.uid;
      await DokuCheckoutSheet.show(context, paymentUrl: url,
        invoiceNumber: '', planTitle: title, amount: amount);
      if (!mounted || FirebaseAuth.instance.currentUser?.uid != ownerUid) return;
      setState(() {
        _pendingGoAkal = true;
        _checkoutMessage = 'membership.goakal_closed';
      });
    } catch (_) {
      if (mounted) setState(() => _checkoutMessage = 'membership.payment_open_failed');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _showManualActivation(String title, String duration, String price) async {
    await showModalBottomSheet<void>(context: context, isScrollControlled: true,
      builder: (ctx) => SafeArea(child: SingleChildScrollView(child: Padding(padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(ctx.tr('membership.confirm_plan'), style: OTTypography.cardTitle()),
          const SizedBox(height: 12),
          Text(ctx.tr('membership.manual_summary', args: {'title': ctx.tr(title), 'duration': ctx.tr(duration), 'price': price})),
          const SizedBox(height: 12),
          Text(ctx.tr('membership.manual_explanation')),
          const SizedBox(height: 20),
          EditorialButton(label: ctx.tr('membership.contact_whatsapp'), onPressed: () async {
            final message = ctx.tr('membership.activation_message', args: {'title': ctx.tr(title), 'duration': ctx.tr(duration), 'price': price});
            final uri = Uri.https('wa.me', '/6281292979189', {'text': message});
            try {
              final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
              if (!opened && ctx.mounted) AppSnackBar.error(ctx, ctx.tr('membership.whatsapp_failed'));
            } catch (_) {
              if (ctx.mounted) AppSnackBar.error(ctx, ctx.tr('membership.whatsapp_retry'));
            }
          }),
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(ctx.tr('membership.back'))),
        ])))));
  }

  Future<void> _handleTierCheckout(Map<String, dynamic> tier, AgentModel agent) async {
    final url = tier['applyUrl'] as String? ?? '';
    if (url.isEmpty || url == GoAkalCatalogRegistry.storeUrl) {
      await _showManualActivation(agent.title, tier['name'] as String, tier['label'] as String);
      return;
    }
    await _openGoAkal(url: url, title: '${context.tr(agent.title)} · ${context.tr(tier['name'] as String)}',
      amount: tier['price'] as int, agentId: agent.id);
  }

  Future<void> _handleSubscribe(Map<String, dynamic> tier, AgentModel agent) async {
    if (_isProcessing || !_requireAccount()) return;
    final fbUser = FirebaseAuth.instance.currentUser!;
    // Claim the operation before prompting so repeated activation cannot create two invoices.
    setState(() => _isProcessing = true);
    try {
      final phone = await _getOrPromptPhone();
      if (phone == null || phone.isEmpty || !mounted) return;
      if (FirebaseAuth.instance.currentUser?.uid != fbUser.uid) return;
      final title = '${context.tr(agent.title)} · ${context.tr(tier['name'] as String)}';
      final result = await _subService.createPayment(
        uid: fbUser.uid, agentId: agent.id, plan: tier['planId'] as String,
        planTitle: title, amount: tier['price'] as int,
        name: fbUser.displayName ?? _user?.name ?? context.tr('membership.user'),
        email: fbUser.email ?? '', phone: phone).timeout(const Duration(seconds: 20));
      if (!mounted || FirebaseAuth.instance.currentUser?.uid != fbUser.uid) return;
      final url = result['redirectUrl'] as String? ?? '';
      final invoice = result['invoiceNumber'] as String? ?? '';
      if (url.isEmpty || invoice.trim().isEmpty) throw StateError('Incomplete checkout session');
      _pendingAgentId = agent.id;
      _pendingGoAkal = false;
      final paid = await DokuCheckoutSheet.show(context, paymentUrl: url,
        invoiceNumber: invoice, trxId: result['trxId'] as String?,
        planTitle: title, amount: tier['price'] as int);
      if (!mounted || FirebaseAuth.instance.currentUser?.uid != fbUser.uid) return;
      // Payment confirmation is independent of the server entitlement snapshot.
      try {
        final fresh = await _authService.getFreshCurrentUserModel();
        if (!mounted || FirebaseAuth.instance.currentUser?.uid != fbUser.uid) return;
        final active = fresh?.hasAccessToAgent(agent.id) ?? false;
        setState(() {
          _user = fresh;
          _checkoutMessage = paid == true
              ? (active ? 'membership.payment_access_confirmed'
                  : 'membership.payment_access_pending')
              : (active ? 'membership.access_payment_pending'
                  : 'membership.payment_access_unconfirmed');
        });
      } catch (_) {
        if (mounted) setState(() => _checkoutMessage = paid == true
            ? 'membership.payment_verified_check_access'
            : 'membership.payment_access_check_again');
      }
    } catch (_) {
      if (mounted) setState(() => _checkoutMessage = 'membership.checkout_prepare_failed');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  String _durationLabel(String label) => label.replaceAll(RegExp(r'\s*\([^)]*\)'), '').trim();

  Widget _duration(List<String> names, int selected, ValueChanged<int> changed) {
    return DropdownButtonFormField<int>(
      key: ValueKey('${names.join('|')}:$selected'),
      initialValue: selected, isExpanded: true,
      decoration: InputDecoration(labelText: context.tr('membership.access_period')),
      items: [for (var i = 0; i < names.length; i++)
        DropdownMenuItem(value: i, child: Text(context.tr(_durationLabel(names[i]))))],
      onChanged: _isProcessing ? null : (value) { if (value != null) changed(value); },
    );
  }

  Widget _agentPlan(AgentModel agent, {bool doku = false}) {
    final tiers = doku ? _tahawwulatTiers : GoAkalCatalogRegistry.getTiersForAgent(agent.id);
    if (tiers.isEmpty) return EditorialEmptyState(title: context.tr('membership.plan_unavailable', args: {'title': context.tr(agent.title)}));
    final stored = _agentDurationIndices[agent.id] ?? 0;
    final index = stored < tiers.length ? stored : 0;
    final tier = tiers[index];
    return EditorialCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(context.tr(agent.title), style: OTTypography.corpusTitle().copyWith(fontSize: 26)),
      const SizedBox(height: 8),
      Text(doku ? context.tr('membership.five_roles') : context.tr('membership.selected_access')),
      const SizedBox(height: 20),
      _duration(tiers.map((t) => t['name'] as String).toList(), index,
        (value) => setState(() => _agentDurationIndices[agent.id] = value)),
      const SizedBox(height: 20),
      Text(context.tr('membership.total', args: {'price': tier['label']}), style: OTTypography.price().copyWith(fontSize: 30)),
      Text(context.tr('membership.period_access', args: {'duration': context.tr(_durationLabel(tier['name'] as String))})),
      const SizedBox(height: 20),
      Wrap(spacing: 12, runSpacing: 12, children: [
        EditorialButton(label: context.tr('membership.goakal_continue'), icon: Icons.arrow_forward_rounded,
          onPressed: _isProcessing ? null : () => _handleTierCheckout(tier, agent)),
        if (doku) EditorialButton(label: context.tr('membership.doku_pay'), secondary: true,
          onPressed: _isProcessing ? null : () => _handleSubscribe(tier, agent)),
      ]),
    ]));
  }

  Widget _bundlePlan(ThematicBundleMeta bundle) {
    final tiers = bundle.tiers;
    if (tiers.isEmpty) return const SizedBox.shrink();
    final stored = _bundleDurationIndices[bundle.slug] ?? 0;
    final index = stored < tiers.length ? stored : 0;
    final tier = tiers[index];
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Text(context.tr(bundle.title), style: OTTypography.bookTitle()),
      subtitle: Text(context.tr('membership.bundle_summary', args: {'subtitle': context.tr(bundle.subtitle), 'price': tier.priceLabel, 'duration': context.tr(tier.title)})),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      childrenPadding: const EdgeInsets.only(top: 12, bottom: 24),
      children: [
        Text(context.tr('membership.plan_scope')),
        const SizedBox(height: 8),
        for (final item in bundle.includedItems.where((item) =>
            !item.contains('Komputasi Optimal') && !item.contains('Pembaruan Korpus') && !item.contains('Layanan Khadim')))
          Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(context.tr(item.replaceAll('Super AI ', '')))),
        const SizedBox(height: 16),
        _duration(tiers.map((t) => t.title).toList(), index,
          (value) => setState(() => _bundleDurationIndices[bundle.slug] = value)),
        const SizedBox(height: 16),
        Text(context.tr('membership.total', args: {'price': tier.priceLabel}), style: OTTypography.price().copyWith(fontSize: 28)),
        Text(context.tr('membership.period_access', args: {'duration': context.tr(tier.title)})),
        const SizedBox(height: 16),
        EditorialButton(label: tier.isLiveOnGoAkal ? context.tr('membership.goakal_continue') : context.tr('membership.ask_availability'),
          icon: Icons.arrow_forward_rounded, onPressed: _isProcessing ? null : () async {
            if (tier.isLiveOnGoAkal) {
              await _openGoAkal(url: tier.applyUrl, title: '${context.tr(bundle.title)} · ${context.tr(tier.title)}', amount: tier.amount);
            } else { await _showManualActivation(bundle.title, tier.title, tier.priceLabel); }
          }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final busy = _isProcessing || _isSyncingGoAkal;
    final others = _otherAgents;
    return EditorialPage(title: context.tr('membership.title'), eyebrow: context.tr('membership.eyebrow'),
      subtitle: context.tr('membership.subtitle'),
      showBack: true, maxWidth: 820,
      children: [
        if (FirebaseAuth.instance.currentUser == null) ...[
          EditorialButton(label: context.tr('membership.login_subscribe'), onPressed: () => Navigator.pushNamed(context, AppRoutes.login)),
          const SizedBox(height: 24),
        ] else ...[
          Text(_user?.email ?? FirebaseAuth.instance.currentUser?.email ?? '', textDirection: TextDirection.ltr),
          const SizedBox(height: 16),
        ],
        Wrap(spacing: 12, runSpacing: 8, children: [
          EditorialButton(label: context.tr('membership.sync_goakal'), secondary: true, busy: _isSyncingGoAkal,
            icon: Icons.sync, onPressed: busy ? null : _syncAkalPurchases),
          EditorialButton(label: context.tr('membership.redeem_access'), secondary: true, onPressed: busy ? null : () async {
            var redeemed = false;
            await RedeemCodeSheet.show(context, onSuccess: () => redeemed = true);
            if (mounted && redeemed) await _refreshAccess();
          }),
        ]),
        if (_checkoutMessage != null) ...[
          const SizedBox(height: 20),
          EditorialCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(context.tr(_checkoutMessage!)),
            const SizedBox(height: 12),
            EditorialButton(label: _pendingGoAkal ? context.tr('membership.sync_goakal') : context.tr('membership.check_access'),
              secondary: true, onPressed: busy ? null : (_pendingGoAkal ? _syncAkalPurchases : _refreshAccess)),
          ])),
        ],
        if (_isProcessing) const Padding(padding: EdgeInsets.only(top: 16), child: LinearProgressIndicator()),
        const SizedBox(height: 32),
        DropdownButtonFormField<int>(initialValue: _selectedSegment, isExpanded: true,
          decoration: InputDecoration(labelText: context.tr('membership.membership_scope')),
          items: [DropdownMenuItem(value: 0, child: Text(context.tr('membership.thematic'))),
            DropdownMenuItem(value: 1, child: Text(context.tr('membership.one_discipline')))],
          onChanged: busy ? null : (value) { if (value != null) setState(() => _selectedSegment = value); }),
        const SizedBox(height: 24),
        if (_selectedSegment == 0)
          for (final bundle in GoAkalCatalogRegistry.thematicBundles) _bundlePlan(bundle)
        else ...[
          _agentPlan(_tahawwulatAgent, doku: true),
          if (others.isNotEmpty) ...[
            const SizedBox(height: 32),
            EditorialSection(title: context.tr('membership.other_disciplines'), child: DropdownButtonFormField<String>(
              initialValue: _selectedOtherAgent?.id ?? others.first.id, isExpanded: true,
              decoration: InputDecoration(labelText: context.tr('membership.choose_discipline')),
              items: [for (final agent in others) DropdownMenuItem(value: agent.id, child: Text(context.tr(agent.title)))],
              onChanged: busy ? null : (value) => setState(() => _selectedOtherAgent = others.firstWhere((a) => a.id == value)))),
            const SizedBox(height: 16),
            _agentPlan(_selectedOtherAgent ?? others.first),
          ],
        ],
        const SizedBox(height: 32),
        Text(context.tr('membership.manual_renewal')),
        const SizedBox(height: 12),
        Text(context.tr('membership.price_explanation')),
      ]);
  }
}
