do {
    cls
    Write-Host ".+======================================================+." -ForegroundColor Cyan
    Write-Host "           MONITORIZAÇÃO DE SEGURANÇA E ANÁLISE           " -ForegroundColor Yellow
    Write-Host ".+======================================================+." -ForegroundColor Cyan
    Write-Host "   1. Verificar Tentativas de Login Falhadas              "
    Write-Host "   2. Ver Logs de Segurança mais Recentes                 "
    Write-Host "   3. Ver Logs de Segurança mais Recentes (Detalhado)     "
    Write-Host "   4. Monitoramento de Ports abertas (Real-Time)          "
    Write-Host "    Q. Voltar ao menu                                     " -ForegroundColor Red
    Write-Host ".+======================================================+." -ForegroundColor Cyan
    $escolha = Read-Host " --> "
    
    switch ($escolha) {
        "1"{
            # ----- Tentativas de Login ----- #
            #
            # Esta linha filtra os "Event Logs" do Windows á procura de tentativas de login falhadas.
            # O comando -FilterHashtable pega nos parâmetros dados pela hashtable á sua frente (@{...}) e apresenta apenas os logs com o LogName "Security", e o ID universal no Windows de um evento de login falhado.
            # Ainda nos filtros iniciais, o "-MaxEvents 5" mostra só os ultimos 5 eventos, e por fim o "-ErrorAction Stop", que caso não haja registo de falhas de login é apanhado pelo catch e avisa o user.
            #
            # No caso de haver logs, é mostrada uma tabela ao user.
            # Para mostrar essa tabela mostramos a hora do evento e a mensagem dada pelo sistema com o "Select-Object TimeCreated, Message", e em seguida formatamos a tabela com "Format-Table -Wrap".
            # É necessário formatar a tabela com -Wrap pois a mensagem de erro pode ser bastante longa. Assim leva "line break" e mostra tudo (debugging dá jeito).
            #
            # yap yap yap
            #
            cls
            Write-Host "Últimas 10 Tentativas de Login:" -ForegroundColor Yellow
            try {Get-WinEvent -FilterHashtable @{LogName='Security'; Id=4625} -MaxEvents 5 -ErrorAction Stop | Select-Object TimeCreated, Message | Format-Table -Wrap}
            catch { Write-Host "! Sem falhas! (O script foi aberto como Admin?)" -ForegroundColor Red }
        
            Write-Host "`nPressione ENTER para continuar... " -ForegroundColor Yellow -NoNewline
            do {$tecla=[System.Console]::ReadKey($true)} until ($tecla.Key -eq [System.ConsoleKey]::Enter)
        }


        "2"{
            # ----- Logs de segurança ----- #
            #
            # Esta linha é bastante semelhante á da opção anterior, mas abrange todas as logs com o LogName "Security".
            # Para não encher o ecrã, esta versão mostra apenas o "Header" do parâmetro "Message".
            # Como o PowerShell não tem um argumento para isto, esta modificação é feita á pata com uma Calculated Property.
            # Esta Calculated Property inclui uma expressão que divide o texto cada vez que vê um "line break".
            # Como só precisamos da primeira linha, descartamos o resto ao mostrar apenas a primeira linha com "[0]".
            #
            cls
            Write-Host "Últimos 20 Logs de Segurança:" -ForegroundColor Yellow
            try{
                Get-WinEvent -LogName Security -MaxEvents 20 -ErrorAction Stop | Select-Object TimeCreated, @{
                    Name = "Mensagem"
                    Expression = { ($_.Message -split "`n")[0] }
                } | Format-Table -Wrap # O wrap ainda é usado no caso da primeira linha ser muito longa
            }
            catch {Write-Host "! Sem logs! (O script foi aberto como Admin?)" -ForegroundColor Red}

            Write-Host "`nPressione ENTER para continuar... " -ForegroundColor Yellow -NoNewline
            do {$tecla=[System.Console]::ReadKey($true)} until ($tecla.Key -eq [System.ConsoleKey]::Enter)
        
        
        }


        "3"{
            # Versão detalhada da opção acima
            cls
            Write-Host "Últimos 20 Logs de Segurança (Detalhado):" -ForegroundColor Yellow
            try {Get-WinEvent -LogName Security -MaxEvents 20 -ErrorAction Stop | Select-Object TimeCreated, Message | Format-Table -Wrap}
            catch {Write-Host "! Sem logs! (O script foi aberto como Admin?)" -ForegroundColor Red}

            Write-Host "`nPressione ENTER para continuar... " -ForegroundColor Yellow -NoNewline
            do {$tecla=[System.Console]::ReadKey($true)} until ($tecla.Key -eq [System.ConsoleKey]::Enter)
        }


        "4"{
            do{
                $key=$null # Limpa a variável para não parar automaticamente após o primeiro run
                cls
                Write-Host "! Pressione 'Q' para sair" -ForegroundColor Red
                Write-Host "Monitoramento de Ports abertas (Real-Time):`n" -ForegroundColor Yellow
                #
                # Esta linha usa a ferramenta "netstat" para mostrar estatisticas de uso de rede.
                # Para mostrar apenas as portas abertas, usamos os seguintes parâmetros: 
                # • -a (Mostra todas as conexões ativas e as suas portas TCP/UDP)
                # • -n (Normalmente o "netstat" mostra hostnames de DNS envés dos IPs. Este parâmetro previne isso)
                # • -o (Mostra o Process ID do programe que abriu a porta)
                # Por fim usamos o "Select-String" para mostrar só as linhas com "LISTENING" (Porta aberta por um processo á espera de resposta) e "ESTABLISHED" (Conexão establecida e ativa pela Porta).
                #
                netstat -ano | Select-String "LISTENING", "EsTABLISHED"
                Start-Sleep -Milliseconds 600

                # Esta linha intercepta os inputs da consola e verifica se alguma tecla foi pressionada. Se não, o KeyAvailable devolve $false.
                if ([System.Console]::KeyAvailable) {
                    $key = [System.Console]::ReadKey($true) # Se a linha anterior devolver "$true" (tecla pressionada), a variável "$key" capta e guarda a tecla pressionada.
                                                            # No final temos o comando "Readkey()" que devido á forma como o .NET Framework funciona,
                                                            # se tiver o argumento "$true", intercepta a tecla recebida e não envia o texto para a consola.
                }


            } while ($key.Key -ne "Q")

            Write-Host "`nPressione ENTER para continuar... " -ForegroundColor Yellow -NoNewline
            do {$tecla=[System.Console]::ReadKey($true)} until ($tecla.Key -eq [System.ConsoleKey]::Enter)
        }
        

        {$_ -in "q", "quit"} {Return}
        default {Write-Host "! Opção inválida, escolhe entre |1-4 ou Q (quit)|" -ForegroundColor Red; Start-Sleep -Milliseconds 1200}

    }
} while ($true)