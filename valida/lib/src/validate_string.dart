import 'package:valida/serde_type.dart';
import 'package:valida/src/utils.dart';
import 'package:valida/src/validate.dart';
import 'package:validators/validators.dart' as validators;

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
class ValidaString extends ValidaField<String> with ValidaLength {
  /// Should be within this array
  final List<String>? isIn;

  @override
  final int? minLength;
  @override
  final int? maxLength;

  /// Should be a phone number
  // final bool? isPhone;

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

  /// The minimum length of surrogate pairs in the String
  final int? surrogatePairsLengthMin;

  /// The maximum length of surrogate pairs in the String
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
  @override
  final String? description;

  /// Specification of the validation that should be
  /// executed over a given string
  const ValidaString({
    this.isIn,
    this.maxLength,
    this.minLength,
    // this.isPhone,
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
    this.description,
  });

  @override
  Map<String, Object?> toJson() {
    return {
      ValidaField.variantTypeString: variantType.name,
      'isIn': isIn,
      'maxLength': maxLength,
      'minLength': minLength,
      // 'isPhone': isPhone,
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
      'description': description,
    }..removeWhere((key, value) => value == null);
  }

  factory ValidaString.fromJson(Map<String, Object?> map) {
    return ValidaString(
      isIn:
          map['isIn'] == null ? null : List<String>.from(map['isIn']! as List),
      maxLength: map['maxLength'] as int?,
      minLength: map['minLength'] as int?,
      // isPhone: map['isPhone'] as bool?,
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
      description: map['description'] as String?,
    );
  }

  static const fieldsSerde = {
    'isIn': SerdeType.list(SerdeType.str),
    'maxLength': SerdeType.int,
    'minLength': SerdeType.int,
    // 'isPhone': SerdeType.bool,
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
    'description': SerdeType.str,
  };

  @override
  List<ValidaError> validate(
    String property,
    Object? Function(String property) getter,
  ) {
    final List<ValidaError> errors = [];
    final value = getter(property) as String?;
    if (value == null) return errors;

    final _addError = addErrorFunc(property, value, errors);

    if (isIn != null && !isIn!.contains(value)) {
      _addError(
        errorCode: 'ValidaString.isIn',
        message: 'Should is be in $isIn',
        validationParam: isIn,
      );
    }
    errors.addAll(validateLength(property, value, value.length));

    // TODO: support `ValidaString.isPhone`
    // if (isPhone == true && !validators.isPhone(value)) {
    //   _addError(
    //     errorCode: 'ValidaString.isPhone',
    //     message: 'Should be a phone number',
    //     validationParam: null,
    //   );
    // }
    if (isEmail == true && !validators.isEmail(value)) {
      _addError(
        errorCode: 'ValidaString.isEmail',
        message: 'Should be an email',
        validationParam: null,
      );
    }
    if (isDate == true && !validators.isDate(value)) {
      _addError(
        errorCode: 'ValidaString.isDate',
        message: 'Should be a date',
        validationParam: null,
      );
    }
    if (isTime == true && DateTime.tryParse('1970-01-01T$value') == null) {
      _addError(
        errorCode: 'ValidaString.isTime',
        message: 'Should be a time',
        validationParam: null,
      );
    }
    if (isBool == true && (value != 'true' && value != 'false')) {
      _addError(
        errorCode: 'ValidaString.isBool',
        message: 'Should be "true" or "false"',
        validationParam: null,
      );
    }
    if (isNum == true && !validators.isNumeric(value)) {
      _addError(
        errorCode: 'ValidaString.isNum',
        message: 'Should be numeric',
        validationParam: null,
      );
    }
    if (isUrl == true && !validators.isURL(value)) {
      _addError(
        errorCode: 'ValidaString.isUrl',
        message: 'Should be an url',
        validationParam: null,
      );
    }
    if (isUUID != null &&
        !validators.isUUID(value, isUUID!.name.replaceFirst('v', ''))) {
      _addError(
        errorCode: 'ValidaString.isUUID',
        message: 'Should be an UUID (${isUUID!.name})',
        validationParam: isUUID,
      );
    }
    if (isCurrency == true && !ISO4217CurrencyCodes.contains(value)) {
      _addError(
        errorCode: 'ValidaString.isCurrency',
        message: 'Should be a ISO 4217 currency code',
        validationParam: null,
      );
    }
    if (isJSON == true && !validators.isJSON(value)) {
      _addError(
        errorCode: 'ValidaString.isJSON',
        message: 'Should be a JSON String',
        validationParam: null,
      );
    }
    if (matches != null && !validators.matches(value, matches)) {
      _addError(
        errorCode: 'ValidaString.matches',
        message: 'Should match "$matches"',
        validationParam: matches,
      );
    }
    if (contains != null && !validators.contains(value, contains)) {
      _addError(
        errorCode: 'ValidaString.contains',
        message: 'Should contain "$contains"',
        validationParam: contains,
      );
    }
    if (isAlpha == true && !validators.isAlpha(value)) {
      _addError(
        errorCode: 'ValidaString.isAlpha',
        message: 'Should contain only letters',
        validationParam: null,
      );
    }
    if (isAlphanumeric == true && !validators.isAlphanumeric(value)) {
      _addError(
        errorCode: 'ValidaString.isAlphanumeric',
        message: 'Should be alphanumeric',
        validationParam: null,
      );
    }
    if (isLowercase == true && !validators.isLowercase(value)) {
      _addError(
        errorCode: 'ValidaString.isLowercase',
        message: 'Should be lowercase',
        validationParam: null,
      );
    }
    if (isUppercase == true && !validators.isUppercase(value)) {
      _addError(
        errorCode: 'ValidaString.isUppercase',
        message: 'Should be uppercase',
        validationParam: null,
      );
    }
    if (isAscii == true && !validators.isAscii(value)) {
      _addError(
        errorCode: 'ValidaString.isAscii',
        message: 'Should be ascii',
        validationParam: null,
      );
    }
    if (isBase64 == true && !validators.isBase64(value)) {
      _addError(
        errorCode: 'ValidaString.isBase64',
        message: 'Should be base64 encoded',
        validationParam: null,
      );
    }
    if (isCreditCard == true && !validators.isCreditCard(value)) {
      _addError(
        errorCode: 'ValidaString.isCreditCard',
        message: 'Should be a credit card',
        validationParam: null,
      );
    }
    if (isFQDN == true && !validators.isFQDN(value)) {
      _addError(
        errorCode: 'ValidaString.isFQDN',
        message: 'Should be a FQDN',
        validationParam: null,
      );
    }
    if (isHexadecimal == true && !validators.isHexadecimal(value)) {
      _addError(
        errorCode: 'ValidaString.isHexadecimal',
        message: 'Should be hexadecimal',
        validationParam: null,
      );
    }
    if (isHexColor == true && !validators.isHexColor(value)) {
      _addError(
        errorCode: 'ValidaString.isHexColor',
        message: 'Should be a hex color',
        validationParam: null,
      );
    }
    if (isDivisibleBy != null &&
        !validators.isDivisibleBy(value, isDivisibleBy)) {
      _addError(
        errorCode: 'ValidaString.isDivisibleBy',
        message: 'Should be divisible by $isDivisibleBy',
        validationParam: isDivisibleBy,
      );
    }
    if (surrogatePairsLengthMin != null &&
        !validators.isLength(value, surrogatePairsLengthMin!)) {
      _addError(
        errorCode: 'ValidaString.surrogatePairsLengthMin',
        message:
            'Should have at a minimum $surrogatePairsLengthMin surrogate pairs',
        validationParam: surrogatePairsLengthMin,
      );
    }
    if (surrogatePairsLengthMax != null &&
        !validators.isLength(value, 0, surrogatePairsLengthMax)) {
      _addError(
        errorCode: 'ValidaString.surrogatePairsLengthMax',
        message:
            'Should have at a maximum $surrogatePairsLengthMax surrogate pairs',
        validationParam: surrogatePairsLengthMax,
      );
    }
    if (isInt == true && !validators.isInt(value)) {
      _addError(
        errorCode: 'ValidaString.isInt',
        message: 'Should be an integer',
        validationParam: null,
      );
    }
    if (isFloat == true && !validators.isFloat(value)) {
      _addError(
        errorCode: 'ValidaString.isFloat',
        message: 'Should be a floating point number',
        validationParam: null,
      );
    }
    if (isISBN != null &&
        !validators.isISBN(value, isISBN!.name.replaceFirst('v', ''))) {
      _addError(
        errorCode: 'ValidaString.isISBN',
        message: 'Should be an ISBN (${isISBN!.name})',
        validationParam: isISBN,
      );
    }
    if (isIP != null &&
        !validators.isIP(value, isIP!.name.replaceFirst('v', ''))) {
      _addError(
        errorCode: 'ValidaString.isIP',
        message: 'Should be and IP (${isIP!.name})',
        validationParam: isIP,
      );
    }
    if (customValidate != null) {
      errors.addAll(customValidate!(value));
    }

    return errors;
  }
}

T? _parseEnum<T extends Enum>(String? raw, List<T> enumValues) {
  if (raw == null) {
    return null;
  }
  for (final value in enumValues) {
    final str = value.toString();
    if (raw == str || raw == value.name) {
      return value;
    }
  }
  throw Error();
}

String? _toEnumString(Enum? value) {
  return value?.name;
}

/// List of active codes of official ISO 4217
/// currency names as of 1 April 2022.
/// Taken from https://en.wikipedia.org/wiki/ISO_4217
Set<String> ISO4217CurrencyCodes = const {
  'AED',
  'AFN',
  'ALL',
  'AMD',
  'ANG',
  'AOA',
  'ARS',
  'AUD',
  'AWG',
  'AZN',
  'BAM',
  'BBD',
  'BDT',
  'BGN',
  'BHD',
  'BIF',
  'BMD',
  'BND',
  'BOB',
  'BOV',
  'BRL',
  'BSD',
  'BTN',
  'BWP',
  'BYN',
  'BZD',
  'CAD',
  'CDF',
  'CHE',
  'CHF',
  'CHW',
  'CLF',
  'CLP',
  'COP',
  'COU',
  'CRC',
  'CUC',
  'CUP',
  'CVE',
  'CZK',
  'DJF',
  'DKK',
  'DOP',
  'DZD',
  'EGP',
  'ERN',
  'ETB',
  'EUR',
  'FJD',
  'FKP',
  'GBP',
  'GEL',
  'GHS',
  'GIP',
  'GMD',
  'GNF',
  'GTQ',
  'GYD',
  'HKD',
  'HNL',
  'HRK',
  'HTG',
  'HUF',
  'IDR',
  'ILS',
  'INR',
  'IQD',
  'IRR',
  'ISK',
  'JMD',
  'JOD',
  'JPY',
  'KES',
  'KGS',
  'KHR',
  'KMF',
  'KPW',
  'KRW',
  'KWD',
  'KYD',
  'KZT',
  'LAK',
  'LBP',
  'LKR',
  'LRD',
  'LSL',
  'LYD',
  'MAD',
  'MDL',
  'MGA',
  'MKD',
  'MMK',
  'MNT',
  'MOP',
  'MRU',
  'MUR',
  'MVR',
  'MWK',
  'MXN',
  'MXV',
  'MYR',
  'MZN',
  'NAD',
  'NGN',
  'NIO',
  'NOK',
  'NPR',
  'NZD',
  'OMR',
  'PAB',
  'PEN',
  'PGK',
  'PHP',
  'PKR',
  'PLN',
  'PYG',
  'QAR',
  'RON',
  'RSD',
  'CNY',
  'RUB',
  'RWF',
  'SAR',
  'SBD',
  'SCR',
  'SDG',
  'SEK',
  'SGD',
  'SHP',
  'SLL',
  'SOS',
  'SRD',
  'SSP',
  'STN',
  'SVC',
  'SYP',
  'SZL',
  'THB',
  'TJS',
  'TMT',
  'TND',
  'TOP',
  'TRY',
  'TTD',
  'TWD',
  'TZS',
  'UAH',
  'UGX',
  'USD',
  'USN',
  'UYI',
  'UYU',
  'UYW',
  'UZS',
  'VED',
  'VES',
  'VND',
  'VUV',
  'WST',
  'XAF',
  'XAG',
  'XAU',
  'XBA',
  'XBB',
  'XBC',
  'XBD',
  'XCD',
  'XDR',
  'XOF',
  'XPD',
  'XPF',
  'XPT',
  'XSU',
  'XTS',
  'XUA',
  'XXX',
  'YER',
  'ZAR',
  'ZMW',
  'ZW',
};
