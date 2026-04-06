# Menu fixe
do {
        cls
        Write-Host ".+===============================================================+." -ForegroundColor Cyan
        Write-Host "   Painel de Administração & Monitorização - Windows Server 2025  " -ForegroundColor Yellow
        Write-Host ".+===============================================================+." -ForegroundColor Cyan
        Write-Host "   1. Gestão de Processos e Memória (btop)"
        Write-Host "   2. Monitorização do Sistema de Ficheiros"
        Write-Host "   3. Monitorização de Segurança e Análise"
        Write-Host "   4. Gestão de Utilizadores e Grupos"
        Write-Host "   5. Gestão do Servidor e Serviços"
        Write-Host "   6. Gestão e Monitorização de Redes"
        Write-Host "   7. Planos de Backup e Recuperação"
        Write-Host "   8. Migração, Virtualização e Reposição"
        Write-Host "    Q. Sair do Script" -ForegroundColor Red
        Write-Host ".+===============================================================+." -ForegroundColor Cyan
        Write-Host " --> " -NoNewline
        $escolha = Read-Host

        switch ($escolha) {
            "1" {& ".\1.Btop"} # O comando (& ".\Ficheiro 1") nesta escolha é utilizado quando o nome do ficheiro tem espaços (antes tinha mas assim tá + bueno)
            "2" {.\2.SistemaFicheiros}
            "3" {.\3.SecurityMonitoring}
            "4" {.\4.UserManager}
            "5" {& ".\5.Server&Services"}
            "6" {& ".\6.Networking-MonitorManage"}
            "7" {& ".\7.Backup&Recovery"}
            "8" {& ".\8.HyperV-Management"}
            
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