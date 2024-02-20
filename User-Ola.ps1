# User 

Import-Module .\encryption\enc-dec.ps1

$port = 50551

$chost = "127.0.0.1"

$listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Parse($chost), $port)
$listener.Start()

$creds = @{"ola.lap1" = "password1"}

$authenticated = $false


Write-Host "Waiting for connection on port $port..."
while ($true) {

    $client = $listener.AcceptTcpClient()
    $stream = $client.GetStream()

    $reader = [System.IO.StreamReader]::new($stream)
    $writer = [System.IO.StreamReader]::new($stream)

    if ($authenticated -eq $false) {
        $message = Authenticate
        $writer.WriteLine($message)
        $writer.Flush()
        $authenticated = $true
    }

    $message  =  $reader.ReadLine() | ConvertFrom-Json

    if ($message.Type -eq "tgt") {

    }

    


    $client.Close()
}

$listener.Stop()



function Authenticate {
    $date = (get-date).Ticks;
    $encryptedData =  xorEncDec $date $creds['ola.lap1']


    $userRequest = @{
        Name = "ola.lap1"
        Type = "userauth"
        Data = $encryptedData
    }
    
    $userRequestObject = $userRequest | ConvertTo-Json

    return $userRequestObject

}