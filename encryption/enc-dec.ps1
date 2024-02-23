
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
    $message = $message | ConvertTo-Json
    $writer.WriteLine($message)
    $writer.Flush()

}


function  receiveMessage ($reader){
    $message = $reader.ReadLine()
    $message | ConvertFrom-Json
}