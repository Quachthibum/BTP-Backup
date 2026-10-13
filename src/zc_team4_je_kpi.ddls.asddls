@EndUserText.label: 'Journal Entry KPIs'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true

define view entity ZC_TEAM4_JE_KPI
  as select from ZI_TEAM4_JE_KPI
{
  key KpiKey,
      ParkedCount,
      OverdueAmount,
      OpenAmount,
      Currency
}
