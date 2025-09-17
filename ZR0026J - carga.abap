*&---------------------------------------------------------------------*
*& Report ZR0026J
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zr0026j.

*Tipos
TYPES: BEGIN OF ty_file,
         forne LIKE zt0006-forne,
         denom LIKE zt0006-denom,
         ender LIKE zt0006-ender,
         telef LIKE zt0006-telef,
         email LIKE zt0006-email,
         cnpj  LIKE zt0006-cnpj,
       END OF ty_file.

*Tabelas internas
DATA: t_file TYPE STANDARD TABLE OF ty_file.
DATA: t_bdcdata TYPE STANDARD TABLE OF bdcdata.

*Work area
DATA: w_file TYPE ty_file.
DATA: w_bdcdata TYPE bdcdata.

*Tela de Seleção
PARAMETERS p_file TYPE localfile.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  PERFORM f_seleciona_arquivo.

START-OF-SELECTION.
  PERFORM f_upload_file.
  PERFORM f_monta_bdc.

*&---------------------------------------------------------------------*
*& Form F_SELECIONA_ARQUIVO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_seleciona_arquivo .
  CALL FUNCTION 'KD_GET_FILENAME_ON_F4'
    EXPORTING
*     PROGRAM_NAME        = SYST-REPID
*     DYNPRO_NUMBER       = SYST-DYNNR
      field_name = p_file
*     STATIC     = ' '
*     MASK       = ' '
*     FILEOPERATION       = 'R'
*     PATH       =
    CHANGING
      file_name  = p_file
*     LOCATION_FLAG       = 'P'
* EXCEPTIONS
*     MASK_TOO_LONG       = 1
*     OTHERS     = 2
    .
  IF sy-subrc <> 0.
    MESSAGE TEXT-002 TYPE 'I'. "Erro na seleção do arquivo.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_UPLOAD_FILE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_upload_file .

  DATA: vl_file TYPE string.
  vl_file = p_file.

  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename = vl_file
*     FILETYPE = 'ASC'
*     HAS_FIELD_SEPARATOR           = ' '
*     HEADER_LENGTH                 = 0
*     READ_BY_LINE                  = 'X'
*     DAT_MODE = ' '
*     CODEPAGE = ' '
*     IGNORE_CERR                   = ABAP_TRUE
*     REPLACEMENT                   = '#'
*     CHECK_BOM                     = ' '
*     VIRUS_SCAN_PROFILE            =
*     NO_AUTH_CHECK                 = ' '
* IMPORTING
*     FILELENGTH                    =
*     HEADER   =
    TABLES
      data_tab = t_file
* CHANGING
*     ISSCANPERFORMED               = ' '
* EXCEPTIONS
*     FILE_OPEN_ERROR               = 1
*     FILE_READ_ERROR               = 2
*     NO_BATCH = 3
*     GUI_REFUSE_FILETRANSFER       = 4
*     INVALID_TYPE                  = 5
*     NO_AUTHORITY                  = 6
*     UNKNOWN_ERROR                 = 7
*     BAD_DATA_FORMAT               = 8
*     HEADER_NOT_ALLOWED            = 9
*     SEPARATOR_NOT_ALLOWED         = 10
*     HEADER_TOO_LONG               = 11
*     UNKNOWN_DP_ERROR              = 12
*     ACCESS_DENIED                 = 13
*     DP_OUT_OF_MEMORY              = 14
*     DISK_FULL                     = 15
*     DP_TIMEOUT                    = 16
*     OTHERS   = 17
    .
  IF sy-subrc <> 0.
    MESSAGE TEXT-001 TYPE 'I'. "Erro no upload do arquivo.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_MONTA_BDC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_monta_bdc .

  PERFORM f_abre_pasta.

  LOOP AT t_file INTO W_FILE.

    PERFORM f_monta_tela USING 'SAPLZT0006' '0001'. "PRIMEIRO PARAMETRO: NOME DA DHDB E 2O É O NUMERO DA TELA.
    PERFORM f_monta_dados USING 'BDC_CURSOR' 'ZT0006-DENOM(01)'.
    PERFORM f_monta_dados USING 'BDC_OKCODE' '=NEWL'.

    PERFORM f_monta_tela USING 'SAPLZT0006' '0002'.
    PERFORM f_monta_dados USING 'BDC_CURSOR' 'ZT0006-CNPJ'.
    PERFORM f_monta_dados USING 'BDC_OKCODE' '=SAVE'.
    PERFORM f_monta_dados USING 'ZT0006-FORNE' w_file-forne.
    PERFORM f_monta_dados USING 'ZT0006-DENOM' w_file-denom.
    PERFORM f_monta_dados USING 'ZT0006-ENDER' w_file-ender.
    PERFORM f_monta_dados USING 'ZT0006-TELEF' w_file-telef.
    PERFORM f_monta_dados USING 'ZT0006-EMAIL' w_file-email.
    PERFORM f_monta_dados USING 'ZT0006-CNPJ'  w_file-cnpj.

    PERFORM f_monta_tela USING 'SAPLZT0006' '0002'.
    PERFORM f_monta_dados USING 'BDC_CURSOR' 'ZT0006-DENOM'.
    PERFORM f_monta_dados USING 'BDC_OKCODE' '=ENDE'.

    PERFORM f_insere_bdc.
  ENDLOOP.

  PERFORM f_fecha_pasta.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_MONTA_TELA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM f_monta_tela  USING    p_program
                            p_screen.
  CLEAR w_bdcdata.
  w_bdcdata-program = p_program.
  w_bdcdata-dynpro = p_screen.
  w_bdcdata-dynbegin = 'X'.
  APPEND w_bdcdata TO t_bdcdata.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_MONTA_DADOS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM f_monta_dados  USING    p_name
                             p_value.
  CLEAR w_bdcdata.
  w_bdcdata-fnam = p_name.
  w_bdcdata-fval = p_value.
  APPEND w_bdcdata TO t_bdcdata.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_ABRE_PASTA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_abre_pasta .
  CALL FUNCTION 'BDC_OPEN_GROUP'
    EXPORTING
      client              = sy-mandt
*     DEST                = FILLER8
      group               = 'CARGA_FORNEC'
*     HOLDDATE            = FILLER8
      keep                = 'X'
      user                = sy-uname
*     RECORD              = FILLER1
*     PROG                = SY-CPROG
*     DCPFM               = '%'
*     DATFM               = '%'
* IMPORTING
*     QID                 =
    EXCEPTIONS
      client_invalid      = 1
      destination_invalid = 2
      group_invalid       = 3
      group_is_locked     = 4
      holddate_invalid    = 5
      internal_error      = 6
      queue_error         = 7
      running             = 8
      system_lock_error   = 9
      user_invalid        = 10
      OTHERS              = 11.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_INSERE_BDC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_insere_bdc .
  CALL FUNCTION 'BDC_INSERT'
    EXPORTING
      tcode            = 'ZCAD004'
*     POST_LOCAL       = NOVBLOCAL
*     PRINTING         = NOPRINT
*     SIMUBATCH        = ' '
*     CTUPARAMS        = ' '
    TABLES
      dynprotab        = t_bdcdata
    EXCEPTIONS
      internal_error   = 1
      not_open         = 2
      queue_error      = 3
      tcode_invalid    = 4
      printing_invalid = 5
      posting_invalid  = 6
      OTHERS           = 7.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_FECHA_PASTA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_fecha_pasta .
CALL FUNCTION 'BDC_CLOSE_GROUP'
 EXCEPTIONS
   NOT_OPEN          = 1
   QUEUE_ERROR       = 2
   OTHERS            = 3
          .
IF sy-subrc <> 0.
MESSAGE TEXT-003 TYPE 'I'. "Erro ao abrir pasta.
ELSE.
REFRESH T_BDCDATA.
ENDIF.

ENDFORM.