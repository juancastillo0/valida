import 'package:valida/serde_type.dart';
import 'package:valida/validate/validate.dart';

/// Different IP versions
enum IPVersion {
  v4,
  v6,
}

/// Different UUID versions
enum UUIDVersion {
  v3,
  v4,
  v5,
  all,
}

/// Different ISBN versions
enum ISBNVersion { v10, v13 }

/// Specification of the validation that should be
/// executed over a given String
class ValidaString extends ValidaField<String> implements ValidaLength {
  /// Should be within this array
  final List<String>? isIn; // enum

  @override
  final int? minLength;
  @override
  final int? maxLength;

  /// Should be a phone number
  final bool? isPhone;

  /// Should be an email
  final bool? isEmail;

  /// Should be a date
  final bool? isDate;

  /// Should be a time
  final bool? isTime;

  /// Should be a "true" or "false"
  final bool? isBool;

  /// Should be numeric
  final bool? isNum;

  /// Should be an url
  final bool? isUrl;

  /// Should be an uuid of the specific version
  final UUIDVersion? isUUID;

  /// Should be a currency
  final bool? isCurrency;

  /// Should be json parsable
  final bool? isJSON;

  /// Should match the regular expression
  final String? matches;

  /// Should contain the String
  final String? contains;

  /// Should be a letter
  final bool? isAlpha;

  /// Should be a letter or a number
  final bool? isAlphanumeric;

  // isVariableWidth, isHalfWidth, isFullWidth, isSurrogatePair,
  // isPostalCode, isMultibyte,

  /// Should be ASCII
  final bool? isAscii;

  /// Should be Base64 encoded
  final bool? isBase64;

  /// Should be a credit card
  final bool? isCreditCard;

  /// Should be a FQDN
  final bool? isFQDN;

  /// Should be hexadecimal
  final bool? isHexadecimal;

  /// Should be a hex color
  final bool? isHexColor;

  /// Should be an integer
  final bool? isInt;

  /// Should be a floating point number
  final bool? isFloat;

  /// Should be a ISBN of the specific version
  final ISBNVersion? isISBN;

  /// Should be an IP
  final IPVersion? isIP;

  /// Should be a number divisible by this one
  final int? isDivisibleBy;
  final int? surrogatePairsLengthMin;
  final int? surrogatePairsLengthMax;

  /// Should be lowercase
  final bool? isLowercase;

  /// Should be uppercase
  final bool? isUppercase;

  @override
  ValidaFieldType get variantType => ValidaFieldType.string;

  @override
  final List<ValidaError> Function(String)? customValidate;
  @override
  final String? customValidateName;

  /// Specification of the validation that should be
  /// executed over a given string
  const ValidaString({
    this.isIn,
    this.maxLength,
    this.minLength,
    this.isPhone,
    this.isEmail,
    this.isDate,
    this.isTime,
    this.isBool,
    this.isNum,
    this.isUrl,
    this.isUUID,
    this.isCurrency,
    this.isJSON,
    this.matches,
    this.contains,
    this.isAlpha,
    this.isAlphanumeric,
    this.isLowercase,
    this.isUppercase,
    //
    this.isAscii,
    this.isBase64,
    this.isCreditCard,
    this.isDivisibleBy,
    this.surrogatePairsLengthMin,
    this.surrogatePairsLengthMax,
    this.isFQDN,
    this.isHexadecimal,
    this.isHexColor,
    this.isInt,
    this.isFloat,
    this.isISBN,
    this.isIP,
    //
    this.customValidate,
    this.customValidateName,
  });

  @override
  Map<String, Object?> toJson() {
    return {
      ValidaField.variantTypeString: variantType.toString(),
      'isIn': isIn,
      'maxLength': maxLength,
      'minLength': minLength,
      'isPhone': isPhone,
      'isEmail': isEmail,
      'isDate': isDate,
      'isTime': isTime,
      'isBool': isBool,
      'isNum': isNum,
      'isUrl': isUrl,
      'isUUID': _toEnumString(isUUID),
      'isCurrency': isCurrency,
      'isJSON': isJSON,
      'matches': matches,
      'contains': contains,
      'isAlpha': isAlpha,
      'isAlphanumeric': isAlphanumeric,
      'isLowercase': isLowercase,
      'isUppercase': isUppercase,
      'customValidate': customValidateName,
      'isAscii': isAscii,
      'isBase64': isBase64,
      'isCreditCard': isCreditCard,
      'isFQDN': isFQDN,
      'isHexadecimal': isHexadecimal,
      'isHexColor': isHexColor,
      'isDivisibleBy': isDivisibleBy,
      'surrogatePairsLengthMin': surrogatePairsLengthMin,
      'surrogatePairsLengthMax': surrogatePairsLengthMax,
      'isInt': isInt,
      'isFloat': isFloat,
      'isISBN': _toEnumString(isISBN),
      'isIP': _toEnumString(isIP),
    }..removeWhere((key, value) => value == null);
  }

  factory ValidaString.fromJson(Map<String, Object?> map) {
    return ValidaString(
      isIn:
          map['isIn'] == null ? null : List<String>.from(map['isIn']! as List),
      maxLength: map['maxLength'] as int?,
      minLength: map['minLength'] as int?,
      isPhone: map['isPhone'] as bool?,
      isEmail: map['isEmail'] as bool?,
      isDate: map['isDate'] as bool?,
      isTime: map['isTime'] as bool?,
      isBool: map['isBool'] as bool?,
      isNum: map['isNum'] as bool?,
      isUrl: map['isUrl'] as bool?,
      isUUID: map['isUUID'] is UUIDVersion
          ? map['isUUID']! as UUIDVersion
          : _parseEnum(map['isUUID'] as String?, UUIDVersion.values),
      isCurrency: map['isCurrency'] as bool?,
      isJSON: map['isJSON'] as bool?,
      matches: map['matches'] as String?,
      contains: map['contains'] as String?,
      isAlpha: map['isAlpha'] as bool?,
      isAlphanumeric: map['isAlphanumeric'] as bool?,
      isLowercase: map['isLowercase'] as bool?,
      isUppercase: map['isUppercase'] as bool?,
      customValidateName: map['customValidate'] as String?,
      isAscii: map['isAscii'] as bool?,
      isBase64: map['isBase64'] as bool?,
      isCreditCard: map['isCreditCard'] as bool?,
      isFQDN: map['isFQDN'] as bool?,
      isHexadecimal: map['isHexadecimal'] as bool?,
      isHexColor: map['isHexColor'] as bool?,
      isDivisibleBy: map['isDivisibleBy'] as int?,
      surrogatePairsLengthMin: map['surrogatePairsLengthMin'] as int?,
      surrogatePairsLengthMax: map['surrogatePairsLengthMax'] as int?,
      isInt: map['isInt'] as bool?,
      isFloat: map['isFloat'] as bool?,
      isISBN: map['isISBN'] is ISBNVersion
          ? map['isISBN']! as ISBNVersion
          : _parseEnum(map['isISBN'] as String?, ISBNVersion.values),
      isIP: map['isIP'] is IPVersion
          ? map['isIP']! as IPVersion
          : _parseEnum(map['isIP'] as String?, IPVersion.values),
    );
  }

  static const fieldsSerde = {
    'isIn': SerdeType.list(SerdeType.str),
    'maxLength': SerdeType.int,
    'minLength': SerdeType.int,
    'isPhone': SerdeType.bool,
    'isEmail': SerdeType.bool,
    'isDate': SerdeType.bool,
    'isTime': SerdeType.bool,
    'isBool': SerdeType.bool,
    'isNum': SerdeType.bool,
    'isUrl': SerdeType.bool,
    'isUUID': SerdeType.enumV(UUIDVersion.values),
    'isCurrency': SerdeType.bool,
    'isJSON': SerdeType.bool,
    'matches': SerdeType.str,
    'contains': SerdeType.str,
    'isAlpha': SerdeType.bool,
    'isAlphanumeric': SerdeType.bool,
    'isLowercase': SerdeType.bool,
    'isUppercase': SerdeType.bool,
    'customValidate': SerdeType.function,
    'isAscii': SerdeType.bool,
    'isBase64': SerdeType.bool,
    'isCreditCard': SerdeType.bool,
    'isFQDN': SerdeType.bool,
    'isHexadecimal': SerdeType.bool,
    'isHexColor': SerdeType.bool,
    'isDivisibleBy': SerdeType.int,
    'surrogatePairsLengthMin': SerdeType.int,
    'surrogatePairsLengthMax': SerdeType.int,
    'isInt': SerdeType.bool,
    'isFloat': SerdeType.bool,
    'isISBN': SerdeType.enumV(ISBNVersion.values),
    'isIP': SerdeType.enumV(IPVersion.values),
  };
}

T? _parseEnum<T>(String? raw, List<T> enumValues) {
  if (raw == null) {
    return null;
  }
  for (final value in enumValues) {
    final str = value.toString();
    if (raw == str || raw == str.split('.')[1]) {
      return value;
    }
  }
  throw Error();
}

String? _toEnumString(Object? value) {
  return value == null ? null : value.toString().split('.')[1];
}
