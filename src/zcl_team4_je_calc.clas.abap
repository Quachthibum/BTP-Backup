CLASS zcl_team4_je_calc DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_amounts,
        tax_amount   TYPE zteam4_jeh-tax_amount,
        gross_amount TYPE zteam4_jeh-gross_amount,
      END OF ty_amounts,

      BEGIN OF ty_item,
        debit_credit TYPE zteam4_jei-debit_credit,
        amount       TYPE zteam4_jei-amount,
      END OF ty_item,

      tt_items TYPE STANDARD TABLE OF ty_item
        WITH EMPTY KEY,

      BEGIN OF ty_totals,
        debit  TYPE zteam4_jei-amount,
        credit TYPE zteam4_jei-amount,
        count  TYPE i,
      END OF ty_totals.

    CLASS-METHODS:
      calculate_amounts
        IMPORTING
          iv_net_amount TYPE zteam4_jeh-net_amount
          iv_tax_rate   TYPE zteam4_jeh-tax_rate
        RETURNING
          VALUE(rs_result) TYPE ty_amounts,

      calculate_totals
        IMPORTING
          it_items TYPE tt_items
        RETURNING
          VALUE(rs_result) TYPE ty_totals,

      is_balanced
        IMPORTING
          is_totals TYPE ty_totals
        RETURNING
          VALUE(rv_result) TYPE abap_bool.

ENDCLASS.
CLASS zcl_team4_je_calc IMPLEMENTATION.

  METHOD calculate_amounts.

    rs_result-tax_amount =
      iv_net_amount * iv_tax_rate / 100.

    rs_result-gross_amount =
      iv_net_amount + rs_result-tax_amount.

  ENDMETHOD.


  METHOD calculate_totals.

    LOOP AT it_items INTO DATA(ls_item).

      rs_result-count += 1.

      CASE to_upper( ls_item-debit_credit ).

        WHEN zcl_team4_je_config=>dc-debit_s
          OR zcl_team4_je_config=>dc-debit_d.

          rs_result-debit += ls_item-amount.

        WHEN zcl_team4_je_config=>dc-credit_h
          OR zcl_team4_je_config=>dc-credit_c.

          rs_result-credit += ls_item-amount.

      ENDCASE.

    ENDLOOP.

  ENDMETHOD.


  METHOD is_balanced.

    rv_result = xsdbool(
      is_totals-count > 0
      AND is_totals-debit > 0
      AND is_totals-credit > 0
      AND is_totals-debit = is_totals-credit
    ).

  ENDMETHOD.

ENDCLASS.
