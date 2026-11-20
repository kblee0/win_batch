<#
.SYNOPSIS
    Hyper-V PowerShell 모듈을 사용하여 VHD 파일의 용량을 확장하거나 축소합니다.
.DESCRIPTION
    Hyper-V 모듈의 Resize-VHD, Get-VHD 등을 사용하여 VHD의 가상 크기를 감지 및 조정합니다.
    용량 축소 시 -o 옵션을 주면 파티션 내부 조각 모음(Defrag)을 먼저 수행하여 축소 성공률을 극대화합니다.
.PARAMETER ImagePath
    VHD 파일의 전체 경로입니다.
.PARAMETER SizeGB
    최종 목표 용량 (GB 단위 정수)
.PARAMETER Optimize
    [-o] 용량 축소 시 파일들을 디스크 앞쪽으로 정렬하는 파티션 최적화(Defrag)를 먼저 수행합니다.
.EXAMPLE
    .\VHD-Resize.ps1 "C:\VMs\disk.vhd" 50 -o
#>

param(
    [Parameter(Position = 0)]
    [string]$VhdPath,

    [Parameter(Position = 1)]
    [string]$TargetSizeGB,

    [switch]$o
)

$ErrorActionPreference = 'Stop'

# ============================================================
# 설정
# ============================================================
$MB = 1MB
$GB = 1GB
$ReservedSize = 1MB

$Mounted = $false
$DiskNumber = $null

# ============================================================
# 사용법
# ============================================================
function Show-Usage {
    Write-Host ""
    Write-Host "VHD-Resize.ps1 <vhd file path> <target size (GB)> [-o]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -o    파티션 축소 전 최적화 수행"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\VHD-Resize.ps1 D:\Data.vhdx 100"
    Write-Host "  .\VHD-Resize.ps1 D:\Data.vhdx 50"
    Write-Host "  .\VHD-Resize.ps1 D:\Data.vhdx 50 -o"
    Write-Host ""
}

# ============================================================
# 출력
# ============================================================
function Write-Info($Message) {
    Write-Host "[INFO] $Message" -ForegroundColor Cyan
}

function Write-OK($Message) {
    Write-Host "[ OK ] $Message" -ForegroundColor Green
}

function Write-Warn($Message) {
    Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

# ============================================================
# VHD Mount / Dismount
# ============================================================
function Mount-TargetVhd {
    $vhd = Mount-VHD -Path $VhdPath -Passthru
    return $vhd.DiskNumber
}

function Dismount-TargetVhd {
    Dismount-VHD -Path $VhdPath
}

# ============================================================
# 마지막 파티션 조회
# ============================================================
function Get-LastPartition {
    param(
        [Parameter(Mandatory)]
        [int]$DiskNumber
    )

    $partitions = @(
        Get-Partition -DiskNumber $DiskNumber |
            Sort-Object Offset
    )

    if ($partitions.Count -eq 0) {
        throw "VHD에 파티션이 없습니다."
    }

    return $partitions[-1]
}

# ============================================================
# 마지막 파티션 최대 확장
# VHD 크기에 맞춰 확장 가능한 최대 크기로 변경
# ============================================================

function Expand-LastPartitionToMax {
    param(
        [Parameter(Mandatory)]
        [int]$DiskNumber
    )

    $last = Get-LastPartition -DiskNumber $DiskNumber

    $supported = Get-PartitionSupportedSize `
        -DiskNumber $DiskNumber `
        -PartitionNumber $last.PartitionNumber

    # 실제 확장 가능 크기 계산
    $ExpandSize = [long]($supported.SizeMax - $last.Size)

    # 최소 확장 크기: 1MB
    if ($ExpandSize -ge 1MB) {

        Write-Info "마지막 파티션 최대 확장"
        Write-Info "현재 크기 : $([math]::Round($last.Size / $GB, 3)) GB"
        Write-Info "확장 크기 : $([math]::Round($supported.SizeMax / $GB, 3)) GB"
        Write-Info "확장 가능 : $([math]::Round($ExpandSize / 1KB, 2)) KB"

        Resize-Partition `
            -DiskNumber $DiskNumber `
            -PartitionNumber $last.PartitionNumber `
            -Size $supported.SizeMax

        Write-OK "마지막 파티션 확장 완료"
    }
    else {
        Write-Info "추가 확장 공간이 1MB 미만입니다. 확장 생략."
    }
}

# ============================================================
# 파티션 확장
# 1. VHD 크기 증가
# 2. VHD Mount
# 3. 마지막 파티션 최대 확장
# ============================================================
function Expand-Partition {
    param(
        [Parameter(Mandatory)]
        [long]$TargetBytes
    )

    Write-Info "VHD 확장 작업 시작"

    # VHD Dismount
    Dismount-TargetVhd
    $script:Mounted = $false

    # VHD 크기 변경
    Resize-VHD -Path $VhdPath -SizeBytes $TargetBytes

    Write-OK "VHD 크기 증가 완료"

    # VHD Mount
    $script:DiskNumber = Mount-TargetVhd
    $script:Mounted = $true

    # 마지막 파티션 최대 확장
    Expand-LastPartitionToMax -DiskNumber $script:DiskNumber
}

# ============================================================
# 파티션 축소
# 1. (옵션) 파티션 최적화
# 2. 마지막 파티션 축소
# 3. VHD 크기 축소
# 4. 마지막 파티션 최대 확장
# ============================================================
function Shrink-Partition {
    param(
        [Parameter(Mandatory)]
        [long]$TargetBytes,

        [Parameter(Mandatory)]
        [bool]$Optimize
    )

    Write-Info "VHD 축소 작업 시작"

    $last = Get-LastPartition -DiskNumber $script:DiskNumber

    # --------------------------------------------------------
    # 파티션 최적화
    # --------------------------------------------------------
    if ($Optimize) {

        Write-Info "파티션 최적화 시작"

        $volume = Get-Volume -Partition $last

        if (-not $volume.DriveLetter) {
            throw "-o 옵션 사용 시 마지막 파티션에 드라이브 문자가 필요합니다."
        }

        if ($volume.FileSystem -ne 'NTFS') {
            throw "-o 옵션은 NTFS 파티션만 지원합니다."
        }

        Optimize-Volume `
            -DriveLetter $volume.DriveLetter `
            -Defrag `
            -Verbose

        Write-OK "파티션 최적화 완료"
    }

    # --------------------------------------------------------
    # 축소 가능 크기 확인
    # --------------------------------------------------------
    $supported = Get-PartitionSupportedSize `
        -DiskNumber $script:DiskNumber `
        -PartitionNumber $last.PartitionNumber

    # 목표 VHD 크기에 맞는 파티션 크기 계산
    $TargetPartitionSize = [long](
        [math]::Floor(
            ($TargetBytes - $last.Offset - $ReservedSize) / $MB
        ) * $MB
    )

    Write-Info "현재 파티션 : $([math]::Round($last.Size / $GB, 2)) GB"
    Write-Info "최소 가능 크기 : $([math]::Round($supported.SizeMin / $GB, 2)) GB"
    Write-Info "목표 파티션 : $([math]::Round($TargetPartitionSize / $GB, 2)) GB"

    if ($TargetPartitionSize -lt $supported.SizeMin) {
        throw "목표 크기로 축소할 수 없습니다. 파티션 최소 크기를 초과했습니다."
    }

    if ($TargetPartitionSize -ge $last.Size) {
        throw "마지막 파티션을 축소할 수 없습니다. 목표 크기를 확인하세요."
    }

    # --------------------------------------------------------
    # 마지막 파티션 축소
    # --------------------------------------------------------
    Write-Info "마지막 파티션 축소 시작"

    Resize-Partition `
        -DiskNumber $script:DiskNumber `
        -PartitionNumber $last.PartitionNumber `
        -Size $TargetPartitionSize

    Write-OK "마지막 파티션 축소 완료"

    # --------------------------------------------------------
    # VHD Dismount 및 크기 축소
    # --------------------------------------------------------
    Dismount-TargetVhd
    $script:Mounted = $false

    Resize-VHD -Path $VhdPath -SizeBytes $TargetBytes
    Write-Info "Resize-VHD $TargetBytes"
    Write-OK "VHD 크기 감소 완료"

    # --------------------------------------------------------
    # VHD 재마운트
    # --------------------------------------------------------
    $script:DiskNumber = Mount-TargetVhd
    $script:Mounted = $true

    # 마지막 파티션 최대 확장
    Expand-LastPartitionToMax -DiskNumber $script:DiskNumber
}

# ============================================================
# Main
# ============================================================
try {

    # --------------------------------------------------------
    # 파라미터 검사
    # --------------------------------------------------------
    if (
        [string]::IsNullOrWhiteSpace($VhdPath) -or
        [string]::IsNullOrWhiteSpace($TargetSizeGB) -or
        $args.Count -gt 0
    ) {
        Show-Usage
        return
    }

    $parsedSize = 0.0

    if (
        -not [double]::TryParse(
            $TargetSizeGB,
            [Globalization.NumberStyles]::Float,
            [Globalization.CultureInfo]::InvariantCulture,
            [ref]$parsedSize
        ) -or
        $parsedSize -le 0
    ) {
        Show-Usage
        return
    }

    if ($parsedSize -gt 65536) {
        Show-Usage
        return
    }

    # --------------------------------------------------------
    # 관리자 권한 확인
    # --------------------------------------------------------
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)

    if (-not $principal.IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator
    )) {
        throw "관리자 권한으로 실행해야 합니다."
    }

    # --------------------------------------------------------
    # 필수 명령 확인
    # --------------------------------------------------------
    Import-Module Hyper-V -ErrorAction Stop

    foreach ($cmd in @(
        'Get-VHD',
        'Resize-VHD',
        'Mount-VHD',
        'Dismount-VHD',
        'Get-Partition',
        'Get-PartitionSupportedSize',
        'Resize-Partition'
    )) {
        if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
            throw "필수 명령을 찾을 수 없습니다: $cmd"
        }
    }

    # --------------------------------------------------------
    # VHD 파일 확인
    # --------------------------------------------------------
    if (-not (Test-Path -LiteralPath $VhdPath -PathType Leaf)) {
        throw "VHD 파일을 찾을 수 없습니다: $VhdPath"
    }

    $VhdPath = (Resolve-Path -LiteralPath $VhdPath).Path

    $TargetBytes = [long](
        [math]::Ceiling(($parsedSize * $GB) / $MB) * $MB
    )

    $vhd = Get-VHD -Path $VhdPath

    # Differencing VHD는 제외
    if ($vhd.VhdType -eq 'Differencing') {
        throw "Differencing VHD는 지원하지 않습니다."
    }

    if ($vhd.VhdType -notin @('Dynamic', 'Fixed')) {
        throw "지원하지 않는 VHD 유형입니다: $($vhd.VhdType)"
    }

    if ($vhd.IsAttached) {
        throw "VHD가 이미 마운트되어 있습니다."
    }

    $CurrentBytes = [long]$vhd.Size

    Write-Host ""
    Write-Host "VHD       : $VhdPath"
    Write-Host "현재 크기 : $([math]::Round($CurrentBytes / $GB, 2)) GB"
    Write-Host "목표 크기 : $([math]::Round($TargetBytes / $GB, 2)) GB"
    Write-Host ""

    # --------------------------------------------------------
    # 동일 크기 검사
    # --------------------------------------------------------
    if ($CurrentBytes -eq $TargetBytes) {
        Write-Warn "현재 크기와 목표 크기가 동일합니다."
        return
    }

    if ($TargetBytes -lt 1GB) {
        throw "목표 VHD 크기는 최소 1GB 이상이어야 합니다."
    }

    # --------------------------------------------------------
    # VHD Mount 및 마지막 파티션 확인
    # --------------------------------------------------------
    $DiskNumber = Mount-TargetVhd
    $Mounted = $true

    $disk = Get-Disk -Number $DiskNumber

    if ($disk.IsReadOnly) {
        throw "VHD 디스크가 읽기 전용입니다."
    }

    $last = Get-LastPartition -DiskNumber $DiskNumber

    Write-Info "Disk Number : $DiskNumber"
    Write-Info "Partition   : $($last.PartitionNumber)"
    Write-Info "Type        : $($last.Type)"

    if ($last.Type -ne 'Basic') {
        throw "마지막 파티션이 Basic 타입이 아닙니다."
    }

    # --------------------------------------------------------
    # 확장 / 축소 분기
    # --------------------------------------------------------
    if ($TargetBytes -gt $CurrentBytes) {

        Expand-Partition -TargetBytes $TargetBytes

    }
    else {

        Shrink-Partition `
            -TargetBytes $TargetBytes `
            -Optimize ([bool]$o)
    }

    # --------------------------------------------------------
    # 완료
    # --------------------------------------------------------
    Dismount-TargetVhd
    $Mounted = $false

    $result = Get-VHD -Path $VhdPath

    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-OK "VHD Resize 작업 완료"
    Write-Host "최종 크기 : $([math]::Round($result.Size / $GB, 2)) GB"
    Write-Host "========================================" -ForegroundColor Green

}
catch {

    Write-Host ""
    Write-Host "[ERROR] $($_.Exception.Message)" -ForegroundColor Red
    exit 1

}
finally {

    if ($Mounted) {
        try {
            Dismount-TargetVhd
            Write-Info "VHD 마운트 해제 완료"
        }
        catch {
            Write-Warn "VHD 마운트 해제 실패: $($_.Exception.Message)"
        }
    }
}
