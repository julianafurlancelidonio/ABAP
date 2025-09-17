*&---------------------------------------------------------------------*
*& Report ZRT0005
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zrt0005.

*Definição dos Parâmetros
PARAMETERS: p_peso TYPE p DECIMALS 2.
PARAMETERS: p_altura TYPE p DECIMALS 2.

*Definição dos Valores
DATA: v_imc TYPE p DECIMALS 2.
DATA: v_imc_exit TYPE string.

*Definição do Cálculo
v_imc = p_peso / ( p_altura * p_altura ).
v_imc_exit = replace( val = condense( CONV string( v_imc ) ) sub = '.' with = ',' ).

*Definição das Condições
IF v_imc < '17'.
  WRITE: 'O IMC é', v_imc_exit, 'e a situação é muito abaixo do peso'.
ELSEIF v_imc >= '17.0' AND v_imc < '18.5'.
  WRITE: 'O IMC é', v_imc_exit.
  WRITE: 'e a situação é abaixo do peso'.
ELSEIF v_imc >= '18.5' AND v_imc < '25.0'.
  WRITE: 'O IMC é', v_imc.
  WRITE: 'e a situação é peso normal'.
ELSEIF v_imc >= '25.0' AND v_imc < '30.0'.
  WRITE: 'O IMC é', v_imc.
  WRITE: 'e a situação é acima do peso'.
ELSEIF v_imc >= '30.0' AND v_imc < '35.0'.
  WRITE: 'O IMC é', v_imc.
  WRITE: 'e a situação é obesidade I'.
ELSEIF v_imc >= '35.0' AND v_imc < '40.0'.
  WRITE: 'O IMC é', v_imc.
  WRITE: 'e a situação é obesidade II (severa)'.
ELSEIF v_imc >= '40.0'.
  WRITE: 'O IMC é', v_imc.
  WRITE: 'e a situação é obesidade III (mórbida)'.
ENDIF.