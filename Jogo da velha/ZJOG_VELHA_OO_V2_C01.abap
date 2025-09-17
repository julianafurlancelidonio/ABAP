*&---------------------------------------------------------------------*
*& Include          ZJOG_VELHA_OO_V2_C01
*&---------------------------------------------------------------------*
CLASS: lcl_jogo DEFINITION.
  PUBLIC SECTION.
    DATA: g_ucomm     TYPE syucomm,
          v_jogada    TYPE c VALUE 'X',
          v_resultado TYPE c VALUE 'O'.

    METHODS:
      jogar CHANGING cv_but1 TYPE any
                     cv_but2 TYPE any
                     cv_but3 TYPE any
                     cv_bub1 TYPE any
                     cv_bub2 TYPE any
                     cv_bub3 TYPE any
                     cv_buc1 TYPE any
                     cv_buc2 TYPE any
                     cv_buc3 TYPE any
                     cv_comm TYPE any.
ENDCLASS.
*&---------------------------------------------------------------------*
*& Class (Implementation) lcl_jogo
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
CLASS lcl_jogo IMPLEMENTATION.

  METHOD jogar.
    CASE sy-ucomm.
      WHEN 'BUT1'.
        cv_but1 = v_jogada.
      WHEN 'BUB1'.
        cv_bub1 = v_jogada.
      WHEN 'BUC1'.
        cv_buc1 = v_jogada.
      WHEN 'BUT2'.
        cv_but2 = v_jogada.
      WHEN 'BUB2'.
        cv_bub2 = v_jogada.
      WHEN 'BUC2'.
        cv_buc2 = v_jogada.
      WHEN 'BUT3'.
        cv_but3 = v_jogada.
      WHEN 'BUB3'.
        cv_bub3 = v_jogada.
      WHEN 'BUC3'.
        cv_buc3 = v_jogada.
    ENDCASE.

    IF v_jogada = 'X'.
      v_jogada = 'O'.
    ELSE.
      v_jogada = 'X'.
    ENDIF.

    IF  ( cv_but1 = 'X' AND cv_bub2 = 'X' AND cv_buc3 = 'X' ) OR
        ( cv_buc1 = 'X' AND cv_bub2 = 'X' AND cv_but3 = 'X' ) OR
        ( cv_but1 = 'X' AND cv_but2 = 'X' AND cv_but3 = 'X' ) OR
        ( cv_bub1 = 'X' AND cv_bub2 = 'X' AND cv_bub3 = 'X' ) OR
        ( cv_buc1 = 'X' AND cv_buc2 = 'X' AND cv_buc3 = 'X' ) OR
        ( cv_but1 = 'X' AND cv_bub1 = 'X' AND cv_buc1 = 'X' ) OR
        ( cv_but2 = 'X' AND cv_bub2 = 'X' AND cv_buc2 = 'X' ) OR
        ( cv_but3 = 'X' AND cv_bub3 = 'X' AND cv_buc3 = 'X' ).
      cv_comm = 'X ganhou!'.
    ELSEIF ( cv_but1 = 'O' AND cv_bub2 = 'O' AND cv_buc3 = 'O' ) OR
           ( cv_buc1 = 'O' AND cv_bub2 = 'O' AND cv_but3 = 'O' ) OR
           ( cv_but1 = 'O' AND cv_but2 = 'O' AND cv_but3 = 'O' ) OR
           ( cv_bub1 = 'O' AND cv_bub2 = 'O' AND cv_bub3 = 'O' ) OR
           ( cv_buc1 = 'O' AND cv_buc2 = 'O' AND cv_buc3 = 'O' ) OR
           ( cv_but1 = 'O' AND cv_bub1 = 'O' AND cv_buc1 = 'O' ) OR
           ( cv_but2 = 'O' AND cv_bub2 = 'O' AND cv_buc2 = 'O' ) OR
           ( cv_but3 = 'O' AND cv_bub3 = 'O' AND cv_buc3 = 'O' ).
      cv_comm = 'O ganhou!'.
    ELSEIF cv_but1 <> ' ' AND cv_but2 <> ' ' AND cv_but3 <> ' ' AND
           cv_bub1 <> ' ' AND cv_bub2 <> ' ' AND cv_bub3 <> ' ' AND
           cv_buc1 <> ' ' AND cv_buc2 <> ' ' AND cv_buc3 <> ' '.
      cv_comm = 'Empate!'.
    ENDIF.
    CASE sy-ucomm.
      WHEN 'INICIO'.
        CLEAR:  cv_but1, cv_but2 ,cv_but3 ,
                cv_bub1 , cv_bub2 , cv_bub3 ,
                cv_buc1 , cv_buc2 , cv_buc3.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.