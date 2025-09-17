*&---------------------------------------------------------------------*
*& Report ZRT0005
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zrt0005.

*Defini��o dos Par�metros
PARAMETERS: p_peso TYPE p DECIMALS 2.
PARAMETERS: p_altura TYPE p DECIMALS 2.

*Defini��o dos Valores
DATA: v_imc TYPE p DECIMALS 2.
DATA: v_imc_exit TYPE string.

*Defini��o do C�lculo
v_imc = p_peso / ( p_altura * p_altura ).
v_imc_exit = replace( val = condense( CONV string( v_imc ) ) sub = '.' with = ',' ).

*Defini��o das Condi��es
IF v_imc < '17'.
  WRITE: 'O IMC �', v_imc_exit, 'e a situa��o � muito abaixo do peso'.
ELSEIF v_imc >= '17.0' AND v_imc < '18.5'.
  WRITE: 'O IMC �', v_imc_exit.
  WRITE: 'e a situa��o � abaixo do peso'.
ELSEIF v_imc >= '18.5' AND v_imc < '25.0'.
  WRITE: 'O IMC �', v_imc.
  WRITE: 'e a situa��o � peso normal'.
ELSEIF v_imc >= '25.0' AND v_imc < '30.0'.
  WRITE: 'O IMC �', v_imc.
  WRITE: 'e a situa��o � acima do peso'.
ELSEIF v_imc >= '30.0' AND v_imc < '35.0'.
  WRITE: 'O IMC �', v_imc.
  WRITE: 'e a situa��o � obesidade I'.
ELSEIF v_imc >= '35.0' AND v_imc < '40.0'.
  WRITE: 'O IMC �', v_imc.
  WRITE: 'e a situa��o � obesidade II (severa)'.
ELSEIF v_imc >= '40.0'.
  WRITE: 'O IMC �', v_imc.
  WRITE: 'e a situa��o � obesidade III (m�rbida)'.
ENDIF.