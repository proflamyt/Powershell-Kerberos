# User 

Import-Module .\encryption\enc-dec.ps1 -Force

$port = 12345

$chost = "127.0.0.1"

$tcpConnection = New-Object System.Net.Sockets.TcpClient($chost, $port)
$tcpStream = $tcpConnection.GetStream()
$reader = New-Object System.IO.StreamReader($tcpStream)
$writer = New-Object System.IO.StreamWriter($tcpStream)
$writer.AutoFlush = $true

$creds = @{"ola.lap1" = "password1"}

$authenticated = $false





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


while ($tcpConnection.Connected) {

    # send first request
    
    if ($authenticated -eq $false) {
        Write-Host "Sending First Authentication Request"
        $message = Authenticate; 
        sendMessage $writer "userauth" $message
        Write-Host "Sent"
        $authenticated = $true
    }
    # Receive response

    $message = receiveMessage $reader

    Write-Host "This is " + $message

    if ($message.Type -eq "tgt") {
        $data =  @{
            "message" = "give me money, money"
        }
        $encryptedData = ServiceRequest $message.data $data

        return $message.userTGT, $encryptedData
    }

    elseif ($message.Type -eq "svt") {
        <# Action when this condition is true #>
        serverRequest
    }

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