import 'package:khata_core/src/ledger.dart';
import 'package:khata_core/src/money.dart';
import 'package:khata_core/src/party_rules.dart';
import 'package:khata_core/src/sheet_reader.dart';
import 'package:meta/meta.dart';

/// What a column of the import file holds.
enum OpeningColumn {
  name,
  code,
  fatherName,
  village,
  mobile,
  role,

  /// One amount column; its side comes from [side], a Dr / Cr suffix, or the
  /// import's default side.
  amount,

  /// A column saying udhaar / jama (Dr / Cr).
  side,

  /// Separate amount columns: the party owes us / we owe the party.
  udhaar,
  jama,
}

/// Why a row cannot be imported (blocks it) — see [OpeningRow.errors].
enum OpeningRowError {
  nameMissing,
  amountInvalid,
  amountNegative,

  /// An amount with no udhaar / jama anywhere (no side column, no Dr / Cr,
  /// no default chosen). Never guessed.
  sideMissing,
  sideUnknown,

  /// Both the udhaar and the jama column have an amount.
  sideConflict,
  mobileInvalid,
  roleUnknown,

  /// Same code / same party as an earlier row of the file.
  duplicateInFile,

  /// A party with this name already exists and nothing in the row says it is
  /// (or is not) the same person: add its code, village or mobile.
  possibleDuplicate,

  /// The code belongs to a different party than the row's name.
  codeTaken,

  /// The party already has an opening balance entry.
  alreadyHasOpening,
}

/// Things worth a look that do not block a row.
enum OpeningRowWarning {
  /// Blank or zero amount: the party is added / matched, no entry posted.
  noAmount,

  /// Matched by code, but the name differs from the saved party.
  nameDiffers,

  /// The mobile number belongs to another party.
  mobileOfOther,
}

enum RowMatch {
  /// No party like this: it is created.
  none,
  code,
  nameAndVillage,
  nameAndMobile,

  /// Same name; neither the file nor the saved party says village or mobile.
  nameOnly,
}

/// A party already in the business, as the matcher needs it.
@immutable
final class ExistingParty {
  const ExistingParty({
    required this.id,
    required this.code,
    required this.name,
    this.village,
    this.mobile,
    this.hasOpeningBalance = false,
  });

  final String id;
  final String code;
  final String name;
  final String? village;
  final String? mobile;

  /// A posted opening-balance entry that is not reversed.
  final bool hasOpeningBalance;
}

/// One data row of the file, read and checked.
@immutable
final class OpeningRow {
  const OpeningRow({
    required this.number,
    required this.name,
    required this.role,
    this.code,
    this.fatherName,
    this.village,
    this.mobile,
    this.amount = Money.zero,
    this.side,
    this.matchedPartyId,
    this.matchedBy = RowMatch.none,
    this.matchedPartyName,
    this.errors = const [],
    this.warnings = const [],
    this.detail,
  });

  /// Row number in the file.
  final int number;
  final String name;

  /// Upper-cased, or null when the file has none (the app numbers it).
  final String? code;
  final String? fatherName;
  final String? village;

  /// 10 digits, or null.
  final String? mobile;
  final PartyRole role;

  /// Always >= 0; zero means no opening balance for this party.
  final Money amount;
  final Side? side;

  /// The existing party this row is, or null when a party is created.
  final String? matchedPartyId;
  final RowMatch matchedBy;
  final String? matchedPartyName;
  final List<OpeningRowError> errors;
  final List<OpeningRowWarning> warnings;

  /// Extra words for the message (the other row number, the party's code).
  final String? detail;

  bool get hasError => errors.isNotEmpty;
  bool get createsParty => !hasError && matchedPartyId == null;
  bool get postsEntry => !hasError && amount.isPositive;

  /// Signed effect on the party's balance (jama positive), zero when none.
  Money get signed => side == null || !amount.isPositive
      ? Money.zero
      : side == Side.jama
      ? amount
      : -amount;
}

/// The file's layout was not understood.
enum SheetProblem {
  /// Nothing in the file.
  empty,

  /// No header row with a name column.
  noNameColumn,

  /// No amount, udhaar or jama column.
  noAmountColumn,

  /// More rows than one import takes.
  tooManyRows,
}

/// Result of reading a file against the business's parties.
@immutable
final class OpeningPreview {
  const OpeningPreview({
    required this.rows,
    required this.columns,
    this.problem,
  });

  const OpeningPreview.unreadable(this.problem)
    : rows = const [],
      columns = const {};

  final List<OpeningRow> rows;

  /// Which file column (0-based) was read as what.
  final Map<OpeningColumn, int> columns;
  final SheetProblem? problem;

  List<OpeningRow> get valid => [
    for (final r in rows)
      if (!r.hasError) r,
  ];
  List<OpeningRow> get invalid => [
    for (final r in rows)
      if (r.hasError) r,
  ];

  int get newParties => valid.where((r) => r.createsParty).length;
  int get matchedParties => valid.where((r) => r.matchedPartyId != null).length;
  int get entries => valid.where((r) => r.postsEntry).length;

  Money get totalUdhaar => valid
      .where((r) => r.postsEntry && r.side == Side.udhaar)
      .fold(Money.zero, (sum, r) => sum + r.amount);
  Money get totalJama => valid
      .where((r) => r.postsEntry && r.side == Side.jama)
      .fold(Money.zero, (sum, r) => sum + r.amount);

  /// Σ jama − Σ udhaar of the valid rows (the ledger's sign).
  Money get net => totalJama - totalUdhaar;

  /// Some valid row would create a party or post an entry.
  bool get canImport =>
      problem == null && valid.any((r) => r.createsParty || r.postsEntry);

  /// Same text for the same rows, however the file was uploaded: used to
  /// recognise the same file imported twice. Only valid rows count.
  String get fingerprint => [
    for (final r in valid)
      [
        r.name.toLowerCase(),
        r.code ?? '',
        r.village?.toLowerCase() ?? '',
        r.mobile ?? '',
        r.side?.dbName ?? '',
        r.amount.paise,
      ].join('|'),
  ].join('\n');
}

/// Reads an opening-balance file: finds the columns, checks every row,
/// matches rows to existing parties. Pure: no database, no clock.
///
/// Rules (docs/domain/ledger-and-mandi.md, "Opening balance"):
/// * each row is a party and the amount it owes (udhaar) or is owed (jama)
///   on the opening date;
/// * the side is never guessed: it comes from a side column, `Dr` / `Cr`
///   after the amount, separate udhaar / jama columns, or the `defaultSide`
///   the person chose for rows that say nothing;
/// * negative amounts are rejected, not flipped;
/// * a party that already has an opening balance is never given a second.
abstract final class OpeningBalanceImport {
  static const maxRows = 5000;

  static final _aliases = <OpeningColumn, List<String>>{
    OpeningColumn.name: [
      'name',
      'party',
      'party name',
      'farmer',
      'farmer name',
      'customer',
      'customer name',
      'account',
      'account name',
      'a/c name',
      'naam',
      'नाम',
      'पार्टी',
      'किसान',
      'ਨਾਮ',
      'ਪਾਰਟੀ',
      'ਕਿਸਾਨ',
    ],
    OpeningColumn.code: [
      'code',
      'party code',
      'id',
      'a/c no',
      'account no',
      'कोड',
      'ਕੋਡ',
    ],
    OpeningColumn.fatherName: [
      'father',
      'father name',
      'father/husband',
      'father or husband',
      'husband',
      's/o',
      'w/o',
      'care of',
      'पिता',
      'पिता का नाम',
      'ਪਿਤਾ',
    ],
    OpeningColumn.village: [
      'village',
      'gaon',
      'place',
      'city',
      'town',
      'address',
      'गांव',
      'गाँव',
      'ਪਿੰਡ',
    ],
    OpeningColumn.mobile: [
      'mobile',
      'mobile no',
      'mobile number',
      'phone',
      'phone no',
      'contact',
      'mob',
      'मोबाइल',
      'फोन',
      'ਮੋਬਾਈਲ',
      'ਫੋਨ',
    ],
    OpeningColumn.role: [
      'role',
      'party type',
      'category',
      'group',
      'भूमिका',
      'ਭੂਮਿਕਾ',
    ],
    OpeningColumn.amount: [
      'amount',
      'balance',
      'baki',
      'baaki',
      'bal',
      'opening',
      'opening balance',
      'opening baki',
      'outstanding',
      'रकम',
      'राशि',
      'बाकी',
      'बैलेंस',
      'ਰਕਮ',
      'ਬਕਾਇਆ',
      'ਬਾਕੀ',
    ],
    OpeningColumn.side: [
      'type',
      'side',
      'dr/cr',
      'dr cr',
      'drcr',
      'dr or cr',
      'nature',
      'baki type',
      'balance type',
      'प्रकार',
      'ਕਿਸਮ',
    ],
    OpeningColumn.udhaar: [
      'udhaar',
      'udhar',
      'debit',
      'dr',
      'dr amount',
      'debit amount',
      'receivable',
      'to receive',
      'उधार',
      'ਉਧਾਰ',
    ],
    OpeningColumn.jama: [
      'jama',
      'credit',
      'cr',
      'cr amount',
      'credit amount',
      'payable',
      'to pay',
      'जमा',
      'ਜਮ੍ਹਾ',
      'ਜਮਾ',
    ],
  };

  static String _headerKey(String s) => s
      .toLowerCase()
      .replaceAll(RegExp(r'[_.\-*()₹]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  static final _aliasLookup = <String, OpeningColumn>{
    for (final e in _aliases.entries)
      for (final a in e.value) _headerKey(a): e.key,
  };

  /// Which column holds what, from the first row. Null when that row does
  /// not look like a header (no name column).
  static Map<OpeningColumn, int>? detectColumns(SheetRow header) {
    final found = <OpeningColumn, int>{};
    for (var i = 0; i < header.cells.length; i++) {
      final column = _aliasLookup[_headerKey(header.cells[i])];
      if (column != null) found.putIfAbsent(column, () => i);
    }
    return found.containsKey(OpeningColumn.name) ? found : null;
  }

  /// A side word: `udhaar`, `Dr`, `jama`, `Cr`, Hindi / Punjabi too.
  static Side? parseSide(String input) {
    final t = input.trim().toLowerCase().replaceAll('.', '');
    return switch (t) {
      'udhaar' ||
      'udhar' ||
      'dr' ||
      'debit' ||
      'd' ||
      'baki' ||
      'lena' ||
      'receivable' ||
      'to receive' ||
      'उधार' ||
      'लेना' ||
      'ਉਧਾਰ' ||
      'ਲੈਣਾ' => Side.udhaar,
      'jama' ||
      'jamma' ||
      'cr' ||
      'credit' ||
      'c' ||
      'dena' ||
      'payable' ||
      'to pay' ||
      'जमा' ||
      'देना' ||
      'ਜਮ੍ਹਾ' ||
      'ਜਮਾ' ||
      'ਦੇਣਾ' => Side.jama,
      _ => null,
    };
  }

  static final _amountPattern = RegExp(
    r'^(?:(dr|cr|d|c)\.?\s*)?(\(?-?)\s*(\d[\d,]*(?:\.\d+)?|\.\d+)\s*\)?'
    r'\s*(?:/-)?\s*(dr|cr|d|c|udhaar|udhar|jama|debit|credit)?\.?$',
  );

  /// An amount cell: `15,000`, `₹1,555.80`, `15000 Dr`, `Cr 400`.
  static ({Money? amount, Side? side, OpeningRowError? error}) parseAmount(
    String input,
  ) {
    var t = input.trim().toLowerCase();
    if (t.isEmpty) return (amount: null, side: null, error: null);
    t = t.replaceAll('₹', '').replaceAll(RegExp(r'\brs\.?|\binr\b'), '').trim();
    final m = _amountPattern.firstMatch(t);
    if (m == null) {
      return (amount: null, side: null, error: OpeningRowError.amountInvalid);
    }
    final negative = m[2]!.contains('-') || m[2]!.contains('(');
    final money = Money.tryParse(m[3]!);
    if (money == null) {
      return (amount: null, side: null, error: OpeningRowError.amountInvalid);
    }
    final sideWord = m[1] ?? m[4];
    final side = sideWord == null ? null : parseSide(sideWord);
    if (negative && money.isPositive) {
      return (amount: null, side: side, error: OpeningRowError.amountNegative);
    }
    return (amount: money, side: side, error: null);
  }

  static PartyRole? _parseRole(String input) {
    final t = input.trim().toLowerCase();
    final direct = PartyRole.parse(t);
    if (direct != null) return direct;
    return switch (t) {
      'kisan' || 'किसान' || 'ਕਿਸਾਨ' => PartyRole.farmer,
      'khareedar' || 'खरीदार' || 'ਖਰੀਦਾਰ' => PartyRole.buyer,
      'grahak' || 'ग्राहक' || 'ਗਾਹਕ' => PartyRole.customer,
      _ => null,
    };
  }

  /// Normalised for matching: case, spacing and dots do not matter.
  static String normaliseName(String s) => s
      .toLowerCase()
      .replaceAll(RegExp('[.,]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  /// Reads [sheet] (first row = header) against [existing] parties.
  static OpeningPreview preview(
    Sheet sheet, {
    required List<ExistingParty> existing,
    Side? defaultSide,
    PartyRole defaultRole = PartyRole.farmer,
  }) {
    if (sheet.isEmpty) {
      return const OpeningPreview.unreadable(SheetProblem.empty);
    }
    final columns = detectColumns(sheet.rows.first);
    if (columns == null) {
      return const OpeningPreview.unreadable(SheetProblem.noNameColumn);
    }
    if (!columns.containsKey(OpeningColumn.amount) &&
        !columns.containsKey(OpeningColumn.udhaar) &&
        !columns.containsKey(OpeningColumn.jama)) {
      return OpeningPreview(
        rows: const [],
        columns: columns,
        problem: SheetProblem.noAmountColumn,
      );
    }
    final data = sheet.rows.skip(1).toList();
    if (data.length > maxRows) {
      return OpeningPreview(
        rows: const [],
        columns: columns,
        problem: SheetProblem.tooManyRows,
      );
    }

    final index = _ExistingIndex(existing);
    final seenCodes = <String, int>{};
    final seenParties = <String, int>{};
    final rows = <OpeningRow>[];
    for (final raw in data) {
      rows.add(
        _readRow(
          raw,
          columns,
          index,
          defaultSide,
          defaultRole,
          seenCodes,
          seenParties,
        ),
      );
    }
    return OpeningPreview(rows: rows, columns: columns);
  }

  static OpeningRow _readRow(
    SheetRow raw,
    Map<OpeningColumn, int> columns,
    _ExistingIndex index,
    Side? defaultSide,
    PartyRole defaultRole,
    Map<String, int> seenCodes,
    Map<String, int> seenParties,
  ) {
    String cell(OpeningColumn c) => raw.cell(columns[c]);
    final errors = <OpeningRowError>[];
    final warnings = <OpeningRowWarning>[];
    String? detail;

    final name = cell(OpeningColumn.name).replaceAll(RegExp(r'\s+'), ' ');
    if (name.isEmpty) errors.add(OpeningRowError.nameMissing);
    final codeText = cell(OpeningColumn.code).toUpperCase();
    final code = codeText.isEmpty ? null : codeText;
    final father = _nullIfBlank(cell(OpeningColumn.fatherName));
    final village = _nullIfBlank(cell(OpeningColumn.village));

    final mobileText = cell(OpeningColumn.mobile);
    String? mobile;
    if (mobileText.isNotEmpty) {
      mobile = IndianMobile.normalise(mobileText);
      if (mobile == null) errors.add(OpeningRowError.mobileInvalid);
    }

    var role = defaultRole;
    final roleText = cell(OpeningColumn.role);
    if (roleText.isNotEmpty) {
      final parsed = _parseRole(roleText);
      if (parsed == null) {
        errors.add(OpeningRowError.roleUnknown);
      } else {
        role = parsed;
      }
    }

    // Amount and side.
    var amount = Money.zero;
    Side? side;
    final hasUdhaarCol = columns.containsKey(OpeningColumn.udhaar);
    final hasJamaCol = columns.containsKey(OpeningColumn.jama);
    if (hasUdhaarCol || hasJamaCol) {
      final u = parseAmount(cell(OpeningColumn.udhaar));
      final j = parseAmount(cell(OpeningColumn.jama));
      final problem = u.error ?? j.error;
      if (problem != null) {
        errors.add(problem);
      } else if ((u.amount?.isPositive ?? false) &&
          (j.amount?.isPositive ?? false)) {
        errors.add(OpeningRowError.sideConflict);
      } else if (u.amount?.isPositive ?? false) {
        amount = u.amount!;
        side = Side.udhaar;
      } else if (j.amount?.isPositive ?? false) {
        amount = j.amount!;
        side = Side.jama;
      }
    }
    if (columns.containsKey(OpeningColumn.amount) && amount.isZero) {
      final a = parseAmount(cell(OpeningColumn.amount));
      if (a.error != null) {
        errors.add(a.error!);
      } else if (a.amount != null && a.amount!.isPositive) {
        amount = a.amount!;
        final sideText = cell(OpeningColumn.side);
        Side? explicit;
        if (sideText.isNotEmpty) {
          explicit = parseSide(sideText);
          if (explicit == null) errors.add(OpeningRowError.sideUnknown);
        }
        side = explicit ?? a.side ?? defaultSide;
        if (side == null && !errors.contains(OpeningRowError.sideUnknown)) {
          errors.add(OpeningRowError.sideMissing);
        }
      }
    }
    if (amount.isZero && errors.isEmpty) {
      warnings.add(OpeningRowWarning.noAmount);
    }

    // Match to an existing party, then check for repeats in the file.
    String? matchedId;
    String? matchedName;
    var matchedBy = RowMatch.none;
    if (name.isNotEmpty) {
      final match = index.find(
        name: name,
        code: code,
        village: village,
        mobile: mobile,
      );
      switch (match) {
        case _Found(:final party, :final by):
          matchedId = party.id;
          matchedName = party.name;
          matchedBy = by;
          if (by == RowMatch.code &&
              normaliseName(party.name) != normaliseName(name)) {
            warnings.add(OpeningRowWarning.nameDiffers);
          }
          if (party.hasOpeningBalance) {
            errors.add(OpeningRowError.alreadyHasOpening);
          }
        case _Ambiguous(:final party):
          errors.add(OpeningRowError.possibleDuplicate);
          matchedName = party.name;
          detail = party.code;
        case _CodeTaken(:final party):
          errors.add(OpeningRowError.codeTaken);
          matchedName = party.name;
          detail = party.code;
        case _NoMatch():
          break;
      }
      if (mobile != null && matchedId == null) {
        final owner = index.byMobile[mobile];
        if (owner != null && !errors.contains(OpeningRowError.codeTaken)) {
          warnings.add(OpeningRowWarning.mobileOfOther);
        }
      }

      // Repeats inside the file (the earlier row wins).
      final partyKey =
          matchedId ??
          (code != null
              ? 'code:$code'
              : 'new:${normaliseName(name)}|${normaliseName(village ?? '')}|'
                    '${mobile ?? ''}');
      final earlier =
          (code == null ? null : seenCodes[code]) ?? seenParties[partyKey];
      if (earlier != null) {
        errors.add(OpeningRowError.duplicateInFile);
        detail = '$earlier';
      } else {
        if (code != null) seenCodes[code] = raw.number;
        seenParties[partyKey] = raw.number;
      }
    }

    return OpeningRow(
      number: raw.number,
      name: name,
      role: role,
      code: code,
      fatherName: father,
      village: village,
      mobile: mobile,
      amount: amount,
      side: amount.isPositive ? side : null,
      matchedPartyId: matchedId,
      matchedBy: matchedBy,
      matchedPartyName: matchedName,
      errors: errors,
      warnings: warnings,
      detail: detail,
    );
  }

  static String? _nullIfBlank(String s) => s.trim().isEmpty ? null : s.trim();
}

sealed class _Match {
  const _Match();
}

final class _Found extends _Match {
  const _Found(this.party, this.by);

  final ExistingParty party;
  final RowMatch by;
}

final class _Ambiguous extends _Match {
  const _Ambiguous(this.party);

  final ExistingParty party;
}

final class _CodeTaken extends _Match {
  const _CodeTaken(this.party);

  final ExistingParty party;
}

final class _NoMatch extends _Match {
  const _NoMatch();
}

class _ExistingIndex {
  _ExistingIndex(List<ExistingParty> parties) {
    for (final p in parties) {
      byCode[p.code.trim().toUpperCase()] = p;
      (byName[OpeningBalanceImport.normaliseName(p.name)] ??= []).add(p);
      if (p.mobile != null) byMobile[p.mobile!] = p;
    }
  }

  final byCode = <String, ExistingParty>{};
  final byName = <String, List<ExistingParty>>{};
  final byMobile = <String, ExistingParty>{};

  _Match find({
    required String name,
    String? code,
    String? village,
    String? mobile,
  }) {
    final normName = OpeningBalanceImport.normaliseName(name);
    final sameName = byName[normName] ?? const [];

    if (code != null) {
      final owner = byCode[code];
      if (owner != null) {
        final ownerName = OpeningBalanceImport.normaliseName(owner.name);
        // The code is the person's identity; a different name is a warning,
        // unless it is exactly the name of someone else.
        if (ownerName != normName && sameName.isNotEmpty) {
          return _CodeTaken(owner);
        }
        return _Found(owner, RowMatch.code);
      }
    }

    if (sameName.isEmpty) return const _NoMatch();

    final normVillage = OpeningBalanceImport.normaliseName(village ?? '');
    if (normVillage.isNotEmpty) {
      final hits = [
        for (final p in sameName)
          if (OpeningBalanceImport.normaliseName(p.village ?? '') ==
              normVillage)
            p,
      ];
      if (hits.length == 1) return _Found(hits.single, RowMatch.nameAndVillage);
      if (hits.length > 1) return _Ambiguous(hits.first);
    }
    if (mobile != null) {
      final hits = [
        for (final p in sameName)
          if (p.mobile == mobile) p,
      ];
      if (hits.length == 1) return _Found(hits.single, RowMatch.nameAndMobile);
      if (hits.length > 1) return _Ambiguous(hits.first);
    }
    // Same name but the file says a village / mobile that differs from every
    // saved party of that name: a different person.
    final differs = sameName.every(
      (p) =>
          (normVillage.isNotEmpty &&
              (p.village ?? '').trim().isNotEmpty &&
              OpeningBalanceImport.normaliseName(p.village!) != normVillage) ||
          (mobile != null && p.mobile != null && p.mobile != mobile),
    );
    if (differs) return const _NoMatch();
    // One saved party and nothing on either side to tell them apart.
    final bare =
        sameName.length == 1 &&
        normVillage.isEmpty &&
        mobile == null &&
        (sameName.single.village ?? '').trim().isEmpty &&
        sameName.single.mobile == null;
    if (bare) return _Found(sameName.single, RowMatch.nameOnly);
    return _Ambiguous(sameName.first);
  }
}
