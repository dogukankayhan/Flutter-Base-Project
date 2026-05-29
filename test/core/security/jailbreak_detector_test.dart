import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_base_kit/core/security/jailbreak_detector.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('JailbreakDetector', () {
    const platform = MethodChannel('com.example.app/security');

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(platform, null);
    });

    test('returns true when device is jailbroken', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(platform, (MethodCall methodCall) async {
        if (methodCall.method == 'isJailbroken') {
          return true;
        }
        return null;
      });

      final result = await JailbreakDetector.isDeviceCompromised();
      expect(result, isTrue);
    });

    test('returns false when device is not jailbroken', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(platform, (MethodCall methodCall) async {
        if (methodCall.method == 'isJailbroken') {
          return false;
        }
        return null;
      });

      final result = await JailbreakDetector.isDeviceCompromised();
      expect(result, isFalse);
    });

    test('returns false when platform method throws exception', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(platform, (MethodCall methodCall) async {
        throw PlatformException(code: 'ERROR', message: 'Test error');
      });

      final result = await JailbreakDetector.isDeviceCompromised();
      expect(result, isFalse);
    });
  });
}
