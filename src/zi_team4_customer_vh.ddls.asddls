@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'TEAM4 Customer Value Help'
@Search.searchable: true

define view entity ZI_TEAM4_CUSTOMER_VH
  as select from zteam4_customer
{
      @EndUserText.label: 'Customer'
      @Search.defaultSearchElement: true
  key customer_id   as Customer,

      @EndUserText.label: 'Customer Name'
      @Search.defaultSearchElement: true
      customer_name as CustomerName,

      @EndUserText.label: 'Post Code'
      postcode      as PostCode,

      @EndUserText.label: 'City'
      @Search.defaultSearchElement: true
      city          as City,

      @EndUserText.label: 'Country'
      country       as Country,

      @EndUserText.label: 'Telephone'
      telephone     as Telephone
}
