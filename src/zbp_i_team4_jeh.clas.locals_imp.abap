CLASS lhc_Header DEFINITION
  INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    CONSTANTS:
      gc_status_parked   TYPE zteam4_jeh-status VALUE 'P',
      gc_status_open     TYPE zteam4_jeh-status VALUE 'O',
      gc_status_cleared  TYPE zteam4_jeh-status VALUE 'C',

      "Debit/Credit indicators used by generated posting items.
      gc_debit           TYPE zteam4_jei-debit_credit VALUE 'S',
      gc_credit          TYPE zteam4_jei-debit_credit VALUE 'H',

      "Fixed item numbers used by the three-line posting model.
      gc_item_customer   TYPE zteam4_jei-item_no VALUE '001',
      gc_item_revenue    TYPE zteam4_jei-item_no VALUE '002',
      gc_item_tax        TYPE zteam4_jei-item_no VALUE '003',

      "Mock G/L accounts used for receivable, revenue, and tax.
      gc_gl_customer     TYPE zteam4_jei-gl_account VALUE '1400000000',
      gc_gl_revenue      TYPE zteam4_jei-gl_account VALUE '4000000000',
      gc_gl_tax          TYPE zteam4_jei-gl_account VALUE '2200000000',
      "Tax code assigned to the output tax posting item.
      gc_tax_code        TYPE zteam4_jei-tax_code VALUE 'A1',

      "Mock technical users used to simulate workflow roles.
      gc_user_chief      TYPE string VALUE 'CB9980001379',
      gc_user_accountant TYPE string VALUE 'CB9980001379'.

    "----------------------------------------------------------
    " Early numbering for Header -> _Items
    "----------------------------------------------------------
    METHODS earlynumbering_cba_Item
      FOR NUMBERING
      IMPORTING entities
                  FOR CREATE Header\_Items.

    " Authorization / Features
    METHODS get_instance_authorizations
      FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations
      FOR Header RESULT result.

    METHODS get_instance_features
      FOR INSTANCE FEATURES
      keys REQUEST requested_features
      FOR Header RESULT result.

    METHODS generatepostings FOR MODIFY
      keys FOR ACTION Header~GeneratePostings
      RESULT result.

    METHODS post FOR MODIFY
      keys FOR ACTION Header~Post
      RESULT result.

    METHODS clear FOR MODIFY
      keys FOR ACTION Header~Clear
      RESULT result.

    METHODS setinitialvalues FOR DETERMINE ON MODIFY
       keys FOR Header~setInitialValues.

    METHODS calculateamounts FOR DETERMINE ON MODIFY
       keys FOR Header~calculateAmounts.

    METHODS validateheader FOR VALIDATE ON SAVE
       keys FOR Header~validateHeader.

    METHODS validatebalance FOR VALIDATE ON SAVE
       keys FOR Header~validateBalance.

    METHODS deriveFromSalesOrder FOR DETERMINE ON MODIFY
       keys FOR Header~deriveFromSalesOrder.
    METHODS checkReferenceExists FOR VALIDATE ON SAVE
       keys FOR Header~checkReferenceExists.

    METHODS emptyOnSave FOR VALIDATE ON SAVE
       keys FOR Header~emptyOnSave.

    METHODS deriveCustomerName FOR DETERMINE ON MODIFY
       keys FOR Header~deriveCustomerName.
    METHODS ownerIsUser FOR VALIDATE ON SAVE
       keys FOR Header~ownerIsUser.
    METHODS GetDefaultsForClear FOR READ
       keys FOR FUNCTION Header~GetDefaultsForClear RESULT result.


    METHODS get_next_number
      IMPORTING
        iv_current_max   TYPE zteam4_jeh-document_number
      RETURNING
        VALUE(rv_number) TYPE zteam4_jeh-document_number.

ENDCLASS.

CLASS lhc_Header IMPLEMENTATION.

  METHOD get_instance_authorizations.

    DATA(lv_user) =
      to_upper(
        cl_abap_context_info=>get_user_technical_name( )
      ).

    READ ENTITIES OF zi_team4_jeh IN LOCAL MODE
      ENTITY Header
        FIELDS ( Status )
        WITH CORRESPONDING #( keys )
      RESULT DATA(headers).

    result = VALUE #(
      FOR header IN headers

      LET is_chief =
            xsdbool(
              lv_user = gc_user_chief
            )

          is_accountant =
            xsdbool(
              lv_user = gc_user_accountant
            )

          is_known_user =
            xsdbool(
              is_chief = abap_true
              OR is_accountant = abap_true
            )

          is_parked =
            xsdbool(
              header-Status = gc_status_parked
            )

          is_open =
            xsdbool(
              header-Status = gc_status_open
            )

          is_cleared =
            xsdbool(
              header-Status = gc_status_cleared
            )

      IN
      (
        %tky = header-%tky

        " Both roles may update Parked/Posted documents.
        %update = COND #(
          WHEN is_known_user = abap_true
           AND is_cleared = abap_false
            THEN if_abap_behv=>auth-allowed
          ELSE
            if_abap_behv=>auth-unauthorized
        )

        " Authorization permits delete for configured users.
        " Parked-only delete is controlled by instance features.
        %delete = COND #(
          WHEN is_known_user = abap_true
            THEN if_abap_behv=>auth-allowed
          ELSE
            if_abap_behv=>auth-unauthorized
        )

        %action-Edit = COND #(
          WHEN is_known_user = abap_true
           AND is_cleared = abap_false
            THEN if_abap_behv=>auth-allowed
          ELSE
            if_abap_behv=>auth-unauthorized
        )

        %action-GeneratePostings = COND #(
          WHEN is_known_user = abap_true
           AND is_parked = abap_true
            THEN if_abap_behv=>auth-allowed
          ELSE
            if_abap_behv=>auth-unauthorized
        )

        " Chief Accountant only.
        %action-Post = COND #(
          WHEN is_chief = abap_true
           AND is_parked = abap_true
            THEN if_abap_behv=>auth-allowed
          ELSE
            if_abap_behv=>auth-unauthorized
        )

        " Chief Accountant only.
        %action-Clear = COND #(
          WHEN is_chief = abap_true
           AND is_open = abap_true
            THEN if_abap_behv=>auth-allowed
          ELSE
            if_abap_behv=>auth-unauthorized
        )
      )
    ).

  ENDMETHOD.

  METHOD get_instance_features.

    DATA(lv_user) =
      to_upper(
        cl_abap_context_info=>get_user_technical_name( )
      ).

    DATA(lv_is_chief) =
      xsdbool(
        lv_user = gc_user_chief
      ).

    DATA(lv_is_accountant) =
      xsdbool(
        lv_user = gc_user_accountant
      ).

    DATA(lv_is_known_user) =
      xsdbool(
        lv_is_chief = abap_true
        OR lv_is_accountant = abap_true
      ).
    "Read the Header status and fields required by feature control.
    READ ENTITIES OF zi_team4_jeh IN LOCAL MODE
      ENTITY Header
        FIELDS (
          JournalEntryUUID
          Status
          Reference
        )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_headers).

    "Read existing Items to control Generate/Post availability.
    READ ENTITIES OF zi_team4_jeh IN LOCAL MODE
      ENTITY Header BY \_Items
        FIELDS (
          JournalEntryUUID
          ItemNo
        )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_items).

    result = VALUE #(
      FOR ls_header IN lt_headers

      LET
          lv_has_items =
            xsdbool(
              line_exists(
                lt_items[
                  JournalEntryUUID = ls_header-JournalEntryUUID
                ]
              )
            )

          lv_has_reference =
            xsdbool(
              ls_header-Reference IS NOT INITIAL
            )

          lv_is_cleared =
            xsdbool(
              ls_header-Status = gc_status_cleared
            )

          lv_is_open =
            xsdbool(
              ls_header-Status = gc_status_open
            )

          lv_is_parked =
            xsdbool(
              ls_header-Status = gc_status_parked
            )

          "Parked and Posted/Open documents may enter Edit mode.
          lv_can_edit =
            xsdbool(
              lv_is_known_user = abap_true
              AND lv_is_cleared = abap_false
            )

          "General accounting fields are editable only while Parked.
           lv_parked_fields_editable =
             xsdbool(
               lv_is_known_user = abap_true
               AND lv_is_parked = abap_true
             )


           "Due Date may be edited for Parked and Posted/Open documents.
            lv_due_date_editable =
              xsdbool(
                lv_is_known_user = abap_true
                AND (
                  lv_is_parked = abap_true
                  OR lv_is_open = abap_true
                )
              )

            "Manual amounts are editable only for a manual Parked JE.
            lv_manual_amount_editable =
              xsdbool(
                lv_parked_fields_editable = abap_true
                AND lv_has_reference = abap_false
              )


      IN
      (
        %tky = ls_header-%tky

        %action-Edit = COND #(
          WHEN lv_can_edit = abap_true
            THEN if_abap_behv=>fc-o-enabled
          ELSE
            if_abap_behv=>fc-o-disabled
        )

        %update = COND #(
          WHEN lv_can_edit = abap_true
            THEN if_abap_behv=>fc-o-enabled
          ELSE
            if_abap_behv=>fc-o-disabled
        )

        %delete = COND #(
          WHEN lv_is_known_user = abap_true
           AND lv_is_parked = abap_true
            THEN if_abap_behv=>fc-o-enabled
          ELSE
            if_abap_behv=>fc-o-disabled
        )

        %field-CompanyCode = COND #(
        WHEN lv_parked_fields_editable = abap_true
          THEN if_abap_behv=>fc-f-unrestricted
        ELSE
          if_abap_behv=>fc-f-read_only
      )

      %field-FiscalYear = COND #(
        WHEN lv_parked_fields_editable = abap_true
          THEN if_abap_behv=>fc-f-unrestricted
        ELSE
          if_abap_behv=>fc-f-read_only
      )

      %field-DocumentType = COND #(
        WHEN lv_parked_fields_editable = abap_true
          THEN if_abap_behv=>fc-f-unrestricted
        ELSE
          if_abap_behv=>fc-f-read_only
      )

      %field-DocumentDate = COND #(
        WHEN lv_parked_fields_editable = abap_true
          THEN if_abap_behv=>fc-f-unrestricted
        ELSE
          if_abap_behv=>fc-f-read_only
      )

      %field-PostingDate = COND #(
        WHEN lv_parked_fields_editable = abap_true
          THEN if_abap_behv=>fc-f-unrestricted
        ELSE
          if_abap_behv=>fc-f-read_only
      )

      %field-TransactionCurrency = COND #(
        WHEN lv_parked_fields_editable = abap_true
          THEN if_abap_behv=>fc-f-unrestricted
        ELSE
          if_abap_behv=>fc-f-read_only
      )

      "Due Date remains editable after Posting.
      %field-DueDate = COND #(
        WHEN lv_due_date_editable = abap_true
          THEN if_abap_behv=>fc-f-unrestricted
        ELSE
          if_abap_behv=>fc-f-read_only
      )

      %field-Customer = COND #(
        WHEN lv_parked_fields_editable = abap_true
          THEN if_abap_behv=>fc-f-unrestricted
        ELSE
          if_abap_behv=>fc-f-read_only
      )

      %field-Reference = COND #(
        WHEN lv_parked_fields_editable = abap_true
          THEN if_abap_behv=>fc-f-unrestricted
        ELSE
          if_abap_behv=>fc-f-read_only
      )
        "Net Amount is manually editable only when there is no
        %field-NetAmount = COND #(
          WHEN lv_manual_amount_editable = abap_true
            THEN if_abap_behv=>fc-f-unrestricted
          ELSE
            if_abap_behv=>fc-f-read_only
        )

        %field-TaxRate = COND #(
          WHEN lv_manual_amount_editable = abap_true
            THEN if_abap_behv=>fc-f-unrestricted
          ELSE
            if_abap_behv=>fc-f-read_only
        )


        " Manual Item creation is allowed only for manual Parked JEs.
        %assoc-_Items = COND #(
          WHEN lv_is_known_user = abap_true
           AND lv_is_parked = abap_true
           AND lv_has_reference = abap_false
            THEN if_abap_behv=>fc-o-enabled
          ELSE
            if_abap_behv=>fc-o-disabled
        )

        %action-GeneratePostings = COND #(
          WHEN lv_is_known_user = abap_true
           AND lv_is_parked = abap_true
           AND lv_has_reference = abap_false
           AND lv_has_items = abap_false
            THEN if_abap_behv=>fc-o-enabled
          ELSE
            if_abap_behv=>fc-o-disabled
        )

        " Chief Accountant only.
        %action-Post = COND #(
          WHEN lv_is_chief = abap_true
           AND lv_is_parked = abap_true
           AND lv_has_items = abap_true
            THEN if_abap_behv=>fc-o-enabled
          ELSE
            if_abap_behv=>fc-o-disabled
        )

        " Chief Accountant only.
        %action-Clear = COND #(
          WHEN lv_is_chief = abap_true
           AND lv_is_open = abap_true
            THEN if_abap_behv=>fc-o-enabled
          ELSE
            if_abap_behv=>fc-o-disabled
        )
      )
    ).

  ENDMETHOD.

  METHOD Clear.

    DATA(lv_user) =
        to_upper(
            cl_abap_context_info=>get_user_technical_name( )
        ).

    " Only the mock Chief Accountant may clear.
    IF lv_user <> gc_user_chief.

      LOOP AT keys INTO DATA(unauthorized_key).

        APPEND VALUE #(
          %tky = unauthorized_key-%tky
        ) TO failed-header.

        APPEND VALUE #(
          %tky = unauthorized_key-%tky
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = |Only the mock Chief Accountant can clear a Journal Entry| )
        ) TO reported-header.

      ENDLOOP.

      RETURN.

    ENDIF.

    READ ENTITIES OF zi_team4_jeh IN LOCAL MODE
      ENTITY Header
        FIELDS (
          Status
          DocumentNumber
          ClearingDocument
          ClearingDate
          Customer
          PostingDate
          GrossAmount
          TransactionCurrency
        )
        WITH CORRESPONDING #( keys )
      RESULT DATA(headers).

    SELECT MAX( clearing_document )
      FROM zteam4_jeh
      INTO @DATA(max_clearing_document).

    DATA next_clearing_number TYPE i.

    IF max_clearing_document IS INITIAL.
      next_clearing_number = 1.
    ELSE.
      TRY.
          next_clearing_number = CONV i( max_clearing_document ) + 1.
        CATCH cx_sy_conversion_no_number.
          next_clearing_number = 1.
      ENDTRY.
    ENDIF.

    LOOP AT headers INTO DATA(header).

      IF header-Status <> gc_status_open.
        APPEND VALUE #( %tky = header-%tky ) TO failed-header.
        APPEND VALUE #(
          %tky = header-%tky
          %element-Status = if_abap_behv=>mk-on
          %msg = NEW zcm_team4_jeh(
            severity = if_abap_behv_message=>severity-error
            textid   = zcm_team4_jeh=>clear_only_posted
          )
        ) TO reported-header.
        CONTINUE.
      ENDIF.

      IF header-DocumentNumber IS INITIAL.
        APPEND VALUE #( %tky = header-%tky ) TO failed-header.
        APPEND VALUE #(
          %tky = header-%tky
          %element-DocumentNumber = if_abap_behv=>mk-on
          %msg = NEW zcm_team4_jeh(
            severity = if_abap_behv_message=>severity-error
            textid   = zcm_team4_jeh=>doc_no_required_clear
          )
        ) TO reported-header.
        CONTINUE.
      ENDIF.

      IF header-ClearingDocument IS NOT INITIAL.
        APPEND VALUE #( %tky = header-%tky ) TO failed-header.
        APPEND VALUE #(
          %tky = header-%tky
          %element-ClearingDocument = if_abap_behv=>mk-on
          %msg = NEW zcm_team4_jeh(
            severity = if_abap_behv_message=>severity-error
            textid   = zcm_team4_jeh=>already_cleared
          )
        ) TO reported-header.
        CONTINUE.
      ENDIF.

      " ---- popup parameters and checks ----
      DATA(param) = keys[ KEY entity %tky = header-%tky ]-%param.

      " Blank date in the popup means today
      DATA(clearing_date) = COND dats(
        WHEN param-ClearingDate IS INITIAL
        THEN cl_abap_context_info=>get_system_date( )
        ELSE param-ClearingDate ).

      SELECT SINGLE gl_account, balance
  FROM zteam4_custbank
  WHERE customer = @header-Customer
    AND bank_id  = @param-BankId
  INTO @DATA(bank).
      DATA(bank_found) = xsdbool( sy-subrc = 0 ).

      DATA(error_text) = VALUE string( ).

      IF bank_found = abap_false.
        error_text = 'Select a bank account that belongs to this customer'.
      ELSEIF clearing_date < header-PostingDate.
        error_text = 'Clearing date cannot be before the posting date'.
      ELSEIF bank-balance < header-GrossAmount.
        error_text = 'Insufficient bank balance to pay this invoice'.
      ENDIF.

      IF error_text IS NOT INITIAL.
        APPEND VALUE #( %tky = header-%tky ) TO failed-header.
        APPEND VALUE #(
          %tky = header-%tky
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = error_text )
        ) TO reported-header.
        CONTINUE.
      ENDIF.
      " ---- end of popup block ----

      DATA clearing_document TYPE zteam4_jeh-clearing_document.
      clearing_document = |{ next_clearing_number WIDTH = 10 ALIGN = RIGHT PAD = '0' }|.
      next_clearing_number += 1.

      MODIFY ENTITIES OF zi_team4_jeh IN LOCAL MODE
        ENTITY Header
          UPDATE FIELDS (
            ClearingDocument
            ClearingDate
            Status
            StatusCriticality
            StatusText
            PaymentBankId
            PaymentBankGL
            PaymentReference
          )
          WITH VALUE #(
            (
              %tky              = header-%tky
              ClearingDocument  = clearing_document
              ClearingDate      = clearing_date
              Status            = gc_status_cleared
              StatusCriticality = 3
              StatusText        = 'Cleared'
              PaymentBankId     = param-BankId
              PaymentBankGL     = bank-gl_account
              PaymentReference  = param-PaymentReference
            )
          )
        FAILED DATA(failed_update)
        REPORTED DATA(reported_update).

      IF failed_update IS NOT INITIAL.
        APPEND VALUE #( %tky = header-%tky ) TO failed-header.
        APPEND VALUE #(
          %tky = header-%tky
          %msg = NEW zcm_team4_jeh(
            severity = if_abap_behv_message=>severity-error
            textid   = zcm_team4_jeh=>doc_clear_failed
          )
        ) TO reported-header.
        CONTINUE.
      ENDIF.

      APPEND VALUE #(
        %tky = header-%tky
        %msg = NEW zcm_team4_jeh(
          severity = if_abap_behv_message=>severity-success
          textid   = zcm_team4_jeh=>doc_cleared_success
          attr1    = CONV #( clearing_document )
        )
      ) TO reported-header.

    ENDLOOP.

    READ ENTITIES OF zi_team4_jeh IN LOCAL MODE
      ENTITY Header
        ALL FIELDS
        WITH CORRESPONDING #( keys )
      RESULT DATA(result_headers).

    result = VALUE #(
      FOR result_header IN result_headers
      (
        %tky   = result_header-%tky
        %param = result_header
      )
    ).

  ENDMETHOD.

  METHOD GeneratePostings.

    READ ENTITIES OF zi_team4_jeh IN LOCAL MODE
      ENTITY Header
        FIELDS (
          JournalEntryUUID
          Status
          NetAmount
          TaxAmount
          GrossAmount
          TransactionCurrency
        )
        WITH CORRESPONDING #( keys )
      RESULT DATA(headers).

    READ ENTITIES OF zi_team4_jeh IN LOCAL MODE
      ENTITY Header BY \_Items
        FIELDS (
          JournalEntryUUID
          ItemNo
        )
        WITH CORRESPONDING #( keys )
      RESULT DATA(existing_items).

    LOOP AT headers INTO DATA(header).

      IF header-Status <> gc_status_parked.
        APPEND VALUE #( %tky = header-%tky ) TO failed-header.
        APPEND VALUE #(
          %tky = header-%tky
          %element-Status = if_abap_behv=>mk-on
          %msg = NEW zcm_team4_jeh(
            severity = if_abap_behv_message=>severity-error
            textid   = zcm_team4_jeh=>lines_only_for_parked
          )
        ) TO reported-header.
        CONTINUE.
      ENDIF.

      IF header-NetAmount <= 0.
        APPEND VALUE #( %tky = header-%tky ) TO failed-header.
        APPEND VALUE #(
          %tky = header-%tky
          %element-NetAmount = if_abap_behv=>mk-on
          %msg = NEW zcm_team4_jeh(
            severity = if_abap_behv_message=>severity-error
            textid   = zcm_team4_jeh=>net_amount_invalid
          )
        ) TO reported-header.
        CONTINUE.
      ENDIF.

      IF header-TaxAmount < 0 OR header-GrossAmount <= 0.
        APPEND VALUE #( %tky = header-%tky ) TO failed-header.
        APPEND VALUE #(
          %tky = header-%tky
          %element-GrossAmount = if_abap_behv=>mk-on
          %msg = NEW zcm_team4_jeh(
            severity = if_abap_behv_message=>severity-error
            textid   = zcm_team4_jeh=>tax_or_gross_invalid
          )
        ) TO reported-header.
        CONTINUE.
      ENDIF.

      IF header-TransactionCurrency IS INITIAL.
        APPEND VALUE #( %tky = header-%tky ) TO failed-header.
        APPEND VALUE #(
          %tky = header-%tky
          %element-TransactionCurrency = if_abap_behv=>mk-on
          %msg = NEW zcm_team4_jeh(
            severity = if_abap_behv_message=>severity-error
            textid   = zcm_team4_jeh=>currency_required
          )
        ) TO reported-header.
        CONTINUE.
      ENDIF.

      IF line_exists( existing_items[ JournalEntryUUID = header-JournalEntryUUID ] ).
        APPEND VALUE #( %tky = header-%tky ) TO failed-header.
        APPEND VALUE #(
          %tky = header-%tky
          %msg = NEW zcm_team4_jeh(
            severity = if_abap_behv_message=>severity-error
            textid   = zcm_team4_jeh=>items_already_exist
          )
        ) TO reported-header.
        CONTINUE.
      ENDIF.

      MODIFY ENTITIES OF zi_team4_jeh IN LOCAL MODE
        ENTITY Header
          CREATE BY \_Items
          AUTO FILL CID
          FIELDS (
            ItemNo
            GLAccount
            GLAccountName
            DebitCredit
            TransactionCurrency
            Amount
            TaxCode
            ItemText
          )
          WITH VALUE #(
            (
              %tky = header-%tky
              %target = VALUE #(
                (
                  ItemNo              = gc_item_customer
                  GLAccount           = gc_gl_customer
                  GLAccountName       = 'Customer Receivable'
                  DebitCredit         = gc_debit
                  TransactionCurrency = header-TransactionCurrency
                  Amount              = header-GrossAmount
                  ItemText            = 'Customer receivable'
                )
                (
                  ItemNo              = gc_item_revenue
                  GLAccount           = gc_gl_revenue
                  GLAccountName       = 'Sales Revenue'
                  DebitCredit         = gc_credit
                  TransactionCurrency = header-TransactionCurrency
                  Amount              = header-NetAmount
                  ItemText            = 'Sales revenue'
                )
                (
                  ItemNo              = gc_item_tax
                  GLAccount           = gc_gl_tax
                  GLAccountName       = 'Output Tax'
                  DebitCredit         = gc_credit
                  TransactionCurrency = header-TransactionCurrency
                  Amount              = header-TaxAmount
                  TaxCode             = gc_tax_code
                  ItemText            = 'Output tax'
                )
              )
            )
          )
        FAILED DATA(failed_create)
        REPORTED DATA(reported_create).

      IF failed_create IS NOT INITIAL.
        APPEND VALUE #( %tky = header-%tky ) TO failed-header.
        APPEND VALUE #(
          %tky = header-%tky
          %msg = NEW zcm_team4_jeh(
            severity = if_abap_behv_message=>severity-error
            textid   = zcm_team4_jeh=>items_gen_failed
          )
        ) TO reported-header.
        CONTINUE.
      ENDIF.

      APPEND VALUE #(
        %tky = header-%tky
        %msg = NEW zcm_team4_jeh(
          severity = if_abap_behv_message=>severity-success
          textid   = zcm_team4_jeh=>items_generated_success
        )
      ) TO reported-header.

    ENDLOOP.

    READ ENTITIES OF zi_team4_jeh IN LOCAL MODE
      ENTITY Header
        ALL FIELDS
        WITH CORRESPONDING #( keys )
      RESULT DATA(result_headers).

    result = VALUE #(
      FOR result_header IN result_headers
      (
        %tky   = result_header-%tky
        %param = result_header
      )
    ).

  ENDMETHOD.

  METHOD Post.

    DATA(lv_user) =
        to_upper(
            cl_abap_context_info=>get_user_technical_name( )
        ).

    " Only the mock Chief Accountant may post.
    IF lv_user <> gc_user_chief.

      LOOP AT keys INTO DATA(unauthorized_key).

        APPEND VALUE #(
        %tky = unauthorized_key-%tky
        ) TO failed-header.

        APPEND VALUE #(
            %tky = unauthorized_key-%tky
            %msg = new_message_with_text(
                severity = if_abap_behv_message=>severity-error
                text = |Only the mock Chief Accountant can post a Journal Entry|
            )
        ) TO reported-header.

      ENDLOOP.

      RETURN.

    ENDIF.

    READ ENTITIES OF zi_team4_jeh IN LOCAL MODE
      ENTITY Header
        FIELDS (
          JournalEntryUUID
          Status
          CompanyCode
          FiscalYear
          DocumentNumber
        )
        WITH CORRESPONDING #( keys )
      RESULT DATA(headers).

    READ ENTITIES OF zi_team4_jeh IN LOCAL MODE
      ENTITY Header BY \_Items
        FIELDS (
          JournalEntryUUID
          ItemNo
          DebitCredit
          Amount
        )
        WITH CORRESPONDING #( keys )
      RESULT DATA(items).

    SELECT MAX( document_number )
      FROM zteam4_jeh
      INTO @DATA(max_document_number).

    DATA(document_number) = get_next_number( max_document_number ).

    LOOP AT headers INTO DATA(header).

      IF header-Status <> gc_status_parked.
        APPEND VALUE #( %tky = header-%tky ) TO failed-header.
        APPEND VALUE #(
          %tky = header-%tky
          %element-Status = if_abap_behv=>mk-on
          %msg = NEW zcm_team4_jeh(
            severity = if_abap_behv_message=>severity-error
            textid   = zcm_team4_jeh=>post_only_parked
          )
        ) TO reported-header.
        CONTINUE.
      ENDIF.

      IF header-DocumentNumber IS NOT INITIAL.
        APPEND VALUE #( %tky = header-%tky ) TO failed-header.
        APPEND VALUE #(
          %tky = header-%tky
          %element-DocumentNumber = if_abap_behv=>mk-on
          %msg = NEW zcm_team4_jeh(
            severity = if_abap_behv_message=>severity-error
            textid   = zcm_team4_jeh=>already_has_doc_no
          )
        ) TO reported-header.
        CONTINUE.
      ENDIF.

      DATA total_debit  TYPE zteam4_jei-amount.
      DATA total_credit TYPE zteam4_jei-amount.
      DATA item_count   TYPE i.

      CLEAR:
        total_debit,
        total_credit,
        item_count.

      LOOP AT items INTO DATA(item)
        WHERE JournalEntryUUID = header-JournalEntryUUID.

        item_count += 1.

        CASE to_upper( item-DebitCredit ).
          WHEN 'S' OR 'D'.
            total_debit += item-Amount.
          WHEN 'H' OR 'C'.
            total_credit += item-Amount.
        ENDCASE.

      ENDLOOP.

      IF item_count = 0.
        APPEND VALUE #( %tky = header-%tky ) TO failed-header.
        APPEND VALUE #(
          %tky = header-%tky
          %msg = NEW zcm_team4_jeh(
            severity = if_abap_behv_message=>severity-error
            textid   = zcm_team4_jeh=>generate_items_first
          )
        ) TO reported-header.
        CONTINUE.
      ENDIF.

      IF total_debit <= 0
         OR total_credit <= 0
         OR total_debit <> total_credit.

        APPEND VALUE #( %tky = header-%tky ) TO failed-header.
        APPEND VALUE #(
          %tky = header-%tky
          %msg = NEW zcm_team4_jeh(
            severity = if_abap_behv_message=>severity-error
            textid   = zcm_team4_jeh=>entry_not_balanced
            attr1    = |{ total_debit NUMBER = USER }|
            attr2    = |{ total_credit NUMBER = USER }|
          )
        ) TO reported-header.
        CONTINUE.
      ENDIF.

      MODIFY ENTITIES OF zi_team4_jeh IN LOCAL MODE
        ENTITY Header
          UPDATE FIELDS (
            DocumentNumber
            Status
            StatusCriticality
            StatusText
          )
          WITH VALUE #(
            (
              %tky              = header-%tky
              DocumentNumber    = document_number
              Status            = gc_status_open
              StatusCriticality = 2
              StatusText        = 'Posted'
            )
          )
        FAILED DATA(failed_update)
        REPORTED DATA(reported_update).

      IF failed_update IS NOT INITIAL.
        APPEND VALUE #( %tky = header-%tky ) TO failed-header.
        APPEND VALUE #(
          %tky = header-%tky
          %msg = NEW zcm_team4_jeh(
            severity = if_abap_behv_message=>severity-error
            textid   = zcm_team4_jeh=>doc_post_failed
          )
        ) TO reported-header.
        CONTINUE.
      ENDIF.

      APPEND VALUE #(
        %tky = header-%tky
        %msg = NEW zcm_team4_jeh(
          severity = if_abap_behv_message=>severity-success
          textid   = zcm_team4_jeh=>doc_posted_success
          attr1    = CONV #( document_number )
        )
      ) TO reported-header.

    ENDLOOP.

    READ ENTITIES OF zi_team4_jeh IN LOCAL MODE
      ENTITY Header
        ALL FIELDS
        WITH CORRESPONDING #( keys )
      RESULT DATA(result_headers).

    result = VALUE #(
      FOR result_header IN result_headers
      (
        %tky   = result_header-%tky
        %param = result_header
      )
    ).

  ENDMETHOD.

  METHOD calculateAmounts.

    READ ENTITIES OF zi_team4_jeh IN LOCAL MODE
      ENTITY Header
        FIELDS (
          NetAmount
          TaxRate
        )
        WITH CORRESPONDING #( keys )
      RESULT DATA(headers).

    MODIFY ENTITIES OF zi_team4_jeh IN LOCAL MODE
      ENTITY Header
        UPDATE FIELDS (
          TaxAmount
          GrossAmount
        )
        WITH VALUE #(
          FOR header IN headers
          LET tax_amount =
            header-NetAmount * header-TaxRate / 100
          IN
          (
            %tky        = header-%tky
            TaxAmount   = tax_amount
            GrossAmount = header-NetAmount + tax_amount
          )
        ).

  ENDMETHOD.

  METHOD setInitialValues.

    DATA(lv_today) = cl_abap_context_info=>get_system_date( ).

    MODIFY ENTITIES OF zi_team4_jeh IN LOCAL MODE
      ENTITY Header
        UPDATE FIELDS (
          Status
          StatusCriticality
          StatusText
          TaxRate
          TransactionCurrency
          DocumentDate
          PostingDate
          FiscalYear
          DueDate
        )
        WITH VALUE #(
          FOR key IN keys
          (
            %tky                = key-%tky
            Status              = gc_status_parked
            StatusCriticality   = 1
            StatusText          = 'Parked'
            TaxRate             = '10.00'
            TransactionCurrency = 'USD'
            DocumentDate        = lv_today
            PostingDate         = lv_today
            FiscalYear          = lv_today(4)
            DueDate             = lv_today + 30
          )
        ).

  ENDMETHOD.

  METHOD validateBalance.

    READ ENTITIES OF zi_team4_jeh IN LOCAL MODE
      ENTITY Header BY \_Items
        FIELDS (
          DebitCredit
          Amount
        )
        WITH CORRESPONDING #( keys )
      RESULT DATA(items)
      LINK DATA(links).

    LOOP AT keys INTO DATA(key).

      " Clear state area for validateBalance
      APPEND VALUE #(
        %tky        = key-%tky
        %state_area = 'VALIDATE_BALANCE'
      ) TO reported-header.

      DATA total_debit  TYPE zteam4_jei-amount.
      DATA total_credit TYPE zteam4_jei-amount.
      DATA item_count   TYPE i.

      CLEAR:
        total_debit,
        total_credit,
        item_count.

      LOOP AT links INTO DATA(link)
        WHERE source-%tky = key-%tky.

        READ TABLE items
          WITH KEY %tky = link-target-%tky
          INTO DATA(item).

        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.

        item_count += 1.

        CASE to_upper( item-DebitCredit ).
          WHEN 'S' OR 'D'.
            total_debit += item-Amount.
          WHEN 'H' OR 'C'.
            total_credit += item-Amount.
        ENDCASE.

      ENDLOOP.

      " If line items exist, enforce that Debit equals Credit
      IF item_count > 0.
        IF total_debit <= 0
           OR total_credit <= 0
           OR total_debit <> total_credit.

          APPEND VALUE #(
            %tky = key-%tky
          ) TO failed-header.

          APPEND VALUE #(
            %tky        = key-%tky
            %state_area = 'VALIDATE_BALANCE'
            %msg        = NEW zcm_team4_jeh(
              severity = if_abap_behv_message=>severity-error
              textid   = zcm_team4_jeh=>entry_not_balanced
              attr1    = |{ total_debit NUMBER = USER }|
              attr2    = |{ total_credit NUMBER = USER }|
            )
          ) TO reported-header.

        ENDIF.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD validateHeader.

    "==============================================================
    " Validate Header business consistency.
    "
    " Not handled here:
    "   - Empty mandatory fields       -> emptyOnSave
    "   - Ownership                    -> ownerIsUser
    "   - Customer/Reference existence -> checkReferenceExists
    "   - Individual Item validation   -> Item~validateItem
    "   - Debit/Credit balance         -> validateBalance
    "==============================================================

    READ ENTITIES OF zi_team4_jeh IN LOCAL MODE
      ENTITY Header
        FIELDS (
          JournalEntryUUID
          FiscalYear
          PostingDate
          DueDate
          NetAmount
          TaxRate
          Status
        )
        WITH CORRESPONDING #( keys )
      RESULT DATA(headers).

    DATA current_active_status TYPE zteam4_jeh-status.

    LOOP AT headers INTO DATA(header).

      " Clear old state messages reported by this validation.
      APPEND VALUE #(
        %tky        = header-%tky
        %state_area = 'VALIDATE_HEADER'
      ) TO reported-header.


      " Prevent changes to an already cleared active document.
      CLEAR current_active_status.

      SELECT SINGLE status
        FROM zteam4_jeh
        WHERE journal_entry_uuid = @header-JournalEntryUUID
        INTO @current_active_status.

      IF sy-subrc = 0
         AND current_active_status = gc_status_cleared.

        APPEND VALUE #(
          %tky = header-%tky
        ) TO failed-header.

        APPEND VALUE #(
          %tky        = header-%tky
          %state_area = 'VALIDATE_HEADER'
          %msg        = NEW zcm_team4_jeh(
            severity = if_abap_behv_message=>severity-error
            textid   = zcm_team4_jeh=>cleared_doc_no_modify
          )
        ) TO reported-header.

        CONTINUE.

      ENDIF.


      " Net Amount must contain a positive value.
      IF header-NetAmount <= 0.

        APPEND VALUE #(
          %tky = header-%tky
        ) TO failed-header.

        APPEND VALUE #(
          %tky               = header-%tky
          %state_area        = 'VALIDATE_HEADER'
          %element-NetAmount = if_abap_behv=>mk-on
          %msg               = NEW zcm_team4_jeh(
            severity = if_abap_behv_message=>severity-error
            textid   = zcm_team4_jeh=>net_amount_invalid
          )
        ) TO reported-header.

      ENDIF.


      " Tax Rate must be between 0 and 100.
      IF header-TaxRate < 0
         OR header-TaxRate > 100.

        APPEND VALUE #(
          %tky = header-%tky
        ) TO failed-header.

        APPEND VALUE #(
          %tky             = header-%tky
          %state_area      = 'VALIDATE_HEADER'
          %element-TaxRate = if_abap_behv=>mk-on
          %msg             = NEW zcm_team4_jeh(
            severity = if_abap_behv_message=>severity-error
            textid   = zcm_team4_jeh=>tax_rate_invalid
          )
        ) TO reported-header.

      ENDIF.


      " Due Date cannot be earlier than Posting Date.
      IF header-DueDate IS NOT INITIAL
         AND header-PostingDate IS NOT INITIAL
         AND header-DueDate < header-PostingDate.

        APPEND VALUE #(
          %tky = header-%tky
        ) TO failed-header.

        APPEND VALUE #(
          %tky             = header-%tky
          %state_area      = 'VALIDATE_HEADER'
          %element-DueDate = if_abap_behv=>mk-on
          %msg             = NEW zcm_team4_jeh(
            severity = if_abap_behv_message=>severity-error
            textid   = zcm_team4_jeh=>due_date_invalid
          )
        ) TO reported-header.

      ENDIF.


      " Fiscal Year must match the Posting Date calendar year.
      IF header-FiscalYear IS NOT INITIAL
         AND header-PostingDate IS NOT INITIAL
         AND header-FiscalYear <> header-PostingDate(4).

        APPEND VALUE #(
          %tky = header-%tky
        ) TO failed-header.

        APPEND VALUE #(
          %tky                = header-%tky
          %state_area         = 'VALIDATE_HEADER'
          %element-FiscalYear = if_abap_behv=>mk-on
          %msg                = NEW zcm_team4_jeh(
            severity = if_abap_behv_message=>severity-error
            textid   = zcm_team4_jeh=>fiscal_year_invalid
          )
        ) TO reported-header.

      ENDIF.


      " Only supported lifecycle statuses are allowed.
      IF header-Status <> gc_status_parked
         AND header-Status <> gc_status_open
         AND header-Status <> gc_status_cleared.

        APPEND VALUE #(
          %tky = header-%tky
        ) TO failed-header.

        APPEND VALUE #(
          %tky            = header-%tky
          %state_area     = 'VALIDATE_HEADER'
          %element-Status = if_abap_behv=>mk-on
          %msg            = NEW zcm_team4_jeh(
            severity = if_abap_behv_message=>severity-error
            textid   = zcm_team4_jeh=>status_invalid
          )
        ) TO reported-header.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD earlynumbering_cba_Item.

    LOOP AT entities INTO DATA(ls_header_cba).

      DATA(lv_journal_entry_uuid) =
        ls_header_cba-JournalEntryUUID.

      IF lv_journal_entry_uuid IS INITIAL
         AND ls_header_cba-%target IS NOT INITIAL.

        lv_journal_entry_uuid =
          ls_header_cba-%target[ 1 ]-JournalEntryUUID.

      ENDIF.

      SELECT SINGLE
        FROM zteam4_jei
        FIELDS MAX( item_no )
        WHERE journal_entry_uuid = @lv_journal_entry_uuid
        INTO @DATA(lv_max_active).

      SELECT SINGLE
        FROM zteam4_jei_d
        FIELDS MAX( itemno )
        WHERE journalentryuuid = @lv_journal_entry_uuid
        INTO @DATA(lv_max_draft).

      DATA lv_next_item TYPE i.

      IF lv_max_active IS INITIAL
         AND lv_max_draft IS INITIAL.

        lv_next_item = 1.

      ELSEIF lv_max_active >= lv_max_draft.

        TRY.
            lv_next_item = CONV i( lv_max_active ) + 1.
          CATCH cx_sy_conversion_no_number
                cx_sy_conversion_overflow.
            lv_next_item = 1.
        ENDTRY.

      ELSE.

        TRY.
            lv_next_item = CONV i( lv_max_draft ) + 1.
          CATCH cx_sy_conversion_no_number
                cx_sy_conversion_overflow.
            lv_next_item = 1.
        ENDTRY.

      ENDIF.

      LOOP AT ls_header_cba-%target INTO DATA(ls_target).

        DATA lv_item_no TYPE zteam4_jei-item_no.

        IF ls_target-ItemNo IS INITIAL.

          lv_item_no =
            |{ lv_next_item
                 WIDTH = 3
                 ALIGN = RIGHT
                 PAD   = '0' }|.

        ELSE.

          lv_item_no = ls_target-ItemNo.

        ENDIF.

        DATA ls_mapped_item LIKE LINE OF mapped-item.

        ls_mapped_item =
          CORRESPONDING #( ls_target ).

        ls_mapped_item-JournalEntryUUID =
          lv_journal_entry_uuid.

        ls_mapped_item-ItemNo =
          lv_item_no.

        APPEND ls_mapped_item TO mapped-item.

        lv_next_item += 1.

      ENDLOOP.

    ENDLOOP.

  ENDMETHOD.

  METHOD derivefromsalesorder.

    READ ENTITIES OF zi_team4_jeh IN LOCAL MODE
      ENTITY Header
        FIELDS (
          JournalEntryUUID
          CompanyCode
          Customer
          Reference
          DocumentDate
          PostingDate
          TaxRate
          Status
        )
        WITH CORRESPONDING #( keys )
      RESULT DATA(headers).

    LOOP AT headers INTO DATA(header).

      IF header-Status <> gc_status_parked.
        CONTINUE.
      ENDIF.

      IF header-Reference IS INITIAL.
        APPEND VALUE #(
            %tky = header-%tky
            %element-Customer = if_abap_behv=>mk-on
            %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text = 'Select Customer before selecting Sales Order'
            )
        ) TO reported-header.

        CONTINUE.
      ENDIF.

      SELECT SINGLE
        FROM zteam4_so
        FIELDS
          sales_order,
          customer_id,
          sales_order_date,
          transaction_currency,
          net_amount,
          payment_terms_days,
          description
        WHERE sales_order = @header-Reference
        INTO @DATA(sales_order).

      IF sy-subrc <> 0.

        APPEND VALUE #(
          %tky               = header-%tky
          %element-Reference = if_abap_behv=>mk-on
          %msg = NEW zcm_team4_jeh(
            severity = if_abap_behv_message=>severity-error
            textid   = zcm_team4_jeh=>sales_order_not_exist
            attr1    = CONV #( header-Reference )
          )
        ) TO reported-header.

        CONTINUE.

      ENDIF.

      IF sales_order-customer_id <> header-Customer.

        APPEND VALUE #(
          %tky               = header-%tky
          %element-Reference = if_abap_behv=>mk-on
          %msg = NEW zcm_team4_jeh(
            severity = if_abap_behv_message=>severity-error
            textid   = zcm_team4_jeh=>so_customer_mismatch
            attr1    = CONV #( header-Reference )
            attr2    = CONV #( header-Customer )
          )
        ) TO reported-header.

        CONTINUE.

      ENDIF.

      DATA lv_company_code TYPE zteam4_jeh-company_code.

      lv_company_code = SWITCH #( sales_order-customer_id
        WHEN 'CUST01' THEN '1000'
        WHEN 'CUST02' THEN '2000'
        WHEN 'CUST03' THEN '3000'
        ELSE '1000' ).

      DATA lv_tax_amount TYPE zteam4_jeh-tax_amount.
      DATA lv_gross_amount TYPE zteam4_jeh-gross_amount.

      lv_tax_amount =
        sales_order-net_amount
        * header-TaxRate
        / 100.

      lv_gross_amount =
        sales_order-net_amount
        + lv_tax_amount.

      DATA lv_due_date TYPE zteam4_jeh-due_date.

      IF header-DocumentDate IS NOT INITIAL.
        lv_due_date =
          header-DocumentDate
          + sales_order-payment_terms_days.
      ELSE.
        lv_due_date =
          cl_abap_context_info=>get_system_date( )
          + sales_order-payment_terms_days.
      ENDIF.

      MODIFY ENTITIES OF zi_team4_jeh IN LOCAL MODE
        ENTITY Header
          UPDATE FIELDS (
            CompanyCode
            NetAmount
            TaxAmount
            GrossAmount
            TransactionCurrency
            DueDate
          )
          WITH VALUE #(
            (
              %tky                = header-%tky
              CompanyCode         = lv_company_code
              NetAmount           = sales_order-net_amount
              TaxAmount           = lv_tax_amount
              GrossAmount         = lv_gross_amount
              TransactionCurrency = sales_order-transaction_currency
              DueDate             = lv_due_date
            )
          )
        FAILED DATA(failed_update)
        REPORTED DATA(reported_update).

      IF failed_update IS NOT INITIAL.

        APPEND VALUE #(
          %tky = header-%tky
          %msg = NEW zcm_team4_jeh(
            severity = if_abap_behv_message=>severity-error
            textid   = zcm_team4_jeh=>header_derive_failed
          )
        ) TO reported-header.

        CONTINUE.

      ENDIF.

      READ ENTITIES OF zi_team4_jeh IN LOCAL MODE
        ENTITY Header BY \_Items
          ALL FIELDS
          WITH VALUE #(
            (
              %tky = header-%tky
            )
          )
        RESULT DATA(existing_items).

      IF existing_items IS NOT INITIAL.

        MODIFY ENTITIES OF zi_team4_jeh IN LOCAL MODE
          ENTITY Item
            DELETE FROM VALUE #(
              FOR existing_item IN existing_items
              (
                %tky = existing_item-%tky
              )
            )
          FAILED DATA(failed_delete)
          REPORTED DATA(reported_delete).

        IF failed_delete IS NOT INITIAL.

          APPEND VALUE #(
            %tky = header-%tky
            %msg = NEW zcm_team4_jeh(
              severity = if_abap_behv_message=>severity-error
              textid   = zcm_team4_jeh=>old_items_remove_failed
            )
          ) TO reported-header.

          CONTINUE.

        ENDIF.

      ENDIF.

      MODIFY ENTITIES OF zi_team4_jeh IN LOCAL MODE
        ENTITY Header
          CREATE BY \_Items
          AUTO FILL CID
          FIELDS (
            ItemNo
            GLAccount
            GLAccountName
            DebitCredit
            TransactionCurrency
            Amount
            TaxCode
            ItemText
          )
          WITH VALUE #(
            (
              %tky = header-%tky
              %target = VALUE #(
                (
                  %is_draft           = header-%is_draft
                  ItemNo              = gc_item_customer
                  GLAccount           = gc_gl_customer
                  GLAccountName       = 'Customer Receivable'
                  DebitCredit         = gc_debit
                  TransactionCurrency = sales_order-transaction_currency
                  Amount              = lv_gross_amount
                  ItemText            = |Ref { sales_order-sales_order } - { sales_order-description }|
                )
                (
                  %is_draft           = header-%is_draft
                  ItemNo              = gc_item_revenue
                  GLAccount           = gc_gl_revenue
                  GLAccountName       = 'Sales Revenue'
                  DebitCredit         = gc_credit
                  TransactionCurrency = sales_order-transaction_currency
                  Amount              = sales_order-net_amount
                  ItemText            = sales_order-description
                )
                (
                  %is_draft           = header-%is_draft
                  ItemNo              = gc_item_tax
                  GLAccount           = gc_gl_tax
                  GLAccountName       = 'Output Tax'
                  DebitCredit         = gc_credit
                  TransactionCurrency = sales_order-transaction_currency
                  Amount              = lv_tax_amount
                  TaxCode             = gc_tax_code
                  ItemText            = |Output tax for { sales_order-sales_order }|
                )
              )
            )
          )
        FAILED DATA(failed_create)
        MAPPED DATA(mapped_create)
        REPORTED DATA(reported_create).

      IF failed_create IS NOT INITIAL.

        APPEND VALUE #(
          %tky = header-%tky
          %msg = NEW zcm_team4_jeh(
            severity = if_abap_behv_message=>severity-error
            textid   = zcm_team4_jeh=>items_gen_failed
          )
        ) TO reported-header.

        CONTINUE.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD get_next_number.

    DATA lv_number TYPE i.

    IF iv_current_max IS INITIAL.
      lv_number = 1.
    ELSE.
      TRY.
          lv_number = CONV i( iv_current_max ) + 1.
        CATCH cx_sy_conversion_no_number.
          lv_number = 1.
      ENDTRY.
    ENDIF.

    rv_number =
      |{ lv_number
           WIDTH = 10
           ALIGN = RIGHT
           PAD = '0' }|.

  ENDMETHOD.


  METHOD checkReferenceExists.

    "==============================================================
    " VALIDATE CUSTOMER AND SALES ORDER REFERENCE
    "==============================================================
    " Responsibilities:
    "   1. Validate that the selected Customer exists.
    "   2. Allow an empty Reference for a manual Journal Entry.
    "   3. Validate that the selected Sales Order exists.
    "   4. Validate that the Sales Order belongs to the Customer.
    "   5. Validate the Sales Order currency and Net Amount.
    "   6. Validate Header Currency against Sales Order Currency.
    "==============================================================

    READ ENTITIES OF zi_team4_jeh IN LOCAL MODE
      ENTITY Header
        FIELDS (
          Customer
          Reference
          TransactionCurrency
        )
        WITH CORRESPONDING #( keys )
      RESULT DATA(headers).

    DATA:
      sales_order       TYPE zteam4_so,
      existing_customer TYPE zteam4_customer-customer_id.

    LOOP AT headers INTO DATA(header).

      "------------------------------------------------------------
      " Invalidate old messages returned by this validation.
      "------------------------------------------------------------
      APPEND VALUE #(
        %tky        = header-%tky
        %state_area = 'CHECK_REFERENCE'
      ) TO reported-header.


      "------------------------------------------------------------
      " Empty Customer is handled by emptyOnSave.
      " Do not return the same error from two validations.
      "------------------------------------------------------------
      IF header-Customer IS INITIAL.
        CONTINUE.
      ENDIF.


      "------------------------------------------------------------
      " Validate that Customer exists in the Customer master table.
      " This check must happen before checking whether Reference is
      " empty because Reference is optional for a manual Journal Entry.
      "------------------------------------------------------------
      CLEAR existing_customer.

      SELECT SINGLE customer_id
        FROM zteam4_customer
        WHERE customer_id = @header-Customer
        INTO @existing_customer.

      IF sy-subrc <> 0.

        APPEND VALUE #(
          %tky = header-%tky
        ) TO failed-header.

        APPEND VALUE #(
          %tky              = header-%tky
          %state_area       = 'CHECK_REFERENCE'
          %element-Customer = if_abap_behv=>mk-on
          %msg = NEW zcm_team4_jeh(
            severity = if_abap_behv_message=>severity-error
            textid   = zcm_team4_jeh=>customer_not_exist
            attr1    = CONV #( header-Customer )
          )
        ) TO reported-header.

        CONTINUE.

      ENDIF.


      "------------------------------------------------------------
      " Reference is optional for a manual Journal Entry.
      "
      " Customer has already been validated at this point.
      "------------------------------------------------------------
      IF header-Reference IS INITIAL.
        CONTINUE.
      ENDIF.


      "------------------------------------------------------------
      " Validate Sales Order existence.
      "------------------------------------------------------------
      CLEAR sales_order.

      SELECT SINGLE
        FROM zteam4_so
        FIELDS
          sales_order,
          customer_id,
          transaction_currency,
          net_amount
        WHERE sales_order = @header-Reference
        INTO CORRESPONDING FIELDS OF @sales_order.

      IF sy-subrc <> 0.

        APPEND VALUE #(
          %tky = header-%tky
        ) TO failed-header.

        APPEND VALUE #(
          %tky               = header-%tky
          %state_area        = 'CHECK_REFERENCE'
          %element-Reference = if_abap_behv=>mk-on
          %msg = NEW zcm_team4_jeh(
            severity = if_abap_behv_message=>severity-error
            textid   = zcm_team4_jeh=>sales_order_not_exist
            attr1    = CONV #( header-Reference )
          )
        ) TO reported-header.

        CONTINUE.

      ENDIF.


      "------------------------------------------------------------
      " Validate Customer/Sales Order relationship.
      "------------------------------------------------------------
      IF sales_order-customer_id <> header-Customer.

        APPEND VALUE #(
          %tky = header-%tky
        ) TO failed-header.

        APPEND VALUE #(
          %tky               = header-%tky
          %state_area        = 'CHECK_REFERENCE'
          %element-Reference = if_abap_behv=>mk-on
          %msg = NEW zcm_team4_jeh(
            severity = if_abap_behv_message=>severity-error
            textid   = zcm_team4_jeh=>so_customer_mismatch
            attr1    = CONV #( header-Reference )
            attr2    = CONV #( header-Customer )
          )
        ) TO reported-header.

      ENDIF.


      "------------------------------------------------------------
      " Validate that Sales Order Currency is available.
      "------------------------------------------------------------
      IF sales_order-transaction_currency IS INITIAL.

        APPEND VALUE #(
          %tky = header-%tky
        ) TO failed-header.

        APPEND VALUE #(
          %tky                         = header-%tky
          %state_area                  = 'CHECK_REFERENCE'
          %element-TransactionCurrency = if_abap_behv=>mk-on
          %msg = NEW zcm_team4_jeh(
            severity = if_abap_behv_message=>severity-error
            textid   = zcm_team4_jeh=>currency_required
          )
        ) TO reported-header.

      ENDIF.


      "------------------------------------------------------------
      " Validate Header/Sales Order Currency consistency.
      "
      " Normally deriveFromSalesOrder copies the Sales Order Currency
      " to the Header. This check is an additional backend safeguard.
      "------------------------------------------------------------
      IF header-TransactionCurrency IS NOT INITIAL
         AND sales_order-transaction_currency IS NOT INITIAL
         AND header-TransactionCurrency
             <> sales_order-transaction_currency.

        APPEND VALUE #(
          %tky = header-%tky
        ) TO failed-header.

        APPEND VALUE #(
          %tky                         = header-%tky
          %state_area                  = 'CHECK_REFERENCE'
          %element-TransactionCurrency = if_abap_behv=>mk-on
          %msg = NEW zcm_team4_jeh(
            severity = if_abap_behv_message=>severity-error
            textid   = zcm_team4_jeh=>currency_mismatch
            attr1    = CONV #( header-TransactionCurrency )
            attr2    = CONV #(
              sales_order-transaction_currency
            )
          )
        ) TO reported-header.

      ENDIF.


      "------------------------------------------------------------
      " Validate Sales Order Net Amount.
      "------------------------------------------------------------
      IF sales_order-net_amount <= 0.

        APPEND VALUE #(
          %tky = header-%tky
        ) TO failed-header.

        APPEND VALUE #(
          %tky               = header-%tky
          %state_area        = 'CHECK_REFERENCE'
          %element-Reference = if_abap_behv=>mk-on
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     =
              |Sales Order { header-Reference } has an invalid Net Amount|
          )
        ) TO reported-header.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD emptyOnSave.

    READ ENTITIES OF zi_team4_jeh IN LOCAL MODE
      ENTITY Header
        FIELDS (
          CompanyCode
          FiscalYear
          DocumentType
          DocumentDate
          PostingDate
          DueDate
          TransactionCurrency
          Customer
          NetAmount
          TaxRate
        )
        WITH CORRESPONDING #( keys )
      RESULT DATA(headers).

    LOOP AT headers INTO DATA(header).

      " Clear old state messages reported by this validation.
      APPEND VALUE #(
        %tky        = header-%tky
        %state_area = 'EMPTY_ON_SAVE'
      ) TO reported-header.


      IF header-CompanyCode IS INITIAL.

        APPEND VALUE #( %tky = header-%tky )
          TO failed-header.

        APPEND VALUE #(
          %tky                 = header-%tky
          %state_area          = 'EMPTY_ON_SAVE'
          %element-CompanyCode = if_abap_behv=>mk-on
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = 'Company Code is required'
          )
        ) TO reported-header.

      ENDIF.


      IF header-FiscalYear IS INITIAL.

        APPEND VALUE #( %tky = header-%tky )
          TO failed-header.

        APPEND VALUE #(
          %tky                = header-%tky
          %state_area         = 'EMPTY_ON_SAVE'
          %element-FiscalYear = if_abap_behv=>mk-on
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = 'Fiscal Year is required'
          )
        ) TO reported-header.

      ENDIF.


      IF header-DocumentType IS INITIAL.

        APPEND VALUE #( %tky = header-%tky )
          TO failed-header.

        APPEND VALUE #(
          %tky                 = header-%tky
          %state_area          = 'EMPTY_ON_SAVE'
          %element-DocumentType = if_abap_behv=>mk-on
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = 'Document Type is required'
          )
        ) TO reported-header.

      ENDIF.


      IF header-DocumentDate IS INITIAL.

        APPEND VALUE #( %tky = header-%tky )
          TO failed-header.

        APPEND VALUE #(
          %tky                  = header-%tky
          %state_area           = 'EMPTY_ON_SAVE'
          %element-DocumentDate = if_abap_behv=>mk-on
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = 'Document Date is required'
          )
        ) TO reported-header.

      ENDIF.


      IF header-PostingDate IS INITIAL.

        APPEND VALUE #( %tky = header-%tky )
          TO failed-header.

        APPEND VALUE #(
          %tky                 = header-%tky
          %state_area          = 'EMPTY_ON_SAVE'
          %element-PostingDate = if_abap_behv=>mk-on
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = 'Posting Date is required'
          )
        ) TO reported-header.

      ENDIF.


      IF header-DueDate IS INITIAL.

        APPEND VALUE #( %tky = header-%tky )
          TO failed-header.

        APPEND VALUE #(
          %tky             = header-%tky
          %state_area      = 'EMPTY_ON_SAVE'
          %element-DueDate = if_abap_behv=>mk-on
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = 'Due Date is required'
          )
        ) TO reported-header.

      ENDIF.


      IF header-TransactionCurrency IS INITIAL.

        APPEND VALUE #( %tky = header-%tky )
          TO failed-header.

        APPEND VALUE #(
          %tky                         = header-%tky
          %state_area                  = 'EMPTY_ON_SAVE'
          %element-TransactionCurrency = if_abap_behv=>mk-on
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = 'Transaction Currency is required'
          )
        ) TO reported-header.

      ENDIF.


      IF header-Customer IS INITIAL.

        APPEND VALUE #( %tky = header-%tky )
          TO failed-header.

        APPEND VALUE #(
          %tky              = header-%tky
          %state_area       = 'EMPTY_ON_SAVE'
          %element-Customer = if_abap_behv=>mk-on
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = 'Customer is required'
          )
        ) TO reported-header.

      ENDIF.


      IF header-NetAmount IS INITIAL.

        APPEND VALUE #( %tky = header-%tky )
          TO failed-header.

        APPEND VALUE #(
          %tky               = header-%tky
          %state_area        = 'EMPTY_ON_SAVE'
          %element-NetAmount = if_abap_behv=>mk-on
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = 'Net Amount is required'
          )
        ) TO reported-header.

      ENDIF.


      " Keep this check only if a zero-percent tax rate is not allowed.
      IF header-TaxRate IS INITIAL.

        APPEND VALUE #( %tky = header-%tky )
          TO failed-header.

        APPEND VALUE #(
          %tky             = header-%tky
          %state_area      = 'EMPTY_ON_SAVE'
          %element-TaxRate = if_abap_behv=>mk-on
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = 'Tax Rate is required'
          )
        ) TO reported-header.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD deriveCustomerName.

    READ ENTITIES OF zi_team4_jeh IN LOCAL MODE
      ENTITY Header
        FIELDS (
          Customer
          CustomerName
        )
        WITH CORRESPONDING #( keys )
      RESULT DATA(headers).

    LOOP AT headers INTO DATA(header).

      DATA lv_customer_name TYPE zteam4_customer-customer_name.

      CLEAR lv_customer_name.

      IF header-Customer IS NOT INITIAL.

        SELECT SINGLE customer_name
          FROM zteam4_customer
          WHERE customer_id = @header-Customer
          INTO @lv_customer_name.

      ENDIF.

      MODIFY ENTITIES OF zi_team4_jeh IN LOCAL MODE
        ENTITY Header
          UPDATE FIELDS (
            CustomerName
          )
          WITH VALUE #(
            (
              %tky         = header-%tky
              CustomerName = lv_customer_name
            )
          ).

    ENDLOOP.

  ENDMETHOD.

  METHOD ownerIsUser.

    DATA(lv_user) =
      to_upper(
        cl_abap_context_info=>get_user_technical_name( )
      ).

    READ ENTITIES OF zi_team4_jeh IN LOCAL MODE
      ENTITY Header
        FIELDS (
          Status
        )
        WITH CORRESPONDING #( keys )
      RESULT DATA(headers).

    LOOP AT headers INTO DATA(header).

      " Invalidate previous state messages from this validation.
      APPEND VALUE #(
        %tky        = header-%tky
        %state_area = 'MOCK_USER_ROLE'
      ) TO reported-header.

      " Allow only the two configured mock workflow users.
      IF lv_user <> gc_user_chief
         AND lv_user <> gc_user_accountant.

        APPEND VALUE #(
          %tky = header-%tky
        ) TO failed-header.

        APPEND VALUE #(
          %tky        = header-%tky
          %state_area = 'MOCK_USER_ROLE'
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     =
              |User { lv_user } is not authorized for Journal Entry processing|
          )
        ) TO reported-header.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD getdefaultsforclear.

    READ ENTITIES OF zi_team4_jeh IN LOCAL MODE
      ENTITY Header
        FIELDS ( DocumentNumber Customer CustomerName DueDate
                 GrossAmount TransactionCurrency )
        WITH CORRESPONDING #( keys )
      RESULT DATA(headers).

    DATA(today) = cl_abap_context_info=>get_system_date( ).

    LOOP AT headers INTO DATA(h).

      INSERT VALUE #( %tky = h-%tky ) INTO TABLE result REFERENCE INTO DATA(new_line).

      new_line->%param-DocumentNumber = h-DocumentNumber.
      new_line->%param-Customer       = h-Customer.
      new_line->%param-CustomerName   = h-CustomerName.
      new_line->%param-DueDate        = h-DueDate.
      new_line->%param-GrossAmount    = h-GrossAmount.
      new_line->%param-Currency       = h-TransactionCurrency.
      new_line->%param-ClearingDate   = today.

      " Preselect the bank when the customer has exactly one
      SELECT bank_id, balance
        FROM zteam4_custbank
        WHERE customer = @h-Customer
        INTO TABLE @DATA(banks).
      IF lines( banks ) = 1.
        new_line->%param-BankId      = banks[ 1 ]-bank_id.
        new_line->%param-BankBalance = banks[ 1 ]-balance.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

CLASS lhc_Item DEFINITION
  INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Item RESULT result.

    METHODS validateItem
        FOR VALIDATE ON SAVE
        keys FOR Item~validateItem.
    METHODS validateDocumentBalance FOR VALIDATE ON SAVE IMPORTING
                                                           keys FOR Item~validateDocumentBalance.

ENDCLASS.

CLASS lhc_Item IMPLEMENTATION.

  METHOD validateItem.

    READ ENTITIES OF zi_team4_jeh IN LOCAL MODE
      ENTITY Item
        FIELDS (
          JournalEntryUUID
          ItemNo
          GLAccount
          DebitCredit
          TransactionCurrency
          Amount
        )
        WITH CORRESPONDING #( keys )
      RESULT DATA(items).

    READ ENTITIES OF zi_team4_jeh IN LOCAL MODE
      ENTITY Item BY \_Header
        FIELDS (
          JournalEntryUUID
          TransactionCurrency
        )
        WITH CORRESPONDING #( keys )
      RESULT DATA(headers)
      LINK DATA(links).

    LOOP AT items INTO DATA(item).

      "Find parent Header
      READ TABLE links INTO DATA(header_link)
        WITH KEY source-%tky = item-%tky.

      DATA(parent_found) = xsdbool( sy-subrc = 0 ).

      "Invalidate previous validation messages
      APPEND VALUE #(
        %tky        = item-%tky
        %state_area = 'VALIDATE_ITEM'
      ) TO reported-item.

      "----------------------------------------------------------
      "G/L Account required
      "----------------------------------------------------------
      IF item-GLAccount IS INITIAL.

        APPEND VALUE #(
          %tky = item-%tky
        ) TO failed-item.

        IF parent_found = abap_true.

          APPEND VALUE #(
            %tky                 = item-%tky
            %state_area          = 'VALIDATE_ITEM'
            %path-Header-%tky    = header_link-target-%tky
            %element-GLAccount   = if_abap_behv=>mk-on
            %msg                 = NEW zcm_team4_jeh(
              severity = if_abap_behv_message=>severity-error
              textid   = zcm_team4_jeh=>gl_account_required
            )
          ) TO reported-item.

        ELSE.

          APPEND VALUE #(
            %tky               = item-%tky
            %state_area        = 'VALIDATE_ITEM'
            %element-GLAccount = if_abap_behv=>mk-on
            %msg               = NEW zcm_team4_jeh(
              severity = if_abap_behv_message=>severity-error
              textid   = zcm_team4_jeh=>gl_account_required
            )
          ) TO reported-item.

        ENDIF.

      ENDIF.

      "----------------------------------------------------------
      "Amount must be positive
      "----------------------------------------------------------
      IF item-Amount <= 0.

        APPEND VALUE #(
          %tky = item-%tky
        ) TO failed-item.

        IF parent_found = abap_true.

          APPEND VALUE #(
            %tky               = item-%tky
            %state_area        = 'VALIDATE_ITEM'
            %path-Header-%tky  = header_link-target-%tky
            %element-Amount    = if_abap_behv=>mk-on
            %msg               = NEW zcm_team4_jeh(
              severity = if_abap_behv_message=>severity-error
              textid   = zcm_team4_jeh=>item_amount_invalid
            )
          ) TO reported-item.

        ELSE.

          APPEND VALUE #(
            %tky            = item-%tky
            %state_area     = 'VALIDATE_ITEM'
            %element-Amount = if_abap_behv=>mk-on
            %msg            = NEW zcm_team4_jeh(
              severity = if_abap_behv_message=>severity-error
              textid   = zcm_team4_jeh=>item_amount_invalid
            )
          ) TO reported-item.

        ENDIF.

      ENDIF.

      "----------------------------------------------------------
      "Debit/Credit
      "----------------------------------------------------------
      DATA(lv_dc) = to_upper( item-DebitCredit ).

      IF item-DebitCredit IS INITIAL
         OR (
              lv_dc <> 'S'
          AND lv_dc <> 'D'
          AND lv_dc <> 'H'
          AND lv_dc <> 'C'
         ).

        APPEND VALUE #(
          %tky = item-%tky
        ) TO failed-item.

        IF parent_found = abap_true.

          APPEND VALUE #(
            %tky                   = item-%tky
            %state_area            = 'VALIDATE_ITEM'
            %path-Header-%tky      = header_link-target-%tky
            %element-DebitCredit   = if_abap_behv=>mk-on
            %msg                   = NEW zcm_team4_jeh(
              severity = if_abap_behv_message=>severity-error
              textid   = zcm_team4_jeh=>debit_credit_invalid
            )
          ) TO reported-item.

        ELSE.

          APPEND VALUE #(
            %tky                 = item-%tky
            %state_area          = 'VALIDATE_ITEM'
            %element-DebitCredit = if_abap_behv=>mk-on
            %msg                 = NEW zcm_team4_jeh(
              severity = if_abap_behv_message=>severity-error
              textid   = zcm_team4_jeh=>debit_credit_invalid
            )
          ) TO reported-item.

        ENDIF.

      ENDIF.

      "----------------------------------------------------------
      "Currency required
      "----------------------------------------------------------
      IF item-TransactionCurrency IS INITIAL.

        APPEND VALUE #(
          %tky = item-%tky
        ) TO failed-item.

        IF parent_found = abap_true.

          APPEND VALUE #(
            %tky                           = item-%tky
            %state_area                    = 'VALIDATE_ITEM'
            %path-Header-%tky              = header_link-target-%tky
            %element-TransactionCurrency   = if_abap_behv=>mk-on
            %msg                           = NEW zcm_team4_jeh(
              severity = if_abap_behv_message=>severity-error
              textid   = zcm_team4_jeh=>currency_required
            )
          ) TO reported-item.

        ELSE.

          APPEND VALUE #(
            %tky                         = item-%tky
            %state_area                  = 'VALIDATE_ITEM'
            %element-TransactionCurrency = if_abap_behv=>mk-on
            %msg                         = NEW zcm_team4_jeh(
              severity = if_abap_behv_message=>severity-error
              textid   = zcm_team4_jeh=>currency_required
            )
          ) TO reported-item.

        ENDIF.

      ELSEIF parent_found = abap_true.

        READ TABLE headers INTO DATA(header)
          WITH KEY %tky = header_link-target-%tky.

        IF sy-subrc = 0
           AND header-TransactionCurrency IS NOT INITIAL
           AND item-TransactionCurrency
                 <> header-TransactionCurrency.

          APPEND VALUE #(
            %tky = item-%tky
          ) TO failed-item.

          APPEND VALUE #(
            %tky                           = item-%tky
            %state_area                    = 'VALIDATE_ITEM'
            %path-Header-%tky              = header_link-target-%tky
            %element-TransactionCurrency   = if_abap_behv=>mk-on
            %msg                           = NEW zcm_team4_jeh(
              severity = if_abap_behv_message=>severity-error
              textid   = zcm_team4_jeh=>currency_mismatch
              attr1    = CONV #( item-TransactionCurrency )
              attr2    = CONV #( header-TransactionCurrency )
            )
          ) TO reported-item.

        ENDIF.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD get_instance_features.

    READ ENTITIES OF zi_team4_jeh IN LOCAL MODE
      ENTITY Item BY \_Header
        FIELDS (
          Status
          Reference
        )
        WITH CORRESPONDING #( keys )
      RESULT DATA(headers_by_item)
      LINK DATA(links).

    result = VALUE #(
      FOR key IN keys

      LET header_link =
            VALUE #(
              links[
                source-%tky = key-%tky
              ]
              OPTIONAL
            )

          header =
            VALUE #(
              headers_by_item[
                %tky = header_link-target-%tky
              ]
              OPTIONAL
            )

          is_item_editable =
            xsdbool(
              header-Status = 'P'
              AND header-Reference IS INITIAL
            )

      IN
      (
        %tky = key-%tky

        %update = COND #(
          WHEN is_item_editable = abap_true
          THEN if_abap_behv=>fc-o-enabled
          ELSE if_abap_behv=>fc-o-disabled
        )

        %delete = COND #(
          WHEN is_item_editable = abap_true
          THEN if_abap_behv=>fc-o-enabled
          ELSE if_abap_behv=>fc-o-disabled
        )
      )
    ).

  ENDMETHOD.

  METHOD validateDocumentBalance.

    READ ENTITIES OF zi_team4_jeh IN LOCAL MODE
      ENTITY Item BY \_Header
        FIELDS (
          JournalEntryUUID
        )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_parent_headers)
      LINK DATA(lt_item_header_links).

    LOOP AT keys INTO DATA(ls_item_key).

      "Resolve the parent Header of the changed Item.
      READ TABLE lt_item_header_links
        INTO DATA(ls_header_link)
        WITH KEY source-%tky = ls_item_key-%tky.

      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      "Remove the previous document-balance message from the Header.
      APPEND VALUE #(
        %tky        = ls_header_link-target-%tky
        %state_area = 'VALIDATE_DOCUMENT_BALANCE'
      ) TO reported-header.

      "Read all sibling Items from the current transactional buffer.
      READ ENTITIES OF zi_team4_jeh IN LOCAL MODE
        ENTITY Header BY \_Items
          FIELDS (
            JournalEntryUUID
            ItemNo
            DebitCredit
            Amount
          )
          WITH VALUE #(
            (
              %tky = ls_header_link-target-%tky
            )
          )
        RESULT DATA(lt_sibling_items).

      "A Parked draft may temporarily have no posting Items.
      IF lt_sibling_items IS INITIAL.
        CONTINUE.
      ENDIF.

      DATA lv_total_debit  TYPE zteam4_jei-amount.
      DATA lv_total_credit TYPE zteam4_jei-amount.

      CLEAR:
        lv_total_debit,
        lv_total_credit.

      "Calculate totals from the complete Item set.
      LOOP AT lt_sibling_items INTO DATA(ls_sibling_item).

        CASE to_upper( ls_sibling_item-DebitCredit ).

          WHEN 'S' OR 'D'.
            lv_total_debit += ls_sibling_item-Amount.

          WHEN 'H' OR 'C'.
            lv_total_credit += ls_sibling_item-Amount.

        ENDCASE.

      ENDLOOP.

      "Reject the transaction when debit and credit are not balanced.
      IF lv_total_debit <= 0
         OR lv_total_credit <= 0
         OR lv_total_debit <> lv_total_credit.

        "Block the Item update that triggered this validation.
        APPEND VALUE #(
          %tky = ls_item_key-%tky
        ) TO failed-item.

        "Report the document-level message on the parent Header.
        APPEND VALUE #(
          %tky        = ls_header_link-target-%tky
          %state_area = 'VALIDATE_DOCUMENT_BALANCE'
          %msg        = NEW zcm_team4_jeh(
            severity = if_abap_behv_message=>severity-error
            textid   = zcm_team4_jeh=>entry_not_balanced
            attr1    = |{ lv_total_debit NUMBER = USER }|
            attr2    = |{ lv_total_credit NUMBER = USER }|
          )
        ) TO reported-header.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.


ENDCLASS.

