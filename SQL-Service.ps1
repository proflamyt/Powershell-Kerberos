# SQL Service


#  Domain  Controller 
Import-Module .\encryption\enc-dec.ps1

$port = 5005

$chost = "127.0.0.1"

$listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Parse($chost), $port)
$listener.Start()

$creds = @{"sql.service"="iloveyou" }

$svc_pass = $users["sql.service"]



Write-Host "Waiting for connection on port $port..."

while ($true) {

    $client = $listener.AcceptTcpClient()
    $stream = $client.GetStream()

    $reader = [System.IO.StreamReader]::new($stream)


    $message = receiveMessage $reader



    $client.Close()
}

$listener.Stop()



function sendData ($serviceTKT, $EncryptedData) {
    $session = xorEncDec $serviceTKT $svc_pass
    $data =  xorEncDec $EncryptedData $session

    
}