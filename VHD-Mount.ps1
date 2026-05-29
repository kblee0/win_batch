<#
.SYNOPSIS
    VHDX 가상 디스크를 드라이브 문자 또는 특정 폴더 경로에 유연하게 마운트/언마운트하는 툴입니다.
    powershell -NoProfile -ExecutionPolicy Bypass -File VHD-Mount.ps1 c:\img\doc.vhdx -p c:\img\doc
#>
[CmdletBinding(DefaultParameterSetName="DriveLetter")]
param(
    [Parameter(Position=0)]
    [string]$ImagePath,

    [Parameter(ParameterSetName="DriveLetter")]
    [string]$d,

    [Parameter(ParameterSetName="MountPath")]
    [string]$p,

    [Parameter(ParameterSetName="Unmount")]
    [switch]$u,

    [Parameter(ParameterSetName="DriveLetter")]
    [Parameter(ParameterSetName="MountPath")]
    [switch]$r
)

# ---------------------------------------------------------
# 관리자 권한 유효성 검증
# ---------------------------------------------------------
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "`n[권한 오류] 이 스크립트를 실행하려면 '관리자 권한'이 필요합니다." -ForegroundColor Red
    Write-Host "CMD 또는 PowerShell을 '관리자 권한으로 실행'한 뒤 다시 시도해 주세요.`n" -ForegroundColor Yellow
    exit 1
}

# ---------------------------------------------------------
# 사용법(Help) 안내 출력
# ---------------------------------------------------------
function Show-Usage {
    Write-Host "`n[사용법] 파라미터가 올바르지 않습니다." -ForegroundColor Red
    Write-Host "Usage:" -ForegroundColor Yellow
    Write-Host "  .\VHD-Mount.ps1 <Image Path> -d <Drive Letter> [-r] : 드라이브로 마운트 (기존 경로 세척)"
    Write-Host "  .\VHD-Mount.ps1 <Image Path> -p <Mount Path>   [-r] : 특정 폴더로 마운트 (기존 경로 세척)"
    Write-Host "  .\VHD-Mount.ps1 <Image Path> -u                     : 가상 디스크 연결 해제 (Unmount)"
    Write-Host "`nOptions:" -ForegroundColor Yellow
    Write-Host "  -r : 읽기 전용 (ReadOnly) 모드로 마운트"
    Write-Host "  -u : 언마운트 수행"
    Write-Host "`nExamples:" -ForegroundColor Yellow
    Write-Host "  .\VHD-Mount.ps1 L:\img\home.vhdx -p C:\home"
    Write-Host "  .\VHD-Mount.ps1 L:\img\doc.vhdx  -p C:\home\doc -r"
    Write-Host "  .\VHD-Mount.ps1 L:\img\test.vhdx -d M"
    Write-Host "  .\VHD-Mount.ps1 L:\img\home.vhdx -u`n"
    exit 1
}

# ---------------------------------------------------------
# 파라미터 상호 검증 및 파일 유효성 체크
# ---------------------------------------------------------
if ([string]::IsNullOrWhiteSpace($ImagePath) -or -not ($d -or $p -or $u)) {
    Show-Usage
}

# 파일 경로 절대경로로 변환 및 존재 여부 체크
$ResolvedPath = Resolve-Path $ImagePath -ErrorAction SilentlyContinue
if (-not $ResolvedPath) {
    Write-Host "`n[오류] 지정한 VHD 파일 경로를 찾을 수 없습니다: $ImagePath" -ForegroundColor Red
    exit 1
}
$ImagePath = $ResolvedPath.Path

# ---------------------------------------------------------
# [기능 1] 언마운트 처리 (-u)
# ---------------------------------------------------------
if ($u) {
    Write-Host "가상 디스크 연결 해제 중: $ImagePath" -ForegroundColor Cyan
    Dismount-DiskImage -ImagePath $ImagePath -ErrorAction SilentlyContinue
    Write-Host "언마운트가 완료되었습니다." -ForegroundColor Green
    exit 0
}

# ---------------------------------------------------------
# [기능 2] 마운트 처리 (-d 또는 -p)
# ---------------------------------------------------------
try {
    $accessMode = if ($r) { "ReadOnly" } else { "ReadWrite" }
    Write-Host "가상 디스크 연결 중 ($accessMode)..." -ForegroundColor Cyan
    
    $diskImage = Mount-DiskImage -ImagePath $ImagePath -Access $accessMode -NoDriveLetter -Passthru
    $partition = $diskImage | Get-Disk | Get-Partition | Where-Object { $_.Type -eq "Basic" }

    if (-not $partition) {
        throw "가상 디스크 내부에서 유효한 데이터 파티션을 찾을 수 없습니다."
    }

    # [기존 경로 세척] \\ 로 시작하는 GUID 주소 제외한 일반 경로 청소
    $partition.AccessPaths | Where-Object { $_ -notlike "`\\`*" } | ForEach-Object {
        $partition | Remove-PartitionAccessPath -AccessPath $_ -Confirm:$false -ErrorAction SilentlyContinue
    }

    # 타겟 경로 바인딩 분기
    if ($d) {
        if ([string]::IsNullOrWhiteSpace($d)) { throw "드라이브 문자가 비어있습니다." }
        
        $driveLetter = $d.SubString(0,1).ToUpper() + ":"
        Write-Host "새로운 드라이브 마운트 적용: $driveLetter" -ForegroundColor Cyan
        $partition | Add-PartitionAccessPath -AccessPath "$driveLetter\"
    }
    elseif ($p) {
        if ([string]::IsNullOrWhiteSpace($p)) { throw "마운트 폴더 경로가 비어있습니다." }
        
        $mountPath = $p
        if (-not $mountPath.EndsWith("\")) { $mountPath += "\" }
        
        if (-not (Test-Path $mountPath)) {
            New-Item -ItemType Directory -Path $mountPath -Force | Out-Null
        }

        Write-Host "새로운 폴더 마운트 적용: $mountPath" -ForegroundColor Cyan
        $partition | Add-PartitionAccessPath -AccessPath $mountPath
    }

    Write-Host "작업이 성공적으로 완료되었습니다." -ForegroundColor Green

} catch {
    Write-Host "`n[오류 발생] $_" -ForegroundColor Red
    if ($diskImage) { Dismount-DiskImage -ImagePath $ImagePath -ErrorAction SilentlyContinue }
    exit 1
}