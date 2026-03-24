# Menu fixe
do {
        cls
        Write-Host ".+===============================================================+." -ForegroundColor Cyan
        Write-Host "   Painel de Administração & Monitorização - Windows Server 2025  " -ForegroundColor Yellow
        Write-Host ".+===============================================================+." -ForegroundColor Cyan
        Write-Host "   1. Gestão de Processos e Memória (btop)"
        Write-Host "   2. Monitorização do Sistema de Ficheiros" -ForegroundColor DarkGray
        Write-Host "   3. Monitorização de Recursos (CPU, RAM, Disco, Rede)" -ForegroundColor DarkGray
        Write-Host "   4. Monitorização de Segurança e Análise" -ForegroundColor DarkGray
        Write-Host "   5. Gestão de Utilizadores e Grupos" -ForegroundColor DarkGray
        Write-Host "   6. Gestão de Servidores e Serviços" -ForegroundColor DarkGray
        Write-Host "   7. Planos de Backup e Recuperação" -ForegroundColor DarkGray
        Write-Host "    Q. Sair do Sistema" -ForegroundColor Red
        Write-Host ".+===============================================================+." -ForegroundColor Cyan

        $escolha = Read-Host " --> "

        switch -Regex ($escolha) {
            '1' {& ".\1.Btop"}
            '2' {Write-Host "`nEm desenvolvimento..." -ForegroundColor Magenta; Start-Sleep -Milliseconds 1200}
            '3' {Write-Host "`nEm desenvolvimento..." -ForegroundColor Magenta; Start-Sleep -Milliseconds 1200}
            '4' {Write-Host "`nEm desenvolvimento..." -ForegroundColor Magenta; Start-Sleep -Milliseconds 1200}
            '5' {Write-Host "`nEm desenvolvimento..." -ForegroundColor Magenta; Start-Sleep -Milliseconds 1200}
            '6' {Write-Host "`nEm desenvolvimento..." -ForegroundColor Magenta; Start-Sleep -Milliseconds 1200}
            '7' {Write-Host "`nEm desenvolvimento..." -ForegroundColor Magenta; Start-Sleep -Milliseconds 1200}
            'q|quit' { 
                Write-Host "! A encerrar o sistema. Adeus!" -ForegroundColor Red
                Start-Sleep -Milliseconds 1200
                cls
                exit
            }
            default { 
                Write-Host "! Opção inválida, escolhe entre |1-7 ou Q|" -ForegroundColor Red
                Start-Sleep -Milliseconds 1200
            }
        }
    } while ($true)