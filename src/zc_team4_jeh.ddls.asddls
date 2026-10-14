@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Journal Entry'
@Metadata.allowExtensions: true
define root view entity ZC_TEAM4_JEH
  provider contract transactional_query
  as projection on ZI_TEAM4_JEH
{
  key JournalEntryUUID,

      CompanyCode,
      DocumentNumber,
      FiscalYear,
      DocumentType,
      DocumentDate,
      PostingDate,
      TransactionCurrency,
      Reference,
      Customer,
      CustomerName,
      NetAmount,
      TaxRate,
      TaxAmount,
      GrossAmount,
      DueDate,
      PaymentBankId,
      PaymentBankGL,
      PaymentReference,
      Status,
      StatusCriticality,
      StatusText,
      ClearingDocument,
      ClearingDate,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,

      _Items : redirected to composition child ZC_TEAM4_JEI
}
