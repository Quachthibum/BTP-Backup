CLASS zcl_team4_je_master_data DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_customer,
        customer_id   TYPE zteam4_customer-customer_id,
        customer_name TYPE zteam4_customer-customer_name,
      END OF ty_customer,

      BEGIN OF ty_sales_order,
        sales_order         TYPE zteam4_so-sales_order,
        customer_id         TYPE zteam4_so-customer_id,
        sales_order_date    TYPE zteam4_so-sales_order_date,
        transaction_currency TYPE zteam4_so-transaction_currency,
        net_amount          TYPE zteam4_so-net_amount,
        payment_terms_days  TYPE zteam4_so-payment_terms_days,
        description         TYPE zteam4_so-description,
      END OF ty_sales_order.

    CLASS-METHODS get_customer
      IMPORTING
        iv_customer_id     TYPE zteam4_customer-customer_id
      RETURNING
        VALUE(rs_customer) TYPE ty_customer.

    CLASS-METHODS customer_exists
      IMPORTING
        iv_customer_id   TYPE zteam4_customer-customer_id
      RETURNING
        VALUE(rv_exists) TYPE abap_bool.

    CLASS-METHODS get_sales_order
      IMPORTING
        iv_sales_order       TYPE zteam4_so-sales_order
      RETURNING
        VALUE(rs_sales_order) TYPE ty_sales_order.

    CLASS-METHODS sales_order_exists
      IMPORTING
        iv_sales_order   TYPE zteam4_so-sales_order
      RETURNING
        VALUE(rv_exists) TYPE abap_bool.

    CLASS-METHODS determine_company_code
      IMPORTING
        iv_customer_id        TYPE zteam4_customer-customer_id
      RETURNING
        VALUE(rv_company_code) TYPE zteam4_jeh-company_code.

ENDCLASS.



CLASS zcl_team4_je_master_data IMPLEMENTATION.

  METHOD get_customer.

    CLEAR rs_customer.

    IF iv_customer_id IS INITIAL.
      RETURN.
    ENDIF.

    SELECT SINGLE
           customer_id,
           customer_name
      FROM zteam4_customer
      WHERE customer_id = @iv_customer_id
      INTO CORRESPONDING FIELDS OF @rs_customer.

  ENDMETHOD.


  METHOD customer_exists.

    rv_exists = xsdbool(
      get_customer( iv_customer_id )-customer_id IS NOT INITIAL
    ).

  ENDMETHOD.


  METHOD get_sales_order.

    CLEAR rs_sales_order.

    IF iv_sales_order IS INITIAL.
      RETURN.
    ENDIF.

    SELECT SINGLE
           sales_order,
           customer_id,
           sales_order_date,
           transaction_currency,
           net_amount,
           payment_terms_days,
           description
      FROM zteam4_so
      WHERE sales_order = @iv_sales_order
      INTO CORRESPONDING FIELDS OF @rs_sales_order.

  ENDMETHOD.


  METHOD sales_order_exists.

    rv_exists = xsdbool(
      get_sales_order( iv_sales_order )-sales_order IS NOT INITIAL
    ).

  ENDMETHOD.


  METHOD determine_company_code.

    rv_company_code =
      SWITCH #(
        iv_customer_id
        WHEN 'CUST01' THEN '1000'
        WHEN 'CUST02' THEN '2000'
        WHEN 'CUST03' THEN '3000'
        ELSE '1000'
      ).

  ENDMETHOD.

ENDCLASS.
