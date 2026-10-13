CLASS zcm_team4_jeh DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    INTERFACES if_t100_message.
    INTERFACES if_t100_dyn_msg.
    INTERFACES if_abap_behv_message.

    CONSTANTS:
      gc_msgid TYPE symsgid VALUE 'ZFI_TEAM4_JE'.

    CONSTANTS:
      BEGIN OF company_code_required,
        msgid TYPE symsgid VALUE 'ZFI_TEAM4_JE',
        msgno TYPE symsgno VALUE '001',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF company_code_required,

      BEGIN OF net_amount_invalid,
        msgid TYPE symsgid VALUE 'ZFI_TEAM4_JE',
        msgno TYPE symsgno VALUE '002',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF net_amount_invalid,

      BEGIN OF due_date_before_posting,
        msgid TYPE symsgid VALUE 'ZFI_TEAM4_JE',
        msgno TYPE symsgno VALUE '003',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF due_date_before_posting,

      BEGIN OF status_invalid,
        msgid TYPE symsgid VALUE 'ZFI_TEAM4_JE',
        msgno TYPE symsgno VALUE '004',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF status_invalid,

      BEGIN OF cleared_doc_no_modify,
        msgid TYPE symsgid VALUE 'ZFI_TEAM4_JE',
        msgno TYPE symsgno VALUE '005',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF cleared_doc_no_modify,

      BEGIN OF customer_not_exist,
        msgid TYPE symsgid VALUE 'ZFI_TEAM4_JE',
        msgno TYPE symsgno VALUE '006',
        attr1 TYPE scx_attrname VALUE 'MV_ATTR1',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF customer_not_exist,

      BEGIN OF company_code_invalid,
        msgid TYPE symsgid VALUE 'ZFI_TEAM4_JE',
        msgno TYPE symsgno VALUE '007',
        attr1 TYPE scx_attrname VALUE 'MV_ATTR1',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF company_code_invalid,

      BEGIN OF tax_rate_invalid,
        msgid TYPE symsgid VALUE 'ZFI_TEAM4_JE',
        msgno TYPE symsgno VALUE '008',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF tax_rate_invalid,

      BEGIN OF gl_account_required,
        msgid TYPE symsgid VALUE 'ZFI_TEAM4_JE',
        msgno TYPE symsgno VALUE '009',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF gl_account_required,

      BEGIN OF item_amount_invalid,
        msgid TYPE symsgid VALUE 'ZFI_TEAM4_JE',
        msgno TYPE symsgno VALUE '010',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF item_amount_invalid,

      BEGIN OF debit_credit_invalid,
        msgid TYPE symsgid VALUE 'ZFI_TEAM4_JE',
        msgno TYPE symsgno VALUE '011',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF debit_credit_invalid,

      BEGIN OF currency_mismatch,
        msgid TYPE symsgid VALUE 'ZFI_TEAM4_JE',
        msgno TYPE symsgno VALUE '012',
        attr1 TYPE scx_attrname VALUE 'MV_ATTR1',
        attr2 TYPE scx_attrname VALUE 'MV_ATTR2',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF currency_mismatch,

      BEGIN OF entry_not_balanced,
        msgid TYPE symsgid VALUE 'ZFI_TEAM4_JE',
        msgno TYPE symsgno VALUE '013',
        attr1 TYPE scx_attrname VALUE 'MV_ATTR1',
        attr2 TYPE scx_attrname VALUE 'MV_ATTR2',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF entry_not_balanced,

      BEGIN OF sales_order_not_exist,
        msgid TYPE symsgid VALUE 'ZFI_TEAM4_JE',
        msgno TYPE symsgno VALUE '014',
        attr1 TYPE scx_attrname VALUE 'MV_ATTR1',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF sales_order_not_exist,

      BEGIN OF so_customer_mismatch,
        msgid TYPE symsgid VALUE 'ZFI_TEAM4_JE',
        msgno TYPE symsgno VALUE '015',
        attr1 TYPE scx_attrname VALUE 'MV_ATTR1',
        attr2 TYPE scx_attrname VALUE 'MV_ATTR2',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF so_customer_mismatch,

      BEGIN OF lines_only_for_parked,
        msgid TYPE symsgid VALUE 'ZFI_TEAM4_JE',
        msgno TYPE symsgno VALUE '016',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF lines_only_for_parked,

      BEGIN OF tax_or_gross_invalid,
        msgid TYPE symsgid VALUE 'ZFI_TEAM4_JE',
        msgno TYPE symsgno VALUE '017',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF tax_or_gross_invalid,

      BEGIN OF currency_required,
        msgid TYPE symsgid VALUE 'ZFI_TEAM4_JE',
        msgno TYPE symsgno VALUE '018',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF currency_required,

      BEGIN OF items_already_exist,
        msgid TYPE symsgid VALUE 'ZFI_TEAM4_JE',
        msgno TYPE symsgno VALUE '019',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF items_already_exist,

      BEGIN OF items_generated_success,
        msgid TYPE symsgid VALUE 'ZFI_TEAM4_JE',
        msgno TYPE symsgno VALUE '020',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF items_generated_success,

      BEGIN OF items_gen_failed,
        msgid TYPE symsgid VALUE 'ZFI_TEAM4_JE',
        msgno TYPE symsgno VALUE '021',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF items_gen_failed,

      BEGIN OF post_only_parked,
        msgid TYPE symsgid VALUE 'ZFI_TEAM4_JE',
        msgno TYPE symsgno VALUE '022',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF post_only_parked,

      BEGIN OF already_has_doc_no,
        msgid TYPE symsgid VALUE 'ZFI_TEAM4_JE',
        msgno TYPE symsgno VALUE '023',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF already_has_doc_no,

      BEGIN OF generate_items_first,
        msgid TYPE symsgid VALUE 'ZFI_TEAM4_JE',
        msgno TYPE symsgno VALUE '024',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF generate_items_first,

      BEGIN OF doc_posted_success,
        msgid TYPE symsgid VALUE 'ZFI_TEAM4_JE',
        msgno TYPE symsgno VALUE '025',
        attr1 TYPE scx_attrname VALUE 'MV_ATTR1',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF doc_posted_success,

      BEGIN OF doc_post_failed,
        msgid TYPE symsgid VALUE 'ZFI_TEAM4_JE',
        msgno TYPE symsgno VALUE '026',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF doc_post_failed,

      BEGIN OF clear_only_posted,
        msgid TYPE symsgid VALUE 'ZFI_TEAM4_JE',
        msgno TYPE symsgno VALUE '027',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF clear_only_posted,

      BEGIN OF doc_no_required_clear,
        msgid TYPE symsgid VALUE 'ZFI_TEAM4_JE',
        msgno TYPE symsgno VALUE '028',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF doc_no_required_clear,

      BEGIN OF already_cleared,
        msgid TYPE symsgid VALUE 'ZFI_TEAM4_JE',
        msgno TYPE symsgno VALUE '029',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF already_cleared,

      BEGIN OF doc_cleared_success,
        msgid TYPE symsgid VALUE 'ZFI_TEAM4_JE',
        msgno TYPE symsgno VALUE '030',
        attr1 TYPE scx_attrname VALUE 'MV_ATTR1',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF doc_cleared_success,

      BEGIN OF doc_clear_failed,
        msgid TYPE symsgid VALUE 'ZFI_TEAM4_JE',
        msgno TYPE symsgno VALUE '031',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF doc_clear_failed,

      BEGIN OF header_derive_failed,
        msgid TYPE symsgid VALUE 'ZFI_TEAM4_JE',
        msgno TYPE symsgno VALUE '032',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF header_derive_failed,

      BEGIN OF old_items_remove_failed,
        msgid TYPE symsgid VALUE 'ZFI_TEAM4_JE',
        msgno TYPE symsgno VALUE '033',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF old_items_remove_failed,

      BEGIN OF due_date_invalid,
        msgid TYPE symsgid VALUE 'ZFI_TEAM4_JE',
        msgno TYPE symsgno VALUE '034',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF due_date_invalid,

      BEGIN OF fiscal_year_invalid,
        msgid TYPE symsgid VALUE 'ZFI_TEAM4_JE',
        msgno TYPE symsgno VALUE '035',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF fiscal_year_invalid.

    DATA mv_attr1 TYPE string.
    DATA mv_attr2 TYPE string.
    DATA mv_attr3 TYPE string.
    DATA mv_attr4 TYPE string.

    METHODS constructor
      IMPORTING
        severity   TYPE if_abap_behv_message=>t_severity DEFAULT if_abap_behv_message=>severity-error
        textid     LIKE if_t100_message=>t100key OPTIONAL
        previous   LIKE previous OPTIONAL
        attr1      TYPE string OPTIONAL
        attr2      TYPE string OPTIONAL
        attr3      TYPE string OPTIONAL
        attr4      TYPE string OPTIONAL.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcm_team4_jeh IMPLEMENTATION.

  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    CALL METHOD super->constructor
      EXPORTING
        previous = previous.

    CLEAR me->textid.
    IF textid IS INITIAL.
      if_t100_message~t100key = if_t100_message=>default_textid.
    ELSE.
      if_t100_message~t100key = textid.
    ENDIF.

    me->if_abap_behv_message~m_severity = severity.
    me->mv_attr1 = attr1.
    me->mv_attr2 = attr2.
    me->mv_attr3 = attr3.
    me->mv_attr4 = attr4.
  ENDMETHOD.

ENDCLASS.

