#INCLUDE "protheus.CH"
#INCLUDE "TOPCONN.CH"

User Function M410LIOK()

    Local lRet      := .T.
	Local nPorDes   := aCols[n,FG_POSVAR("C6_DESCONT","aHeader")]
    Local nParam    := GETMV("CL_MAXDESC")

    if(nPorDes > nParam)
        MsgStop("O Desconto do item n�o pode ser maior que: "+ cValToChar(nParam)+"%","M410LIOK")
        lRet := .F.
    EndIf

return lRet
