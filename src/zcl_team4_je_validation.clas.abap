CLASS zcl_team4_je_validation DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.

    CLASS-METHODS:

      valid_tax_rate
        IMPORTING
          iv_tax_rate TYPE zteam4_jeh-tax_rate
        RETURNING
          VALUE(rv_valid) TYPE abap_bool,

      valid_due_date
        IMPORTING
          iv_posting_date TYPE zteam4_jeh-posting_date
          iv_due_date     TYPE zteam4_jeh-due_date
        RETURNING
          VALUE(rv_valid) TYPE abap_bool,

      valid_fiscal_year
        IMPORTING
          iv_fiscal_year  TYPE zteam4_jeh-fiscal_year
          iv_posting_date TYPE zteam4_jeh-posting_date
        RETURNING
          VALUE(rv_valid) TYPE abap_bool,

      valid_status
        IMPORTING
          iv_status TYPE zteam4_jeh-status
        RETURNING
          VALUE(rv_valid) TYPE abap_bool.

ENDCLASS.
CLASS zcl_team4_je_validation IMPLEMENTATION.

  METHOD valid_tax_rate.

    rv_valid = xsdbool(
      iv_tax_rate >= 0
      AND iv_tax_rate <= 100
    ).

  ENDMETHOD.


  METHOD valid_due_date.

    rv_valid = xsdbool(
      iv_due_date IS INITIAL
      OR iv_posting_date IS INITIAL
      OR iv_due_date >= iv_posting_date
    ).

  ENDMETHOD.


  METHOD valid_fiscal_year.

    rv_valid = xsdbool(
      iv_fiscal_year IS INITIAL
      OR iv_posting_date IS INITIAL
      OR iv_fiscal_year = iv_posting_date(4)
    ).

  ENDMETHOD.


  METHOD valid_status.

    rv_valid = xsdbool(
      iv_status = zcl_team4_je_config=>status-parked
      OR iv_status = zcl_team4_je_config=>status-open
      OR iv_status = zcl_team4_je_config=>status-cleared
    ).

  ENDMETHOD.

ENDCLASS.
