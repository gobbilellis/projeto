#INCLUDE "protheus.CH"
#INCLUDE "TOPCONN.CH"


User Function M410AGRV

	// Local nPosPrcUnit    := Ascan(aHeader, {|x| AllTrim(x[2]) == "C6_PRUNIT"})
	Local nPosPrcVen    := Ascan(aHeader, {|x| AllTrim(x[2]) == "C6_PRCVEN"})
	Local nPosDes    := Ascan(aHeader, {|x| AllTrim(x[2]) == "C6_DESCONT"})
	Local nPosVlDes    := Ascan(aHeader, {|x| AllTrim(x[2]) == "C6_VALDESC"})
	Local nPosYPrcVe    := Ascan(aHeader, {|x| AllTrim(x[2]) == "C6_YPRCVE"})
	Local nPosYDesc    := Ascan(aHeader, {|x| AllTrim(x[2]) == "C6_YDESCON"})
	Local nPosYVlDes    := Ascan(aHeader, {|x| AllTrim(x[2]) == "C6_YVALDES"})
	Local cCodProd    := Ascan(aHeader, {|x| AllTrim(x[2]) == "C6_PRODUTO"})

	Local nTotalPrcVen := 0
	Local nTotalPrcUnit := 0
	Local nTotalDesc := 0
	Local cAux := ""

	Private cComAuto := AllTrim(M->C5_YCOMAUT) // Recebendo o valor se a comissão vai ser aplicada automáticamente 1 para Automático 2 para Manual
	Private cZeraDesc := AllTrim(M->C5_YDESCNF) // Recebendo o valor se o desconto vai ser levado para a nota fiscal ou não. Valor 1 para Sim e Valor 2 para não

	//Se a comissão tiver como automático, executo o fonte fazendo as tratativas
	If(cComAuto == '1') //Opção Automática no Cálculo de comissão.
		For nX := 1 to Len(aCols)
			nTotalPrcVen	+= aCols[nX, nPosPrcVen]
			cAux := aCols[nX, cCodProd]
			// nTotalPrcUnit 	+= aCols[nX, nPosPrcUnit]
			nTotalPrcUnit 	+= POSICIONE("SB1",1,xFilial("SB1")+cAux,"B1_PRV1")              
			// nTotalPrcUnit 	+= POSICIONE("SB1",1,xFilial("SB1")+SB1->B1_COD,"B1_PRV1")              

		next

		nTotalDesc:= 	(-100*(nTotalPrcVen / nTotalPrcUnit))+100

		For nX := 1 To 5
			If !(Empty(&("M->C5_VEND" + cValToChar(nX))))
				&("M->C5_COMIS" + cValToChar(nX))  := ZCOMIS(&("M->C5_VEND"+ cValToChar(nX)), nTotalDesc)   //ATRIBUI O RETORNO DA FUNÇÃO A COMISSAO DO PEDIDO DE VENDA
			EndIf
		next

	EndIf

	if(cZeraDesc == '2') //Opção Não será apresentado desconto na nota fiscal
		For nX := 1 to Len(aCols)
			aCols[nX, nPosYPrcVe] 	:= aCols[nX, nPosPrcVen]
			aCols[nX, nPosYDesc] 	:= aCols[nX, nPosDes]
			aCols[nX, nPosYVlDes] 	:= aCols[nX, nPosVlDes]
			aCols[nX, nPosPrcVen] 	:= 0
			aCols[nX, nPosDes] 		:= 0
			aCols[nX, nPosVlDes] 	:= 0
		next

	EndIf

return

Static Function ZCOMIS(cVend, nDesc)

	Local qSQuery	  := ""
	Local cSql   	  := ""
	Local nComis	  := 0
	
	cSql := "SELECT ZA3_COMIS "
	cSql += "FROM " + RetSqlName("ZA3")+ " ZA3 "
	cSql += "WHERE ZA3_DESC = '" 	+ cValToChar(nDesc) + "'"
	cSql += "AND	ZA3_CODVEN = '" + cVend + "'"
	cSql += "AND D_E_L_E_T_ = ''" 

	TCQUERY cSql NEW ALIAS qSQuery
			
	While qSQuery->(!eof())	
		nComis += qSQuery->ZA3_COMIS
		qSQuery->(DbSkip())              		
	EndDo    
			
	qSQuery->(DbCloseArea())

Return nComis
