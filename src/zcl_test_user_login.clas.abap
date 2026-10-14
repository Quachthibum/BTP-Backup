CLASS zcl_test_user_login DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.

CLASS zcl_test_user_login IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    DELETE FROM zteam4_custbank.
    INSERT zteam4_custbank FROM TABLE @( VALUE #(
      ( customer = 'CUST01' bank_id = 'B001' bank_name = 'First National Bank'
        bank_account = '****4421' gl_account = '111000' )
      ( customer = 'CUST01' bank_id = 'B002' bank_name = 'Chase Business Banking'
        bank_account = '****8810' gl_account = '111100' )
      ( customer = 'CUST02' bank_id = 'B001' bank_name = 'Citibank N.A.'
        bank_account = '****0057' gl_account = '111000' )
      ( customer = 'CUST03' bank_id = 'B001' bank_name = 'Deutsche Bank AG'
        bank_account = '****7745' gl_account = '111200' ) ) ).
    out->write( |{ sy-dbcnt } rows inserted| ).
  ENDMETHOD.
ENDCLASS.
