*&---------------------------------------------------------------------*
*& Report ZR0017JFC
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zr0017jfc.
TABLES: ztpjfc,
        ztfjfc.

TYPES:
  BEGIN OF ty_alv,
    idpessoa      TYPE ztpjfc-idpessoa,
    nome          TYPE ztpjfc-nome,
    familia       TYPE ztpjfc-familia,
    idade         TYPE char3,
    nacionalidade TYPE ztfjfc-nacionalidade,
  END OF ty_alv,

  BEGIN OF ty_alv2,
    idfamilia     TYPE ztfjfc-idfamilia,
    familia       TYPE ztfjfc-familia,
    nacionalidade TYPE ztfjfc-nacionalidade,
  END OF ty_alv2.


DATA: t_ztpjfc TYPE TABLE OF ztpjfc,
      w_ztpjfc LIKE LINE OF t_ztpjfc,

      t_alv    TYPE TABLE OF ty_alv,
      w_alv    LIKE LINE OF t_alv,
      v_idade  TYPE sy-datum,

      t_ztfjfc TYPE TABLE OF ztfjfc,
      w_ztfjfc LIKE LINE OF t_ztfjfc,

      t_alv2   TYPE TABLE OF ty_alv2,
      w_alv2   LIKE LINE OF t_alv2.


SELECT-OPTIONS: s_idpess FOR ztpjfc-idpessoa,
                s_family FOR ztpjfc-familia,
                s_nacion FOR ztfjfc-nacionalidade.

PERFORM f_selec_dados.

PERFORM f_imprime_dados.

*&---------------------------------------------------------------------*
*& Form F_SELEC_DADOS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_selec_dados .
  SELECT *
    FROM ztpjfc
    INTO TABLE t_ztpjfc
    WHERE idpessoa IN s_idpess
      AND familia  IN s_family.

  SELECT *
    FROM ztfjfc
    INTO TABLE t_ztfjfc
    WHERE nacionalidade IN s_nacion.

  IF sy-subrc = 0.

    LOOP AT t_ztpjfc INTO w_ztpjfc.
      CLEAR: w_alv, v_idade.
      w_alv-idpessoa   = w_ztpjfc-idpessoa.
      w_alv-nome       = w_ztpjfc-nome.
      w_alv-familia    = w_ztpjfc-familia.
      v_idade          = sy-datum - w_ztpjfc-nascimento.
      w_alv-idade      = v_idade+1(3).
      READ TABLE t_ztfjfc INTO w_ztfjfc
        WITH KEY familia = w_alv-familia.
      IF sy-subrc = 0.
        w_alv-nacionalidade = w_ztfjfc-nacionalidade.
      ENDIF.
      APPEND w_alv TO t_alv.
    ENDLOOP.

    LOOP AT t_ztfjfc INTO w_ztfjfc.
      CLEAR: w_alv2.
      w_alv2-idfamilia = w_ztfjfc-idfamilia.
      w_alv2-familia = w_ztfjfc-familia.
      w_alv2-nacionalidade = w_ztfjfc-nacionalidade.
      APPEND w_alv2 TO t_alv2.
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
  IF sy-subrc = 0.

    DATA(io_splitter) = NEW cl_gui_splitter_container( rows    = 2 parent                  = cl_gui_container=>default_screen
                                                       columns = 1 no_autodef_progid_dynnr = t_yes ).
    DATA(io_container1) = io_splitter->get_container( row = 1 column = 1 ).
    cl_salv_table=>factory( EXPORTING r_container = io_container1 IMPORTING r_salv_table = DATA(o_alv) CHANGING t_table = t_alv ).
    o_alv->get_functions( )->set_all( t_yes ).
    o_alv->get_selections( )->set_selection_mode( if_salv_c_selection_mode=>single ).
    o_alv->get_columns( )->set_optimize( t_yes ).
    o_alv->get_columns( )->get_column( 'IDADE' )->set_short_text( 'IDADE' ).
    o_alv->get_columns( )->get_column( 'IDADE' )->set_medium_text( 'IDADE' ).
    o_alv->get_columns( )->get_column( 'IDADE' )->set_long_text( 'IDADE' ).
    o_alv->display( ).
    WRITE: space.

    DATA(io_container2) = io_splitter->get_container( row = 2 column = 1 ).
    cl_salv_table=>factory( EXPORTING r_container = io_container2 IMPORTING r_salv_table = DATA(o_alv2) CHANGING t_table = t_alv2 ).
    o_alv2->get_functions( )->set_all( t_yes ).
    o_alv2->get_selections( )->set_selection_mode( if_salv_c_selection_mode=>single ).
    o_alv2->get_columns( )->set_optimize( t_yes ).
    o_alv2->display( ).

  ENDIF.

ENDFORM.