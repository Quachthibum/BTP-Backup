@EndUserText.label: 'Clearing popup parameters'
define abstract entity ZA_TEAM4_CLEAR_PARAM
{
  @EndUserText.label: 'Clearing Date'
  ClearingDate     : abap.dats;

  @EndUserText.label: 'Customer Bank'
  @Consumption.valueHelpDefinition: [{
    entity: { name: 'ZI_TEAM4_CUSTBANK', element: 'BankId' }
  }]
  BankId           : abap.char(4);

  @EndUserText.label: 'Payment Reference'
  PaymentReference : abap.char(30);
}
