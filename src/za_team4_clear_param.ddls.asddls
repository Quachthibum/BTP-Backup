@EndUserText.label: 'Clearing popup parameters'
define abstract entity ZA_TEAM4_CLEAR_PARAM
{
  @EndUserText.label: 'Document Number'
  DocumentNumber   : abap.char(10);

  @EndUserText.label: 'Customer'
  Customer         : abap.char(10);

  @EndUserText.label: 'Customer Name'
  CustomerName     : abap.char(80);

  @EndUserText.label: 'Due Date'
  DueDate          : abap.dats;

  @EndUserText.label: 'Gross Amount to Pay'
  @Semantics.amount.currencyCode: 'Currency'
  GrossAmount      : abap.curr(15,2);

  @UI.hidden: true
  @EndUserText.label: 'Currency'
  Currency         : abap.cuky;

  @EndUserText.label: 'Clearing Date'
  ClearingDate     : abap.dats;

  @EndUserText.label: 'Customer Bank'
  @Consumption.valueHelpDefinition: [{
    entity: { name: 'ZI_TEAM4_CUSTBANK', element: 'BankId' },
    additionalBinding: [
      { localElement: 'Customer',    element: 'Customer', usage: #FILTER },
      { localElement: 'BankBalance', element: 'Balance',  usage: #RESULT }
    ]
  }]
  BankId           : abap.char(4);

  @EndUserText.label: 'Bank Balance'
  @Semantics.amount.currencyCode: 'Currency'
  BankBalance      : abap.curr(15,2);

  @EndUserText.label: 'Payment Reference'
  PaymentReference : abap.char(30);
}
