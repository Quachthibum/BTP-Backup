@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Journal Entry - Item Interface'
define view entity ZI_TEAM4_JEI
  as select from zteam4_jei

  association to parent ZI_TEAM4_JEH as _Header
    on $projection.JournalEntryUUID = _Header.JournalEntryUUID

{
  key journal_entry_uuid    as JournalEntryUUID,
  key item_no                as ItemNo,
      gl_account              as GLAccount,
      gl_account_name         as GLAccountName,
      debit_credit            as DebitCredit,
      transaction_currency    as TransactionCurrency,

      @Semantics.amount.currencyCode: 'TransactionCurrency'
      amount                  as Amount,

      tax_code                as TaxCode,
      item_text               as ItemText,

      _Header
}
