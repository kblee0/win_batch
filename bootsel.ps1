# 관리자 권한 확인 및 Elevation
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process -FilePath "powershell.exe" -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Add-Type -AssemblyName "System.Windows.Forms"

# BCD 항목을 가져오는 함수
function Get-BCDEditEntries {
    $bcdEntries = bcdedit | Select-String -Pattern "description|identifier" | ForEach-Object { $_.Line.Trim() }
    $entries = @()
    $currentEntry = @{}

    foreach ($line in $bcdEntries) {
        if ($line -match "^identifier\s+(.*)$") {
            $currentEntry['identifier'] = $matches[1]
        } elseif ($line -match "^description\s+(.*)$") {
            $currentEntry['description'] = $matches[1]

            if ($currentEntry['description'] -notmatch "Windows Boot Manager" -and $currentEntry['identifier']) {
                $entries += $currentEntry
            }

            $currentEntry = @{}
        }
    }

    return $entries
}

# OS 항목을 기본값으로 설정하고 재부팅하는 함수
function Set-DefaultAndReboot ($identifier) {
    try {
        bcdedit /default $identifier
        shutdown.exe /r /t 0
    } catch {
        [System.Windows.Forms.MessageBox]::Show("오류: $($_.Exception.Message)", "오류", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
}

# GUI 창 생성
$form = New-Object System.Windows.Forms.Form
$form.Text = "부팅 항목 선택기"
$form.Size = New-Object System.Drawing.Size(600, 300)
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.MinimizeBox = $false

# OS 목록 박스 생성
$listBox = New-Object System.Windows.Forms.ListBox
$listBox.Size = New-Object System.Drawing.Size(560, 180)
$listBox.Location = New-Object System.Drawing.Point(20, 20)
$listBox.Font = New-Object System.Drawing.Font("Microsoft Sans Serif", 20)
$form.Controls.Add($listBox)

# 버튼 생성 (글꼴 크기 설정 추가)
$setButton = New-Object System.Windows.Forms.Button
$setButton.Text = "기본설정 후 재부팅"
$setButton.Size = New-Object System.Drawing.Size(560, 60)
$setButton.Location = New-Object System.Drawing.Point(20, 190)
$setButton.Font = New-Object System.Drawing.Font("Microsoft Sans Serif", 14)  # 글자 크기 20pt
$form.Controls.Add($setButton)

# BCD 항목 가져오기
$bcdEntries = Get-BCDEditEntries
foreach ($entry in $bcdEntries) {
    $listBox.Items.Add(' ' + $entry['description'])
}
$listBox.SelectedIndex = 0

# 버튼 클릭 동작
$handleSelection = {
    $selectedItem = $listBox.SelectedItem
    if ($selectedItem) {
        $entry = $bcdEntries | Where-Object { $_['description'] -eq $selectedItem }
        if ($entry) {
            Set-DefaultAndReboot $entry['identifier']
        }
    } else {
        [System.Windows.Forms.MessageBox]::Show("OS 항목을 선택하세요.", "경고", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
    }
}
$setButton.Add_Click($handleSelection)

# 엔터 키 처리
$listBox.Add_KeyDown({
    if ($_.KeyCode -eq 'Enter') {
        $handleSelection.Invoke()
    }
})

# 폼 실행
$form.ShowDialog()
