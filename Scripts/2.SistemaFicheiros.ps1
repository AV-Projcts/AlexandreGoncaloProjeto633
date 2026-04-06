# Filesystem
do {
    cls
    Write-Host ".+================================================+." -ForegroundColor Cyan
    Write-Host "                Sistema de Ficheiros                " -ForegroundColor Yellow
    Write-Host ".+================================================+." -ForegroundColor Cyan
    Write-Host "   1. Utilização dos Discos                         "
    Write-Host "   2. Criação Automática de Diretório               "
    Write-Host "   3. Gestão de Permissões de Ficheiros             "
    Write-Host "   4. Identificação de Ficheiros Grandes (>100MB)   "
    Write-Host "   5. Auditoria de Acesso a Ficheiros               "
    Write-Host "    Q. Voltar ao menu                               " -ForegroundColor Red
    Write-Host ".+================================================+." -ForegroundColor Cyan
    $escolha = Read-Host " --> "
    
    switch ($escolha) {
        "1"{
            cls
            Write-Host "Utilização dos Discos:`n" -ForegroundColor Blue

            # Não tem failsafe como outras opções abaixo, pode mostrar o '.Exception' em certos casos
            $drives= Get-PSDrive -PSProvider FileSystem

            # Ao meter a variável $disco no iterador, a mesma é utilizada como um objeto
            # no comando "Get-PSDrive" (Ou seja, disco C, D, E,..)
            foreach ($disco in $drives){
                $tamanhoDisco= $disco.Used + $disco.Free
                $discoUso= ($disco.Used / $tamanhoDisco) * 100
                # Este round arredonda com 2 casas decimais
                $roundPercentagem= [Math]::Round($discoUso, 2)

                # Visualização da percentagem de disco em uso com Progress Bar maluca estilo PowerShell 7
                if ($roundPercentagem -lt 10) {Write-Host "${disco}: [░░░░░░░░░░] - $roundPercentagem% em uso"}
                elseif ($roundPercentagem -ge 10 -and $roundPercentagem -lt 20) {Write-Host "${disco}: [█░░░░░░░░░] - $roundPercentagem% em uso"}
                elseif ($roundPercentagem -ge 20 -and $roundPercentagem -lt 30) {Write-Host "${disco}: [██░░░░░░░░] - $roundPercentagem% em uso"}
                elseif ($roundPercentagem -ge 30 -and $roundPercentagem -lt 40) {Write-Host "${disco}: [███░░░░░░░] - $roundPercentagem% em uso"}
                elseif ($roundPercentagem -ge 40 -and $roundPercentagem -lt 50) {Write-Host "${disco}: [████░░░░░░] - $roundPercentagem% em uso"}
                elseif ($roundPercentagem -ge 50 -and $roundPercentagem -lt 60) {Write-Host "${disco}: [█████░░░░░] - $roundPercentagem% em uso"}
                elseif ($roundPercentagem -ge 60 -and $roundPercentagem -lt 70) {Write-Host "${disco}: [██████░░░░] - $roundPercentagem% em uso"}
                elseif ($roundPercentagem -ge 70 -and $roundPercentagem -lt 80) {Write-Host "${disco}: [███████░░░] - $roundPercentagem% em uso"}
                elseif ($roundPercentagem -ge 80 -and $roundPercentagem -lt 90) {Write-Host "${disco}: [████████░░] - $roundPercentagem% em uso"}
                elseif ($roundPercentagem -ge 90 -and $roundPercentagem -lt 100) {Write-Host "${disco}: [█████████░] (!) - $roundPercentagem% em uso" -ForegroundColor Yellow}
                else {Write-Host "${disco}: [██████████] (X) - ! Disco Cheio !" -ForegroundColor Red}
            }
            # O -NoNewline faz o cursor ficar na linha do print
            Write-Host "`nPressione ENTER para continuar... " -ForegroundColor Yellow -NoNewline
            # Este loop itera até receber Enter
            do {$tecla=[System.Console]::ReadKey($true)} until ($tecla.Key -eq [System.ConsoleKey]::Enter)
        }

        "2"{
            cls
            Write-Host "§§§§§ - Criação Automática de Diretório - §§§§§" -ForegroundColor Yellow
            $caminhoNovo = Read-Host "Introduza o caminho completo da nova pasta (Ex: C:\Temp\NovaPasta)"

            # Verificar se o input tá vazio
            if ([String]::IsNullOrWhiteSpace($caminhoNovo)) {Write-Host "! Erro, o campo não pode estar vazio!" -ForegroundColor Red}
            else {
                try {
                    # Esta linha testa o caminho. Se houver erros, passa diretamente para o "catch" e mostra o motivo
                    $caminhoExiste = Test-Path $caminhoNovo -ErrorAction Stop

                    if (-not $caminhoExiste) {
                        # Nesta linha, o Out-Null descarta o output do comando
                        # Outra vez, o -ErrorAction Stop é usado para passar diretamente para o "catch" em caso de erro
                        # É possível criar caminhos locais ao escrever apenas um nome, mas no output para as logs aparece só o nome, sem um caminho (Valve pls fix)
                        New-Item -ItemType Directory -Path $caminhoNovo -Force -ErrorAction Stop | Out-Null

                        Write-Host "! Diretório criado com sucesso em: $caminhoNovo" -ForegroundColor Green
                        Add-Content -Path ".\FileSystem.log" -Value "$(Get-Date -Format 'dd-MM-yyyy HH:mm:ss') - INFO: Diretório criado em $caminhoNovo"
                        }
                    else {Write-Host "! Erro: O diretório '$caminhoNovo' já existe!" -ForegroundColor Red}       
                }
                catch {
                    #
                    # ----- Explicação bugada ----- #
                    #
                    # A variavél $($_.Exception.Message) existe porque o PowerShell é uma linguagem Object-Oriented.
                    # Neste caso, o objeto é o erro (ErrorRecord), que pode ser chamado com '$_' (objeto atual).
                    # Cada objeto pode conter várias propriedades dentro, neste caso usamos o '.Exception'.
                    # O '.Exception' é a mensagem com várias linhas a descrever o erro, e pode ser vista ao escrever
                    # um comando que não existe num terminal PowerShell.
                    # O '.Message' é a porção do '.Exception' com texto "Human-readable", e neste caso serve para
                    # compactar a mensagem de erro apresentada ao user.
                    #
                    Write-Host "! Erro: $($_.Exception.Message)" -ForegroundColor Red
                }
            }
            Write-Host "`nPressione ENTER para continuar... " -ForegroundColor Yellow -NoNewline
            do {$tecla=[System.Console]::ReadKey($true)} until ($tecla.Key -eq [System.ConsoleKey]::Enter)
        }

        "3"{
            cls
            Write-Host "§§§§§ - Gestão de Permissões de Ficheiros - §§§§§" -ForegroundColor Yellow
            $pastaPerms = Read-Host "Introduza o caminho da pasta"
            if ([String]::IsNullOrWhiteSpace($pastaPerms)) {Write-Host "! Erro, o campo não pode estar vazio!" -ForegroundColor Red}
            else {
                if (Test-Path $pastaPerms) {
                    cls
                    # Ideia - Adicionar forma de ver permissões do user na pasta escolhida no Get-localUser
                    Get-LocalUser | Select-Object Name | Out-Host
                    $userPerm = Read-Host "Introduza o nome do utilizador"
                    Write-Host "`n• 1 - Leitura e Execução (RX)`n• 2 - Controlo Total (F)"
                    # Se o acesso for negado ele dá como sucesso e escreve no log, mas aparece que o acesso foi negado (Bug visual, Valve pls fix)
                    $tipoPerm = Read-Host "Escolha o nível de permissão (1 ou 2)"
                    
                    if ($tipoPerm -eq '1') {
                        # A variável '/grant' só adiciona uma permissão a existentes.
                        # Por isso foi utilizado o '/grant:r', que garante apenas as permissões neste comando.
                        icacls $pastaPerms /grant:r "${userPerm}:(RX)" /T
                        Write-Host "Permissão de LEITURA atribuída com sucesso a $userPerm!" -ForegroundColor Green
                        Add-Content -Path ".\FileSystem.log" -Value "$(Get-Date -Format 'dd-MM-yyyy HH:mm:ss') - AVISO: Permissões de '$userPerm' alteradas para 'Read & Write' em '$pastaPerms'"
                    }
                    elseif ($tipoPerm -eq '2') { 
                        icacls $pastaPerms /grant:r "${userPerm}:(F)" /T
                        Write-Host "Permissão de CONTROLO TOTAL atribuída com sucesso a $userPerm!" -ForegroundColor Green
                        Add-Content -Path ".\FileSystem.log" -Value "$(Get-Date -Format 'dd-MM-yyyy HH:mm:ss') - AVISO: Permissões de '$userPerm' alteradas para 'Full Control' em '$pastaPerms'"
                    }
                    else {Write-Host "Opção de permissão inválida." -ForegroundColor Red}
                    
                }
                else {Write-Host "Erro: O caminho '$pastaPerms' não foi encontrado!" -ForegroundColor Red}    
            }
            Write-Host "`nPressione ENTER para continuar... " -ForegroundColor Yellow -NoNewline
            do {$tecla=[System.Console]::ReadKey($true)} until ($tecla.Key -eq [System.ConsoleKey]::Enter)
        }

        "4"{
            cls
            Write-Host "§§§§§ - Procurar Ficheiros Grandes (> 100MB) - §§§§§" -ForegroundColor Yellow
            $pastaBusca = Read-Host "Pasta a analisar (Ex: C:\Users\$env:USERNAME\Downloads)"
            if ([String]::IsNullOrWhiteSpace($pastaBusca)) {Write-Host "! Erro, o campo não pode estar vazio!" -ForegroundColor Red}
            else {
                if (Test-Path $pastaBusca) {
                    Write-Host "! A analisar... (Isto pode demorar alguns segundos)" -ForegroundColor Cyan
                    #
                    # ----- Explicação bugada (again) ----- #
                    #
                    # O comando Get-ChildItem é equivalente ao comando 'ls -l' no Linux, e mostra uma lista do que está dentro do diretório, com vários detalhes sobre cada item.
                    # Nos parâmetros iniciais, o '-Recurse' mostra o conteúdo no diretório apontado, e todos os outros diretórios contidos nele.
                    # Em seguida o -File mostra apenas ficheiros e exclui os diretórios do output.
                    #
                    # Por fim temos a parte mais complexa desta linha, o '@{Name="Tamanho(MB)";Expression={[math]::Round($_.Length / 1MB, 2)'.
                    #
                    # Isto é uma "Calculated Property", uma propriedade modificável de um objeto (Neste caso de cada ficheiro escolhido pelo -First 10).
                    # Basicamente uma Calculated Property pega numa propriedade já existente do objeto (Neste caso o .Lenght, o tamanho do ficheiro em bytes), formata o texto de acordo com
                    # as funções dentro dela, e envia como uma propriedade já existente (Por exemplo o Name, Directory, etc).
                    # Dentro desta Calculated Property, a informação é processada da seguinte forma:
                    # - Name="Tamanho(MB)" -- Define o nome da coluna para Tamanho(MB).
                    # - Expression={[math]::Round($_.Length / 1MB, 2) -- Esta expressão pega no tamanho do ficheiro (.Lenght), transforma de bytes para megabytes através de divisão, e
                    #                                                    arredonda com 2 casas decimais.
                    #
                    $ficheirosGrandes = Get-ChildItem -Path $pastaBusca -Recurse -File -ErrorAction SilentlyContinue | Where-Object Length -gt 100MB | Sort-Object Length -Descending | Select-Object -First 10 Name, Directory, @{Name="Tamanho(MB)";Expression={[math]::Round($_.Length / 1MB, 2)}}
                    
                    # Este 'if' verifica se o 'Get-ChildItem' achou algum ficheiro superior a 100MB.
                    # Devido á forma como o PowerShell funciona, se a variável não estiver vazia, é vista como $true
                    if ($ficheirosGrandes) {
                        $ficheirosGrandes | Format-Table -AutoSize
                        Add-Content -Path ".\FileSystem.log" -Value "$(Get-Date -Format 'dd-MM-yyyy HH:mm:ss') - ALERTA: Ficheiros maiores que 100MB encontrados em $pastaBusca"
                    }
                    else {Write-Host "! Nenhum ficheiro maior que 100MB encontrado nesta pasta." -ForegroundColor Green}
                }
                else {Write-Host "! Erro: O caminho '$pastaBusca' não foi encontrado!" -ForegroundColor Red}
            }
            Write-Host "`nPressione ENTER para continuar... " -ForegroundColor Yellow -NoNewline
            do {$tecla=[System.Console]::ReadKey($true)} until ($tecla.Key -eq [System.ConsoleKey]::Enter)
        }

        "5"{
            cls
            Write-Host "§§§§§ - Auditoria e Logs de Ficheiros - §§§§§" -ForegroundColor Yellow
                if (Test-Path ".\FileSystem.log") {
                    Write-Host "`nÚltimas 10 ações registadas no sistema:" -ForegroundColor Cyan
                    Get-Content ".\FileSystem.log" -Tail 10
                } else {
                    Write-Host "! Ainda não existem logs gerados!" -ForegroundColor Yellow
                }
            Write-Host "`nPressione ENTER para continuar... " -ForegroundColor Yellow -NoNewline
            do {$tecla=[System.Console]::ReadKey($true)} until ($tecla.Key -eq [System.ConsoleKey]::Enter)
        }

        {$_ -in "q", "quit"} {Return}
        default {Write-Host "! Opção inválida, escolhe entre |1-5 ou Q (quit)|" -ForegroundColor Red; Start-Sleep -Milliseconds 1200}
    }

} while ($true)