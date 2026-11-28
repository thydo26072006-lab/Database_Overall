param(
    [Parameter(Mandatory = $true)][string]$Instance,
    [Parameter(Mandatory = $true)][string]$Database
)

$ErrorActionPreference = 'Stop'
[Console]::InputEncoding = New-Object System.Text.UTF8Encoding($false)
[Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false)

$settings = New-Object System.Data.SqlClient.SqlConnectionStringBuilder
$settings['Data Source'] = $Instance
$settings['Initial Catalog'] = $Database
$settings['Integrated Security'] = $true
$settings['TrustServerCertificate'] = $true
$settings['Connect Timeout'] = 5
$connection = New-Object System.Data.SqlClient.SqlConnection($settings.ConnectionString)

try {
    $inputData = [Console]::In.ReadToEnd() | ConvertFrom-Json
    $connection.Open()
    $command = $connection.CreateCommand()
    $command.CommandText = $inputData.text
    foreach ($entry in $inputData.parameters.PSObject.Properties) {
        if ($entry.Value -is [ValueType]) {
            $parameter = $command.Parameters.Add($entry.Name, [System.Data.SqlDbType]::BigInt)
            $parameter.Value = [long]$entry.Value
        } else {
            $parameter = $command.Parameters.Add($entry.Name, [System.Data.SqlDbType]::NVarChar, 200)
            $parameter.Value = [string]$entry.Value
        }
    }

    $reader = $command.ExecuteReader()
    $rows = while ($reader.Read()) {
        $row = [ordered]@{}
        for ($column = 0; $column -lt $reader.FieldCount; $column++) {
            $name = $reader.GetName($column)
            if ($reader.IsDBNull($column)) {
                $row[$name] = $null
            } else {
                $row[$name] = $reader.GetValue($column)
            }
        }
        [pscustomobject]$row
    }
    $reader.Close()
    ConvertTo-Json -InputObject @($rows | Where-Object { $null -ne $_ }) -Compress
} catch {
    $errorDetails = $_.Exception.GetBaseException()
    @{ error = @{ number = $errorDetails.Number; message = $errorDetails.Message } } | ConvertTo-Json -Compress
    exit 1
} finally {
    $connection.Dispose()
}
