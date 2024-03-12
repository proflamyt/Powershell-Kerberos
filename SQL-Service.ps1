# SQL Service

#  Domain  Controller 
Import-Module .\encryption\enc-dec.ps1 -Force

$port = 5005

$chost = "127.0.0.1"

$listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Parse($chost), $port)
$listener.Start()

$creds = @{"sql.service" = "iloveyou" }

$svc_pass = $creds["sql.service"]

$client = $listener.AcceptTcpClient()

Write-Host "Waiting for connection on port $port..."

if ($client.Connected) {

    $stream = $client.GetStream()

    $messageLenght = $stream.Read($storage, 0, $storage.Length)
    $data = [System.Text.Encoding]::UTF8.GetString($storage)
    $message = $data.substring(0, $messageLenght) | ConvertFrom-Json

  
    $ticket = xorEncDec $message.data.serviceTicket $creds['sql.service']

    $decodedMessage = -join (xorEncDec $message.data.message $ticket  | %{[char]$_}) | ConvertFrom-Json

    if ($decodedMessage.Message = "Give me Money, Money") {
        Write-Host "You Passed"
    }
    }

$listener.Stop()



function sendData ($serviceTKT, $EncryptedData) {
    $session = xorEncDec $serviceTKT $svc_pass
    $data =  xorEncDec $EncryptedData $session

    
}