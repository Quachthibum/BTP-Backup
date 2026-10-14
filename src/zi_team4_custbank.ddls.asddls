@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Customer bank value help'
@ObjectModel.resultSet.sizeCategory: #XS
define view entity ZI_TEAM4_CUSTBANK
  as select from zteam4_custbank
{
      @EndUserText.label: 'Customer'
      @UI.selectionField: [{ position: 10 }]
      @UI.lineItem: [{ position: 5 }]
  key customer     as Customer,

      @EndUserText.label: 'Bank ID'
      @UI.lineItem: [{ position: 10 }]
  key bank_id      as BankId,

      @EndUserText.label: 'Bank Name'
      @UI.lineItem: [{ position: 20 }]
      bank_name    as BankName,

      @EndUserText.label: 'Account'
      @UI.lineItem: [{ position: 30 }]
      bank_account as BankAccount,

      gl_account   as GlAccount,
      currency     as Currency,
      @Semantics.amount.currencyCode: 'Currency'
      @UI.lineItem: [{ position: 40 }]
      @EndUserText.label: 'Balance'
      balance      as Balance
}
