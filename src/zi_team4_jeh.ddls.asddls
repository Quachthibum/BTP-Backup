@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Journal Entry - Header Interface'
define root view entity ZI_TEAM4_JEH
  as select from zteam4_jeh

  composition [0..*] of ZI_TEAM4_JEI as _Items

{
  key journal_entry_uuid       as JournalEntryUUID,
      company_code             as CompanyCode,
      document_number          as DocumentNumber,
      fiscal_year              as FiscalYear,
      document_type            as DocumentType,
      document_date            as DocumentDate,
      posting_date             as PostingDate,
      transaction_currency     as TransactionCurrency,
      reference                as Reference,
      customer                 as Customer,
      customer_name            as CustomerName,

      @Semantics.amount.currencyCode: 'TransactionCurrency'
      net_amount               as NetAmount,

      tax_rate                 as TaxRate,

      @Semantics.amount.currencyCode: 'TransactionCurrency'
      tax_amount                as TaxAmount,

      @Semantics.amount.currencyCode: 'TransactionCurrency'
      gross_amount              as GrossAmount,

      due_date                  as DueDate,
      
      status                    as Status,
      
      status_criticality        as StatusCriticality,
      
      status_text               as StatusText,
      
      clearing_document         as ClearingDocument,
      clearing_date             as ClearingDate,

      @Semantics.user.createdBy: true
      created_by as CreatedBy,
    
      @Semantics.systemDateTime.createdAt: true
      created_at as CreatedAt,
    
      @Semantics.user.lastChangedBy: true
      last_changed_by as LastChangedBy,
    
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at as LastChangedAt,
    
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
       
      _Items
}
