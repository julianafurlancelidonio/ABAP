*&---------------------------------------------------------------------*
*& Report ZJOG_VELHA_OO_V2
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zjog_velha_oo_v2.

INCLUDE: zjog_velha_oo_v2_c01. "Definição/Implementação de Classes
INCLUDE: zjog_velha_oo_v2_top. "Declaração Global, Tela de Seleção

INITIALIZATION.
  CREATE OBJECT lo_jogo.

AT SELECTION-SCREEN.
  lo_jogo->jogar( CHANGING  cv_but1 = p_but1
                            cv_but2 = p_but2
                            cv_but3 = p_but3
                            cv_bub1 = p_bub1
                            cv_bub2 = p_bub2
                            cv_bub3 = p_bub3
                            cv_buc1 = p_buc1
                            cv_buc2 = p_buc2
                            cv_buc3 = p_buc3
                            cv_comm = p_comm ).