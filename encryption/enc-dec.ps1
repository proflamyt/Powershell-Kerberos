
## 
function xorEncDec ($cleartext, $password) {
    $cleartext = $cleartext.toCharArray()
    $ciphertext = @();

    for ($i = 0; $i -lt $cleartext.Count; $i++) {
        $ciphertext += $cleartext[$i] -bxor $password[$i % $password.Length];
    }
    return $ciphertext;
    
}



function GenerateSession() {
    $session = -join((65..90) + (97..122) | Get-Random -Count 6 | %{[char]$_})
 
    return $session
 }



 function sendMessage ($writer, $type, $message){
    $message =  @{
        "Type"= $type
        "data" = $message
    }
    $Jsonmessage = $message | ConvertTo-Json
    $writer.Write($Jsonmessage)
    $writer.Flush()
    $writer.close()
}


function  receiveMessage ($reader){
    $message = $reader.ReadToEnd()
    $message | ConvertFrom-Json
    $reader.close()
}