do{
    cls
    Write-Host ".+==============================================+." -ForegroundColor Cyan
    Write-Host "          PLANOS DE BACKUP E RECUPERAÇÃO          " -ForegroundColor Yellow
    Write-Host ".+==============================================+." -ForegroundColor Cyan
    Write-Host "   1. Criar Backup Manual (ZIP)                   "
    Write-Host "   2. Agendar Backup Automático (ZIP Diário)      "
    Write-Host "   3. Verificar Ficheiro de Backup                "
    Write-Host "   4. Restaurar Dados (Extrair ZIP)               "
    Write-Host "    Q. Voltar ao menu                             " -ForegroundColor Red
    Write-Host ".+==============================================+." -ForegroundColor Cyan
    $escolha = Read-Host " --> "
    
    switch ($escolha) {
        
        "1"{
            cls
            Write-Host "Criar Backup Manual (Formato ZIP):`n" -ForegroundColor Yellow
            $origem = Read-Host "Digite a pasta de origem (ex: C:\Dados)"
            $destino = Read-Host "Digite a pasta de destino onde o ZIP será guardado (ex: C:\Backups)"
            
            if (-not (Test-Path $origem)) {Write-Host "! A pasta de origem não existe!" -ForegroundColor Red}
            else {
                Write-Host "`nModos de Backup:" -ForegroundColor Cyan
                Write-Host "1 - Completo (Cria um ZIP novo com a data atual)"
                Write-Host "2 - Atualização/Incremental (Atualiza um Ficheiro ZIP existente com ficheiros novos/alterados)"
                $tipo = Read-Host "`nEscolha o modo (1 ou 2)"

                try{
                    Write-Host "`nA comprimir ficheiros... (pode demorar uma beca).`n" -ForegroundColor Yellow
                    
                    if ($tipo -eq "1") {
                        # Backup completo (Cria um ficheiro novo com a data e hora no nome).
                        $data = Get-Date -Format "ddMMyyyy_HHmmss"
                        $nomeZip = "Backup_Completo_$data.zip"
                        $caminhoFinal = "$destino\$nomeZip"
                        
                        Compress-Archive -Path "$origem\*" -DestinationPath $caminhoFinal -Force -ErrorAction Stop
                        Write-Host "! Backup Completo guardado em: $caminhoFinal" -ForegroundColor Green
                    } 
                    elseif ($tipo -eq "2") {
                        # Backup Incremental (Adiciona ficheiros novos ou alterados a um ZIP existente e mantém o que já existe).
                        $caminhoFinal = "$destino\Backup_Base.zip"
                        
                        Compress-Archive -Path "$origem\*" -DestinationPath $caminhoFinal -Update -ErrorAction Stop
                        Write-Host "! Backup Incremental atualizado em: $caminhoFinal" -ForegroundColor Green
                    }

                    Add-Content ".\BackupManager.log" -Value "$(Get-Date -Format 'dd-MM-yyyy HH:mm:ss') - INFO: Backup ZIP (Modo $tipo) concluído para '$caminhoFinal'."
                }
                catch {Write-Host "! Erro ao criar o ZIP!`nMotivo: $($_.Exception.Message)" -ForegroundColor Red}
            }

            Write-Host "`nPressione ENTER para continuar... " -ForegroundColor Yellow -NoNewline
            do {$tecla=[System.Console]::ReadKey($true)} until ($tecla.Key -eq [System.ConsoleKey]::Enter)
        }

        "2"{
            cls
            Write-Host "Agendar Backup Automático (ZIP Diário):`n" -ForegroundColor Yellow
            $origemAuto = Read-Host "Digite a pasta de origem"
            $destinoAuto = Read-Host "Digite a pasta de destino para o ficheiro ZIP"
            $hora = Read-Host "Digite a hora para o backup (formato HH:mm, ex: 23:00)"
            $nomeTarefa = "BackupZIP_$(($origemAuto -split '\\')[-1])"

            try {
                # Este comando abre uma janela invisível do PowerShell e corre o comando de backup automático em ZIP.
                # O backup automático é incremental, e vai adicionando os ficheiros da pasta de origem diariamente.
                $comandoScript = "Compress-Archive -Path '$origemAuto\*' -DestinationPath '$destinoAuto\Backup_Auto.zip' -Update"
                $acao = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-WindowStyle Hidden -Command `"$comandoScript`""
                $trigger = New-ScheduledTaskTrigger -Daily -At $hora
                
                # Esta linha cria a tarefa do backup automático com os parâmetros acima.
                Register-ScheduledTask -TaskName $nomeTarefa -Action $acao -Trigger $trigger -Description "Backup ZIP automático" -RunLevel Highest -Force | Out-Null
                
                Write-Host "! Backup ZIP automático agendado para as $hora todos os dias!" -ForegroundColor Green
                Add-Content ".\BackupManager.log" -Value "$(Get-Date -Format 'dd-MM-yyyy HH:mm:ss') - INFO: Backup agendado '$nomeTarefa' criado."
            }
            catch {Write-Host "! Erro ao agendar backup!`nMotivo: $($_.Exception.Message)" -ForegroundColor Red}

            Write-Host "`nPressione ENTER para continuar... " -ForegroundColor Yellow -NoNewline
            do {$tecla=[System.Console]::ReadKey($true)} until ($tecla.Key -eq [System.ConsoleKey]::Enter)
        }

        "3"{
            cls
            Write-Host "Verificação de Ficheiro de Backup (ZIP):`n" -ForegroundColor Yellow
            $arquivoZip = Read-Host "Digite o caminho completo do ficheiro ZIP (ex: C:\Backups\Backup.zip)"

            try {
                # Verifica se o ficheiro ZIP existe e tem dados lá dentro.
                if (Test-Path $arquivoZip) {
                    $ficheiro = Get-Item $arquivoZip
                    $tamanhoMB = [math]::Round($ficheiro.Length / 1MB, 2)
                    
                    if ($ficheiro.Length -gt 0) {
                        Write-Host "! Integridade OK: O ficheiro ZIP existe e tem $tamanhoMB MB." -ForegroundColor Green
                    } else {
                        Write-Host "! AVISO: O ficheiro ZIP existe, mas está vazio!" -ForegroundColor Red
                    }
                } else {
                    Write-Host "! ERRO: O ficheiro ZIP não foi encontrado no caminho especificado!" -ForegroundColor Red
                }
            }
            catch {Write-Host "! Erro ao verificar ficheiro!`nMotivo: $($_.Exception.Message)" -ForegroundColor Red}

            Write-Host "`nPressione ENTER para continuar... " -ForegroundColor Yellow -NoNewline
            do {$tecla=[System.Console]::ReadKey($true)} until ($tecla.Key -eq [System.ConsoleKey]::Enter)
        }

        "4"{
            cls
            Write-Host "Restauração de Dados (Extrair ZIP):`n" -ForegroundColor Yellow
            $ZipFile = Read-Host "Digite o caminho do ficheiro ZIP a restaurar (ex: C:\Backups\Backup.zip)"
            $destinoRestore = Read-Host "Digite a pasta onde quer extrair os dados (ex: C:\Backups)"

            try {
                Write-Host "`n! A extrair ficheiros..." -ForegroundColor Blue
                
                # O comando Expand-Archive descompacta o ficheiro.
                # O parâmetro -Force substitui ficheiros existentes se necessário.
                Expand-Archive -Path $ZipFile -DestinationPath $destinoRestore -Force -ErrorAction Stop
                
                Write-Host "! Dados extraídos com sucesso para $destinoRestore!" -ForegroundColor Green
                Add-Content ".\BackupManager.log" -Value "$(Get-Date -Format 'dd-MM-yyyy HH:mm:ss') - INFO: Ficheiro ZIP '$ZipFile' extraído para '$destinoRestore'."
            }
            catch {Write-Host "! Erro ao restaurar dados!`nMotivo: $($_.Exception.Message)" -ForegroundColor Red}

            Write-Host "`nPressione ENTER para continuar... " -ForegroundColor Yellow -NoNewline
            do {$tecla=[System.Console]::ReadKey($true)} until ($tecla.Key -eq [System.ConsoleKey]::Enter)
        }

        {$_ -in "q", "quit"} {Return}
        default {Write-Host "! Opção inválida, escolhe entre |1-4 ou Q (quit)|" -ForegroundColor Red; Start-Sleep -Milliseconds 1200}

    }
} while($true)