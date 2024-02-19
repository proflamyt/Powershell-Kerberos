
## 
function xorEncDec ($cleartext, $password) {
    $ciphertext = @();

    for ($i = 0; $i -lt $cleartext.Count; $i++) {
        $ciphertext += $cleartext[$i] -bxor $password[$i % $password.Length];
    }
    return $ciphertext;
    
}



function GenerateSession() {
    $session = -join()
 
    return $session
 }