/// Where a setting row applies (`settings.scope` in the database).
enum SettingScope {
  tenant('tenant'),
  partyGroup('party_group'),
  party('party'),
  loan('loan'),
  lot('lot'),
  invoice('invoice');

  const SettingScope(this.dbName);

  final String dbName;

  static SettingScope? parse(String value) {
    for (final s in values) {
      if (s.dbName == value) return s;
    }
    return null;
  }

  /// Loan, lot and invoice rows are all "document" level.
  bool get isDocument => this == loan || this == lot || this == invoice;

  SettingLevel get level => switch (this) {
    tenant => SettingLevel.tenant,
    partyGroup => SettingLevel.partyGroup,
    party => SettingLevel.party,
    loan || lot || invoice => SettingLevel.document,
  };
}

/// The level a resolved value came from, most specific first. Shown in the
/// UI ("18% · from business default") so the owner knows why a number was
/// used.
enum SettingLevel { document, party, partyGroup, tenant, plan, system }
