
<#
.SYNOPSIS
    Monitora o site HelloWorld a cada 60 segundos, grava o resultado (codigo HTTP e mensagem)
    em um log na mesma pasta do script, e para o monitoramento se o retorno for diferente de 200.
 
.EXAMPLE
    .\Monitor-HelloWorld.ps1 -Url "http://helloworld.local"
#>
 
param(
    [string]$Url = "http://helloworld.local",
    [int]$IntervalSeconds = 60
)
 
$LogPath = Join-Path $PSScriptRoot "monitor.log"
 
function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogPath -Value "$timestamp - $Message"
}
 
Write-Log "Monitoramento iniciado para $Url (intervalo: $IntervalSeconds s)"
 
while ($true) {
    try {
        $response = Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 10
        $statusCode = [int]$response.StatusCode
        $statusMessage = $response.StatusDescription
    }
    catch {
        if ($_.Exception.Response) {
            $statusCode = [int]$_.Exception.Response.StatusCode
            $statusMessage = $_.Exception.Response.StatusDescription
        } else {
            $statusCode = "N/A"
            $statusMessage = "Falha de conexao: $($_.Exception.Message)"
        }
    }
 
    Write-Log "HTTP $statusCode - $statusMessage"
 
    if ($statusCode -ne 200) {
        Write-Log "Status diferente de 200 detectado. Encerrando monitoramento."
        break
    }
 
    Start-Sleep -Seconds $IntervalSeconds
}