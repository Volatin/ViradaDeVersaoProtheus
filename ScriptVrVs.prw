#include 'totvs.ch'
#include 'topconn.ch'
/*{Protheus.doc} ScriptVrVs
Funcao ScriptVrVs ERP Protheus responsavel por realizar as chamadas dos metodos da classe 
ScriptViradaVersao que corrigem os erros criticos na migração de release 
de uma forma recursiva para todas as empresas do grupo. 
@type User function 
@version ERP P12.1.2310
@Autor - Mayki Lima
@since   01/2024
*/
User Function ScriptVrVs()

    RPCClearEnv()
	RPCSetEnv('12','01')

    Local  oBjeto     := ScriptViradaVersao:New()
    Local  cQry      := ""
    Local  lVerdad   := .T.

    cQry :="SELECT M0_CODIGO "
    cQry +="FROM SYS_COMPANY (NOLOCK) "
	cQry +="WHERE D_E_L_E_T_ = ' ' "
//	cQry +="AND M0_CODIGO = '11' "
    cQry +="GROUP BY M0_CODIGO " 
	cQry +="ORDER BY M0_CODIGO "

            If Select("TBLEMP")>0
				TBLEMP->(DbCloseArea())
			EndIf

			cQry:= ChangeQuery(cQry)
            TCQUERY (cQry)  Alias "TBLEMP" New
            
             While !TBLEMP->(EOF()) 
                       
                        oBjeto:cEmpresa    := alltrim(TBLEMP->M0_CODIGO)

                        IF lVerdad ==   GetMv("XM_SX3SXG")
			                 oBjeto:UPDATE_SX3xSXG()  
                        ENDIF 
	                    IF lVerdad  == GetMv("XM_UPDSIX")
			                 oBjeto:UPDATE_SIX()  
	                    ENDIF
                        IF lVerdad  == GetMv("XM_SX1SXG")
			                 oBjeto:UPDATE_SX1xSXG()  
	                    ENDIF
                        IF lVerdad  == GetMv("XM_SX1SXG")
                             oBjeto:UPDATE_SIXxSX3() 
                        ENDIF

             TBLEMP->(dbSkip()) 
             EndDo

RETURN()
