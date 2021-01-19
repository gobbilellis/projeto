#INCLUDE 'protheus.ch'
#INCLUDE 'FWMVCDef.ch'


Static cTitulo := "Cadastro de Comissão"

user function CAP01

    Local aArea := GetArea()
    Local oBrowse
    Local cFunBkp := FunName()

    SetFunName ("CAP01")
    
    oBrowse := FWMBrowse():New()

    oBrowse:SetAlias("SA3")

    oBrowse:SetDescription(cTitulo)

    oBrowse:Activate()


    SetFunName(cFunBkp)
    RestArea(aArea)
return

Static Function MenuDef()
    Local aRot := {}

        ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.CAP01' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //Operação 1
        ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.CAP01' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //Operação 3
        ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.CAP01' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //Operação 4
        ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.CAP01' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //Operação 5
        
return aRot

Static Function ModelDef()
    Local oModel := Nil

    Local oStSA3 := FWFormStruct(1,"SA3")

    oModel := MPFormModel():New()

    oModel:AddFields("FORMSA3",,oStSA3)

    oModel:SetPrimaryKey({'A3_FILIAL','A3_COD'})

    oModel:SetDescription("Modelo de Dados de "+cTitulo)

    oModel:GetModel("FORMSA3"):SetDescription("Formulário de "+cTitulo)

return oModel

Static Function ViewDef()

    Local oModel: FWLoadModel("CAP01")

    Local oStSA3 := FWFormStruct(2,"SA3")

    Local oView := Nil

    oView := FWFormView():New()
    oView:SetModel(oModel)

    oView:AddField("VIEW_SA3", oStSA3, "FROMSA3")

    oView:CreateHorizontalBox("TELA",100)

    oView:EnableTitleView('VIEW_SA3', 'Dados dos Vendedores')

    oView:SetCloseOnOk({||.T.})

    oView:SetOwnerView("VIEW_SA3","TELA")

Return oView
