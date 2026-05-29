import 'validator_rule.dart';
import 'rules/required_validator.dart';
import 'rules/min_length_validator.dart';
import 'rules/max_length_validator.dart';
import 'rules/email_validator.dart';
import 'rules/pattern_validator.dart';
import 'rules/range_validator.dart';
import 'rules/min_validator.dart';
import 'rules/max_validator.dart';
import 'rules/equals_validator.dart';
import 'rules/custom_validator.dart';

/// Static factory for all built-in validators.
///
/// Her method opsiyonel [message] parametresi alır (i18n):
/// ```dart
/// Validators.required(message: t.validation.required)
/// Validators.email(message: t.validation.email)
/// ```
abstract final class Validators {
  /// Value must not be null, empty string, or empty iterable.
  static Validator<T> required<T>({String? message}) =>
      RequiredValidator<T>(message);

  /// String must have at least [length] characters.
  static Validator<String> minLength(int length, {String? message}) =>
      MinLengthValidator(length, message);

  /// String must have at most [length] characters.
  static Validator<String> maxLength(int length, {String? message}) =>
      MaxLengthValidator(length, message);

  /// Must be a valid email address.
  static Validator<String> email({String? message}) => EmailValidator(message);

  /// String must match the given regex [pattern].
  static Validator<String> pattern(String pattern, {String? message}) =>
      PatternValidator(pattern, message);

  /// Number must be between [min] and [max] (inclusive).
  static Validator<num> range(num min, num max, {String? message}) =>
      RangeValidator(min, max, message);

  /// Number must be at least [value].
  static Validator<num> min(num value, {String? message}) =>
      MinValidator(value, message);

  /// Number must be at most [value].
  static Validator<num> max(num value, {String? message}) =>
      MaxValidator(value, message);

  /// Value must equal the result of [compareValue] at call time.
  static Validator<T> equals<T>(T Function() compareValue,
          {String? message}) =>
      EqualsValidator<T>(compareValue, message);

  /// Custom validation with a lambda.
  static Validator<T> custom<T>(String? Function(T? value) validate) =>
      CustomValidator<T>(validate);
}
