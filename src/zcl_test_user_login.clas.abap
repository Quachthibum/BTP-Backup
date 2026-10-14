CLASS zcl_test_user_login DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.

CLASS zcl_test_user_login IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    DATA lt_bank TYPE STANDARD TABLE OF zteam4_custbank WITH EMPTY KEY.

    lt_bank = VALUE #(
      " CUST01: two banks -> no preselect. B002 is deliberately low (insufficient-balance test)
      ( customer = 'CUST01' bank_id = 'B001' bank_name = 'First National Bank'
        bank_account = '****4421' gl_account = '111000' currency = 'USD' balance = '50000.00' )
      ( customer = 'CUST01' bank_id = 'B002' bank_name = 'Chase Business Banking'
        bank_account = '****8810' gl_account = '111100' currency = 'USD' balance = '500.00' )
      " CUST02-CUST10: exactly one bank each -> preselected by GetDefaultsForClear
      ( customer = 'CUST02' bank_id = 'B003' bank_name = 'Citibank N.A.'
        bank_account = '****0057' gl_account = '111000' currency = 'USD' balance = '60000.00' )
      ( customer = 'CUST03' bank_id = 'B004' bank_name = 'Deutsche Bank AG'
        bank_account = '****7745' gl_account = '111200' currency = 'USD' balance = '40000.00' )
      ( customer = 'CUST04' bank_id = 'B005' bank_name = 'Wells Fargo Bank'
        bank_account = '****3312' gl_account = '111000' currency = 'USD' balance = '30000.00' )
      ( customer = 'CUST05' bank_id = 'B006' bank_name = 'Bank of America'
        bank_account = '****9021' gl_account = '111000' currency = 'USD' balance = '30000.00' )
      ( customer = 'CUST06' bank_id = 'B007' bank_name = 'JPMorgan Chase'
        bank_account = '****5568' gl_account = '111100' currency = 'USD' balance = '80000.00' )
      ( customer = 'CUST07' bank_id = 'B008' bank_name = 'U.S. Bank'
        bank_account = '****1170' gl_account = '111000' currency = 'USD' balance = '45000.00' )
      ( customer = 'CUST08' bank_id = 'B009' bank_name = 'PNC Bank'
        bank_account = '****6643' gl_account = '111200' currency = 'USD' balance = '25000.00' )
      ( customer = 'CUST09' bank_id = 'B010' bank_name = 'Silicon Valley Bank'
        bank_account = '****2285' gl_account = '111100' currency = 'USD' balance = '70000.00' )
      ( customer = 'CUST10' bank_id = 'B011' bank_name = 'Bank of the West'
        bank_account = '****7714' gl_account = '111000' currency = 'USD' balance = '55000.00' ) ).

    DELETE FROM zteam4_custbank.
    INSERT zteam4_custbank FROM TABLE @lt_bank.
    DATA(lv_count) = sy-dbcnt.
    COMMIT WORK.

    out->write( |{ lv_count } rows inserted| ).
  ENDMETHOD.
ENDCLASS.
