# UserManager

do{
    cls
    Write-Host ".+===========================================+." -ForegroundColor Cyan
    Write-Host "        GESTÃO DE UTILIZADORES E GRUPOS        " -ForegroundColor Yellow
    Write-Host ".+===========================================+." -ForegroundColor Cyan
    Write-Host "   1. Mostrar Utilizadores Locais              "
    Write-Host "   2. Mostrar Grupos Locais                    "
    Write-Host "   3. Criar Novo Utilizador (Requer Admin)     "
    Write-Host "   4. Remover Utilizador (Requer Admin)        "
    Write-Host "   5. Ativar/Desativar Conta de Utilizador     "
    Write-Host "   6. Criar um Grupo                           "
    Write-Host "   7. Remover um Grupo                         "
    Write-Host "   8. Adicionar Utilizador a um Grupo          "
    Write-Host "   9. Remover Utilizador de um Grupo           "
    Write-Host "  10. Ver Grupos de um Utilizador              "
    Write-Host "    Q. Voltar ao menu                          " -ForegroundColor Red
    Write-Host ".+===========================================+." -ForegroundColor Cyan
    $escolha = Read-Host " --> "
    
    switch ($escolha) {
        
        "1"{
            cls
            # Mostrar todos os users com o seus nomes, se estão ativados, e a sua descrição.
            Get-LocalUser | Select-Object Name, Enabled, Description | Format-Table -AutoSize

            Write-Host "`nPressione ENTER para continuar... " -ForegroundColor Yellow -NoNewline
            do {$tecla=[System.Console]::ReadKey($true)} until ($tecla.Key -eq [System.ConsoleKey]::Enter)
        }

        "2"{
            cls
            Get-LocalGroup

            Write-Host "`nPressione ENTER para continuar... " -ForegroundColor Yellow -NoNewline
            do {$tecla=[System.Console]::ReadKey($true)} until ($tecla.Key -eq [System.ConsoleKey]::Enter)
        }




        "3"{
            cls
            Write-Host "Criar um novo utilizador:`n" -ForegroundColor Yellow
            $novoUser = Read-Host "Username"
            $pass = Read-Host "Password" -AsSecureString # Este parâmetro esconde os caracteres do input
            try{
                New-LocalUser -Name $novoUser -Password $pass -Description "User criado por Script" -ErrorAction Stop | Out-Null
                Write-Host "! Utilizador criado!" -ForegroundColor Green
                Add-Content ".\UserManager.log" -Value "$(Get-Date -Format 'dd-MM-yyyy HH:mm:ss') - INFO: User '$novoUser' criado."
            }
            
            catch {Write-Host "! Erro, não foi possível criar o utilizador!`nMotivo: $($_.Exception.Message)" -ForegroundColor Red}

            Write-Host "`nPressione ENTER para continuar... " -ForegroundColor Yellow -NoNewline
            do {$tecla=[System.Console]::ReadKey($true)} until ($tecla.Key -eq [System.ConsoleKey]::Enter)
        
        }

        "4"{
            cls
            Write-Host "Remover utilizador:`n" -ForegroundColor Yellow
            Get-LocalUser | Select-Object Name | Format-Table -AutoSize
            $RemoverUser = Read-Host "Utilizador a remover"
            :RemoverUser do{ # Isto é um labeled break. Ao dar um nome ao "do", conseguimos apontar um break diretamente para sair dele.
                cls
                Write-Host "Utilizador a remover: $RemoverUser"
                $confirmarDelete = Read-Host "`nDeseja apagar este utilizador? (S ou N)"
                switch ($confirmarDelete){
                    
                    {$_ -in "s", "sim"} {
                        # Este script não remove as pastas dos users
                        try{
                            Remove-LocalUser -Name $RemoverUser -ErrorAction Stop | Out-Null # Esta linha tenta remover o user. Se houver algum erro, passa para o "catch"
                            Write-Host "! Utilizador removido!" -ForegroundColor Green
                            Add-Content ".\UserManager.log" -Value "$(Get-Date -Format 'dd-MM-yyyy HH:mm:ss') - INFO: User '$RemoverUser' removido."
                        }
            
                        catch {Write-Host "! Erro, não foi possível remover o utilizador!`nMotivo: $($_.Exception.Message)" -ForegroundColor Red}
                        break RemoverUser # Break apontado para o labeled "do".
                    }
                    {$_ -in "N", "nao", "não"} {Write-Host "! O utilizador não será removido!" -ForegroundColor Blue; break RemoverUser}
                    default {Write-Host "! Opção inválida, escolha |S (sim) ou N (não)|" -ForegroundColor Red; Start-Sleep -Milliseconds 1200}
                }
            } while($true)
            

            Write-Host "`nPressione ENTER para continuar... " -ForegroundColor Yellow -NoNewline
            do {$tecla=[System.Console]::ReadKey($true)} until ($tecla.Key -eq [System.ConsoleKey]::Enter)
        }


        "5"{
            cls
            Write-Host "Ativar/Desativar utilizador:`n" -ForegroundColor Yellow
            Get-LocalUser | Select-Object Name, Enabled | Format-Table -AutoSize
            $EnableDisableUser = Read-Host "Utilizador a Ativar/Desativar"
            :EnableDisableUser do{
                cls
                Write-Host "Utilizador a Ativar/Desativar: $EnableDisableUser"
                $AtivarDesativarUser = Read-Host "`nO que deseja fazer com este utilizador? (1 - Ativar  |  2 - Desativar)"
                switch ($AtivarDesativarUser){
                    
                    "1" {
                        try{
                            Enable-LocalUser -Name $EnableDisableUser -ErrorAction Stop | Out-Null
                            Write-Host "! Utilizador ativado!" -ForegroundColor Green
                            Add-Content ".\UserManager.log" -Value "$(Get-Date -Format 'dd-MM-yyyy HH:mm:ss') - INFO: User '$EnableDisableUser' ativado."
                        }
            
                        catch {Write-Host "! Erro, não foi possível ativar o utilizador!`nMotivo: $($_.Exception.Message)" -ForegroundColor Red}
                        break EnableDisableUser
                    }
                    
                    "2" {
                        try{
                            Disable-LocalUser -Name $EnableDisableUser -ErrorAction Stop | Out-Null
                            Write-Host "! Utilizador desativado!" -ForegroundColor Green
                            Add-Content ".\UserManager.log" -Value "$(Get-Date -Format 'dd-MM-yyyy HH:mm:ss') - INFO: User '$EnableDisableUser' desativado."
                        }
            
                        catch {Write-Host "! Erro, não foi possível desativar o utilizador!`nMotivo: $($_.Exception.Message)" -ForegroundColor Red}
                        break EnableDisableUser
                    }

                    default {Write-Host "! Opção inválida, escolha |1 (Ativar) ou 2 (Desativar)|" -ForegroundColor Red; Start-Sleep -Milliseconds 1200}
                }
            } while($true)
            

            Write-Host "`nPressione ENTER para continuar... " -ForegroundColor Yellow -NoNewline
            do {$tecla=[System.Console]::ReadKey($true)} until ($tecla.Key -eq [System.ConsoleKey]::Enter)
        }

        "6"{
            # Adicionar failsafes (maybe juntar menus?)
            cls
            $criarGrupo = Read-Host "Qual será o nome do grupo?"
            try{
                New-LocalGroup -Name "$criarGrupo" -ErrorAction Stop | Out-Null
                Write-Host "! Grupo criado!" -ForegroundColor Green
                Add-Content ".\UserManager.log" -Value "$(Get-Date -Format 'dd-MM-yyyy HH:mm:ss') - INFO: Grupo '$criarGrupo' criado."
            }
            catch {Write-Host "! Erro, não foi possível criar o grupo!`nMotivo: $($_.Exception.Message)" -ForegroundColor Red}

            Write-Host "`nPressione ENTER para continuar... " -ForegroundColor Yellow -NoNewline
            do {$tecla=[System.Console]::ReadKey($true)} until ($tecla.Key -eq [System.ConsoleKey]::Enter)
        }


        "7"{
            # Adicionar failsafes
            cls
            Get-LocalGroup
            $removerGrupo = Read-Host "Deseja remover que grupo?"
            try{
                Remove-LocalGroup -Name "$removerGrupo" -ErrorAction Stop | Out-Null
                Write-Host "! Grupo removido!" -ForegroundColor Green
                Add-Content ".\UserManager.log" -Value "$(Get-Date -Format 'dd-MM-yyyy HH:mm:ss') - INFO: Grupo '$criarGrupo' removido."
            }
            catch {Write-Host "! Erro, não foi possível remover o grupo!`nMotivo: $($_.Exception.Message)" -ForegroundColor Red}

            Write-Host "`nPressione ENTER para continuar... " -ForegroundColor Yellow -NoNewline
            do {$tecla=[System.Console]::ReadKey($true)} until ($tecla.Key -eq [System.ConsoleKey]::Enter)
        }


        "8"{
            # Adicionar failsafes
            cls
            Get-LocalUser | Select-Object Name | Format-Table -AutoSize
            $AddUserGrupo = Read-Host "Adicionar que utilizador?"
            Get-LocalGroup
            $AddGrupoGrupo = Read-Host "A que grupo?"
            try{
                Add-LocalGroupMember -Group $AddGrupoGrupo -Member $AddUserGrupo -ErrorAction Stop | Out-Null
                Write-Host "! Utilizador adicionado ao grupo!" -ForegroundColor Green
                Add-Content ".\UserManager.log" -Value "$(Get-Date -Format 'dd-MM-yyyy HH:mm:ss') - INFO: Utilizador '$AddUserGrupo' adicionado a '$AddGrupoGrupo'."
            }
            catch {Write-Host "! Erro, não foi possível adicionar o utilizador ao grupo!`nMotivo: $($_.Exception.Message)" -ForegroundColor Red}

            Write-Host "`nPressione ENTER para continuar... " -ForegroundColor Yellow -NoNewline
            do {$tecla=[System.Console]::ReadKey($true)} until ($tecla.Key -eq [System.ConsoleKey]::Enter)
        }


        "9"{
            # Adicionar failsafes
            cls
            Get-LocalUser | Select-Object Name | Format-Table -AutoSize
            $RemoveUserGrupo = Read-Host "Remover que utilizador?"
            Get-LocalGroup
            $RemoveGrupoGrupo = Read-Host "De que grupo?"
            try{
                Remove-LocalGroupMember -Group $RemoveGrupoGrupo -Member $RemoveUserGrupo -ErrorAction Stop | Out-Null
                Write-Host "! Utilizador removido do grupo!" -ForegroundColor Green
                Add-Content ".\UserManager.log" -Value "$(Get-Date -Format 'dd-MM-yyyy HH:mm:ss') - INFO: Utilizador '$RemoveUserGrupo' removido de '$RemoveGrupoGrupo'."
            }
            catch {Write-Host "! Erro, não foi possível remover o utilizador do grupo!`nMotivo: $($_.Exception.Message)" -ForegroundColor Red}

            Write-Host "`nPressione ENTER para continuar... " -ForegroundColor Yellow -NoNewline
            do {$tecla=[System.Console]::ReadKey($true)} until ($tecla.Key -eq [System.ConsoleKey]::Enter)
        }


        "10"{
            cls
            Get-LocalUser | Select-Object Name | Format-Table -AutoSize
            $VerGrupoUser = Read-Host "`nVer o grupo de que user?"
            cls
            net user $VerGrupoUser

            Write-Host "`nPressione ENTER para continuar... " -ForegroundColor Yellow -NoNewline
            do {$tecla=[System.Console]::ReadKey($true)} until ($tecla.Key -eq [System.ConsoleKey]::Enter)
        }


        {$_ -in "q", "quit"} {Return}
        default {Write-Host "! Opção inválida, escolhe entre |1-8 ou Q (quit)|" -ForegroundColor Red; Start-Sleep -Milliseconds 1200}

    }
} while($true)