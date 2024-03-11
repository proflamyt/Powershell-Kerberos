# User 
Import-Module .\encryption\enc-dec.ps1 -Force

$creds = @{"ola.lap1" = "password1"}
$authenticated = $false


$client = [System.Net.Sockets.TcpClient]::new()
$client.Connect($dcHost, $dcPort)

$stream = $client.GetStream()


function Authenticate {
    $date = (get-date).Ticks;
    $encryptedData =  xorEncDec "$date" $creds['ola.lap1']
    $userRequest = @{
        Name = "ola.lap1"
        Data = $encryptedData
    }
    $userRequestObject = $userRequest | ConvertTo-Json
    return $userRequestObject
}


# authenticate with timestamp
$data = Authenticate
$message = [System.Text.Encoding]::UTF8.GetBytes($data)


$stream.Write($message, 0, $message.Length)
# send first request


if ($authenticated -eq $false) {
    Write-Host "Sending First Authentication Request"
    $message = Authenticate; 
    sendMessage  "userauth" $message
    $authenticated = $true
}


# receive tgt and session ticket 
$messageLenght = $stream.Read($storage, 0, $storage.Length)
$data = [System.Text.Encoding]::UTF8.GetString($storage)
$message = $data.substring(0, $messageLenght)

Write-Host "This is " + $message 

if ($message.Type -eq "tgt") {
    $data =  @{
        "message" = "give me money, money"
    }
    $encryptedData = ServiceRequest $message.data.sessionkey $data

    return $message.userTGT, $encryptedData
}

elseif ($message.Type -eq "svt") {
    <# Action when this condition is true #>
    serverRequest
}




function ServiceRequest($EncSession, $data) {
    
    $sessionKey = xorEncDec $EncSession $creds['ola.lap1']

    $encryptedData = $data | ConvertTo-Json

    $encrypted = xorEncDec $encryptedData $creds['ola.lap1']

    return $encrypted

}


# $tcpClient = New-Object System.Net.Sockets.TCPClient
# $tcpClient.Connect("127.0.0.1",7)

function serverRequest($data , $sessionKey) {

    $sessionToken = xorEncDec $sessionKey $creds['ola.lap1']

    $encryptedData = xorEncDec $data $sessionToken

    return $encryptedData

}