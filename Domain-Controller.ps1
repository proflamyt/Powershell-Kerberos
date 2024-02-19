#  Domain  Controller 
Import-Module .\encryption\enc-dec.ps1


$Listener = [System.Net.Sockets.TcpListener] 1234;

$Listener.Start()

while ($true) {
    $client = $Listener.AcceptTcpClient()
    $client.Close()
    
}
$creds = @{"ola.lap1" = "password1"; "adedayo.lap2" = "password2";
             "krbgtb" = "long-pass"; "sql.service"="iloveyou" }

$dc_pass = $users["krbgtb"]


function UserAuthentication($user) {
    # Base64 decryption

    $userobject = ConvertFrom-Json $user

    $timestamp = xorEncDec($userobject.Data , $creds[$userobject.Name])   

    #if timestamp

    # on 
    $session = GenerateSession;

    # encrypt session with user pass and encrypt tct with krbgtg pass

    $UserTGT = xorEncDec($session, $dc_pass)

    $SessionKey = xorEncDec($session, $creds[$userobject.Name])


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



