#include 'totvs.ch'
#include 'topconn.ch'
/*{Protheus.doc} ScriptViradaVersao
Classe ScriptViradaVersao ERP Protheus definida para a correcao sobre os erros 
criticos na migração de release. 
@type User function 
@version ERP P12.1.2310
@Autor - Mayki Lima
@since   01/2024
*/
CLASS ScriptViradaVersao From LongNameClass
	
    Data cQry           As Character
	Data cEmpresa       As Character
	Data cTexto         As Character
	Data oArq   	    As Object
	Data lPrimeira      As Logical
	Data nTimer			As Numeric
	Data nCont			As Numeric
	Data nReg           As Numeric
	Data _nResult       As Numeric
	Data aItems 		As Array 
  
	METHOD New() CONSTRUCTOR
	METHOD UPDATE_SX3xSXG()
	METHOD UPDATE_SIX()
	METHOD UPDATE_SX1xSXG()
	METHOD UPDATE_SIXxSX3()
	
ENDCLASS

METHOD New() CLASS ScriptViradaVersao

	::cQry          := ""
	::cEmpresa      := ""
	::cTexto        := ""
	::nReg 			:= 0
	::oArq          := Nil
	::lPrimeira     := .F.
	::nTimer	    := 0
	::nCont         := 0 
	::_nResult      := 0
    ::aItems 		:= {}

RETURN(Self)

METHOD UPDATE_SX3xSXG() CLASS ScriptViradaVersao

 ::cQry :=   "SELECT X3_ARQUIVO                       			"    
 ::cQry +=   ",X3_CAMPO                                			"
 ::cQry +=   ",X3_TAMANHO                              			"
 ::cQry +=   ",X3_DECIMAL                             			"
 ::cQry +=   ",XG_SIZE                                          "
 ::cQry +=   ",X3_GRPSXG                              			"
 ::cQry +=   "FROM SX3"+::cEmpresa+"0 AS X3           		    "              
 ::cQry +=   "LEFT OUTER JOIN SXG"+::cEmpresa+"0 AS XG   		" 
 ::cQry +=   "ON 1=1                                   			"
 ::cQry +=   "AND XG.XG_GRUPO = X3.X3_GRPSXG                 	"
 ::cQry +=   "WHERE 1=1                                			"
 ::cQry +=   "AND X3.X3_TAMANHO != XG.XG_SIZE                	"

 	        If Select("TMPSX")>0
				TMPSX->(DbCloseArea())
			EndIf
		
			::cQry:= ChangeQuery(::cQry)
            TCQUERY (::cQry)  Alias "TMPSX" New

            While !TMPSX->(EOF()) 

			::nTimer := seconds()
				
				::cQry := "UPDATE SX3"+::cEmpresa+"0 " +CRLF
				//::cQry += "SET X3_TAMANHO = " + cvaltochar(TMPSX->XG_SIZE) + " "   +CRLF
				::cQry += "SET X3_GRPSXG = ' ' "   +CRLF
				::cQry += "WHERE 1=1 " +CRLF
				::cQry += "AND X3_ARQUIVO = '"+ TMPSX->X3_ARQUIVO + "' "  +CRLF
				::cQry += "AND X3_CAMPO = '"+TMPSX->X3_CAMPO+ "' " + CRLF

					Begin Transaction
							::_nResult := TCSQLEXEC(::cQry)
  					End Transaction
					 
					 If ::_nResult < 0
							 LogMsg('tlogmsg', 22, 5, 1, '', '', "> *=*=*=*=*=*=*=*=*=*=*=*=* ")
				             LogMsg('tlogmsg', 22, 5, 1, '', '', ">  ")
							 LogMsg('tlogmsg', 22, 5, 1, '', '', "> *=*=*=*=*=*=*=*=*=*=*=*=* FALHA  UPDATE_SX3xSXG() *=*=*=*=*=*=*=*=*=*=*=*=*")
							 LogMsg('tlogmsg', 22, 5, 1, '', '', "> Empresa: "  + ::cEmpresa)
                   	         LogMsg('tlogmsg', 22, 5, 1, '', '', "> FALHA ao alterar o campo: "   	+ alltrim(TMPSX->X3_CAMPO))
					         LogMsg('tlogmsg', 22, 5, 1, '', '', "> Valor antigo: "   	    + CVALTOCHAR(TMPSX->X3_TAMANHO))
							 LogMsg('tlogmsg', 22, 5, 1, '', '', "> Novo valor: "   		+ CVALTOCHAR(TMPSX->XG_SIZE))
							 LogMsg('tlogmsg', 22, 5, 1, '', '', "> Pertence ao grupo: "   		+ CVALTOCHAR(TMPSX->X3_GRPSXG))
				   			 LogMsg('tlogmsg', 22, 5, 1, '', '', "> DESCRICAO DO ERRO :: " +cValtochar(TcSqlError()))
							 ::nTimer := seconds() - ::nTimer
							 LogMsg('tlogmsg', 22, 5, 1, '', '', "Duracao: .......... "+str(::nTimer,12,3)+" s.")
							 LogMsg('tlogmsg', 22, 5, 1, '', '', "> *=*=*=*=*=*=*=*=*=*=*=*=* ")
		    		else 
							 LogMsg('tlogmsg', 22, 5, 1, '', '', "> *=*=*=*=*=*=*=*=*=*=*=*=* ")
				             LogMsg('tlogmsg', 22, 5, 1, '', '', ">  ")
							 LogMsg('tlogmsg', 22, 5, 1, '', '', "> Metodo: UPDATE_SX3xSXG()")
							 LogMsg('tlogmsg', 22, 5, 1, '', '', "> Empresa: "  + ::cEmpresa)
                   	         LogMsg('tlogmsg', 22, 5, 1, '', '', "> Alterado campo: "   	+ alltrim(TMPSX->X3_CAMPO))
					         LogMsg('tlogmsg', 22, 5, 1, '', '', "> Valor antigo: "   	    + CVALTOCHAR(TMPSX->X3_TAMANHO))
							 LogMsg('tlogmsg', 22, 5, 1, '', '', "> Novo valor: "   		+ CVALTOCHAR(TMPSX->XG_SIZE))
							  LogMsg('tlogmsg', 22, 5, 1, '', '', "> Pertence ao grupo: "   		+ CVALTOCHAR(TMPSX->X3_GRPSXG))
				   			::nTimer := seconds() - ::nTimer
							 LogMsg('tlogmsg', 22, 5, 1, '', '', "Duracao: .......... "+str(::nTimer,12,3)+" s.")
							 LogMsg('tlogmsg', 22, 5, 1, '', '', "> *=*=*=*=*=*=*=*=*=*=*=*=* ")
					endif 
				
				
            TMPSX->(dbSkip()) 
            EndDo		
RETURN()

METHOD UPDATE_SIX() CLASS ScriptViradaVersao 

Local _nResult := 0 

	::cQry := " SELECT R_E_C_N_O_ as RECSIX, CHAVE as CHAVES"+CRLF
    ::cQry += " FROM SIX"+::cEmpresa+"0  " +CRLF
    ::cQry += " WHERE 1=1 "+CRLF
    ::cQry += " AND CHAVE IN (SELECT  CHAVE "  +CRLF                   
    ::cQry += "                   FROM SIX"+::cEmpresa+"0  " +CRLF
    ::cQry += "                   WHERE 1=1 "+CRLF
    ::cQry += "                   GROUP BY INDICE, CHAVE "+CRLF
    ::cQry += "                   HAVING COUNT(*) > 1 ) "+CRLF
    ::cQry += " AND R_E_C_N_O_ NOT IN (SELECT  MIN(R_E_C_N_O_ ) "  +CRLF 
    ::cQry += "                   FROM SIX"+::cEmpresa+"0  " +CRLF
    ::cQry += "                   WHERE 1=1 "+CRLF
    ::cQry += "                   GROUP BY INDICE, CHAVE  "+CRLF
    ::cQry += "                   HAVING COUNT(*) > 1 ) "+CRLF
    ::cQry += " ORDER BY CHAVE "+CRLF

	        If Select("TMPSX")>0
				TMPSX->(DbCloseArea())
			EndIf
     
	 		::cQry:= ChangeQuery(::cQry)
     		TCQUERY (::cQry)  Alias "TMPSX" New

   			 While TMPSX->(!Eof())   

					::nTimer := seconds()

				::cQry := " DELETE SIX"+::cEmpresa+"0  " +CRLF
				::cQry += " WHERE R_E_C_N_O_ = "+cvaltochar(TMPSX->(RECSIX))+" " +CRLF
				
			  	Begin Transaction
					_nResult := TCSQLEXEC(::cQry)
  			  	End Transaction

  	            If _nResult < 0
					         LogMsg('tlogmsg', 22, 5, 1, '', '', "> *=*=*=*=*=*=*=*=*=*=*=*=* ")
				             LogMsg('tlogmsg', 22, 5, 1, '', '', ">  ")
							 LogMsg('tlogmsg', 22, 5, 1, '', '', "> *=*=*=*=*=*=*=*=*=*=*=*=* FALHA  UPDATE_SIX() *=*=*=*=*=*=*=*=*=*=*=*=*")
                   	         LogMsg('tlogmsg', 22, 5, 1, '', '', "> Empresa: "  + ::cEmpresa)
							 LogMsg('tlogmsg', 22, 5, 1, '', '', "> FALHA AO DELETAR A CHAVE: "  + cvaltochar(TMPSX->CHAVES))
							 LogMsg('tlogmsg', 22, 5, 1, '', '', "> RECNO: "  + cvaltochar(TMPSX->RECSIX))
							 LogMsg('tlogmsg', 22, 5, 1, '', '', "> DESCRICAO DO ERRO :: " +cValtochar(TcSqlError()))
							 LogMsg('tlogmsg', 22, 5, 1, '', '', "Duracao: .......... "+str(::nTimer,12,3)+" s.")
							 LogMsg('tlogmsg', 22, 5, 1, '', '', "> *=*=*=*=*=*=*=*=*=*=*=*=* ")
					
  	            else
							 LogMsg('tlogmsg', 22, 5, 1, '', '', "> *=*=*=*=*=*=*=*=*=*=*=*=* ")
				             LogMsg('tlogmsg', 22, 5, 1, '', '', ">  ")
							 LogMsg('tlogmsg', 22, 5, 1, '', '', "> Metodo: UPDATE_SIX()")
                   	         LogMsg('tlogmsg', 22, 5, 1, '', '', "> Empresa: "  + ::cEmpresa)
							 LogMsg('tlogmsg', 22, 5, 1, '', '', "> CHAVE deletada: "  + cvaltochar(TMPSX->CHAVES))
							 LogMsg('tlogmsg', 22, 5, 1, '', '', "> RECNO: "  + cvaltochar(TMPSX->RECSIX))
							 LogMsg('tlogmsg', 22, 5, 1, '', '', "Duracao: .......... "+str(::nTimer,12,3)+" s.")
							 LogMsg('tlogmsg', 22, 5, 1, '', '', "> *=*=*=*=*=*=*=*=*=*=*=*=* ")
				endif
		    			 
			 TMPSX->(DbSkip())
			 EndDo  
			
RETURN()


METHOD UPDATE_SX1xSXG() CLASS ScriptViradaVersao

 ::cQry :=   "SELECT X1_GRPSXG                       			"    
 ::cQry +=   ",XG_GRUPO                                			"
 ::cQry +=   ",X1_ORDEM                               			"
 ::cQry +=   ",X1_GRUPO                                			"
 ::cQry +=   ",X1_TAMANHO                              			"
 ::cQry +=   ",XG_SIZE                             			    "
 ::cQry +=   "FROM SX1"+::cEmpresa+"0 AS X1           		    "              
 ::cQry +=   "LEFT OUTER JOIN SXG"+::cEmpresa+"0 AS XG   		" 
 ::cQry +=   "ON 1=1                                   			"
 ::cQry +=   "AND X1.X1_GRPSXG = XG.XG_GRUPO                 	"
 ::cQry +=   "WHERE 1=1                                			"
 ::cQry +=   "AND X1.X1_GRPSXG != ' '                			"
 ::cQry +=   "AND X1.X1_TAMANHO != XG.XG_SIZE                 	"

 	        If Select("TMPSX")>0
				TMPSX->(DbCloseArea())
			EndIf
			
			::cQry:= ChangeQuery(::cQry)
            TCQUERY (::cQry)  Alias "TMPSX" New

            While !TMPSX->(EOF()) 

			::nTimer := seconds()

				::cQry := "UPDATE SX1"+::cEmpresa+"0 " +CRLF
				::cQry += "SET X1_TAMANHO = " + cvaltochar(TMPSX->XG_SIZE) + " "   +CRLF
				::cQry += "WHERE 1=1 " +CRLF
				::cQry += "AND X1_GRUPO = '"+ TMPSX->X1_GRUPO + "' "  +CRLF
				::cQry += "AND X1_ORDEM = '"+TMPSX->X1_ORDEM+ "' " + CRLF

					Begin Transaction
							::_nResult := TCSQLEXEC(::cQry)
  					End Transaction
					 
					 If ::_nResult < 0
							 LogMsg('tlogmsg', 22, 5, 1, '', '', "> *=*=*=*=*=*=*=*=*=*=*=*=* ")
				             LogMsg('tlogmsg', 22, 5, 1, '', '', ">  ")
							 LogMsg('tlogmsg', 22, 5, 1, '', '', "> *=*=*=*=*=*=*=*=*=*=*=*=* FALHA  UPDATE_SX1xSXG() *=*=*=*=*=*=*=*=*=*=*=*=*")
							 LogMsg('tlogmsg', 22, 5, 1, '', '', "> Empresa: "  + ::cEmpresa)
                   	         LogMsg('tlogmsg', 22, 5, 1, '', '', "> FALHA ao Alterado pergunta do grupo: "   	+ alltrim(TMPSX->X1_GRUPO))
					         LogMsg('tlogmsg', 22, 5, 1, '', '', "> Pergunta de ordem: "   	+ alltrim(TMPSX->X1_ORDEM))
							 LogMsg('tlogmsg', 22, 5, 1, '', '', "> Valor antigo: "   	    + cvaltochar(TMPSX->X1_TAMANHO))
							 LogMsg('tlogmsg', 22, 5, 1, '', '', "> Novo valor: "   		+ cvaltochar(TMPSX->XG_SIZE) )
							 LogMsg('tlogmsg', 22, 5, 1, '', '', "> DESCRICAO DO ERRO :: " +cValtochar(TcSqlError()))
				   			::nTimer := seconds() - ::nTimer
							 LogMsg('tlogmsg', 22, 5, 1, '', '', "Duracao: .......... "+str(::nTimer,12,3)+" s.")
							 LogMsg('tlogmsg', 22, 5, 1, '', '', "> *=*=*=*=*=*=*=*=*=*=*=*=* ")
						   
		    			else 
							 LogMsg('tlogmsg', 22, 5, 1, '', '', "> *=*=*=*=*=*=*=*=*=*=*=*=* ")
				             LogMsg('tlogmsg', 22, 5, 1, '', '', ">  ")
							 LogMsg('tlogmsg', 22, 5, 1, '', '', "> Metodo: UPDATE_SX1xSXG()")
							 LogMsg('tlogmsg', 22, 5, 1, '', '', "> Empresa: "  + ::cEmpresa)
                   	         LogMsg('tlogmsg', 22, 5, 1, '', '', "> Alterado pergunta do grupo: "   	+ alltrim(TMPSX->X1_GRUPO))
					         LogMsg('tlogmsg', 22, 5, 1, '', '', "> Pergunta de ordem: "   	+ alltrim(TMPSX->X1_ORDEM))
							 LogMsg('tlogmsg', 22, 5, 1, '', '', "> Valor antigo: "   	    + cvaltochar(TMPSX->X1_TAMANHO))
							 LogMsg('tlogmsg', 22, 5, 1, '', '', "> Novo valor: "   		+ cvaltochar(TMPSX->XG_SIZE) )
				   			::nTimer := seconds() - ::nTimer
							 LogMsg('tlogmsg', 22, 5, 1, '', '', "Duracao: .......... "+str(::nTimer,12,3)+" s.")
							 LogMsg('tlogmsg', 22, 5, 1, '', '', "> *=*=*=*=*=*=*=*=*=*=*=*=* ")
						endif 		
            TMPSX->(dbSkip()) 
            EndDo			
RETURN()



METHOD UPDATE_SIXxSX3() CLASS ScriptViradaVersao

    Local cNovoIndice := ""
	Local nTotalOri   := 0 
	Local nRestante   := 0

	::cQry := " SELECT CHAVE as CHAVES "+CRLF
    ::cQry += " FROM SIX"+::cEmpresa+"0 (NOLOCK) " +CRLF
    ::cQry += " WHERE 1=1 "+CRLF
    ::cQry += " AND D_E_L_E_T_ = ' ' "  +CRLF     
//	::cQry += " AND CHAVE LIKE '%ABL_FILIAL+ABL_REAVAL+ABL_PRIORI+ABL_SEQUEN%'  "  +CRLF                 
   
	        If Select("TMPSX")>0
				TMPSX->(DbCloseArea())
			EndIf
     
	 		::cQry:= ChangeQuery(::cQry)
     		TCQUERY (::cQry)  Alias "TMPSX" New

             Count To nTotalOri
			 TMPSX->(DbGotop())


   			 While TMPSX->(!Eof())   

			 ::nTimer := seconds()

			  nRestante := nRestante + 1 

               ::aItems := StrTokArr2(TMPSX->CHAVES,'+')

               FOR  ::nCont := 1 TO LEN(::aItems)

                    	::cQry := " SELECT X3_CAMPO as CAMPO "+CRLF
                        ::cQry += " FROM SX3"+::cEmpresa+"0 (NOLOCK) " +CRLF
                        ::cQry += " WHERE 1=1 "+CRLF
                        ::cQry += " AND D_E_L_E_T_ = ' ' "  +CRLF  
                        ::cQry += " AND X3_CAMPO LIKE '%"+alltrim(::aItems[::nCont])+"%' " +CRLF


                                If Select("TMPSX3")>0
				                      TMPSX3->(DbCloseArea())
			                    EndIf
       
	 		                   ::cQry:= ChangeQuery(::cQry)
     		                   TCQUERY (::cQry)  Alias "TMPSX3" New

                          If !TMPSX3->(Eof())   
                            loop 
                          Else
                              
    							cNovoIndice := TMPSX->CHAVES

								if   alltrim(::aItems[::nCont]) $ alltrim(cNovoIndice) 
    							    cNovoIndice :=  strtran(cNovoIndice,::aItems[::nCont],"")
    							    cNovoIndice :=  strtran(cNovoIndice,"++","+")
    							    iif(At("+",cNovoIndice)==1,cNovoIndice:=SUBSTR(cNovoIndice,2,len(cNovoIndice)),)
    							    iif(rAt("+",cNovoIndice)==len(alltrim(cNovoIndice)),cNovoIndice:=SUBSTR(cNovoIndice,1,len(alltrim(cNovoIndice))-1),)
    							Endif 

                                       ::cQry := "UPDATE SIX"+::cEmpresa+"0 " +CRLF
				                       ::cQry += "SET CHAVE = '" + ALLTRIM(cNovoIndice) + "' "   +CRLF
				                       ::cQry += "WHERE 1=1 " +CRLF
				                       ::cQry += "AND CHAVE = '"+ ALLTRIM(TMPSX->CHAVES) + "' "  +CRLF
				                  
                                  
                                	Begin Transaction
										::_nResult := TCSQLEXEC(::cQry)
  			  						End Transaction

  	            		If ::_nResult < 0
					         LogMsg('tlogmsg', 22, 5, 1, '', '', "> *=*=*=*=*=*=*=*=*=*=*=*=* ")
				             LogMsg('tlogmsg', 22, 5, 1, '', '', ">  ")
							 LogMsg('tlogmsg', 22, 5, 1, '', '', "> *=*=*=*=*=*=*=*=*=*=*=*=* FALHA UPDATE_SIXxSX3()  *=*=*=*=*=*=*=*=*=*=*=*=*")
                   	         LogMsg('tlogmsg', 22, 5, 1, '', '', "> Empresa: "  + ::cEmpresa)
							 LogMsg('tlogmsg', 22, 5, 1, '', '', "> FALHA AO ALTERAR A CHAVE: "  + cvaltochar(TMPSX->CHAVES))
							 LogMsg('tlogmsg', 22, 5, 1, '', '', "> DESCRICAO DO ERRO :: " +cValtochar(TcSqlError()))
							 ::nTimer := seconds() - ::nTimer
							 LogMsg('tlogmsg', 22, 5, 1, '', '', "Duracao: .......... "+str(::nTimer,12,3)+" s.")
							 LogMsg('tlogmsg', 22, 5, 1, '', '', "Registros processados: "+cvaltochar(nRestante)+" total de "+cvaltochar(nTotalOri))
							 LogMsg('tlogmsg', 22, 5, 1, '', '', "> *=*=*=*=*=*=*=*=*=*=*=*=* ")
  	            				else
							 LogMsg('tlogmsg', 22, 5, 1, '', '', "> *=*=*=*=*=*=*=*=*=*=*=*=* ")
				             LogMsg('tlogmsg', 22, 5, 1, '', '', ">  ")
							 LogMsg('tlogmsg', 22, 5, 1, '', '', "> Metodo: UPDATE_SIXxSX3() ")
                   	         LogMsg('tlogmsg', 22, 5, 1, '', '', "> Empresa: "  + ::cEmpresa)
							 LogMsg('tlogmsg', 22, 5, 1, '', '', "> Valor anterior da chave: "  + cvaltochar(TMPSX->CHAVES))
							  LogMsg('tlogmsg', 22, 5, 1, '', '',"> Valor atual da chave: "  +  ALLTRIM(cNovoIndice))
							  ::nTimer := seconds() - ::nTimer
							 LogMsg('tlogmsg', 22, 5, 1, '', '', "Duracao: .......... "+str(::nTimer,12,3)+" s.")
						     LogMsg('tlogmsg', 22, 5, 1, '', '', "Registros processados: "+cvaltochar(nRestante)+" total de "+cvaltochar(nTotalOri))
							 LogMsg('tlogmsg', 22, 5, 1, '', '', "> *=*=*=*=*=*=*=*=*=*=*=*=* ")
						endif
                    EndIf 
                          
               NEXT ::nCont
              		    			 
			 TMPSX->(DbSkip())
			 EndDo  

RETURN()
