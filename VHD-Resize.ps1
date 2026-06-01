<#
.SYNOPSIS
    Hyper-V 모듈 없이 Windows 순수 기능만으로 VHD 파일의 용량을 확장하거나 축소합니다.
.DESCRIPTION
    WMI/CIM 스토리지 API를 사용하여 VHD의 가상 크기를 감지하며, 
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

# ----------------------------------------------------
# [2] VHD 가상 크기 자동 감지 및 안전장치
# ----------------------------------------------------
Write-Host "VHD 파일 분석 중..." -ForegroundColor Cyan

# 이스케이프 처리를 포함한 파일의 완전한 절대 경로 확보
$absolutePath = (Get-Item $ImagePath).FullName
$escapedPath = $absolutePath -replace '\\', '\\\\'
$currentSizeMB = 0

# 스토리지 API(CIM)를 통해 가상 가상 크기(Maximum Size) 조회
try {
    $vhdInfo = Get-CimInstance -Namespace Root/Microsoft/Windows/Storage -ClassName MSFT_VirtualDisk -Filter "ImagePath='$escapedPath'" -ErrorAction Stop
    if ($vhdInfo) { $currentSizeMB = [int]($vhdInfo.Size / 1MB) }
} catch {
    # 예외 발생 시 하단 체크 로직에서 스크립트가 차단됩니다.
}

# 크기 조회 실패 시 강제 진행을 차단하고 안전 종료 (데이터 유실 방지)
if ($currentSizeMB -eq 0) {
    Write-Host "------------------------------------------------" -ForegroundColor Red
    Write-Error "오류: CIM 스토리지 API를 통한 VHD 가상 크기 조회가 실패했습니다."
    Write-Host "데이터 안전을 위해 파일 크기 기반의 수동 연산을 차단하고 종료합니다." -ForegroundColor LightMagenta
    Write-Host "------------------------------------------------" -ForegroundColor Red
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

# ----------------------------------------------------
# [3] 시나리오 판별 및 실행 공정
# ----------------------------------------------------
$diskpartScriptPath = [System.IO.Path]::GetTempFileName()

if ($targetSizeMB -gt $currentSizeMB) {
    # ----------------------------------------------------
    # 시나리오 A: 용량 확장 (Expand)
    # ----------------------------------------------------
    Write-Host "작업 유형   : 용량 확장 (Expand)" -ForegroundColor Green
    if ($Optimize) { Write-Host "참고        : 확장 작업 시에는 -o (최적화) 옵션이 무시됩니다." -ForegroundColor DarkGray }
    Write-Host "------------------------------------------------"
    
    $scriptContent = @"
select vdisk file="$absolutePath"
attach vdisk
expand vdisk maximum=$targetSizeMB
select partition 1
extend
detach vdisk
exit
"@
    Set-Content -Path $diskpartScriptPath -Value $scriptContent -Encoding OEM
    Write-Host "용량 확장 작업을 진행 중입니다..." -ForegroundColor Cyan
    $null = diskpart /s $diskpartScriptPath

} else {
    # ----------------------------------------------------
    # 시나리오 B: 용량 축소 (Shrink & Compact)
    # ----------------------------------------------------
    Write-Host "작업 유형   : 용량 축소 (Shrink & Compact)" -ForegroundColor Yellow
    Write-Host "------------------------------------------------"
    
    # -o 스위치가 활성화되었을 때 파티션 내부 파일 선행 정렬(Defrag) 수행
    if ($Optimize) {
        Write-Host "[옵션 작동] 축소 성공률을 높이기 위해 내부 파일 최적화를 시작합니다." -ForegroundColor Skip
        Write-Host "1/3. 디스크 임시 마운트 중..." -ForegroundColor DarkGray
        
        # 임시 마운트 스크립트 작성 및 실행
        "select vdisk file=`"$absolutePath`"`nattach vdisk`nexit" | Set-Content -Path $diskpartScriptPath -Encoding OEM
        $null = diskpart /s $diskpartScriptPath
        
        Start-Sleep -Seconds 3 # Windows OS가 드라이브를 정상 인식하기 위한 버퍼 대기
        
        # 마운트된 가상 디스크의 드라이브 문자(Drive Letter) 실시간 역추적
        $driveLetter = (Get-Disk | Where-Object { $_.Location -match $escapedPath -or $_.Path -match $escapedPath } | Get-Partition | Where-Object { $_.DriveLetter }).DriveLetter
        
        if ($driveLetter) {
            Write-Host "2/3. 드라이브($($driveLetter):) 감지 완료. 조각 모음(Defrag) 수행 중..." -ForegroundColor DarkGray
            # 순수 PowerShell 볼륨 최적화 API를 호출하여 데이터 블록을 앞단으로 꽉 짜서 몰아넣음
            Optimize-Volume -DriveLetter $driveLetter -Defrag -Verbose
        } else {
            Write-Host "경고: 드라이브 문자를 추적하지 못해 선행 조각 모음을 건너넙니다." -ForegroundColor Orange
        }
        
        Write-Host "3/3. 사전 최적화 공정 완료. 본 축소 작업을 이어갑니다.`n" -ForegroundColor DarkGray
    }
    
    # 본 축소 프로세스 구성 (파티션 선축소 -> 디스크 연결 해제 -> VHD 파일 껍데기 다이어트)
    $shrinkDeltaMB = $currentSizeMB - $targetSizeMB
    $scriptContent = @"
select vdisk file="$absolutePath"
attach vdisk
select partition 1
shrink desired=$shrinkDeltaMB
detach vdisk
select vdisk file="$absolutePath"
compact vdisk
exit
"@
    Set-Content -Path $diskpartScriptPath -Value $scriptContent -Encoding OEM
    Write-Host "VHD 볼륨 축소 및 용량 최적화(Compact)를 진행 중입니다..." -ForegroundColor Cyan
    $null = diskpart /s $diskpartScriptPath
}

# ----------------------------------------------------
# [4] 임시 파일 정리 및 최종 종료
# ----------------------------------------------------
if (Test-Path $diskpartScriptPath) { Remove-Item $diskpartScriptPath -Force }

Write-Host "------------------------------------------------"
Write-Host "모든 가상 디스크 작업이 성공적으로 완료되었습니다." -ForegroundColor Green