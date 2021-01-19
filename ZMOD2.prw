//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
  
//Vari�veis Est�ticas
Static cTitulo := "Cadastro de faixa de comiss�o"
  
/*/{Protheus.doc} ZMOD2
Fun��o para cadastros de Comiss�o
@author 
@since 
@version 1.0
    @return Nil, Fun��o n�o tem retorno
    @example
    u_ZMOD2()
/*/
 
User Function ZMOD2()
    Local aArea   := GetArea()
    Local oBrowse
    //Cria um browse para a ZA3
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("ZA3")
    oBrowse:SetDescription(cTitulo)
    // oBrowse:SetFieldDefault("@"+cFiltroEnt)
    oBrowse:Activate()
      
    RestArea(aArea)
Return Nil
 
Static Function MenuDef()
    Local aRot := {}
      
    //Adicionando op��es
    ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.ZMOD2' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.ZMOD2' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.ZMOD2' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.ZMOD2' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
Return aRot
 
Static Function ModelDef()
    //Na montagem da estrutura do Modelo de dados, o cabe�alho filtrar� e exibir� somente 2 campos, j� a grid ir� carregar a estrutura inteira conforme fun��o fModStruct
    Local oModel       := NIL
    Local oStruCab     := FWFormStruct(1, 'ZA3', {|cCampo| AllTRim(cCampo) $ "ZA3_CODVEN;ZA3_NOME;"})
    Local oStruGrid    := fModStruct()
 
    //Monta o modelo de dados, e na P�s Valida��o, informa a fun��o fValidGrid
    oModel := MPFormModel():New('ZMOD2M', /*bPreValidacao*/, {|oModel| fValidGrid(oModel)}, /*bCommit*/, /*bCancel*/ )
 
    //Agora, define no modelo de dados, que ter� um Cabe�alho e uma Grid apontando para estruturas acima
    oModel:AddFields('MdFieldZA3', NIL, oStruCab)
    oModel:AddGrid('MdGridZA3', 'MdFieldZA3', oStruGrid, , )
 
    //Monta o relacionamento entre Grid e Cabe�alho, as express�es da Esquerda representam o campo da Grid e da direita do Cabe�alho
    oModel:SetRelation('MdGridZA3', {;
            {'ZA3_FILIAL', 'xFilial("ZA3")'},;
            {"ZA3_CODVEN",  "ZA3_CODVEN"},;
            {"ZA3_NOME",  "ZA3_NOME"};
        }, ZA3->(IndexKey(1)))
     
    //Definindo outras informa��es do Modelo e da Grid
    oModel:GetModel("MdGridZA3"):SetMaxLine(9999)
    oModel:SetDescription("Atualiza��o de Comiss�o")
    oModel:SetPrimaryKey({"ZA3_FILIAL", "ZA3_CODVEN"})
 
Return oModel
 
Static Function ViewDef()
    //Na montagem da estrutura da visualiza��o de dados, vamos chamar o modelo criado anteriormente, no cabe�alho vamos mostrar somente 2 campos, e na grid vamos carregar conforme a fun��o fViewStruct
    Local oView        := NIL
    Local oModel    := FWLoadModel('ZMOD2')
    Local oStruCab  := FWFormStruct(2, "ZA3", {|cCampo| AllTRim(cCampo) $ "ZA3_CODVEN;ZA3_NOME;"})
    Local oStruGRID := fViewStruct()
 
    //Define que no cabe�alho n�o ter� separa��o de abas (SXA)
    oStruCab:SetNoFolder()
 
    //Cria o View
    oView:= FWFormView():New() 
    oView:SetModel(oModel)              
 
    //Cria uma �rea de Field vinculando a estrutura do cabe�alho com MDFieldZAF, e uma Grid vinculando com MdGridZAF
    oView:AddField('VIEW_ZA3', oStruCab, 'MdFieldZA3')
    oView:AddGrid('GRID_ZA3', oStruGRID, 'MdGridZA3')
 
    //O cabe�alho (MAIN) ter� 25% de tamanho, e o restante de 75% ir� para a GRID
    oView:CreateHorizontalBox("MAIN", 25)
    oView:CreateHorizontalBox("GRID", 75)
 
    //Vincula o MAIN com a VIEW_ZA3 e a GRID com a GRID_ZA3
    oView:SetOwnerView('VIEW_ZA3', 'MAIN')
    oView:SetOwnerView('GRID_ZA3', 'GRID')
    oView:EnableControlBar(.T.)
 
    //Define o campo incremental da grid como o ZA3_ITEM
    // oView:AddIncrementField('GRID_ZA3', 'ZA3_ITEM')
Return oView
 
//Fun��o chamada para montar o modelo de dados da Grid
Static Function fModStruct()
    Local oStruct
    oStruct := FWFormStruct(1, 'ZA3')
Return oStruct
 
//Fun��o chamada para montar a visualiza��o de dados da Grid
Static Function fViewStruct()
    Local cCampoCom := "ZA3_CODVEN;ZA3_NOME;"
    Local oStruct
 
    //Ir� filtrar, e trazer todos os campos, menos os que tiverem na vari�vel cCampoCom
    oStruct := FWFormStruct(2, "ZA3", {|cCampo| !(Alltrim(cCampo) $ cCampoCom)})
Return oStruct
 
//Fun��o que faz a valida��o da grid
Static Function fValidGrid(oModel)
    Local lRet     := .T.
    Local nDeletados := 0
    Local nLinAtual := 0
    Local oModelGRID := oModel:GetModel('MdGridZA3')
    Local oModelMain := oModel:GetModel('MdFieldZA3')
    Local nValorMain := oModelMain:GetValue("ZA3_CODVEN")
    Local nValorGrid := 0
    Local cPictVlr   := PesqPict('ZA3', 'ZA3_CODVEN')
 
    //Percorrendo todos os itens da grid
    For nLinAtual := 1 To oModelGRID:Length() 
        //Posiciona na linha
        oModelGRID:GoLine(nLinAtual) 
         
        //Se a linha for excluida, incrementa a vari�vel de deletados, sen�o ir� incrementar o valor digitado em um campo na grid
        If oModelGRID:IsDeleted()
            nDeletados++
        Else
            nValorGrid += NoRound(oModelGRID:GetValue("ZA3_DESC"), 4)
        EndIf
    Next nLinAtual
 
    //Se o tamanho da Grid for igual ao n�mero de itens deletados, acusa uma falha
    If oModelGRID:Length()==nDeletados
        lRet :=.F.
        Help( , , 'Dados Inv�lidos' , , 'A grid precisa ter pelo menos 1 linha sem ser excluida!', 1, 0, , , , , , {"Inclua uma linha v�lida!"})
    EndIf
 
    // Valida��o do Exemplo, n�o se encaixa no meu caso por�m deixo ai como exemplo de como fazer uma valida��o! - Felipe
    // If lRet
    //     //Se o valor digitado no cabe�alho (valor da NF), n�o bater com o valor de todos os abastecimentos digitados (valor dos itens da Grid), ir� mostrar uma mensagem alertando, por�m ir� permitir salvar (do contr�rio, seria necess�rio alterar lRet para falso)
    //     If nValorMain != nValorGrid
    //         //lRet := .F.
    //         MsgAlert("O valor do cabe�alho (" + Alltrim(Transform(nValorMain, cPictVlr)) + ") tem que ser igual o valor dos itens (" + Alltrim(Transform(nValorGrid, cPictVlr)) + ")!", "Aten��o")
    //     EndIf
    // EndIf
 
Return lRet
