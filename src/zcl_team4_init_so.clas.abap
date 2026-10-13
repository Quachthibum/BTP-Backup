CLASS zcl_team4_init_so DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

ENDCLASS.


CLASS zcl_team4_init_so IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    DATA lt_sales_order TYPE TABLE OF zteam4_so.

    lt_sales_order = VALUE #(

      "==========================================================
      " CUST01 - Acme Corporation
      "==========================================================

      (
        sales_order          = 'SO-99550'
        customer_id          = 'CUST01'
        sales_order_date     = '20260915'
        transaction_currency = 'USD'
        net_amount           = '2500.00'
        payment_terms_days   = 30
        description          = 'Server Rack Hardware'
      )

      (
        sales_order          = 'SO-99602'
        customer_id          = 'CUST01'
        sales_order_date     = '20260918'
        transaction_currency = 'USD'
        net_amount           = '8400.00'
        payment_terms_days   = 45
        description          = 'Cloud Migration Consulting'
      )

      (
        sales_order          = 'SO-99650'
        customer_id          = 'CUST01'
        sales_order_date     = '20260925'
        transaction_currency = 'USD'
        net_amount           = '3200.00'
        payment_terms_days   = 30
        description          = 'Network Infrastructure Upgrade'
      )


      "==========================================================
      " CUST02 - Global Logistics LLC
      "==========================================================

      (
        sales_order          = 'SO-99715'
        customer_id          = 'CUST02'
        sales_order_date     = '20260912'
        transaction_currency = 'USD'
        net_amount           = '4200.00'
        payment_terms_days   = 30
        description          = 'Fleet Telematics Sensors'
      )

      (
        sales_order          = 'SO-99801'
        customer_id          = 'CUST02'
        sales_order_date     = '20260901'
        transaction_currency = 'USD'
        net_amount           = '12000.00'
        payment_terms_days   = 60
        description          = 'Freight Optimization'
      )

      (
        sales_order          = 'SO-99820'
        customer_id          = 'CUST02'
        sales_order_date     = '20260928'
        transaction_currency = 'USD'
        net_amount           = '6500.00'
        payment_terms_days   = 45
        description          = 'Warehouse Automation Service'
      )


      "==========================================================
      " CUST03 - Helios Technologies
      "==========================================================

      (
        sales_order          = 'SO-99933'
        customer_id          = 'CUST03'
        sales_order_date     = '20260919'
        transaction_currency = 'USD'
        net_amount           = '6750.00'
        payment_terms_days   = 30
        description          = 'Solar Firmware Licenses'
      )

      (
        sales_order          = 'SO-99988'
        customer_id          = 'CUST03'
        sales_order_date     = '20260921'
        transaction_currency = 'USD'
        net_amount           = '1800.00'
        payment_terms_days   = 15
        description          = 'PV Efficiency Audit'
      )


      "==========================================================
      " CUST04 - Northwind Industries
      "==========================================================

      (
        sales_order          = 'SO-10001'
        customer_id          = 'CUST04'
        sales_order_date     = '20260922'
        transaction_currency = 'USD'
        net_amount           = '4500.00'
        payment_terms_days   = 30
        description          = 'Industrial Control Systems'
      )

      (
        sales_order          = 'SO-10002'
        customer_id          = 'CUST04'
        sales_order_date     = '20260926'
        transaction_currency = 'USD'
        net_amount           = '7250.00'
        payment_terms_days   = 45
        description          = 'Factory Automation Consulting'
      )


      "==========================================================
      " CUST05 - BlueWave Retail Group
      "==========================================================

      (
        sales_order          = 'SO-10003'
        customer_id          = 'CUST05'
        sales_order_date     = '20260923'
        transaction_currency = 'USD'
        net_amount           = '3850.00'
        payment_terms_days   = 30
        description          = 'Retail POS Equipment'
      )

      (
        sales_order          = 'SO-10004'
        customer_id          = 'CUST05'
        sales_order_date     = '20260929'
        transaction_currency = 'USD'
        net_amount           = '9200.00'
        payment_terms_days   = 60
        description          = 'E-Commerce Platform Upgrade'
      )


      "==========================================================
      " CUST06 - Apex Manufacturing
      "==========================================================

      (
        sales_order          = 'SO-10005'
        customer_id          = 'CUST06'
        sales_order_date     = '20260920'
        transaction_currency = 'USD'
        net_amount           = '15000.00'
        payment_terms_days   = 60
        description          = 'Production Line Automation'
      )

      (
        sales_order          = 'SO-10006'
        customer_id          = 'CUST06'
        sales_order_date     = '20260930'
        transaction_currency = 'USD'
        net_amount           = '5500.00'
        payment_terms_days   = 30
        description          = 'Equipment Maintenance Service'
      )


      "==========================================================
      " CUST07 - GreenField Energy
      "==========================================================

      (
        sales_order          = 'SO-10007'
        customer_id          = 'CUST07'
        sales_order_date     = '20260917'
        transaction_currency = 'USD'
        net_amount           = '11500.00'
        payment_terms_days   = 45
        description          = 'Energy Monitoring Platform'
      )

      (
        sales_order          = 'SO-10008'
        customer_id          = 'CUST07'
        sales_order_date     = '20260927'
        transaction_currency = 'USD'
        net_amount           = '7800.00'
        payment_terms_days   = 30
        description          = 'Solar Plant Monitoring'
      )


      "==========================================================
      " CUST08 - Nova Healthcare
      "==========================================================

      (
        sales_order          = 'SO-10009'
        customer_id          = 'CUST08'
        sales_order_date     = '20260924'
        transaction_currency = 'USD'
        net_amount           = '6200.00'
        payment_terms_days   = 30
        description          = 'Healthcare Data Integration'
      )

      (
        sales_order          = 'SO-10010'
        customer_id          = 'CUST08'
        sales_order_date     = '20261001'
        transaction_currency = 'USD'
        net_amount           = '4100.00'
        payment_terms_days   = 15
        description          = 'Clinical Reporting Service'
      )


      "==========================================================
      " CUST09 - Metro Digital Solutions
      "==========================================================

      (
        sales_order          = 'SO-10011'
        customer_id          = 'CUST09'
        sales_order_date     = '20260916'
        transaction_currency = 'USD'
        net_amount           = '13500.00'
        payment_terms_days   = 60
        description          = 'Enterprise Cloud Platform'
      )

      (
        sales_order          = 'SO-10012'
        customer_id          = 'CUST09'
        sales_order_date     = '20261002'
        transaction_currency = 'USD'
        net_amount           = '8600.00'
        payment_terms_days   = 30
        description          = 'Cybersecurity Assessment'
      )


      "==========================================================
      " CUST10 - Pacific Trading Group
      "==========================================================

      (
        sales_order          = 'SO-10013'
        customer_id          = 'CUST10'
        sales_order_date     = '20260914'
        transaction_currency = 'USD'
        net_amount           = '10200.00'
        payment_terms_days   = 45
        description          = 'Supply Chain Integration'
      )

      (
        sales_order          = 'SO-10014'
        customer_id          = 'CUST10'
        sales_order_date     = '20261003'
        transaction_currency = 'USD'
        net_amount           = '5750.00'
        payment_terms_days   = 30
        description          = 'Trading Analytics Dashboard'
      )

    ).

    DELETE FROM zteam4_so.

    INSERT zteam4_so
      FROM TABLE @lt_sales_order.

    IF sy-subrc = 0.

      out->write(
        'Sales Order mock data created successfully.'
      ).

    ELSE.

      out->write(
        'Error while creating Sales Order mock data.'
      ).

    ENDIF.

  ENDMETHOD.

ENDCLASS.
