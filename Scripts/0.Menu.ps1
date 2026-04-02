# Menu fixe
do {
        cls
        Write-Host ".+===============================================================+." -ForegroundColor Cyan
        Write-Host "   Painel de Administração & Monitorização - Windows Server 2025  " -ForegroundColor Yellow
        Write-Host ".+===============================================================+." -ForegroundColor Cyan
        Write-Host "   1. Gestão de Processos e Memória (btop)"
        Write-Host "   2. Monitorização do Sistema de Ficheiros" -ForegroundColor Yellow
        Write-Host "   3. Monitorização de Segurança e Análise" -ForegroundColor DarkGray
        Write-Host "   4. Gestão de Utilizadores e Grupos" -ForegroundColor DarkGray
        Write-Host "   5. Gestão de Servidores e Serviços" -ForegroundColor DarkGray
        Write-Host "   6. Planos de Backup e Recuperação" -ForegroundColor DarkGray
        Write-Host "    Q. Sair do Sistema" -ForegroundColor Red
        Write-Host ".+===============================================================+." -ForegroundColor Cyan
        Write-Host " --> " -NoNewline
        $escolha = Read-Host

        switch ($escolha) {
            "1" {& ".\1.Btop"} # O comando (& ".\Ficheiro 1") nesta escolha é utilizado quando o nome do ficheiro tem espaços (antes tinha mas assim tá + bueno)
            "2" {.\2.SistemaFicheiros}
            "3" {Write-Host "`nEm desenvolvimento..." -ForegroundColor Magenta; Start-Sleep -Milliseconds 1200}
            "4" {Write-Host "`nEm desenvolvimento..." -ForegroundColor Magenta; Start-Sleep -Milliseconds 1200}
            "5" {Write-Host "`nEm desenvolvimento..." -ForegroundColor Magenta; Start-Sleep -Milliseconds 1200}
            "6" {Write-Host "`nEm desenvolvimento..." -ForegroundColor Magenta; Start-Sleep -Milliseconds 1200}
            
            # Esta seleção do switch procura "q" ou "quit" na variável $escolha
            {$_ -in "q", "quit"} {
                Write-Host "`n § ----- Bye! ----- §" -ForegroundColor Blue
                Start-Sleep -Milliseconds 1200
                cls
                exit
            }
            default {
                Write-Host "! Opção inválida, escolhe entre |1-6 ou Q (quit)|" -ForegroundColor Red
                Start-Sleep -Milliseconds 1200
            }
        }
    } while ($true)