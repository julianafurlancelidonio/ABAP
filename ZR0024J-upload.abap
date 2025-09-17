*&---------------------------------------------------------------------*
*& Report ZR0024J
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zr0024j.
*Parâmetros da tela de seleção
PARAMETERS: p_file TYPE localfile,
            p_csv  RADIOBUTTON GROUP gr1,
            p_txt  RADIOBUTTON GROUP gr1.

*Tipos
TYPES: BEGIN OF ty_txt,
         codigo(10)   TYPE c,
         nome(30)     TYPE c,
         telefone(14) TYPE c.
TYPES END OF ty_txt.

TYPES: BEGIN OF ty_csv,
         line(100) TYPE c,
       END OF ty_csv.

*Tabelas Internas
DATA: t_txt TYPE TABLE OF ty_txt.

DATA: t_csv TYPE TABLE OF ty_csv.

*WORK AREA
DATA: w_txt TYPE ty_txt.

DATA: w_csv TYPE ty_csv.

*Evento será ativado ao clicar no parâmetro p_file.
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.

  PERFORM f_seleciona_arquivos.

START-OF-SELECTION.
  PERFORM f_upload.
  PERFORM f_imprime_dados.

*&---------------------------------------------------------------------*
*& Form F_SELECIONA_ARQUIVOS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_seleciona_arquivos .
  CALL FUNCTION 'KD_GET_FILENAME_ON_F4'
    EXPORTING
*     PROGRAM_NAME  = SYST-REPID
*     DYNPRO_NUMBER = SYST-DYNNR
      field_name    = p_file
*     STATIC        = ' '
*     MASK          = ' '
*     FILEOPERATION = 'R'
*     PATH          =
    CHANGING
      file_name     = p_file
*     LOCATION_FLAG = 'P'
    EXCEPTIONS
      mask_too_long = 1
      OTHERS        = 2.
  .
  IF sy-subrc <> 0.
    MESSAGE TEXT-001 TYPE 'I'. "Erro na seleção do arquivo.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_UPLOAD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_upload .
  DATA vl_filename TYPE string.

  FIELD-SYMBOLS <tabela> TYPE STANDARD TABLE.

  vl_filename = p_file.

  IF p_txt = 'X'.
    ASSIGN t_txt TO <tabela>.
  ELSE.
    ASSIGN t_csv TO <tabela>.
  ENDIF.

  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename                = vl_filename
      filetype                = 'ASC'
*     HAS_FIELD_SEPARATOR     = ' '
*     HEADER_LENGTH           = 0
*     READ_BY_LINE            = 'X'
*     DAT_MODE                = ' '
*     CODEPAGE                = ' '
*     IGNORE_CERR             = ABAP_TRUE
*     REPLACEMENT             = '#'
*     CHECK_BOM               = ' '
*     VIRUS_SCAN_PROFILE      =
*     NO_AUTH_CHECK           = ' '
* IMPORTING
*     FILELENGTH              =
*     HEADER                  =
    TABLES
      data_tab                = <tabela>
    EXCEPTIONS
      file_open_error         = 1
      file_read_error         = 2
      no_batch                = 3
      gui_refuse_filetransfer = 4
      invalid_type            = 5
      no_authority            = 6
      unknown_error           = 7
      bad_data_format         = 8
      header_not_allowed      = 9
      separator_not_allowed   = 10
      header_too_long         = 11
      unknown_dp_error        = 12
      access_denied           = 13
      dp_out_of_memory        = 14
      disk_full               = 15
      dp_timeout              = 16
      OTHERS                  = 17.

  IF sy-subrc <> 0.
    MESSAGE TEXT-002 TYPE 'I'. "Erro na abertura do arquivo
    STOP.
  ENDIF.

  IF p_csv = 'X'.
    LOOP AT <tabela> INTO w_csv.
      SPLIT w_csv AT ';' INTO w_txt-codigo w_txt-nome w_txt-telefone.
      APPEND w_txt TO t_txt.
    ENDLOOP.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_IMPRIME_DADOS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_imprime_dados .
  LOOP AT t_txt INTO w_txt.
    WRITE:/ w_txt-codigo, w_txt-nome, w_txt-telefone.
  ENDLOOP.
ENDFORM.