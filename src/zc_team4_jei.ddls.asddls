@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Journal Entry Item'
@Metadata.allowExtensions: true

define view entity ZC_TEAM4_JEI
  as projection on ZI_TEAM4_JEI
{
  key JournalEntryUUID,
  key ItemNo,

      GLAccount,
      GLAccountName,
      DebitCredit,
      TransactionCurrency,
      Amount,
      TaxCode,
      ItemText,

      _Header : redirected to parent ZC_TEAM4_JEH
}
