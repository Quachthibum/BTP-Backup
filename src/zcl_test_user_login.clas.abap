CLASS zcl_test_user_login DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

ENDCLASS.


CLASS zcl_test_user_login IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    DATA(lv_user_id) =
      cl_abap_context_info=>get_user_technical_name( ).

    DATA(lv_user_name) =
      cl_abap_context_info=>get_user_formatted_name( ).

    out->write( |Technical User ID : { lv_user_id }| ).
    out->write( |User Name         : { lv_user_name }| ).

  ENDMETHOD.

ENDCLASS.
