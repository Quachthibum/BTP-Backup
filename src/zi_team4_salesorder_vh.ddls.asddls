@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'TEAM4 Sales Order Value Help'
@Search.searchable: true

define view entity ZI_TEAM4_SALESORDER_VH
  as select from zteam4_so
{
      @EndUserText.label: 'Sales Order'
      @Search.defaultSearchElement: true
  key sales_order          as SalesOrder,

      @EndUserText.label: 'Company Code'
      case customer_id
        when 'CUST01' then cast( '1000' as abap.char( 4 ) )
        when 'CUST02' then cast( '2000' as abap.char( 4 ) )
        when 'CUST03' then cast( '3000' as abap.char( 4 ) )
        when 'CUST04' then cast( '4000' as abap.char( 4 ) )
        when 'CUST05' then cast( '5000' as abap.char( 4 ) )
        when 'CUST06' then cast( '6000' as abap.char( 4 ) )
        when 'CUST07' then cast( '7000' as abap.char( 4 ) )
        when 'CUST08' then cast( '8000' as abap.char( 4 ) )
        when 'CUST09' then cast( '9000' as abap.char( 4 ) )
        when 'CUST10' then cast( '10000' as abap.char( 5 ) )
        else cast( '1000' as abap.char( 4 ) )
      end                  as CompanyCode,

      @EndUserText.label: 'Customer'
      @Search.defaultSearchElement: true
      customer_id          as Customer,

      @EndUserText.label: 'Sales Order Date'
      sales_order_date     as SalesOrderDate,

      @EndUserText.label: 'Currency'
      transaction_currency as TransactionCurrency,

      @EndUserText.label: 'Net Amount'
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      net_amount           as NetAmount,

      @EndUserText.label: 'Payment Terms Days'
      payment_terms_days   as PaymentTermsDays,

      @EndUserText.label: 'Description'
      @Search.defaultSearchElement: true
      description          as Description
}
