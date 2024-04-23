# Import the YamlDotNet module
Import-Module YamlDotNet

# Specify the relative path to the script file
$mainYamlPath = Join-Path -Path $PSScriptRoot -ChildPath "..\default\main.yaml"

# Read the main.yaml file and store its contents in the $main variable
$main = Import-Yaml -Path $mainYamlPath

# Pull variables from the main.yaml file
$ipRangeStart = $main.ipRangeStart
$ipRangeEnd = $main.ipRangeEnd

# Convert IP addresses to integers
$startIPBytes = [IPAddress]::Parse($ipRangeStart).GetAddressBytes()
$startIP = [IPAddress]::Parse($ipRangeStart).Address
$endIP = [IPAddress]::Parse($ipRangeEnd).Address

# Calculate the number of IP addresses in the range
$ipCount = $endIP - $startIP + 1

# Create an array of IP addresses
$ipAddresses = 1..$ipCount | ForEach-Object {
    $ip = $startIPBytes
    $ip[3] = $startIP + $_ - 1
    [IPAddress]::Parse($ip -join ".")
}

# Create a StringBuilder for the inventory content
$inventoryContent = New-Object System.Text.StringBuilder
$inventoryContent.AppendLine("[windows_hosts]")

# Add information about the Windows hosts to the inventory and dynamically create unique users and secure passwords for each host
foreach ($ip in $ipAddresses) {
    $admin = randomString(13)+ansible
    $adminPassword = randomString(2)+$+randomString(5)+`.+randomString(2)+`*+randomString(2)+`!+randomString(2)+`@+randomString(2)+`#
    $inventoryContent.AppendLine("windows10_ent+$ipCount ansible_host=$ip ansible_user=$admin ansible_password=$adminPassword ansible_port=5986 ansible_connection=winrm ansible_winrm_server_cert_validation=ignore ansible_winrm_transport=ntlm ansible_winrm_scheme=https ansible_winrm_operation_timeout_sec=60 ansible_winrm_read_timeout_sec=70")
}

# Save the inventory to a file
$inventoryContent.ToString() | Out-File -FilePath "..\inventory.ini" -Encoding UTF8