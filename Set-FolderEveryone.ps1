<#
.SYNOPSIS
    지정한 디렉터리와 하위 모든 파일 및 폴더의 권한 상속을 단절하고,
    소유권과 보안 권한을 Everyone 계정으로 일괄 변경합니다.
.USAGE
    .\Set-FolderEveryone.ps1 <Target Directory Path>
    powershell -NoProfile -ExecutionPolicy Bypass -File Set-FolderEveryone.ps1 c:\doc
#>
[CmdletBinding()]
param(
    [Parameter(Position=0)] [string]$TargetDir
)

# 使用법 안내 함수
function Show-Usage {
    Write-Host "`n[오류] 대상 디렉터리 경로가 올바르지 않거나 누락되었습니다." -ForegroundColor Red
    Write-Host "Usage:" -ForegroundColor Yellow
    Write-Host "  .\Set-FolderEveryone.ps1 <Target Directory Path>"
    Write-Host "`nExamples:" -ForegroundColor Yellow
    Write-Host "  .\Set-FolderEveryone.ps1 C:\home\proj\shared_vhd`n"
    exit 1
}

if ([string]::IsNullOrWhiteSpace($TargetDir)) { Show-Usage }

# 관리자 권한 확인
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "`n[권한 오류] 이 스크립트는 '관리자 권한으로 실행'해야 합니다.`n" -ForegroundColor Red
    exit 1
}

# 경로 유효성 검증
$TargetDir = [System.IO.Path]::GetFullPath($TargetDir)
if (-not (Test-Path $TargetDir -PathType Container)) {
    Write-Host "`n[오류] 존재하지 않는 폴더 경로입니다: $TargetDir`n" -ForegroundColor Red
    exit 1
}

try {
    Write-Host "`n[보안 설정] 보안 권한(ACL) 및 소유권 변경 시작..." -ForegroundColor Cyan

    # 보안 규칙 정의 (Everyone 계정)
    $everyoneAccount = New-Object System.Security.Principal.NTAccount("Everyone")
    
    # 폴더용 규칙 (하위 개체 상속 허용)
    $folderRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
        $everyoneAccount, "FullControl", "ContainerInherit, ObjectInherit", "None", "Allow"
    )
    # 파일용 규칙 (단독 개체 권한)
    $fileRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
        $everyoneAccount, "FullControl", "None", "None", "Allow"
    )

    # 폴더 마스터 ACL 설정 (상속 단절 및 Everyone 소유권)
    $folderAcl = New-Object System.Security.AccessControl.DirectorySecurity
    $folderAcl.SetOwner($everyoneAccount)
    $folderAcl.SetAccessRuleProtection($true, $false)
    $folderAcl.ResetAccessRule($folderRule)

    # 파일 마스터 ACL 설정 (상속 단절 및 Everyone 소유권)
    $fileAcl = New-Object System.Security.AccessControl.FileSecurity
    $fileAcl.SetOwner($everyoneAccount)
    $fileAcl.SetAccessRuleProtection($true, $false)
    $fileAcl.ResetAccessRule($fileRule)

    # 최상위 디렉터리 권한 적용
    Set-Acl -LiteralPath $TargetDir -AclObject $folderAcl

    # 하위 디렉터리 순회 및 권한 설정
    Write-Host "-> 하위 폴더 권한 적용 중..." -ForegroundColor Yellow
    foreach ($dir in [System.IO.Directory]::EnumerateDirectories($TargetDir, "*", [System.IO.SearchOption]::AllDirectories)) {
        Set-Acl -LiteralPath $dir -AclObject $folderAcl
    }

    # 하위 파일 순회 및 권한 설정
    Write-Host "-> 하위 파일 권한 적용 중..." -ForegroundColor Yellow
    foreach ($file in [System.IO.Directory]::EnumerateFiles($TargetDir, "*", [System.IO.SearchOption]::AllDirectories)) {
        Set-Acl -LiteralPath $file -AclObject $fileAcl
    }

    Write-Host "[성공] 디렉터리 및 하위 모든 항목의 보안 설정이 완료되었습니다.`n" -ForegroundColor Green

} catch {
    Write-Host "`n[오류 발생] $_`n" -ForegroundColor Red
    exit 1
}