import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_base_kit/core/security/jailbreak_detector.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Jailbreak Detection - iOS & Android', () {
    const platform = MethodChannel('com.base.project/security');

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(platform, null);
    });

    test('iOS: Returns true when device is jailbroken', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(platform, (MethodCall methodCall) async {
        if (methodCall.method == 'isJailbroken') {
          return true; // Simulate jailbroken iOS device
        }
        return null;
      });

      final result = await JailbreakDetector.isDeviceCompromised();
      expect(result, isTrue);
    });

    test('Android: Returns true when device is rooted', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(platform, (MethodCall methodCall) async {
        if (methodCall.method == 'isJailbroken') {
          return true; // Simulate rooted Android device
        }
        return null;
      });

      final result = await JailbreakDetector.isDeviceCompromised();
      expect(result, isTrue);
    });

    test('iOS: Returns false when device is not jailbroken', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(platform, (MethodCall methodCall) async {
        if (methodCall.method == 'isJailbroken') {
          return false; // Device is secure
        }
        return null;
      });

      final result = await JailbreakDetector.isDeviceCompromised();
      expect(result, isFalse);
    });

    test('Android: Returns false when device is not rooted', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(platform, (MethodCall methodCall) async {
        if (methodCall.method == 'isJailbroken') {
          return false; // Device is secure
        }
        return null;
      });

      final result = await JailbreakDetector.isDeviceCompromised();
      expect(result, isFalse);
    });

    test('iOS: Handles null response gracefully', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(platform, (MethodCall methodCall) async {
        if (methodCall.method == 'isJailbroken') {
          return null;
        }
        return null;
      });

      final result = await JailbreakDetector.isDeviceCompromised();
      expect(result, isFalse);
    });

    test('Android + iOS: Returns false on platform exception', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(platform, (MethodCall methodCall) async {
        throw PlatformException(code: 'ERROR', message: 'Platform error');
      });

      final result = await JailbreakDetector.isDeviceCompromised();
      expect(result, isFalse);
    });

    test('Android + iOS: Handles MissingPluginException gracefully',
        () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(platform, (MethodCall methodCall) async {
        throw MissingPluginException();
      });

      final result = await JailbreakDetector.isDeviceCompromised();
      expect(result, isFalse);
    });
  });
}
