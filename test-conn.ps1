# Define the port number to listen on
$port = 12345

# Create a TcpListener object and start listening on the loopback address
$listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Parse("127.0.0.1"), $port)
$listener.Start()

Write-Host "Waiting for connection on port $port..."
while ($true) {
    # Accept the incoming connection
    $client = $listener.AcceptTcpClient()
    $stream = $client.GetStream()

    # Create a StreamReader to read messages from the stream
    $reader = [System.IO.StreamWriter]::new($stream)

    # Read the message from the stream
    $message = $reader.ReadLine()

    Write-Host "Received message: $message"

    $client.Close()

}

# Close the TcpListener and TcpClient
$listener.Stop()

