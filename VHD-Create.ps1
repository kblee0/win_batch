<#
.SYNOPSIS
    Hyper-V PowerShell 모듈을 사용하여
    VHDX 가상 디스크 생성, 자동 마운트 등록, Everyone 독점 권한 설정을 수행합니다.
    powershell -NoProfile -ExecutionPolicy Bypass -File VHD-Create.ps1 C:\img\doc.vhdx  5 -l 'Document' -e
#>
[CmdletBinding()]
param(
    [Parameter(Position=0)] [string]$ImagePath,
    [Parameter(Position=1)] [int]$SizeGB,
    [Parameter()] [string]$l,
    [Parameter()] [switch]$e
)

# ---------------------------------------------------------
# Hyper-V PowerShell 모듈 로드
# ---------------------------------------------------------
try {
    Import-Module Hyper-V -ErrorAction Stop
} catch {
    Write-Host "`n[오류] Hyper-V PowerShell 모듈을 로드할 수 없습니다." -ForegroundColor Red
    Write-Host "Hyper-V 기능이 설치되어 있는지 확인하세요." -ForegroundColor Yellow
    exit 1
}

# ---------------------------------------------------------
# 사용법 및 도움말(Help) 안내 출력
# ---------------------------------------------------------
function Show-Usage {
    Write-Host "`n[오류] 입력 파라미터가 올바르지 않거나 누락되었습니다." -ForegroundColor Red
    Write-Host "Usage:" -ForegroundColor Yellow
    Write-Host "  .\VHD-Create.ps1 <Image Path> <Size GB> [-l <Volume Label>] [-e]"
    Write-Host "`nOptions:" -ForegroundColor Yellow
    Write-Host "  -l : 파티션의 볼륨 라벨(이름)을 지정"
    Write-Host "  -e : 소유주 Everyone 변경, 상속 제거, Everyone 외 모든 계정 권한 박탈"
    Write-Host "`nExamples:" -ForegroundColor Yellow
    Write-Host "  .\VHD-Create.ps1 C:\img\data.vhdx 10"
    Write-Host "  .\VHD-Create.ps1 C:\img\doc.vhdx  5 -l 'Document' -e`n"
    exit 1
}

# 파라미터 필수 값 검증 (누락 시 즉시 도움말 출력)
if ([string]::IsNullOrWhiteSpace($ImagePath) -or $SizeGB -le 0) {
    Show-Usage
}

# [보안] 관리자 권한 필수 체크
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "`n[권한 오류] 이 스크립트는 '관리자 권한으로 실행'해야 합니다.`n" -ForegroundColor Red
    exit 1
}

# 경로 유효성 검증 및 파일 중복 체크
$ImagePath = [System.IO.Path]::GetFullPath($ImagePath)
$parentDir = [System.IO.Path]::GetDirectoryName($ImagePath)
if (-not (Test-Path $parentDir)) { New-Item -ItemType Directory -Path $parentDir -Force | Out-Null }
if (Test-Path $ImagePath) {
    Write-Host "`n[오류] 이미 동일한 가상 디스크 파일이 존재합니다: $ImagePath" -ForegroundColor Red
    exit 1
}

try {
    # 1. Hyper-V를 통한 가상 디스크 생성
    Write-Host "`n1. 가상 디스크 생성 중 ($SizeGB GB)..." -ForegroundColor Cyan
    $sizeBytes = $SizeGB * 1GB
    $volumeLabel = if ([string]::IsNullOrWhiteSpace($l)) { "" } else { $l }

    # New-VHD로 확장 가능한 VHDX 파일 생성
    $vhdFile = New-VHD -Path $ImagePath -SizeBytes $sizeBytes -Dynamic
    Write-Host "   -> VHD 파일 생성 완료: $ImagePath" -ForegroundColor Green
    
    # 2. 가상 디스크 마운트
    Write-Host "2. 가상 디스크 마운트 중..." -ForegroundColor Cyan
    $mountedVhd = Mount-VHD -Path $ImagePath -PassThru
    $diskNumber = $mountedVhd.DiskNumber
    
    # 디스크 초기화 (GPT 파티션 테이블)
    Write-Host "3. 디스크 초기화 및 파티션 생성 중..." -ForegroundColor Cyan
    Initialize-Disk -Number $diskNumber -PartitionStyle GPT -ErrorAction Stop | Out-Null
    
    # 파티션 생성
    $partition = New-Partition -DiskNumber $diskNumber -UseMaximumSize -AssignDriveLetter
    $driveLetter = $partition.DriveLetter
    
    # NTFS 포맷
    Write-Host "4. NTFS 포맷 중..." -ForegroundColor Cyan
    Format-Volume -DriveLetter $driveLetter -FileSystem NTFS -NewFileSystemLabel $volumeLabel -Confirm:$false | Out-Null

    # 5. Everyone 독점 보안 권한 설정 (-e 스위치 활성화 시)
    if ($e) {
        Write-Host "5. [-e] Everyone 독점 보안 권한(ACL) 설정 적용 중..." -ForegroundColor Yellow
        Start-Sleep -Milliseconds 500

        # 마운트된 드라이브의 루트 경로
        $targetPath = "$($driveLetter):\"

        # 순수 파워셸 개체 모델 기반 ACL 완전 초기화 
        $everyoneAccount = New-Object System.Security.Principal.NTAccount("Everyone")
        $acl = New-Object System.Security.AccessControl.DirectorySecurity
        
        $acl.SetOwner($everyoneAccount)
        $acl.SetAccessRuleProtection($true, $false)
        
        $fullControlRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
            $everyoneAccount, "FullControl", "ContainerInherit, ObjectInherit", "None", "Allow"
        )
        $acl.ResetAccessRule($fullControlRule)
        
        Set-Acl -LiteralPath $targetPath -AclObject $acl
        Write-Host "   -> 소유권 이전 및 Everyone 단독 권한 할당 완료" -ForegroundColor Green
    }
    
    # 6. 가상 디스크 언마운트
    Write-Host "6. 가상 디스크 언마운트 중..." -ForegroundColor Cyan
    Dismount-VHD -Path $ImagePath | Out-Null

    Write-Host "`n[성공] VHDX 가상 디스크 생성이 완료되었습니다.`n" -ForegroundColor Green

} catch {
    Write-Host "`n[오류 발생] $_" -ForegroundColor Red
    if (Test-Path $ImagePath) {
        Dismount-VHD -Path $ImagePath -ErrorAction SilentlyContinue | Out-Null
        Remove-Item -Path $ImagePath -Force -ErrorAction SilentlyContinue
    }
    exit 1
}