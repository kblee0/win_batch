# ������ ���� Ȯ�� �� Elevation
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process -FilePath "powershell.exe" -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Add-Type -AssemblyName "System.Windows.Forms"

# BCD �׸��� �������� �Լ�
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

# OS �׸��� �⺻������ �����ϰ� ������ϴ� �Լ�
function Set-DefaultAndReboot ($identifier) {
    try {
        bcdedit /default $identifier
        shutdown.exe /r /t 0
    } catch {
        [System.Windows.Forms.MessageBox]::Show("����: $($_.Exception.Message)", "����", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
}

# GUI â ����
$form = New-Object System.Windows.Forms.Form
$form.Text = "���� �׸� ���ñ�"
$form.Size = New-Object System.Drawing.Size(600, 300)
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.MinimizeBox = $false

# OS ��� �ڽ� ����
$listBox = New-Object System.Windows.Forms.ListBox
$listBox.Size = New-Object System.Drawing.Size(560, 180)
$listBox.Location = New-Object System.Drawing.Point(20, 20)
$listBox.Font = New-Object System.Drawing.Font("Microsoft Sans Serif", 20)
$form.Controls.Add($listBox)

# ��ư ���� (�۲� ũ�� ���� �߰�)
$setButton = New-Object System.Windows.Forms.Button
$setButton.Text = "�⺻���� �� �����"
$setButton.Size = New-Object System.Drawing.Size(560, 60)
$setButton.Location = New-Object System.Drawing.Point(20, 190)
$setButton.Font = New-Object System.Drawing.Font("Microsoft Sans Serif", 14)  # ���� ũ�� 20pt
$form.Controls.Add($setButton)

# BCD �׸� ��������
$bcdEntries = Get-BCDEditEntries
foreach ($entry in $bcdEntries) {
    $listBox.Items.Add(' ' + $entry['description'])
}
$listBox.SelectedIndex = 0

# ��ư Ŭ�� ����
$handleSelection = {
    $selectedItem = $listBox.SelectedItem
    if ($selectedItem) {
        $entry = $bcdEntries | Where-Object { $_['description'] -eq $selectedItem }
        if ($entry) {
            Set-DefaultAndReboot $entry['identifier']
        }
    } else {
        [System.Windows.Forms.MessageBox]::Show("OS �׸��� �����ϼ���.", "���", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
    }
}
$setButton.Add_Click($handleSelection)

# ���� Ű ó��
$listBox.Add_KeyDown({
    if ($_.KeyCode -eq 'Enter') {
        $handleSelection.Invoke()
    }
})

# �� ����
$form.ShowDialog()
