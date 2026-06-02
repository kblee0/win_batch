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

param (
    [Parameter(Position=0, Mandatory=$false)]
    [string]$ImagePath,

    [Parameter(Position=1, Mandatory=$false)]
    [int]$SizeGB,

    [Alias("o")]
    [Switch]$Optimize
)

# ---------------------------------------------------------
# Hyper-V PowerShell 모듈 로드
# ---------------------------------------------------------
try {
    Import-Module Hyper-V -ErrorAction Stop
} catch {
    Write-Error "Hyper-V PowerShell 모듈을 로드할 수 없습니다. Hyper-V 기능이 설치되어 있는지 확인하세요."
    Exit
}

function Ensure-VhdUnmounted {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    try {
        $currentVhd = Get-VHD -Path $Path -ErrorAction Stop
        if ($currentVhd.Attached) {
            Write-Host "이미 마운트된 VHD를 언마운트합니다: $Path" -ForegroundColor Yellow
            Dismount-VHD -Path $Path -ErrorAction Stop
            Start-Sleep -Seconds 1
        }
    } catch {
        if ($_ -and $_.Exception -and $_.Exception.Message -match 'Cannot find virtual hard disk') {
            return
        }
        throw
    }
}

# ----------------------------------------------------
# [1] 파라미터 유효성 검사 및 사용법 출력
# ----------------------------------------------------
if ([string]::IsNullOrEmpty($ImagePath) -or $SizeGB -le 0 -or -not (Test-Path -Path $ImagePath)) {
    Write-Host ""
    Write-Host "사용법 (Usage):" -ForegroundColor Cyan
    Write-Host "  .\VHD-Resize.ps1 <VHD 파일 경로> <목표 용량(GB)> [-o]" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "옵션 설명:" -ForegroundColor Gray
    Write-Host "  -o, -Optimize : 축소 작업 전 파티션 내부 조각 모음을 수행하여 최대한으로 용량을 줄입니다."
    Write-Host ""
    Write-Host "예시 (Example):" -ForegroundColor Cyan
    Write-Host "  .\VHD-Resize.ps1 `"C:\Virtual\my_disk.vhd`" 40 -o"
    Write-Host ""
    if (-not [string]::IsNullOrEmpty($ImagePath) -and -not (Test-Path -Path $ImagePath)) {
        Write-Error "입력하신 파일 경로를 찾을 수 없습니다: $ImagePath"
    }
    Exit
}

# 관리자 권한 필수 검사
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($identity)
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "이 스크립트는 반드시 [관리자 권한]으로 실행되어야 합니다."
    Exit
}

# ---------------------------------------------------------
# [2] VHD 가상 크기 자동 감지 및 안전장치
# ---------------------------------------------------------
Write-Host "VHD 파일 분석 중..." -ForegroundColor Cyan

# 절대경로 확보
$absolutePath = (Get-Item $ImagePath).FullName

Ensure-VhdUnmounted -Path $absolutePath

# Hyper-V 모듈으로 VHD 정보 조회
try {
    $vhdInfo = Get-VHD -Path $absolutePath -ErrorAction Stop
    $currentSizeMB = [int]($vhdInfo.Size / 1MB)
} catch {
    Write-Error "오류: Hyper-V Get-VHD를 통한 VHD 크기 조회가 실패했습니다."
    Write-Host "데이터 안전을 위해 종료합니다." -ForegroundColor LightMagenta
    Exit
}

# 크기 조회 실패 시 강제 진행을 차단하고 안전 종료 (데이터 유실 방지)
if ($currentSizeMB -eq 0) {
    Write-Error "오류: VHD 크기 조회가 실패했습니다."
    Write-Host "데이터 안전을 위해 종료합니다." -ForegroundColor LightMagenta
    Exit
}

$targetSizeMB  = $SizeGB * 1024
$currentSizeGB  = [math]::Round($currentSizeMB / 1024, 2)

Write-Host "------------------------------------------------"
Write-Host "VHD 경로    : $absolutePath"
Write-Host "현재 크기   : $currentSizeGB GB ($currentSizeMB MB)"
Write-Host "목표 크기   : $SizeGB GB ($targetSizeMB MB)"

if ($targetSizeMB -eq $currentSizeMB) {
    Write-Host "현재 크기와 목표 크기가 동일합니다. 작업을 종료합니다." -ForegroundColor Green
    Exit
}

# ---------------------------------------------------------
# [3] 시나리오 판별 및 실행 공정
# ---------------------------------------------------------

if ($targetSizeMB -gt $currentSizeMB) {
    # ---------------------------------------------------------
    # 시나리오 A: 용량 확장 (Expand)
    # ---------------------------------------------------------
    Write-Host "작업 유형   : 용량 확장 (Expand)" -ForegroundColor Green
    if ($Optimize) { Write-Host "참고        : 확장 작업 시에는 -o (최적화) 옵션이 무시됩니다." -ForegroundColor DarkGray }
    Write-Host "------------------------------------------------"
    
    try {
        Write-Host "VHD 파일 크기 확장 중..." -ForegroundColor Cyan
        $targetSizeBytes = $SizeGB * 1GB
        Resize-VHD -Path $absolutePath -SizeBytes $targetSizeBytes -ErrorAction Stop
        
        Write-Host "VHD 마운트 중..." -ForegroundColor Cyan
        $mountedVhd = Mount-VHD -Path $absolutePath -PassThru
        Start-Sleep -Seconds 2
        
        # 파티션 확장
        Write-Host "파티션 확장 중..." -ForegroundColor Cyan
        $disk = $mountedVhd | Get-Disk
        $partition = $disk | Get-Partition | Where-Object { $_.Type -eq "Basic" } | Select-Object -First 1
        
        if ($partition) {
            # 사용 가능한 공간을 모두 파티션에 할당
            $maxSize = ($partition | Get-PartitionSupportedSize).SizeMax
            Resize-Partition -InputObject $partition -Size $maxSize -ErrorAction Stop
            Write-Host "   -> 파티션이 $([math]::Round($maxSize / 1GB, 2)) GB로 확장되었습니다." -ForegroundColor Green
        }
        
        Write-Host "VHD 언마운트 중..." -ForegroundColor Cyan
        Dismount-VHD -Path $absolutePath
        
        Write-Host "용량 확장 작업이 완료되었습니다." -ForegroundColor Green
    } catch {
        Write-Error "용량 확장 중 오류가 발생했습니다: $_"
        Exit 1
    }

} else {
    # ---------------------------------------------------------
    # 시나리오 B: 용량 축소 (Shrink & Compact)
    # ---------------------------------------------------------
    Write-Host "작업 유형   : 용량 축소 (Shrink & Compact)" -ForegroundColor Yellow
    Write-Host "------------------------------------------------"
    
    try {
        $targetSizeBytes = $SizeGB * 1GB
        
        # -o 스위치가 활성화되었을 때 파티션 내부 파일 선행 정렬(Defrag) 수행
        if ($Optimize) {
            Write-Host "[옵션 작동] 축소 성공률을 높이기 위해 내부 파일 최적화를 시작합니다." -ForegroundColor Yellow
            Write-Host "1/4. 디스크 마운트 중..." -ForegroundColor DarkGray
            
            $mountedVhd = Mount-VHD -Path $absolutePath -PassThru
            Start-Sleep -Seconds 2
            
            # 마운트된 가상 디스크의 드라이브 문자 획득
            $disk = $mountedVhd | Get-Disk
            $partition = $disk | Get-Partition | Where-Object { $_.Type -eq "Basic" } | Select-Object -First 1
            $driveLetter = $partition.DriveLetter
            
            if ($driveLetter) {
                Write-Host "2/4. 드라이브($($driveLetter):) 감지 완료. 조각 모음(Defrag) 수행 중..." -ForegroundColor DarkGray
                Optimize-Volume -DriveLetter $driveLetter -Defrag -Verbose
            } else {
                Write-Host "경고: 드라이브 문자를 추적하지 못해 선행 조각 모음을 건너뜁니다." -ForegroundColor Orange
            }
            
            Write-Host "3/4. 파티션 축소 중..." -ForegroundColor Cyan
            $partitionSizeInfo = $partition | Get-PartitionSupportedSize
            $shrinkBuffer = 64MB
            $desiredPartitionSize = [math]::Min($targetSizeBytes - $shrinkBuffer, $partitionSizeInfo.SizeMax)
            if ($desiredPartitionSize -lt $partitionSizeInfo.SizeMin) {
                throw "목표 파티션 크기가 최소 허용 크기보다 작습니다."
            }
            Resize-Partition -InputObject $partition -Size $desiredPartitionSize -ErrorAction Stop
            Write-Host "   -> 파티션이 $([math]::Round($desiredPartitionSize / 1GB, 2)) GB로 축소되었습니다." -ForegroundColor Green
            
            Write-Host "VHD 언마운트 중..." -ForegroundColor Cyan
            Dismount-VHD -Path $absolutePath
        } else {
            # 최적화 없이 바로 축소
            Write-Host "1/3. VHD 마운트 중..." -ForegroundColor Cyan
            $mountedVhd = Mount-VHD -Path $absolutePath -PassThru
            Start-Sleep -Seconds 2
            
            $disk = $mountedVhd | Get-Disk
            $partition = $disk | Get-Partition | Where-Object { $_.Type -eq "Basic" } | Select-Object -First 1
            
            if ($partition) {
                Write-Host "2/3. 파티션 축소 중..." -ForegroundColor Cyan
                $partitionSizeInfo = $partition | Get-PartitionSupportedSize
                $shrinkBuffer = 64MB
                $desiredPartitionSize = [math]::Min($targetSizeBytes - $shrinkBuffer, $partitionSizeInfo.SizeMax)
                if ($desiredPartitionSize -lt $partitionSizeInfo.SizeMin) {
                    throw "목표 파티션 크기가 최소 허용 크기보다 작습니다."
                }
                Resize-Partition -InputObject $partition -Size $desiredPartitionSize -ErrorAction Stop
                Write-Host "   -> 파티션이 $([math]::Round($desiredPartitionSize / 1GB, 2)) GB로 축소되었습니다." -ForegroundColor Green
            }
            
            Write-Host "VHD 언마운트 중..." -ForegroundColor Cyan
            Dismount-VHD -Path $absolutePath
        }
        
        Write-Host "3/3. VHD 파일 크기 조정 중..." -ForegroundColor Cyan
        Resize-VHD -Path $absolutePath -SizeBytes $targetSizeBytes -ErrorAction Stop
        Write-Host "   -> VHD 파일이 $([math]::Round($targetSizeBytes / 1GB, 2)) GB로 축소되었습니다." -ForegroundColor Green
        
        Write-Host "4/3. 미할당 공간 정리 중..." -ForegroundColor Cyan
        $mountedVhd = Mount-VHD -Path $absolutePath -PassThru
        Start-Sleep -Seconds 2
        $partition = ($mountedVhd | Get-Disk | Get-Partition | Where-Object { $_.Type -eq "Basic" } | Select-Object -First 1)
        if ($partition) {
            $maxSize = ($partition | Get-PartitionSupportedSize).SizeMax
            if ($partition.Size -lt $maxSize) {
                Resize-Partition -InputObject $partition -Size $maxSize -ErrorAction Stop
                Write-Host "   -> 파티션이 $([math]::Round($maxSize / 1GB, 2)) GB로 확장되어 미할당 공간이 제거되었습니다." -ForegroundColor Green
            }
        }
        Dismount-VHD -Path $absolutePath
        
        Optimize-VHD -Path $absolutePath -Mode Full
        
        Write-Host "용량 축소 작업이 완료되었습니다." -ForegroundColor Green
    } catch {
        Write-Error "용량 축소 중 오류가 발생했습니다: $_"
        Exit 1
    }
}

# ---------------------------------------------------------
# [4] 최종 완료 메시지
# ---------------------------------------------------------
Write-Host "------------------------------------------------"
Write-Host "모든 가상 디스크 작업이 성공적으로 완료되었습니다." -ForegroundColor Green