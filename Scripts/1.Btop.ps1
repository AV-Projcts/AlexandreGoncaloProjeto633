# 1. btop
cls
if (Get-Command btop -ErrorAction SilentlyContinue) {btop}
else {
    Write-Host "! O programa não está instalado" -ForegroundColor Red
    do {
        $install = Read-Host "Instalar?"
        switch -Regex ($install) {
            "s|sim" {
                winget install btop
                if (Get-Command btop -ErrorAction SilentlyContinue) {
                    Write-Host "\n! O programa foi instalado, iniciará em 5 segundos.." -ForegroundColor Green
                    Start-Sleep -Seconds 5
                    btop
                    return
                    }
                else {Write-Host "! Erro, o BTOP não foi instalado, a sair.." -ForegroundColor Red}

                }
            "n|nao|não" {Write-Host "O programa não será instalado, back to the lobby.."; Return}
            default {Write-Host "! Erro, insere Sim ou Não"}
        }
    }while ($true)
}