<#
.SYNOPSIS
    A script to test if a server is listening on a specific port.

.DESCRIPTION
    This script uses the System.Net.Sockets.TcpClient class to try to establish a TCP connection to a remote server on a specified port. 
    If the connection is successful, it indicates that the server is listening on that port.

.NOTES
    File Name      : PortTester.ps1
    Author         : Howard Pincham
    Date           : 4/8/2024
    Prerequisite   : PowerShell 5.1
    Tested         : Windows 10
#>


<#
.SYNOPSIS
    Tests if a server is listening on a specific port.

.DESCRIPTION
    This function tries to establish a TCP connection to a remote server on a specified port. 
    If the connection is successful, it returns true indicating that the server is listening on that port.

.PARAMETER RemoteServer
    The name or IP address of the remote server.

.PARAMETER Port
    The port number to test.

.EXAMPLE
    Test-PortListening -RemoteServer "localhost" -Port 80
    Tests if the local machine is listening on port 80.
#>
# Define the function to test if a server is listening on a specific port

Add-Type -AssemblyName System.Windows.Forms
function Test-PortListening {
    param (
        [string]$RemoteServer,
        [int]$Port
    )

    # Try to establish a TCP connection to the remote server on the specified port
    try {
        $tcpClient = New-Object System.Net.Sockets.TcpClient
        $tcpClient.Connect($RemoteServer, $Port)

        # If the connection is successful, return true indicating the port is listening
        if ($tcpClient.Connected) {
            return $true
        }
    }
    catch {
        # If an exception occurs, assume the port is not listening
        return $false
    }
    finally {
        # Close the TCP connection
        if ($tcpClient) {
            $tcpClient.Close()
        }
    }
}

# Create a new form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Port Listener Checker"
$form.Size = New-Object System.Drawing.Size(300,250)
$form.StartPosition = "CenterScreen"

# Add labels
$labelServer = New-Object System.Windows.Forms.Label
$labelServer.Location = New-Object System.Drawing.Point(10,20)
$labelServer.Size = New-Object System.Drawing.Size(225,20)
$labelServer.Text = "Enter server address:"
$form.Controls.Add($labelServer)

$labelPort = New-Object System.Windows.Forms.Label
$labelPort.Location = New-Object System.Drawing.Point(10,60)
$labelPort.Size = New-Object System.Drawing.Size(225,20)
$labelPort.Text = "Select or enter port number:"
$form.Controls.Add($labelPort)

# Add textboxes
$textboxServer = New-Object System.Windows.Forms.TextBox
$textboxServer.Location = New-Object System.Drawing.Point(10,40)
$textboxServer.Size = New-Object System.Drawing.Size(225,20)
$form.Controls.Add($textboxServer)

# Add dropdown for port numbers
$dropdownPort = New-Object System.Windows.Forms.ComboBox
$dropdownPort.Location = New-Object System.Drawing.Point(10,80)
$dropdownPort.Size = New-Object System.Drawing.Size(100,20)
$dropdownPort.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList

# Adding most common port numbers to the dropdown
$commonPorts = @(21, 22, 23, 25, 80, 110, 135, 443, 3389, 8080)
$commonPorts | ForEach-Object {
    $dropdownPort.Items.Add($_)
}

$form.Controls.Add($dropdownPort)

# Add textbox for custom port number
$textboxCustomPort = New-Object System.Windows.Forms.TextBox
$textboxCustomPort.Location = New-Object System.Drawing.Point(120,80)
$textboxCustomPort.Size = New-Object System.Drawing.Size(80,20)
$form.Controls.Add($textboxCustomPort)

# Add radio button to select custom port
$radioCustomPort = New-Object System.Windows.Forms.RadioButton
$radioCustomPort.Location = New-Object System.Drawing.Point(210,80)
$radioCustomPort.Size = New-Object System.Drawing.Size(100,20)
$radioCustomPort.Text = "Custom Port"
$radioCustomPort.Checked = $false
$radioCustomPort.Add_Click({
    $textboxCustomPort.Enabled = $radioCustomPort.Checked
    $dropdownPort.Enabled = (-not $radioCustomPort.Checked)
})
$form.Controls.Add($radioCustomPort)

# Add button
$button = New-Object System.Windows.Forms.Button
$button.Location = New-Object System.Drawing.Point(10,120)
$button.Size = New-Object System.Drawing.Size(100,40)
$button.Text = "Check Port"
$button.Add_Click({
    $server = $textboxServer.Text

    # Determine the selected port number
    $port = $null
    if ($radioCustomPort.Checked) {
        $customPort = $textboxCustomPort.Text
        if (-not [int]::TryParse($customPort, [ref]$null)) {
            [System.Windows.Forms.MessageBox]::Show("Please enter a valid custom port number.", "Invalid Port", "OK", [System.Windows.Forms.MessageBoxIcon]::Warning)
            return
        }
        $port = $customPort
    } else {
        $port = $dropdownPort.SelectedItem
    }

    # Perform port test
    if (-not $port) {
        [System.Windows.Forms.MessageBox]::Show("Please select or enter a port number.", "Invalid Port", "OK", [System.Windows.Forms.MessageBoxIcon]::Warning)
        return
    }

    if (Test-PortListening -RemoteServer $server -Port $port) {
        [System.Windows.Forms.MessageBox]::Show("The server $server is listening on port $port.", "Port Check Result", "OK", [System.Windows.Forms.MessageBoxIcon]::Information)
    } else {
        [System.Windows.Forms.MessageBox]::Show("The server $server is not listening on port $port.", "Port Check Result", "OK", [System.Windows.Forms.MessageBoxIcon]::Error)
    }
})
$form.Controls.Add($button)

# Show the form
$form.ShowDialog() | Out-Null
