[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$Instance,

    [ValidatePattern('^BTL2_P3_DEMO(?:_[A-Za-z0-9_]{1,40})?$')]
    [string]$DatabaseName = ('BTL2_P3_DEMO_' + [Guid]::NewGuid().ToString('N').Substring(0, 12)),

    [switch]$TrustServerCertificate
)

$ErrorActionPreference = 'Stop'
$sqlcmd = (Get-Command sqlcmd -CommandType Application).Source
$sqlArgs = @('-S', $Instance, '-E', '-b', '-f', '65001')
if ($TrustServerCertificate) { $sqlArgs += '-C' }

$aggregate = Join-Path $PSScriptRoot 'BTL2_SQL_TONG_HOP.sql'
$metadata = Join-Path $PSScriptRoot '03_Kiem_tra_doi_tuong_Phan2.sql'
foreach ($file in $aggregate, $metadata) {
    if (!(Test-Path -LiteralPath $file -PathType Leaf)) {
        throw "Missing SQL file: $file"
    }
}

$source = [IO.File]::ReadAllText($aggregate, [Text.Encoding]::UTF8)
if (!$source.Contains('USE [BTL2_FIX_12345];')) {
    throw 'Unexpected database name in the aggregate SQL script.'
}

$tempFile = [IO.Path]::GetTempFileName()
try {
    [IO.File]::WriteAllText($tempFile,
        $source.Replace('BTL2_FIX_12345', $DatabaseName), [Text.UTF8Encoding]::new($false))

    & $sqlcmd @sqlArgs -d master -i $tempFile
    if ($LASTEXITCODE -ne 0) {
        throw 'Aggregate SQL failed. Object verification was skipped.'
    }

    & $sqlcmd @sqlArgs -d $DatabaseName -i $metadata
    if ($LASTEXITCODE -ne 0) { throw 'SQL object verification failed.' }

    $verifySeed = @'
SET NOCOUNT ON;
IF (SELECT COUNT(*) FROM dbo.DANH_MUC_MON) <> 6
    OR (SELECT COUNT(*) FROM dbo.MON) <> 7
    OR (SELECT COUNT(*) FROM dbo.SIZE_MON) <> 13
    OR (SELECT COUNT(*) FROM dbo.CA_LAM WHERE NgayLam = '20261113') <> 2
    THROW 51900, 'Unexpected demo row counts.', 1;

IF ISNULL(dbo.fn_N5_DemLuaChonTheoDanhMuc('DM_DOUONG'), -1) <> 8
    OR ISNULL(dbo.fn_N5_TonKhoDenThoiDiem('HH_KIEMTHU', '20261130'), -1) <> 8
    THROW 51901, 'Unexpected demo function results.', 1;

PRINT 'Sample verified: 6 categories, 7 items, 13 sizes, 2 shifts on 2026-11-13.';
'@
    & $sqlcmd @sqlArgs -d $DatabaseName -Q $verifySeed
    if ($LASTEXITCODE -ne 0) { throw 'Demo data verification failed.' }

    Write-Output "Demo database is ready. DB_NAME=$DatabaseName"
} finally {
    Remove-Item -LiteralPath $tempFile
}
