CLASS zcl_team4_je_numbering DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.

    CLASS-METHODS next_document_number
      IMPORTING
        iv_current TYPE zteam4_jeh-document_number
      RETURNING
        VALUE(rv_number) TYPE zteam4_jeh-document_number.

    CLASS-METHODS next_clearing_number
      IMPORTING
        iv_current TYPE zteam4_jeh-clearing_document
      RETURNING
        VALUE(rv_number) TYPE zteam4_jeh-clearing_document.

ENDCLASS.
CLASS zcl_team4_je_numbering IMPLEMENTATION.

  METHOD next_document_number.

    DATA lv_next TYPE i.

    TRY.

        lv_next = COND #(
          WHEN iv_current IS INITIAL
          THEN 1
          ELSE CONV i( iv_current ) + 1
        ).

      CATCH cx_sy_conversion_no_number
            cx_sy_conversion_overflow.

        lv_next = 1.

    ENDTRY.

    rv_number =
      |{ lv_next WIDTH = 10 ALIGN = RIGHT PAD = '0' }|.

  ENDMETHOD.


  METHOD next_clearing_number.

    DATA lv_next TYPE i.

    TRY.

        lv_next = COND #(
          WHEN iv_current IS INITIAL
          THEN 1
          ELSE CONV i( iv_current ) + 1
        ).

      CATCH cx_sy_conversion_no_number
            cx_sy_conversion_overflow.

        lv_next = 1.

    ENDTRY.

    rv_number =
      |{ lv_next WIDTH = 10 ALIGN = RIGHT PAD = '0' }|.

  ENDMETHOD.

ENDCLASS.
