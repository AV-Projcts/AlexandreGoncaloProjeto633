do{
    cls
    Write-Host ".+=============================================+." -ForegroundColor Cyan
    Write-Host "         GESTÃO E MONITORIZAÇÃO DE REDES         " -ForegroundColor Yellow
    Write-Host ".+=============================================+." -ForegroundColor Cyan
    Write-Host "   1. Monitorização de Interfaces (Real-Time)    "
    Write-Host "   2. Teste de Conectividade (Ping / Portas)     "
    Write-Host "    Q. Voltar ao menu                            " -ForegroundColor Red
    Write-Host ".+=============================================+." -ForegroundColor Cyan
    $escolha = Read-Host " --> "
    
    switch ($escolha) {
        
        "1"{
            cls
            $key=$null
            do{
                cls
                Write-Host "Monitorização de Tráfego de Rede:`n" -ForegroundColor Yellow
                Write-Host "! Pressione 'Q' para sair" -ForegroundColor Red
                
                # Recolhe estatísticas das placas de rede e converte os bytes em Megabytes para facilitar a leitura.
                Get-NetAdapterStatistics | Select-Object Name, 
                    @{Name="Recebido (MB)"; Expression={[math]::Round($_.ReceivedBytes / 1MB, 2)}}, 
                    @{Name="Enviado (MB)"; Expression={[math]::Round($_.SentBytes / 1MB, 2)}} | Format-Table -AutoSize
                
                Start-Sleep -Milliseconds 600
                if ([System.Console]::KeyAvailable) {$key = [System.Console]::ReadKey($true)}

            } while ($key.Key -ne "Q")

            Write-Host "`nPressione ENTER para continuar... " -ForegroundColor Yellow -NoNewline
            do {$tecla=[System.Console]::ReadKey($true)} until ($tecla.Key -eq [System.ConsoleKey]::Enter)
        }

        "2"{
            # Este código buga a consola toda depois do output, precisa de CTRL+C (Valve, pls fix)
            cls
            Write-Host "Teste de Conectividade entre Sistemas:`n" -ForegroundColor Yellow
            $destino = Read-Host "Digite o IP ou Hostname alvo (ex: 8.8.8.8 ou srv-bd-01)"
            $porta = Read-Host "Digite a porta para testar (Deixe em branco para Ping normal)"

            Write-Host "`nTestando a conectividade com $destino... Aguarde." -ForegroundColor Cyan
            
            try{
                # Se o user não der input de uma porta, faz apenas o ping. Se der uma porta, testa com a porta específica.
                if ([string]::IsNullOrWhiteSpace($porta)) {$resultado = Test-NetConnection -ComputerName $destino -InformationLevel Detailed -WarningAction SilentlyContinue}
                else {$resultado = Test-NetConnection -ComputerName $destino -Port $porta -InformationLevel Detailed -WarningAction SilentlyContinue}

                cls
                Write-Host "Resultados do Teste de Conectividade:`n" -ForegroundColor Yellow
                $resultado | Format-List

                if ($resultado.PingSucceeded -or $resultado.TcpTestSucceeded) {
                    Write-Host "! Conectividade estabelecida com sucesso!" -ForegroundColor Green
                    Add-Content ".\NetworkManager.log" -Value "$(Get-Date -Format 'dd-MM-yyyy HH:mm:ss') - INFO: Teste conectividade para '$destino' bem sucedido."
                }
                else {
                    Write-Host "! Falha na conectividade com o destino '$destino'." -ForegroundColor Red
                    Add-Content ".\NetworkManager.log" -Value "$(Get-Date -Format 'dd-MM-yyyy HH:mm:ss') - ERRO: Teste conectividade para '$destino' falhou."
                }
            }
            catch {Write-Host "! Erro ao executar o teste: $($_.Exception.Message)" -ForegroundColor Red}

            Write-Host "`nPressione ENTER para continuar... " -ForegroundColor Yellow -NoNewline
            do {$tecla=[System.Console]::ReadKey($true)} until ($tecla.Key -eq [System.ConsoleKey]::Enter)
        }

        {$_ -in "q", "quit"} {Return}
        default {Write-Host "! Opção inválida, escolhe entre |1-2 ou Q (quit)|" -ForegroundColor Red; Start-Sleep -Milliseconds 1200}

    }
} while($true)