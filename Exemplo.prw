#include "protheus.ch"
#INCLUDE 'TBICONN.CH'



User Function M460FIM
cPara := 'Diretor@empresa.com.br' // Informe aqui o e-mail para quem receberá essa informação
cAssunto := 'Inclusão de Nota'
cMensagem := 'Dados da nota:'+'Serie: '+Alltrim(SF2->F2_SERIE)+' - '+'Nota: '+Alltrim(SF2->F2_DOC)
cAnexo    := ''//Exemplo de como preencher:   '\temp\DadosDeposito.txt'
u_sendMail(cPara, cAssunto, cMensagem, cAnexo)
Return .T.



User Function M521DNFS
cPara := 'Diretor@empresa.com.br' // Informe aqui o e-mail para quem receberá essa informação
cAssunto := 'Exclusão de Nota'
cMensagem := 'Dados da nota:'+'Serie: '+Alltrim(SF2->F2_SERIE)+' - '+'Nota: '+Alltrim(SF2->F2_DOC)
cAnexo    := ''
u_sendMail(cPara, cAssunto, cMensagem, cAnexo)
Return .T.


User Function FA070CA4
cPara := 'Diretor@empresa.com.br' // Informe aqui o e-mail para quem receberá essa informação
cAssunto := 'Exclusão de Pagamento'
cMensagem := 'Dados do pagameto:'+'Prefixo: '+Alltrim(SE1->E1_PREFIXO)+' - '+'Titulo: '+Alltrim(SE1->E1_NUM)
cAnexo    := ''
u_sendMail(cPara, cAssunto, cMensagem, cAnexo)
Return .T.



User Function SendMail(cPara, cAssunto, cMensagem, cAnexo)
local oServer  := Nil
local oMessage := Nil
local nErr     := 0
local cPopAddr  := "pop.gmail.com"      // Endereco do servidor POP3
local cSMTPAddr := "smtp.gmail.com"     // Endereco do servidor SMTP
local cPOPPort  := 110                    // Porta do servidor POP
local cSMTPPort := 465                    // Porta do servidor SMTP
local cUser     := "testeuserfunction@gmail.com"     // Usuario que ira realizar a autenticacao
local cPass     := "Teste123"             // Senha do usuario
local nSMTPTime := 60                     // Timeout SMTP
Default cPara		:= ''
Default cAssunto	:= ''
Default cMensagem	:= ''
Default cAnexo		:= '' // O caminho desse arquivo tem que estar dentro de qualquer pasta do ROOTPATH (Normalmente Protheus_Data)
//PREPARE ENVIRONMENT EMPRESA '99' FILIAL '01' TABLES ''

If Empty(cPara)
	conout("[ERROR]Email destino não definido.")
	return .F.
EndIf
// Instancia um novo TMailManager
oServer := tMailManager():New()
// Usa SSL na conexao
oServer:setUseSSL(.T.)
// Inicializao
oServer:init(cPopAddr, cSMTPAddr, cUser, cPass, cPOPPort, cSMTPPort)
// Define o Timeout SMTP
if oServer:SetSMTPTimeout(nSMTPTime) != 0
	conout("[ERROR]Falha ao definir timeout")
	return .F.
endif
// Conecta ao servidor
nErr := oServer:smtpConnect()
if nErr <> 0
	conOut("[ERROR]Falha ao conectar: " + oServer:getErrorString(nErr))
	oServer:smtpDisconnect()
	return .F.
endif

// Realiza autenticacao no servidor
nErr := oServer:smtpAuth(cUser, cPass)
if nErr <> 0
	conOut("[ERROR]Falha ao autenticar: " + oServer:getErrorString(nErr))
	oServer:smtpDisconnect()
	return .F.
endif

// Cria uma nova mensagem (TMailMessage)
oMessage := tMailMessage():new()
oMessage:clear()
oMessage:cFrom    := "User Function"
oMessage:cTo      := cPara
oMessage:cCC      := ''
oMessage:cBCC     := ''
oMessage:cSubject := cAssunto
oMessage:cBody    := cMensagem
If !Empty(cAnexo)
	xRet := oMessage:AttachFile( cAnexo )
	if xRet < 0
		cMsg := "Could not attach file " + cAnexo
		conout( cMsg )
		return
	endif
EndIf
// Envia a mensagem
nErr := oMessage:send(oServer)
if nErr <> 0
	conout("[ERROR]Falha ao enviar: " + oServer:getErrorString(nErr))
	oServer:smtpDisconnect()
	return .F.
endif
// Disconecta do Servidor
oServer:smtpDisconnect()
return .T.
