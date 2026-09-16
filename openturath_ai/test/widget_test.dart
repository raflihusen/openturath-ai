import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/arabic_utils.dart';
import 'package:openturath_ai/core/constants.dart';
import 'package:openturath_ai/core/localization.dart';
import 'package:openturath_ai/models/agent_model.dart';
import 'package:openturath_ai/models/user_model.dart';
import 'package:openturath_ai/services/research_notes_service.dart';

void main() {
  group('UserModel & ModuleEntitlement Unit Tests', () {
    test('User trial without active voucher entitlement has no access', () {
      final user = UserModel(
        uid: 'test_uid_1',
        name: 'Peneliti Turats',
        email: 'peneliti@openturath.id',
        photoUrl: '',
        plan: AppConstants.planTrial,
        questionsUsed: 4,
      );

      expect(user.isTrial, isTrue);
      expect(user.isPremium, isFalse);
      expect(user.questionsRemaining, equals(0));
      expect(user.isTrialExhausted, isFalse);
      expect(user.hasAccess, isFalse);
    });

    test('User with active voucher trial entitlement has access and questions', () {
      final user = UserModel(
        uid: 'test_uid_trial',
        name: 'Peneliti Turats',
        email: 'peneliti@openturath.id',
        photoUrl: '',
        plan: AppConstants.planTrial,
        questionsUsed: 4,
        entitlements: {
          'all_access': ModuleEntitlement(
            plan: 'trial',
            expiry: DateTime.now().add(const Duration(days: 7)),
            status: 'active',
          ),
        },
      );

      expect(user.isTrial, isTrue);
      expect(user.hasAccess, isTrue);
      expect(user.questionsRemaining, equals(9999));
    });

    test('User trial is denied when voucher entitlement is expired', () {
      final user = UserModel(
        uid: 'test_uid_2',
        name: 'Peneliti Turats',
        email: 'peneliti@openturath.id',
        photoUrl: '',
        plan: AppConstants.planTrial,
        questionsUsed: 10,
        entitlements: {
          'all_access': ModuleEntitlement(
            plan: 'trial',
            expiry: DateTime.now().subtract(const Duration(days: 1)),
            status: 'expired',
          ),
        },
      );

      expect(user.questionsRemaining, equals(0));
      expect(user.hasAccess, isFalse);
    });

    test('Modular entitlement gives exclusive access to entitled module only', () {
      final futureExpiry = DateTime.now().add(const Duration(days: 30));
      final userWithTahawwulatOnly = UserModel(
        uid: 'test_uid_3',
        name: 'Tholib Ilmu',
        email: 'tholib@openturath.id',
        photoUrl: '',
        plan: AppConstants.planTrial,
        questionsUsed: 10, // trial habis
        entitlements: {
          'fiqh_tahawwulat': ModuleEntitlement(
            plan: AppConstants.planTholib1m,
            expiry: futureExpiry,
            status: 'active',
          ),
        },
      );

      // Harusnya bisa akses Fikih Tahawwulat dan sub-agennya
      expect(userWithTahawwulatOnly.hasAccessToAgent('fiqh_tahawwulat'), isTrue);
      expect(userWithTahawwulatOnly.hasAccessToAgent('fiqh_tahawwulat_muhaqqiq'), isTrue);
      expect(userWithTahawwulatOnly.hasAccessToAgent('fiqh_tahawwulat_bayan'), isTrue);
      expect(userWithTahawwulatOnly.hasAccessToAgent('fiqh_tahawwulat_khatib'), isTrue);

      // Tapi TIDAK BISA akses Fikih Syafi'i karena trial habis dan modul tidak dibeli
      expect(userWithTahawwulatOnly.hasAccessToAgent('fiqh_syafii'), isFalse);
      expect(userWithTahawwulatOnly.hasAccessToAgent('hadits'), isFalse);
    });

    test('Expired module entitlement correctly denies premium access', () {
      final pastExpiry = DateTime.now().subtract(const Duration(days: 1));
      final userExpired = UserModel(
        uid: 'test_uid_4',
        name: 'User Expired',
        email: 'expired@openturath.id',
        photoUrl: '',
        plan: AppConstants.planTrial,
        questionsUsed: 10,
        entitlements: {
          'fiqh_tahawwulat': ModuleEntitlement(
            plan: AppConstants.planTholib1m,
            expiry: pastExpiry,
            status: 'active',
          ),
        },
      );

      expect(userExpired.isAgentSubscriptionActive('fiqh_tahawwulat'), isFalse);
      expect(userExpired.hasAccessToAgent('fiqh_tahawwulat_khatib'), isFalse);
    });
  });

  group('AgentModel Catalog Tests', () {
    test('Default catalog contains core modules with complete metadata', () {
      final agents = AgentModel.defaultAgents;
      expect(agents.isNotEmpty, isTrue);

      final tahawwulat = agents.firstWhere((a) => a.id == 'fiqh_tahawwulat');
      expect(tahawwulat.title, contains('Tahawwulat'));
      expect(tahawwulat.subAgents?.length, equals(5));
      expect(tahawwulat.referenceBooks?.isNotEmpty, isTrue);
    });
  });

  group('ResearchNote & Citation Generator Tests', () {
    test('ResearchNote formats citation correctly with book, volume, and page', () {
      final note = ResearchNote(
        id: 'note_123',
        agentId: 'fiqh_tahawwulat',
        agentTitle: 'Fiqh Tahawwulat AI',
        title: 'Konsep Sunnah Mawaqif',
        excerpt: 'Sunnah mawaqif adalah ketetapan sikap kenabian dalam menghadapi perubahan zaman.',
        bookTitle: 'Al-Bayan',
        bookVolume: '1',
        bookPage: '45',
        createdAt: DateTime.now(),
      );

      final citation = note.citationFormatted;
      expect(citation, contains('Sunnah mawaqif'));
      expect(citation, contains('OpenTurath AI (Fiqh Tahawwulat AI)'));
      expect(citation, contains('Kitab Al-Bayan Juz 1 Hal 45'));
    });
  });

  group('ArabicUtils Smart Arabic Search Tests', () {
    test('ArabicUtils.normalize strips harakat and unifies letter forms', () {
      const textWithHarakat = 'فِقْهُ التَّحَوُّلَاتِ';
      final normalized = ArabicUtils.normalize(textWithHarakat);
      expect(normalized, equals('فقه التحولات'));
    });

    test('ArabicUtils.matches matches plain query with harakat text', () {
      const sourceArabic = 'فِقْهُ التَّحَوُّلَاتِ وَسُنَّةُ الْمَوَاقِفِ';
      
      // Pencarian tanpa harakat
      expect(ArabicUtils.matches(sourceArabic, 'فقه'), isTrue);
      expect(ArabicUtils.matches(sourceArabic, 'التحولات'), isTrue);
      expect(ArabicUtils.matches(sourceArabic, 'سنة'), isTrue);
      expect(ArabicUtils.matches(sourceArabic, 'المواقف'), isTrue);

      // Pencarian kata yang tidak ada
      expect(ArabicUtils.matches(sourceArabic, 'نحو'), isFalse);
    });

    test('ArabicUtils.matches supports Latin search in bilingual metadata', () {
      const sourceLatin = 'Fiqh Tahawwulat & Al-Manhaji';
      expect(ArabicUtils.matches(sourceLatin, 'tahawwulat'), isTrue);
      expect(ArabicUtils.matches(sourceLatin, 'manhaji'), isTrue);
      expect(ArabicUtils.matches(sourceLatin, 'hadits'), isFalse);
    });
  });

  group('Localization & AppConfig Tests', () {
    test('Localization dictionary returns valid strings for all supported languages', () {
      expect(Loc.tr('app_name'), equals('OpenTurath AI'));
      expect(Loc.tr('choose_plan'), isNotEmpty);
      expect(Loc.tr('save'), isNotEmpty);
    });
  });
}
