CLASS zcl_team4_init_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun.

ENDCLASS.


CLASS zcl_team4_init_data IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    DATA lt_customer TYPE TABLE OF zteam4_customer.

    lt_customer = VALUE #(

      (
        customer_id   = 'CUST01'
        customer_name = 'Acme Corporation'
        postcode      = '10001'
        city          = 'New York'
        country       = 'USA'
        telephone     = '1111111111'
      )

      (
        customer_id   = 'CUST02'
        customer_name = 'Global Logistics LLC'
        postcode      = '60601'
        city          = 'Chicago'
        country       = 'USA'
        telephone     = '2222222222'
      )

      (
        customer_id   = 'CUST03'
        customer_name = 'Helios Technologies'
        postcode      = '92101'
        city          = 'San Diego'
        country       = 'USA'
        telephone     = '3333333333'
      )

      (
        customer_id   = 'CUST04'
        customer_name = 'Northwind Industries'
        postcode      = '98101'
        city          = 'Seattle'
        country       = 'USA'
        telephone     = '4444444444'
      )

      (
        customer_id   = 'CUST05'
        customer_name = 'BlueWave Retail Group'
        postcode      = '33101'
        city          = 'Miami'
        country       = 'USA'
        telephone     = '5555555555'
      )

      (
        customer_id   = 'CUST06'
        customer_name = 'Apex Manufacturing'
        postcode      = '48201'
        city          = 'Detroit'
        country       = 'USA'
        telephone     = '6666666666'
      )

      (
        customer_id   = 'CUST07'
        customer_name = 'GreenField Energy'
        postcode      = '73301'
        city          = 'Austin'
        country       = 'USA'
        telephone     = '7777777777'
      )

      (
        customer_id   = 'CUST08'
        customer_name = 'Nova Healthcare'
        postcode      = '02108'
        city          = 'Boston'
        country       = 'USA'
        telephone     = '8888888888'
      )

      (
        customer_id   = 'CUST09'
        customer_name = 'Metro Digital Solutions'
        postcode      = '94102'
        city          = 'San Francisco'
        country       = 'USA'
        telephone     = '9999999999'
      )

      (
        customer_id   = 'CUST10'
        customer_name = 'Pacific Trading Group'
        postcode      = '90001'
        city          = 'Los Angeles'
        country       = 'USA'
        telephone     = '1010101010'
      )

    ).

    DELETE FROM zteam4_customer.

    INSERT zteam4_customer
      FROM TABLE @lt_customer.


    UPDATE zteam4_jeh SET status_criticality = 1 WHERE status = 'P'.
    UPDATE zteam4_jeh SET status_criticality = 2 WHERE status = 'O'.
    UPDATE zteam4_jeh SET status_criticality = 3 WHERE status = 'C'.
    UPDATE zteam4_jeh SET status_text = 'Parked' WHERE status = 'P'.
    UPDATE zteam4_jeh SET status_text = 'Posted/Open' WHERE status = 'O'.
    UPDATE zteam4_jeh SET status_text = 'Cleared' WHERE status = 'C'.
    COMMIT WORK.

    UPDATE zteam4_jeh_d SET statuscriticality = 1 WHERE status = 'P'.
    UPDATE zteam4_jeh_d SET statuscriticality = 2 WHERE status = 'O'.
    UPDATE zteam4_jeh_d SET statuscriticality = 3 WHERE status = 'C'.
    UPDATE zteam4_jeh_d SET statustext = 'Parked' WHERE status = 'P'.
    UPDATE zteam4_jeh_d SET statustext = 'Posted/Open' WHERE status = 'O'.
    UPDATE zteam4_jeh_d SET statustext = 'Cleared' WHERE status = 'C'.
    COMMIT WORK.

    IF sy-subrc = 0.

      out->write(
        'Customer mock data created successfully.'
      ).

    ELSE.

      out->write(
        'Error while creating customer data.'
      ).

    ENDIF.

  ENDMETHOD.

ENDCLASS.
