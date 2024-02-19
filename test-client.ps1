# Define the server's IP address and port
$serverIpAddress = "127.0.0.1"
$serverPort = 12345

# Create a TcpClient object and connect to the server
$client = [System.Net.Sockets.TcpClient]::new()
$client.Connect($serverIpAddress, $serverPort)

# Get the network stream from the client
$stream = $client.GetStream()

# Create a StreamWriter to send messages to the server
$writer = [System.IO.StreamWriter]::new($stream)

# Send a message to the server
$message = "Hello, server! This is the client."
$writer.WriteLine($message)
$writer.Flush()

Write-Host "Message sent to server: $message"

# Close the TcpClient
$client.Close()
