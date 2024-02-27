#  Domain  Controller 
Import-Module .\encryption\enc-dec.ps1 -Force

$port = 12345

$chost = "127.0.0.1"

$listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Parse($chost), $port)
$listener.Start()

$creds = @{"ola.lap1" = "password1"; "adedayo.lap2" = "password2";
             "krbgtb" = "long-pass"; "sql.service"="iloveyou" }

$dc_pass = $creds["krbgtb"]

$i = 0

Write-Host "Waiting for connection on port $port..."

while ( $i -lt 3) {
    $i ++;

    $client = $listener.AcceptTcpClient()
    $stream = $client.GetStream()

    $reader = [System.IO.StreamReader]::new($stream)
    $writer = [System.IO.StreamWriter]::new($stream)

    $message = receiveMessage $reader

    Write-Host $message
    Write-Host "Received"
    
    if ($message.Type -eq "userauth") {
        $result = UserAuthentication $message
        sendMessage $writer "tgt" $result
    }
    Else {
        $result = ServiceAuthentication $message.data[0] $message.data[1] 
        sendMessage $writer "svt" $result
    }

    $client.Close()
}

$listener.Stop()





function UserAuthentication($userObject) {
    # Base64 decryption

    $timestamp = xorEncDec $userObject["data"]  $creds[$userObject.Name]  

    #if timestamp

    if ((get-date).Ticks - $timestamp -gt 1000) {
        return "Error"
    }

    $session = GenerateSession;

    # encrypt session with user pass and encrypt tct with krbgtg pass

    $UserTGT = xorEncDec $session $dc_pass

    $SessionKey = xorEncDec $session, $creds[$userObject.Name]


    return $UserTGT, $SessionKey
};


function ServiceAuthentication($userTGT, $encrypteddata) {

    $session = xorEncDec $userTGT $dc_pass

    $data = xorEncDec $encrypteddata $session

    $dataObject = ConvertFrom-Json $data

    $ServiceSession = GenerateSession

    # encrypt sessison key with user pass

    $SessionKey = xorEncDec $ServiceSession $creds[$dataobject.Name]

    $SQLTicket = xorEncDec $SessionKey $creds[$dataobject.Service]


    return $SQLTicket, $SessionKey
}






