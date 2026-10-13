CLASS zcl_team4_je_config DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.

    CONSTANTS:
      BEGIN OF status,
        parked  TYPE zteam4_jeh-status VALUE 'P',
        open    TYPE zteam4_jeh-status VALUE 'O',
        cleared TYPE zteam4_jeh-status VALUE 'C',
      END OF status,

      BEGIN OF status_text,
        parked  TYPE zteam4_jeh-status_text VALUE 'Parked',
        posted  TYPE zteam4_jeh-status_text VALUE 'Posted',
        cleared TYPE zteam4_jeh-status_text VALUE 'Cleared',
      END OF status_text,

      BEGIN OF criticality,
        parked  TYPE zteam4_jeh-status_criticality VALUE 1,
        posted  TYPE zteam4_jeh-status_criticality VALUE 2,
        cleared TYPE zteam4_jeh-status_criticality VALUE 3,
      END OF criticality,

      BEGIN OF dc,
        debit_s  TYPE zteam4_jei-debit_credit VALUE 'S',
        debit_d  TYPE zteam4_jei-debit_credit VALUE 'D',
        credit_h TYPE zteam4_jei-debit_credit VALUE 'H',
        credit_c TYPE zteam4_jei-debit_credit VALUE 'C',
      END OF dc,

      BEGIN OF item_no,
        customer TYPE zteam4_jei-item_no VALUE '001',
        revenue  TYPE zteam4_jei-item_no VALUE '002',
        tax      TYPE zteam4_jei-item_no VALUE '003',
      END OF item_no,

      BEGIN OF posting,
        gl_customer TYPE zteam4_jei-gl_account VALUE '1400000000',
        gl_revenue  TYPE zteam4_jei-gl_account VALUE '4000000000',
        gl_tax      TYPE zteam4_jei-gl_account VALUE '2200000000',
        tax_code    TYPE zteam4_jei-tax_code VALUE 'A1',
      END OF posting,

      BEGIN OF default,
        currency TYPE zteam4_jeh-transaction_currency VALUE 'USD',
        tax_rate TYPE zteam4_jeh-tax_rate VALUE '10.00',
        due_days TYPE i VALUE 30,
      END OF default.

ENDCLASS.


CLASS zcl_team4_je_config IMPLEMENTATION.
ENDCLASS.
