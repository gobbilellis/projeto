//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
  
//Variáveis Estáticas
Static cTitulo := "Cadastro de faixa de comissão"
  
/*/{Protheus.doc} ZMOD2
Função para cadastros de Comissão
@author 
@since 
@version 1.0
    @return Nil, Função não tem retorno
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
      
    //Adicionando opções
    ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.ZMOD2' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.ZMOD2' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.ZMOD2' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.ZMOD2' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
Return aRot
 
Static Function ModelDef()
    //Na montagem da estrutura do Modelo de dados, o cabeçalho filtrará e exibirá somente 2 campos, já a grid irá carregar a estrutura inteira conforme função fModStruct
    Local oModel       := NIL
    Local oStruCab     := FWFormStruct(1, 'ZA3', {|cCampo| AllTRim(cCampo) $ "ZA3_CODVEN;ZA3_NOME;"})
    Local oStruGrid    := fModStruct()
 

    oStruCab:SetProperty('ZA3_CODVEN',MODEL_FIELD_OBRIGAT,.T.)
    
    //Monta o modelo de dados, e na Pós Validação, informa a função fValidGrid
    oModel := MPFormModel():New('ZMOD2M', /*bPreValidacao*/, {|oModel| fValidGrid(oModel)}, /*bCommit*/, /*bCancel*/ )
 
    //Agora, define no modelo de dados, que terá um Cabeçalho e uma Grid apontando para estruturas acima
    oModel:AddFields('MdFieldZA3', NIL, oStruCab)
    oModel:AddGrid('MdGridZA3', 'MdFieldZA3', oStruGrid, , )
 
    //Monta o relacionamento entre Grid e Cabeçalho, as expressões da Esquerda representam o campo da Grid e da direita do Cabeçalho
    oModel:SetRelation('MdGridZA3', {;
            {'ZA3_FILIAL', 'xFilial("ZA3")'},;
            {"ZA3_CODVEN",  "ZA3_CODVEN"},;
            {"ZA3_NOME",  "ZA3_NOME"};
        }, ZA3->(IndexKey(1)))
     
    //Definindo outras informações do Modelo e da Grid
    oModel:GetModel("MdGridZA3"):SetMaxLine(9999)
    oModel:SetDescription("Atualização de Comissão")
    oModel:SetPrimaryKey({"ZA3_FILIAL", "ZA3_CODVEN"})
 
Return oModel
 
Static Function ViewDef()
    //Na montagem da estrutura da visualização de dados, vamos chamar o modelo criado anteriormente, no cabeçalho vamos mostrar somente 2 campos, e na grid vamos carregar conforme a função fViewStruct
    Local oView        := NIL
    Local oModel    := FWLoadModel('ZMOD2')
    Local oStruCab  := FWFormStruct(2, "ZA3", {|cCampo| AllTRim(cCampo) $ "ZA3_CODVEN;ZA3_NOME;"})
    Local oStruGRID := fViewStruct()
 
    //Define que no cabeçalho não terá separação de abas (SXA)
    oStruCab:SetNoFolder()
 
    //Cria o View
    oView:= FWFormView():New() 
    oView:SetModel(oModel)              
 
    //Cria uma área de Field vinculando a estrutura do cabeçalho com MDFieldZAF, e uma Grid vinculando com MdGridZAF
    oView:AddField('VIEW_ZA3', oStruCab, 'MdFieldZA3')
    oView:AddGrid('GRID_ZA3', oStruGRID, 'MdGridZA3')
 
    //O cabeçalho (MAIN) terá 25% de tamanho, e o restante de 75% irá para a GRID
    oView:CreateHorizontalBox("MAIN", 25)
    oView:CreateHorizontalBox("GRID", 75)
 
    //Vincula o MAIN com a VIEW_ZA3 e a GRID com a GRID_ZA3
    oView:SetOwnerView('VIEW_ZA3', 'MAIN')
    oView:SetOwnerView('GRID_ZA3', 'GRID')
    oView:EnableControlBar(.T.)
 
    //Define o campo incremental da grid como o ZA3_ITEM
    // oView:AddIncrementField('GRID_ZA3', 'ZA3_ITEM')
Return oView
 
//Função chamada para montar o modelo de dados da Grid
Static Function fModStruct()
    Local oStruct
    oStruct := FWFormStruct(1, 'ZA3')
Return oStruct
 
//Função chamada para montar a visualização de dados da Grid
Static Function fViewStruct()
    Local cCampoCom := "ZA3_CODVEN;ZA3_NOME;"
    Local oStruct
 
    //Irá filtrar, e trazer todos os campos, menos os que tiverem na variável cCampoCom
    oStruct := FWFormStruct(2, "ZA3", {|cCampo| !(Alltrim(cCampo) $ cCampoCom)})
Return oStruct
 
//Função que faz a validação da grid
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
         
        //Se a linha for excluida, incrementa a variável de deletados, senão irá incrementar o valor digitado em um campo na grid
        If oModelGRID:IsDeleted()
            nDeletados++
        Else
            nValorGrid += NoRound(oModelGRID:GetValue("ZA3_DESC"), 4)
        EndIf
    Next nLinAtual
 
    //Se o tamanho da Grid for igual ao número de itens deletados, acusa uma falha
    If oModelGRID:Length()==nDeletados
        lRet :=.F.
        Help( , , 'Dados Inválidos' , , 'A grid precisa ter pelo menos 1 linha sem ser excluida!', 1, 0, , , , , , {"Inclua uma linha válida!"})
    EndIf
 
    // Validação do Exemplo, não se encaixa no meu caso porém deixo ai como exemplo de como fazer uma validação! - Felipe
    // If lRet
    //     //Se o valor digitado no cabeçalho (valor da NF), não bater com o valor de todos os abastecimentos digitados (valor dos itens da Grid), irá mostrar uma mensagem alertando, porém irá permitir salvar (do contrário, seria necessário alterar lRet para falso)
    //     If nValorMain != nValorGrid
    //         //lRet := .F.
    //         MsgAlert("O valor do cabeçalho (" + Alltrim(Transform(nValorMain, cPictVlr)) + ") tem que ser igual o valor dos itens (" + Alltrim(Transform(nValorGrid, cPictVlr)) + ")!", "Atenção")
    //     EndIf
    // EndIf
 
Return lRet
