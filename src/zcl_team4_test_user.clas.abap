CLASS zcl_team4_test_user DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

ENDCLASS.


CLASS zcl_team4_test_user IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    SELECT
      FROM I_APIsForCloudDevelopment
      FIELDS
        ReleasedObjectType,
        ReleasedObjectName,
        ReleaseState,
        ReleaseStateDescription
      WHERE ReleasedObjectName LIKE '%USER%'
      INTO TABLE @DATA(lt_api).

    out->write( |Released USER APIs found: { lines( lt_api ) }| ).

    LOOP AT lt_api INTO DATA(ls_api).

      out->write(
        |{ ls_api-ReleasedObjectType } ; | &&
        |{ ls_api-ReleasedObjectName } ; | &&
        |{ ls_api-ReleaseState } ; | &&
        |{ ls_api-ReleaseStateDescription }|
      ).

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
