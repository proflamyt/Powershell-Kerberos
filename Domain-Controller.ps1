#  Domain  Controller 
Import-Module .\encryption\enc-dec.ps1

$port = 12345

$chost = "127.0.0.1"

$listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Parse($chost), $port)
$listener.Start()

$creds = @{"ola.lap1" = "password1"; "adedayo.lap2" = "password2";
             "krbgtb" = "long-pass"; "sql.service"="iloveyou" }

$dc_pass = $users["krbgtb"]


function UserAuthentication($userObject) {
    # Base64 decryption

    $timestamp = xorEncDec $userObject.Data  $creds[$userObject.Name]  

    #if timestamp

    # on 
    $session = GenerateSession;

    # encrypt session with user pass and encrypt tct with krbgtg pass

    $UserTGT = xorEncDec($session, $dc_pass)

    $SessionKey = xorEncDec($session, $creds[$userObject.Name])


    return $UserTGT, $SessionKey
}


function ServiceAuthentication($userTGT, $encrypteddata){

    $session = xorEncDec($userTGT, $dc_pass)

    $data = xorEncDec($encrypteddata, $session)

    $dataObject = ConvertFrom-Json $data

    $ServiceSession = GenerateSession;

    # encrypt sessison key with user pass

    $SessionKey = xorEncDec($ServiceSession, $creds[$dataobject.Name])

    $SQLTicket = xorEncDec($SessionKey, $creds[$dataobject.Service])


    return $SQLTicket, $SessionKey
}


function  sendMessage ($message){

    $message | ConvertTo-Json

}


function  receiveMessage ($message){

    $message | ConvertFrom-Json
}

Write-Host "Waiting for connection on port $port..."
while ($true) {

    $client = $listener.AcceptTcpClient()
    $stream = $client.GetStream()

    $reader = [System.IO.StreamReader]::new($stream)

    $message = receiveMessage $reader.ReadLine()

    if ($message.type -eq "userauth") {
        UserAuthentication $message
    }
    else {
        ServiceAuthentication $message
    }

    $client.Close()
}

$listener.Stop()