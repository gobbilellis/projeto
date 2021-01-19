#INCLUDE 'protheus.ch'
#INCLUDE 'FWMVCDef.ch'


Static cTitulo := "Cadastro de Comissão"

user function CAP01

    Local aArea := GetArea()
    Local oBrowse
    Local cFunBkp := FunName()

    oBrowse: FWMBrowse():New()
    oBrowse: SetAlias("ZA3")
    oBrowse:SetDescription(cTitulo)
    oBrowse:Activate()


    SetFunName(cFunBkp)
    RestArea(aArea)
return Nil

Static Function MenuDef()
    Local aRot := {}

        ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.CAP01' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //Operação 1
        ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.CAP01' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //Operação 3
        ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.CAP01' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //Operação 4
        ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.CAP01' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //Operação 5
        
return aRot

Static Function ModelDef()
    Local oModel := Nil
    Local oStTmp := FWFormModel Struct():New()
    Local oStFilho := FWFormStruct(1,'ZA3')
    Local

    //Adicionar tabela na estrutura temp.
    oStTmp:AddTable('ZA3',{'ZA3_COD','ZA3_NOME'},"Cabecalho ZA3")

    //Adiciona o campo desconto
    oStTmp:AddField(;
        "Desconto",;
        "Desconto",;
        "ZA3_DESC",;
        "N",;
        TamSX3("ZA3_DESC")[1],;
        2,;
        Nil,;
        Nil,;
        {},;
        .F.,;
        FWBuildFeature(STRUCT_FEATURE_INIPAD,"Iif(!INCLUI,ZA3->ZA3_FILIAL,FWxFilial('ZA3'))"),;
        .T.,;
        .F.,;
        .F.)
