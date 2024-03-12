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

function ServiceRequest($EncSession, $data) {
    
    $sessionKey = xorEncDec $EncSession $creds['ola.lap1']

    $dataToEncrypt = $data | ConvertTo-Json

    $encryptedData = xorEncDec $dataToEncrypt $sessionKey

    return $encryptedData

}


function serverRequest($message,  $sessionToken, $sqlTicket) {
    $tcpClient = New-Object System.Net.Sockets.TCPClient

    $tcpClient.Connect("127.0.0.1", 5005)

    $stream = $tcpClient.GetStream()

    $encryptedData = xorEncDec $message $sessionToken

    $messageToServer = @{
        "data" = @{
            "message" = $encryptedData
            "serviceTicket" = $sqlTicket
        }

    } | ConvertTo-Json
    $message = [System.Text.Encoding]::UTF8.GetBytes($messageToServer)

    Write-Host $messageToServer

    $stream.Write($message, 0, $message.Length)

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
$message = $data.substring(0, $messageLenght) | ConvertFrom-Json

Write-Host "This is " + $message.data


Write-Host "Received Message From DC"

if ($message.Type -eq "tgt") {
   
    $data =  @{
        "Name" = "ola.lap1"
        "Service" = "sql.service"
        "message" = "give me money, money"
    }
    $encryptedData = ServiceRequest $message.data.sessionkey $data

    $dataSend = @{
        "data"= @{
            "usertgt" = $message.data.usertgt
            "encryptedData" = $encryptedData
        }
        "Type" = "service"
    } | ConvertTo-Json

    $message = [System.Text.Encoding]::UTF8.GetBytes($dataSend)
    $stream.Write($message, 0, $message.Length)

    

    #Read Data
    # receive tgt and session ticket 
    $messageLenght = $stream.Read($storage, 0, $storage.Length)
    $data = [System.Text.Encoding]::UTF8.GetString($storage)
    $message = $data.substring(0, $messageLenght) | ConvertFrom-Json

    

    if ($message.Type -eq "serviceresponse") {
        <# Action when this condition is true #>
        $sessionKey = -join(xorEncDec $message.data.SessionKey $creds['ola.lap1'] | %{[char]$_})

        $messageToServer = @{
            "Message" = "Give me Money, Money"

        } | ConvertTo-Json

        
       
        $encryptedData = serverRequest $messageToServer $sessionKey $message.data.SQLTicket
        

        Write-Host $dataToSend

    }
        
}

elseif ($message.Type -eq "serviceresponse") {
    <# Action when this condition is true #>
    serverRequest
}









