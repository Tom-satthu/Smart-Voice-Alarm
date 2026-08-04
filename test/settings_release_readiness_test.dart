import 'package:flutter_test/flutter_test.dart';
import 'package:smart_voice_alarm/core/constants/app_constants.dart';
import 'package:smart_voice_alarm/core/config/release_config.dart';
import 'package:smart_voice_alarm/core/services/support_contact.dart';

void main() {
  group('AppConstants release readiness', () {
    test('support email is the official inbox', () {
      expect(AppConstants.supportEmail, 'timeforwork789@gmail.com');
    });

    test('Android public developer name is Unicode-correct', () {
      expect(AppConstants.developerName, 'Nguyên Đức');
      expect(AppConstants.developerName.contains('Nguyên'), isTrue);
      expect(AppConstants.developerName.contains('Đức'), isTrue);
    });

    test('uses live legal URLs and no placeholder store URLs', () {
      expect(AppConstants.privacyPolicyUrl, startsWith('https://'));
      expect(AppConstants.termsOfUseUrl, startsWith('https://'));
      expect(AppConstants.websiteUrl, startsWith('https://'));
      expect(AppConstants.playStoreUrl, isEmpty);
      expect(AppConstants.appStoreUrl, isEmpty);
      expect(AppConstants.appStoreId, isEmpty);
      expect(AppConstants.hasPrivacyPolicyUrl, isTrue);
      expect(AppConstants.hasTermsOfUseUrl, isTrue);
      expect(AppConstants.hasWebsiteUrl, isTrue);
      expect(AppConstants.hasPlayStoreUrl, isFalse);
      expect(AppConstants.hasAppStoreUrl, isFalse);

      for (final url in [AppConstants.playStoreUrl, AppConstants.appStoreUrl]) {
        expect(url.contains('example.com'), isFalse);
        expect(url.contains('tom-satthu.github.io'), isFalse);
      }
    });

    test('release uses the app-managed trial and annual subscription', () {
      expect(
        ReleaseConfig.monetizationMode,
        MonetizationMode.trialWithAnnualSubscription,
      );
      expect(ReleaseConfig.showPremium, isTrue);
      expect(ReleaseConfig.initializeBilling, isTrue);
      expect(AppConstants.premiumSubscriptionId, 'premium_annual');
      expect(AppConstants.premiumAnnualBasePlanId, 'annual-auto');
    });
  });

  group('SupportContact mailto', () {
    test('builds mailto with support email and diagnostics only', () {
      final uri = SupportContact.mailtoUri(
        subject: 'Smart Voice Alarm Support',
        appVersion: '1.0.0',
        buildNumber: '1',
        platformLabel: 'android',
        osVersion: '14',
        deviceModel: 'SM-G975F',
      );

      expect(uri.scheme, 'mailto');
      expect(uri.path, AppConstants.supportEmail);
      final query = uri.query;
      expect(query.contains('Smart%20Voice%20Alarm%20Support'), isTrue);
      expect(query.contains('App%20version%3A%201.0.0%20(1)'), isTrue);
      expect(query.contains('Platform%3A%20android'), isTrue);
      expect(query.contains('OS%3A%2014'), isTrue);
      expect(query.contains('Device%3A%20SM-G975F'), isTrue);
      expect(query.toLowerCase().contains('alarm label'), isFalse);
      expect(query.toLowerCase().contains('device identifier'), isFalse);
    });

    test('omits optional device fields when absent', () {
      final uri = SupportContact.mailtoUri(
        appVersion: '2.0.0',
        buildNumber: '9',
        platformLabel: 'iOS',
      );
      expect(uri.query.contains('Device%3A'), isFalse);
      expect(uri.query.contains('OS%3A'), isFalse);
      expect(uri.query.contains('Platform%3A%20iOS'), isTrue);
    });
  });
}
