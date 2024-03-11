#  Domain  Controller 
Import-Module .\encryption\enc-dec.ps1 -Force


$listener = [System.Net.Sockets.TcpListener]::new($dcHost, $dcPort)
$listener.Start()
$client = $listener.AcceptTcpClient()
$stream = $client.GetStream()

$creds = @{"ola.lap1" = "password1"; "adedayo.lap2" = "password2";
             "krbgtb" = "long-pass"; "sql.service"="iloveyou" }

$dc_pass = $creds["krbgtb"]




Write-Host "Waiting for connection on port $dcPort..."



# Reader for receiving data


function UserAuthentication($userObject) {
    # Base64 decryption
    $userObject = $userObject | ConvertFrom-Json

    $timestamp = xorEncDec $userObject.Data  $creds[$userObject.Name]  

    $ola =  [bigint]-join($timestamp | %{[char]$_})

    # if ((get-date).Ticks - $ola -gt 1000) {
    #     return "Error"
    # }
    $session = GenerateSession;
    # encrypt session with user pass and encrypt tct with krbgtg pass
    $UserTGT = xorEncDec $session $dc_pass
    $SessionKey = xorEncDec $session $creds[$userObject.Name]
    $send =  @{
    "Type" = "tgt"
    "data" = @{
        "usertgt" = $UserTGT
        "sessionkey" = $SessionKey
    }
}
    return $send
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


# receive user ticket 
$messageLenght = $stream.Read($storage, 0, $storage.Length)

$data = [System.Text.Encoding]::UTF8.GetString($storage)
$message = $data.substring(0, $messageLenght) 

Write-Host $message
Write-Host "Received"

$data = UserAuthentication $message | ConvertTo-Json

$tosend = [System.Text.Encoding]::UTF8.GetBytes($data)
$stream.Write($tosend, 0, $tosend.Length)


# Another 
$messageLenght = $stream.Read($storage, 0, $storage.Length)

$data = [System.Text.Encoding]::UTF8.GetString($storage)
$message = $data.substring(0, $messageLenght)  | ConvertFrom-Json



IF ($message.Type -eq "userauth") {
    $result = UserAuthentication $message.data
    
}
Else {
    $result = ServiceAuthentication $message.data[0] $message.data[1] 
    sendMessage $writer "svt" $result
}

$client.Close()
$listener.Stop()









