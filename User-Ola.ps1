# User 

Import-Module .\encryption\enc-dec.ps1

$port = 50551

$chost = "127.0.0.1"

$tcpConnection = New-Object System.Net.Sockets.TcpClient($chost, $port)
$tcpStream = $tcpConnection.GetStream()
$reader = New-Object System.IO.StreamReader($tcpStream)
$writer = New-Object System.IO.StreamWriter($tcpStream)
$writer.AutoFlush = $true

$creds = @{"ola.lap1" = "password1"}

$authenticated = $false


Write-Host "Waiting for connection on port $port..."
while ($tcpConnection.Connected) {

    if ($authenticated -eq $false) {
        $message = Authenticate
        $writer.WriteLine($message)
        $writer.Flush()
        $authenticated = $true
    }

    $message  =  receiveMessage $reader

    if ($message["Type"] -eq "tgt") {
        $data =  @{
            "message" = "give me money, money"
        }
        $encryptedData = ServiceRequest $message.data $data

        return $message.userTGT, $encryptedData
    }

    elseif ($message["Type"] -eq "svt") {
        <# Action when this condition is true #>
        serverRequest
    }

}




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