#  Domain  Controller 
Import-Module .\encryption\enc-dec.ps1

$port = 12345

$chost = "127.0.0.1"

$listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Parse($chost), $port)
$listener.Start()

$creds = @{"ola.lap1" = "password1"; "adedayo.lap2" = "password2";
             "krbgtb" = "long-pass"; "sql.service"="iloveyou" }

$dc_pass = $users["krbgtb"]



Write-Host "Waiting for connection on port $port..."
while ($true) {

    $client = $listener.AcceptTcpClient()
    $stream = $client.GetStream()

    $reader = [System.IO.StreamReader]::new($stream)
    $writer = [System.IO.StreamReader]::new($stream)

    $message = receiveMessage $reader.ReadLine()

    if ($message.Type -eq "userauth") {
        $result = UserAuthentication $message
        sendMessage $writer $result
    }
    else {
        $result = ServiceAuthentication $message
        
        sendMessage $writer $result
    }

    $client.Close()
}

$listener.Stop()





function UserAuthentication($userObject) {
    # Base64 decryption

    $timestamp = xorEncDec $userObject.Data  $creds[$userObject.Name]  

    #if timestamp

    if ((get-date).Ticks - $timestamp -gt 1000) {
        return "Error"
    }

    $session = GenerateSession;

    # encrypt session with user pass and encrypt tct with krbgtg pass

    $UserTGT = xorEncDec $session $dc_pass

    $SessionKey = xorEncDec $session, $creds[$userObject.Name]


    return $UserTGT, $SessionKey
}


function ServiceAuthentication($userTGT, $encrypteddata){

    $session = xorEncDec $userTGT $dc_pass

    $data = xorEncDec $encrypteddata $session

    $dataObject = ConvertFrom-Json $data

    $ServiceSession = GenerateSession

    # encrypt sessison key with user pass

    $SessionKey = xorEncDec $ServiceSession $creds[$dataobject.Name]

    $SQLTicket = xorEncDec $SessionKey $creds[$dataobject.Service]


    return $SQLTicket, $SessionKey
}


function sendMessage ($writer,  $message){

    $message = $message | ConvertTo-Json
    $writer.WriteLine($message)
    $writer.Flush()

}

function  receiveMessage ($message){

    $message | ConvertFrom-Json
}



