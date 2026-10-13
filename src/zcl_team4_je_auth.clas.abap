CLASS zcl_team4_je_auth DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.

    CLASS-METHODS:
      get_current_user
        RETURNING
          VALUE(rv_user) TYPE string,

      is_chief
        RETURNING
          VALUE(rv_result) TYPE abap_bool,

      is_accountant
        RETURNING
          VALUE(rv_result) TYPE abap_bool,

      is_known_user
        RETURNING
          VALUE(rv_result) TYPE abap_bool.

  PRIVATE SECTION.

    CONSTANTS:
      gc_user_chief      TYPE string VALUE 'CB9980000333',
      gc_user_accountant TYPE string VALUE 'CB9980001379'.

ENDCLASS.


CLASS zcl_team4_je_auth IMPLEMENTATION.

  METHOD get_current_user.

    rv_user = to_upper(
      cl_abap_context_info=>get_user_technical_name( )
    ).

  ENDMETHOD.


  METHOD is_chief.

    rv_result = xsdbool(
      get_current_user( ) = gc_user_chief
    ).

  ENDMETHOD.


  METHOD is_accountant.

    rv_result = xsdbool(
      get_current_user( ) = gc_user_accountant
    ).

  ENDMETHOD.


  METHOD is_known_user.

    rv_result = xsdbool(
      is_chief( ) = abap_true
      OR
      is_accountant( ) = abap_true
    ).

  ENDMETHOD.

ENDCLASS.
