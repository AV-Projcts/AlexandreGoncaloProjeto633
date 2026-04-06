# Server & Services

# Variável lista com todos os serviços a analizar (Preguiça Simulator 2026)
$servicosAlvo = @("LanmanServer", "Spooler", "Netlogon", "ProfSvc", "TermService", "Dhcp", "Dnscache")

do{
    cls
    Write-Host ".+=============================================+." -ForegroundColor Cyan
    Write-Host "          Gestão do Servidor E Serviços          " -ForegroundColor Yellow
    Write-Host ".+=============================================+." -ForegroundColor Cyan
    Write-Host "   1. Verificar Serviços Ativos                  "
    Write-Host "   2. Monitorização de Disponibilidade (Live)    "
    Write-Host "   3. Reiniciar um Serviço                       "
    Write-Host "   4. Configurar Reinício Automático (Falha)     "
    Write-Host "   5. Ver Logs de Falhas de Serviços             "
    Write-Host "    Q. Voltar ao menu                            " -ForegroundColor Red
    Write-Host ".+=============================================+." -ForegroundColor Cyan
    $escolha = Read-Host " --> "
    
    switch ($escolha) {
        
        "1"{
            cls
            Write-Host "Verificação de Serviços Ativos:`n" -ForegroundColor Yellow

            # Esta linha pega na lista de serviços ($servicosAlvo), recebe o estado dos mesmos e mostra numa tabela formatada.
            Get-Service -Name $servicosAlvo -ErrorAction SilentlyContinue | Select-Object Status, Name, DisplayName | Format-Table -AutoSize

            Write-Host "`nPressione ENTER para continuar... " -ForegroundColor Yellow -NoNewline
            do {$tecla=[System.Console]::ReadKey($true)} until ($tecla.Key -eq [System.ConsoleKey]::Enter)
        }

        "2"{
            cls
            do{
                # Mesma coisa que acima mas real-time
                cls
                Write-Host "Monitorização de Disponibilidade:`n" -ForegroundColor Yellow
                Write-Host "! Pressione 'Q' para sair" -ForegroundColor Red
                
                Get-Service -Name $servicosAlvo -ErrorAction SilentlyContinue | Select-Object Status, Name, DisplayName | Format-Table -AutoSize
                
                Start-Sleep -Milliseconds 600
                if ([System.Console]::KeyAvailable) {$key = [System.Console]::ReadKey($true)}
                
            } while ($key.Key -ne "Q")

            Write-Host "`nPressione ENTER para continuar... " -ForegroundColor Yellow -NoNewline
            do {$tecla=[System.Console]::ReadKey($true)} until ($tecla.Key -eq [System.ConsoleKey]::Enter)
        }

        "3"{
            cls
            Write-Host "Reiniciar Serviço:`n" -ForegroundColor Yellow
            Get-Service -Name $servicosAlvo -ErrorAction SilentlyContinue | Select-Object Status, Name, DisplayName | Format-Table -AutoSize
            $servicoRestart = Read-Host "Digite o nome do serviço a reiniciar (ex: Spooler)"
            try{
                Restart-Service -Name $servicoRestart -Force -ErrorAction Stop | Out-Null
                Write-Host "! Serviço '$servicoRestart' reiniciado com sucesso!" -ForegroundColor Green
                Add-Content ".\ServiceManager.log" -Value "$(Get-Date -Format 'dd-MM-yyyy HH:mm:ss') - INFO: Serviço '$servicoRestart' reiniciado manualmente."
            }
            catch {Write-Host "! Erro, não foi possível reiniciar o serviço!`nMotivo: $($_.Exception.Message)" -ForegroundColor Red}

            Write-Host "`nPressione ENTER para continuar... " -ForegroundColor Yellow -NoNewline
            do {$tecla=[System.Console]::ReadKey($true)} until ($tecla.Key -eq [System.ConsoleKey]::Enter)
        }

        "4"{
            cls
            Write-Host "Configurar Reinício Automático (Recuperação):`n" -ForegroundColor Yellow
            Write-Host "! Configura o serviço para tentar reiniciar sozinho 3 vezes se for abaixo.`n" -ForegroundColor Blue
            
            $servicoAuto = Read-Host "Digite o nome do serviço"
            try{
                # Nesta linha o sc.exe tenta reiniciar o programa 3 vezes (com delay timers entre cada restart) se detetar que o serviço foi abaixo.
                sc.exe failure $servicoAuto reset= 86400 actions= restart/60000/restart/60000/restart/60000 | Out-Null
                Write-Host "! Reinício automático ativado para '$servicoAuto'!" -ForegroundColor Green
                Add-Content ".\ServiceManager.log" -Value "$(Get-Date -Format 'dd-MM-yyyy HH:mm:ss') - INFO: Auto-restart configurado para o serviço '$servicoAuto'."
            }
            catch {Write-Host "! Erro ao configurar serviço!`nMotivo: $($_.Exception.Message)" -ForegroundColor Red}

            Write-Host "`nPressione ENTER para continuar... " -ForegroundColor Yellow -NoNewline
            do {$tecla=[System.Console]::ReadKey($true)} until ($tecla.Key -eq [System.ConsoleKey]::Enter)
        }

        "5"{
            cls
            Write-Host "Logs de Falhas de Serviços (Últimos 10 Eventos):`n" -ForegroundColor Yellow
            try {
                # Filtra especificamente á procura de crashes no Service Control Manager
                $falhas = Get-WinEvent -FilterHashtable @{LogName='System'; ProviderName='Service Control Manager'; Id=7031,7032,7034} -MaxEvents 10 -ErrorAction Stop
                
                # Esta linha mostra a hora do log e a razão, resumida ao header para não encher a consola.
                $falhas | Select-Object TimeCreated, Id, @{Name="Falha (Resumo)"; Expression={($_.Message -split "`n")[0]}} | Format-Table -AutoSize
            } 
            catch {Write-Host "! Nenhum log de falha recente encontrado no sistema!" -ForegroundColor Green}

            Write-Host "`nPressione ENTER para continuar... " -ForegroundColor Yellow -NoNewline
            do {$tecla=[System.Console]::ReadKey($true)} until ($tecla.Key -eq [System.ConsoleKey]::Enter)
        }

        {$_ -in "q", "quit"} {Return}
        default {Write-Host "! Opção inválida, escolhe entre |1-5 ou Q (quit)|" -ForegroundColor Red; Start-Sleep -Milliseconds 1200}

    }
} while($true)