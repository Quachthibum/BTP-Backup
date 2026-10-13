@EndUserText.label: 'Journal Entry KPIs'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.ignorePropagatedAnnotations: true

define view entity ZI_TEAM4_JE_KPI
  as select from zteam4_jeh
{
  key cast( '1' as abap.char(1) ) as KpiKey,

      // KPI 1: Parked Documents
      sum( case when status = 'P' then 1 else 0 end ) 
        as ParkedCount,

      // KPI 2: Overdue Receivables
      @Semantics.amount.currencyCode: 'Currency'
      sum( case when status = 'O'
                 and due_date < $session.system_date
            then gross_amount
            else cast( 0 as abap.curr(15,2) )
           end ) as OverdueAmount,

      // KPI 3: Total Open Invoices
      @Semantics.amount.currencyCode: 'Currency'
      sum( case when status = 'O'
            then gross_amount
            else cast( 0 as abap.curr(15,2) )
           end ) as OpenAmount,

      // Currency
      cast( 'USD' as abap.cuky ) as Currency
}
