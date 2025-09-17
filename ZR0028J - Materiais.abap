*&---------------------------------------------------------------------*
*& Report ZR0028J
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zr0028j.
TYPE-POOLS slis.

*Tabela Transparente
TABLES: zt0008.

*Tabelas Internas
DATA: t_zt0008   TYPE TABLE OF zt0008,
      t_zt0001j  TYPE TABLE OF zt0001j,
      t_saida    TYPE TABLE OF zs0001,
      t_fieldcat TYPE slis_t_fieldcat_alv,
      t_sort     TYPE slis_t_sortinfo_alv,
      t_header   TYPE slis_t_listheader.

*Work Area
DATA: w_zt0008   TYPE zt0008,
      w_zt0001j  TYPE zt0001j,
      w_saida    TYPE zs0001,
      w_fieldcat TYPE slis_fieldcat_alv,
      w_sort     TYPE slis_sortinfo_alv,
      w_layout   TYPE slis_layout_alv,
      w_header   TYPE slis_listheader,
      w_variant  TYPE disvariant.

*Declarar tela de seleção
SELECTION-SCREEN BEGIN OF BLOCK bc01 WITH FRAME TITLE TEXT-oo1.
SELECT-OPTIONS: s_tpmat FOR zt0008-tpmat,
                s_mater FOR zt0008-mater.
SELECTION-SCREEN END OF BLOCK bc01.

SELECTION-SCREEN BEGIN OF BLOCK bc02 WITH FRAME TITLE TEXT-oo2.
PARAMETERS: p_varian TYPE slis_vari. "GERAR VARIANTE NO RELATÓRIO ALV
SELECTION-SCREEN END OF BLOCK bc02.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_varian.
  PERFORM f_variant_f4 CHANGING p_varian.

START-OF-SELECTION.

  PERFORM f_seleciona_dados.
  PERFORM f_monta_tabela_saida.
  PERFORM f_monta_alv.
*&---------------------------------------------------------------------*
*& Form F_SELECIONA_DADOS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_seleciona_dados .
  SELECT * FROM zt0008 INTO TABLE t_zt0008
  WHERE tpmat IN s_tpmat
  AND mater IN s_mater.

  IF sy-subrc IS INITIAL.
    SELECT * FROM zt0001j INTO TABLE t_zt0001j
    FOR ALL ENTRIES IN t_zt0008
    WHERE tpmat = t_zt0008-tpmat.

  ELSE.
    MESSAGE TEXT-003 TYPE 'I'. "Não foi encontrado nenhum registro com esses parâmetros.
    STOP.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_MONTA_TABELA_SAIDA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_monta_tabela_saida .
  LOOP AT t_zt0008 INTO w_zt0008.

    CLEAR w_saida.
    w_saida-mater = w_zt0008-mater.
    w_saida-denom = w_zt0008-denom.
    w_saida-brgew = w_zt0008-brgew.
    w_saida-ntgew = w_zt0008-ntgew.
    w_saida-gewei = w_zt0008-gewei.
    w_saida-status = w_zt0008-status.
    w_saida-tpmat = w_zt0008-tpmat.

    READ TABLE t_zt0001j INTO w_zt0001j WITH KEY tpmat = w_zt0008-tpmat.
    IF sy-subrc IS INITIAL.
      w_saida-denom_tp = w_zt0001j-denom.
    ENDIF.

    APPEND w_saida TO t_saida.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_MONTA_ALV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_monta_alv .
  PERFORM f_define_fieldcat.
  PERFORM f_ordena.
  PERFORM f_layout.
  PERFORM f_imprime_alv.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_DEFINE_FIELDCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_define_fieldcat .
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid
      i_internal_tabname     = 'T_SAIDA'
      i_structure_name       = 'zs0001'
*     I_CLIENT_NEVER_DISPLAY = 'X'
*     I_INCLNAME             =
*     I_BYPASSING_BUFFER     =
*     I_BUFFER_ACTIVE        =
    CHANGING
      ct_fieldcat            = t_fieldcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.
  IF sy-subrc <> 0.
    MESSAGE TEXT-006 TYPE 'I'. "Erro na definição da fieldcat.
    STOP.
  ELSE.

    LOOP AT t_fieldcat INTO w_fieldcat.
      CASE w_fieldcat-fieldname.
        WHEN 'BRGEW'.
          w_fieldcat-seltext_s = w_fieldcat-seltext_m = w_fieldcat-seltext_l = w_fieldcat-reptext_ddic = TEXT-004. "Peso bruto
        WHEN 'NTGEW'.
          w_fieldcat-seltext_s = w_fieldcat-seltext_m = w_fieldcat-seltext_l = w_fieldcat-reptext_ddic = TEXT-005. "Peso liquido
        WHEN 'MATER'.
          w_fieldcat-hotspot = 'X'.
      ENDCASE.
      MODIFY t_fieldcat FROM w_fieldcat INDEX sy-tabix TRANSPORTING seltext_s seltext_m seltext_l reptext_ddic HOTSPOT.
    ENDLOOP.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_ORDENA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_ordena . "colunas que eu desejo exibir já ordenadas.
  CLEAR w_sort.
  w_sort-spos = 1.
  w_sort-fieldname = 'MATER'. "nome do campo.
  w_sort-tabname = 'T_SAIDA'. "tabela em que está o campo.
  w_sort-up = 'X'.

  APPEND w_sort TO t_sort.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_LAYOUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_layout .
  w_layout-zebra = 'X'.
  w_layout-colwidth_optimize = 'X'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_IMPRIME_ALV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_imprime_alv .

  w_variant-variant = p_varian.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
*     I_INTERFACE_CHECK      = ' '
*     I_BYPASSING_BUFFER     = ' '
*     I_BUFFER_ACTIVE        = ' '
      i_callback_program     = sy-repid
*     I_CALLBACK_PF_STATUS_SET          = ' '
     I_CALLBACK_USER_COMMAND           = 'USER_COMMAND'
      i_callback_top_of_page = 'F_CABECALHO'
*     I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*     I_CALLBACK_HTML_END_OF_LIST       = ' '
*     I_STRUCTURE_NAME       =
*     I_BACKGROUND_ID        = ' '
*     I_GRID_TITLE           =
*     I_GRID_SETTINGS        =
      is_layout              = w_layout
      it_fieldcat            = t_fieldcat
*     IT_EXCLUDING           =
*     IT_SPECIAL_GROUPS      =
      it_sort                = t_sort
*     IT_FILTER              =
*     IS_SEL_HIDE            =
*     I_DEFAULT              = 'X'
      i_save                 = 'X'
      is_variant             = w_variant
*     IT_EVENTS              =
*     IT_EVENT_EXIT          =
*     IS_PRINT               =
*     IS_REPREP_ID           =
*     I_SCREEN_START_COLUMN  = 0
*     I_SCREEN_START_LINE    = 0
*     I_SCREEN_END_COLUMN    = 0
*     I_SCREEN_END_LINE      = 0
*     I_HTML_HEIGHT_TOP      = 0
*     I_HTML_HEIGHT_END      = 0
*     IT_ALV_GRAPHICS        =
*     IT_HYPERLINK           =
*     IT_ADD_FIELDCAT        =
*     IT_EXCEPT_QINFO        =
*     IR_SALV_FULLSCREEN_ADAPTER        =
* IMPORTING
*     E_EXIT_CAUSED_BY_CALLER           =
*     ES_EXIT_CAUSED_BY_USER =
    TABLES
      t_outtab               = t_saida
    EXCEPTIONS
      program_error          = 1
      OTHERS                 = 2.
ENDFORM.

FORM f_cabecalho.
  CLEAR w_header.
  REFRESH t_header.

  w_header-typ = 'H'.
  w_header-info = TEXT-010. "Relatorio de materiais
  APPEND w_header TO t_header.

  w_header-typ = 'S'.
  w_header-info = TEXT-008. "Data.:
  WRITE sy-datum TO w_header-info.
  APPEND w_header TO t_header.

  w_header-typ = 'S'.
  w_header-info = TEXT-009. "Hora.:
  WRITE sy-uzeit TO w_header-info.
  APPEND w_header TO t_header.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = t_header
      i_logo             = 'ENJOYSAP_LOGO'
*     I_END_OF_LIST_GRID =
*     I_ALV_FORM         =
    .
ENDFORM.

.
*&---------------------------------------------------------------------*
*& Form F_VARIANT_F4
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- P_VARIAN
*&---------------------------------------------------------------------*
FORM f_variant_f4  CHANGING p_p_varian.

  DATA: vl_variant TYPE disvariant.

  vl_variant-report = sy-repid.

  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      is_variant    = vl_variant
*     I_TABNAME_HEADER          =
*     I_TABNAME_ITEM            =
*     IT_DEFAULT_FIELDCAT       =
      i_save        = 'A'
*     I_DISPLAY_VIA_GRID        = ' '
    IMPORTING
*     E_EXIT        =
      es_variant    = vl_variant
    EXCEPTIONS
      not_found     = 1
      program_error = 2
      OTHERS        = 3.
  IF sy-subrc = 0.
    p_p_varian = vl_variant-variant.
  ENDIF.

ENDFORM.

FORM USER_COMMAND USING R_UCOMM LIKE SY-UCOMM
                        RS_SELFIELD TYPE SLIS_SELFIELD.

DATA: TL_VIMSELLIST TYPE STANDARD TABLE OF VIMSELLIST,
      WL_VIMSELLIST TYPE VIMSELLIST.

IF RS_SELFIELD-SEL_TAB_FIELD = 'T_SAIDA_MATER'.

WL_VIMSELLIST-VIEWFIELD = 'MATER'.
WL_VIMSELLIST-OPERATOR = 'EQ'.
WL_VIMSELLIST-VALUE = RS_SELFIELD-VALUE.

APPEND WL_VIMSELLIST TO TL_VIMSELLIST.

ENDIF.

CALL FUNCTION 'VIEW_MAINTENANCE_CALL'
  EXPORTING
    action                               = 'S'
*   CORR_NUMBER                          = '          '
*   GENERATE_MAINT_TOOL_IF_MISSING       = ' '
*   SHOW_SELECTION_POPUP                 = ' '
    view_name                            = 'ZT0008'
*   NO_WARNING_FOR_CLIENTINDEP           = ' '
*   RFC_DESTINATION_FOR_UPGRADE          = ' '
*   CLIENT_FOR_UPGRADE                   = ' '
*   VARIANT_FOR_SELECTION                = ' '
*   COMPLEX_SELCONDS_USED                = ' '
*   CHECK_DDIC_MAINFLAG                  = ' '
*   SUPPRESS_WA_POPUP                    = ' '
 TABLES
   DBA_SELLIST                          = TL_VIMSELLIST
*   EXCL_CUA_FUNCT                       =
 EXCEPTIONS
   CLIENT_REFERENCE                     = 1
   FOREIGN_LOCK                         = 2
   INVALID_ACTION                       = 3
   NO_CLIENTINDEPENDENT_AUTH            = 4
   NO_DATABASE_FUNCTION                 = 5
   NO_EDITOR_FUNCTION                   = 6
   NO_SHOW_AUTH                         = 7
   NO_TVDIR_ENTRY                       = 8
   NO_UPD_AUTH                          = 9
   ONLY_SHOW_ALLOWED                    = 10
   SYSTEM_FAILURE                       = 11
   UNKNOWN_FIELD_IN_DBA_SELLIST         = 12
   VIEW_NOT_FOUND                       = 13
   MAINTENANCE_PROHIBITED               = 14
   OTHERS                               = 15
          .
IF sy-subrc <> 0.
* Implement suitable error handling here
ENDIF.

ENDFORM.