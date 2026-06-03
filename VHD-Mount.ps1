<#
.SYNOPSIS
    VHD/VHDX 가상 디스크 마운트/언마운트 스크립트

USAGE
    VHD-Mount.ps1 [-r] <Image Path> <Mount Path>
    VHD-Mount.ps1 -u <Image Path>

EXAMPLES
    .\VHD-Mount.ps1 D:\img\data.vhdx D:
    .\VHD-Mount.ps1 D:\img\data.vhdx D:\
    .\VHD-Mount.ps1 D:\img\data.vhdx C:\Mount\Data
    .\VHD-Mount.ps1 -r D:\img\data.vhdx M:
    .\VHD-Mount.ps1 -u D:\img\data.vhdx
#>

[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$ImagePath,

    [Parameter(Position = 1)]
    [string]$TargetPath,

    [switch]$u,
    [switch]$r
)

# ---------------------------------------------------------
# 관리자 권한 확인
# ---------------------------------------------------------
if (-not (
    New-Object Security.Principal.WindowsPrincipal(
        [Security.Principal.WindowsIdentity]::GetCurrent()
    )
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {

    Write-Host "`n[오류] 관리자 권한이 필요합니다.`n" -ForegroundColor Red
    exit 1
}

# ---------------------------------------------------------
# 사용법 출력
# ---------------------------------------------------------
function Show-Usage {

    Write-Host @"

Usage:
  VHD-Mount.ps1 [-r] <Image Path> <Drive Letter | Mount Path>
  VHD-Mount.ps1 -u <Image Path>

Options:
  -r    ReadOnly 모드
  -u    언마운트

Examples:
  .\VHD-Mount.ps1 D:\img\data.vhdx D:
  .\VHD-Mount.ps1 D:\img\data.vhdx D:\
  .\VHD-Mount.ps1 D:\img\data.vhdx C:\Mount\Data
  .\VHD-Mount.ps1 -r D:\img\data.vhdx M:
  .\VHD-Mount.ps1 -u D:\img\data.vhdx

"@
    exit 1
}

# ---------------------------------------------------------
# AccessPath 제거
# ---------------------------------------------------------
function Remove-AllPartitionAccessPaths {
    param(
        [Parameter(Mandatory)]
        $Partition
    )

    foreach ($path in $Partition.AccessPaths) {
        # GUID Volume 경로 제외
        if ($path -like "\\*") {
            continue
        }
        Remove-PartitionAccessPath `
            -DiskNumber $Partition.DiskNumber `
            -PartitionNumber $Partition.PartitionNumber `
            -AccessPath $path `
            -Confirm:$false `
            -ErrorAction SilentlyContinue
    }
}

# ---------------------------------------------------------
# 파라미터 검증
# ---------------------------------------------------------
if ([string]::IsNullOrWhiteSpace($ImagePath)) {
    Show-Usage
}

if (-not $u -and [string]::IsNullOrWhiteSpace($TargetPath)) {
    Show-Usage
}

# ---------------------------------------------------------
# VHD 경로 확인
# ---------------------------------------------------------
try {
    $ImagePath = (Resolve-Path $ImagePath -ErrorAction Stop).Path
}
catch {
    Write-Host "`n[오류] VHD 파일을 찾을 수 없습니다:`n$ImagePath`n" -ForegroundColor Red
    exit 1
}

# ---------------------------------------------------------
# 언마운트
# ---------------------------------------------------------
if ($u) {
    try {
        Write-Host "`n언마운트 중..." -ForegroundColor Cyan
        Write-Host "  $ImagePath`n"

        $img = Get-DiskImage -ImagePath $ImagePath -ErrorAction Stop

        if ($img.Attached) {
            $disk = $img | Get-Disk
            foreach ($partition in (Get-Partition -DiskNumber $disk.Number)) {
                Remove-AllPartitionAccessPaths $partition
            }
            Dismount-DiskImage `
                -ImagePath $ImagePath `
                -ErrorAction Stop
        }

        Write-Host "언마운트 완료.`n" -ForegroundColor Green
        exit 0
    }
    catch {
        Write-Host "`n[오류] $_`n" -ForegroundColor Red
        exit 1
    }
}

# ---------------------------------------------------------
# 마운트
# ---------------------------------------------------------
try {
    $accessMode = if ($r) { "ReadOnly" } else { "ReadWrite" }

    Write-Host "`n마운트 중 ($accessMode)..." -ForegroundColor Cyan
    Write-Host "  $ImagePath`n"

    $diskImage = Mount-DiskImage `
        -ImagePath $ImagePath `
        -Access $accessMode `
        -NoDriveLetter `
        -PassThru `
        -ErrorAction Stop

    $disk = $diskImage | Get-Disk

    $partition = Get-Partition -DiskNumber $disk.Number |
        Where-Object Type -eq "Basic" |
        Select-Object -First 1

    if (-not $partition) {
        throw "Basic 파티션을 찾을 수 없습니다."
    }

    # 기존 마운트 제거
    Remove-AllPartitionAccessPaths $partition

    $target = $TargetPath.Trim()

    if (-not $target.EndsWith("\")) {
        $target += "\"
    }
    Write-Host "마운트: $target`n"

    Add-PartitionAccessPath `
        -DiskNumber $partition.DiskNumber `
        -PartitionNumber $partition.PartitionNumber `
        -AccessPath $target `
        -ErrorAction Stop

    Write-Host "마운트 완료.`n" -ForegroundColor Green
}
catch {
    Write-Host "`n[오류] $_`n" -ForegroundColor Red
    if ($diskImage) {
        Dismount-DiskImage `
            -ImagePath $ImagePath `
            -ErrorAction SilentlyContinue
    }
    exit 1
}
