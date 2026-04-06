do{
    cls
    Write-Host ".+=================================================+." -ForegroundColor Cyan
    Write-Host "    MIGRAÇÃO, VIRTUALIZAÇÃO E REPOSIÇÃO (Hyper-V)    " -ForegroundColor Yellow
    Write-Host ".+=================================================+." -ForegroundColor Cyan
    Write-Host "   1. Criar Máquina Virtual (Hyper-V)                "
    Write-Host "   2. Criar Snapshot de Sistema (Checkpoint)         "
    Write-Host "   3. Exportar Sistema (Migração)                    "
    Write-Host "   4. Restaurar Sistema (Reposição)                  "
    Write-Host "    Q. Voltar ao menu                                " -ForegroundColor Red
    Write-Host ".+=================================================+." -ForegroundColor Cyan
    $escolha = Read-Host " --> "
    
    switch ($escolha) {
        
        "1"{
            cls
            Write-Host "Criar Máquina Virtual:`n" -ForegroundColor Yellow
            $nomeVM = Read-Host "Digite o nome da nova VM"
            $ram = Read-Host "Memória RAM em MB (ex: 2048)"
            $disco = Read-Host "Tamanho do disco em GB (ex: 20)"
            
            # Pede o ficheiro ISO para que o servidor ter um disco de instalação
            $caminhoISO = Read-Host "Caminho do ficheiro .iso de instalação (Deixe em branco para ignorar)"

            try {
                Write-Host "`nA criar a Máquina Virtual... Aguarde." -ForegroundColor Cyan
                
                # Prepara a pasta para o disco virtual
                $pastaVM = "C:\VMs\$nomeVM"
                if (-not (Test-Path $pastaVM)) { New-Item -Path $pastaVM -ItemType Directory -Force | Out-Null }
                
                $caminhoVHD = "$pastaVM\$nomeVM.vhdx"
                
                # O New-VM cria uma máquina virtual nova (sem ou sem disco de instalação).
                # O argumento [long] trata o input como um integer de 64 bits e evita crashes quando o user insere um valor muito grande.
                # Caso o comando falhe, passa diretamente para o "catch".
                New-VM -Name $nomeVM -MemoryStartupBytes ([long]$ram * 1MB) -NewVHDPath $caminhoVHD -NewVHDSizeBytes ([long]$disco * 1GB) -ErrorAction Stop | Out-Null
                
                Write-Host "! Máquina Virtual '$nomeVM' criada com sucesso!" -ForegroundColor Green
                
                # Se o utilizador escreveu um caminho ISO, tenta montá-lo na drive de DVD virtual
                if (-not [string]::IsNullOrWhiteSpace($caminhoISO)) {
                    if (Test-Path $caminhoISO) {
                        Set-VMDvdDrive -VMName $nomeVM -Path $caminhoISO -ErrorAction Stop
                        Write-Host "! ISO montado com sucesso na drive de DVD virtual!" -ForegroundColor Green
                    } else {
                        Write-Host "! AVISO: Ficheiro ISO não encontrado. A VM foi criada sem disco de boot." -ForegroundColor Yellow
                    }
                }

                Add-Content ".\VirtualManager.log" -Value "$(Get-Date -Format 'dd-MM-yyyy HH:mm:ss') - INFO: VM '$nomeVM' criada com $ram MB RAM."
            }
            catch {Write-Host "! Erro ao criar VM! O Hyper-V está instalado?`nMotivo: $($_.Exception.Message)" -ForegroundColor Red}

            Write-Host "`nPressione ENTER para continuar... " -ForegroundColor Yellow -NoNewline
            do {$tecla=[System.Console]::ReadKey($true)} until ($tecla.Key -eq [System.ConsoleKey]::Enter)
        }

        "2"{
            cls
            Write-Host "Criar Snapshot de Sistema:`n" -ForegroundColor Yellow
            # Lista as VMs existentes. Se não existirem, continuar.
            Get-VM -ErrorAction SilentlyContinue | Select-Object Name, State | Format-Table -AutoSize
            
            $nomeVM = Read-Host "Digite o nome da VM para o snapshot"
            $nomeSnap = Read-Host "Digite um nome para o Snapshot (ex: AntesDoUpdate)"

            try {
                Write-Host "`nA criar Snapshot... Aguarde." -ForegroundColor Cyan
                # No Hyper-V, as Snapshots chamam-se "Checkpoints".
                Checkpoint-VM -Name $nomeVM -SnapshotName $nomeSnap -ErrorAction Stop | Out-Null
                
                Write-Host "! Snapshot '$nomeSnap' criado com sucesso na VM '$nomeVM'!" -ForegroundColor Green
                Add-Content ".\VirtualManager.log" -Value "$(Get-Date -Format 'dd-MM-yyyy HH:mm:ss') - INFO: Snapshot '$nomeSnap' criado para '$nomeVM'."
            }
            catch {Write-Host "! Erro ao criar Snapshot!`nMotivo: $($_.Exception.Message)" -ForegroundColor Red}

            Write-Host "`nPressione ENTER para continuar... " -ForegroundColor Yellow -NoNewline
            do {$tecla=[System.Console]::ReadKey($true)} until ($tecla.Key -eq [System.ConsoleKey]::Enter)
        }

        "3"{
            cls
            # Exportar VM para outro local.
            Write-Host "Exportar VM (Migração):`n" -ForegroundColor Yellow
            
            Get-VM -ErrorAction SilentlyContinue | Select-Object Name, State | Format-Table -AutoSize
            $nomeVM = Read-Host "`nDigite o nome da VM a exportar"
            $destinoExport = Read-Host "Digite a pasta de destino (ex: C:\Exportacoes)"

            try {
                # Esta linha vê se o caminho existe, se não existir
                if (-not (Test-Path $destinoExport)) { New-Item -Path $destinoExport -ItemType Directory -Force | Out-Null }
                
                Write-Host "`nA exportar a VM (pode demorar alguns minutos)..." -ForegroundColor Blue
                Export-VM -Name $nomeVM -Path $destinoExport -ErrorAction Stop | Out-Null
                
                Write-Host "! VM '$nomeVM' exportada com sucesso para $destinoExport!" -ForegroundColor Green
                Add-Content ".\VirtualManager.log" -Value "$(Get-Date -Format 'dd-MM-yyyy HH:mm:ss') - INFO: VM '$nomeVM' exportada para '$destinoExport'."
            }
            catch {Write-Host "! Erro ao exportar sistema!`nMotivo: $($_.Exception.Message)" -ForegroundColor Red}

            Write-Host "`nPressione ENTER para continuar... " -ForegroundColor Yellow -NoNewline
            do {$tecla=[System.Console]::ReadKey($true)} until ($tecla.Key -eq [System.ConsoleKey]::Enter)
        }

        "4"{
            cls
            # Restaurar VM com snapshots
            Write-Host "Restaurar VM (Reposição via Snapshot):`n" -ForegroundColor Yellow
            
            Get-VM -ErrorAction SilentlyContinue | Select-Object Name, State | Format-Table -AutoSize
            $nomeVM = Read-Host "Digite o nome da VM que deseja restaurar"
            
            try {
                # Mostra as snapshots disponíveis da VM escolhida
                Write-Host "`nSnapshots disponíveis para {$nomeVM}:" -ForegroundColor Cyan
                Get-VMSnapshot -VMName $nomeVM -ErrorAction Stop | Select-Object Name, CreationTime | Format-Table -AutoSize
                
                $nomeSnap = Read-Host "Digite o nome do Snapshot exato a restaurar"
                
                Write-Host "`nA restaurar a Snapshot... Aguarde." -ForegroundColor Yellow
                Get-VM -ErrorAction SilentlyContinue | Select-Object Name, State | Format-Table -AutoSize
                # O parâmetro '-Confirm:$false' desativa a prompt de confirmação e avança.
                Restore-VMCheckpoint -VMName $nomeVM -Name $nomeSnap -Confirm:$false -ErrorAction Stop | Out-Null
                
                Write-Host "! Sistema restaurado com sucesso para o estado do snapshot '$nomeSnap'!" -ForegroundColor Green
                Add-Content ".\VirtualManager.log" -Value "$(Get-Date -Format 'dd-MM-yyyy HH:mm:ss') - INFO: VM '$nomeVM' restaurada para snapshot: '$nomeSnap'."
            }
            catch {Write-Host "! Erro ao restaurar sistema!`nMotivo: $($_.Exception.Message)" -ForegroundColor Red}

            Write-Host "`nPressione ENTER para continuar... " -ForegroundColor Yellow -NoNewline
            do {$tecla=[System.Console]::ReadKey($true)} until ($tecla.Key -eq [System.ConsoleKey]::Enter)
        }

        {$_ -in "q", "quit"} {Return}
        default {Write-Host "! Opção inválida, escolhe entre |1-4 ou Q (quit)|" -ForegroundColor Red; Start-Sleep -Milliseconds 1200}

    }
} while($true)