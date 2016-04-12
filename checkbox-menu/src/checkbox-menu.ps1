$apps = @("choco install vlc","choco install firefox","choco install opera","cup all -y")
$script:results = @()

function GenerateForm {

    [reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null
    [reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null

    $form1 = New-Object System.Windows.Forms.Form
    $button1 = New-Object System.Windows.Forms.Button
    $InitialFormWindowState = New-Object System.Windows.Forms.FormWindowState
    
    $handler_button1_Click = { 
        $form1.Hide()
        for ($i=0; $i -lt $checkBoxes.length; $i++) {
            if ($checkBoxes[$i].Checked) {
                $script:results += $($apps[$i])
            }
        }
        $form1.Close()
    }

    $OnLoadForm_StateCorrection = {
        $form1.WindowState = $InitialFormWindowState
    }

    $form1.Text = "Chocolatey Menu"
    $form1.Name = "form1"
    $form1.DataBindings.DefaultDataSourceUpdateMode = 0
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Width = 300
    $System_Drawing_Size.Height = 10+(20*$apps.length)+10+20+10
    $form1.ClientSize = $System_Drawing_Size

    $checkBoxes = @()
    for ($i=0; $i -lt $apps.length; $i++) {
        $checkBoxes += New-Object System.Windows.Forms.CheckBox
        $checkBoxes[$i].UseVisualStyleBackColor = $True
        $System_Drawing_Size = New-Object System.Drawing.Size
        $System_Drawing_Size.Width = 280
        $System_Drawing_Size.Height = 20
        $checkBoxes[$i].Size = $System_Drawing_Size
        $checkBoxes[$i].TabIndex = $i
        $checkBoxes[$i].Text = $apps[$i]
        $System_Drawing_Point = New-Object System.Drawing.Point
        $System_Drawing_Point.X = 10
        $System_Drawing_Point.Y = 10+(20*$i)
        $checkBoxes[$i].Location = $System_Drawing_Point
        $checkBoxes[$i].DataBindings.DefaultDataSourceUpdateMode = 0
        $checkBoxes[$i].Name = "checkBox"+$i
        $checkBoxes[$i].Checked = $true
        $form1.Controls.Add($checkBoxes[$i])
    }

    $button1.TabIndex = $apps.length+1
    $button1.Name = "button1"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Width = 280
    $System_Drawing_Size.Height = 20
    $button1.Size = $System_Drawing_Size
    $button1.UseVisualStyleBackColor = $True
    $button1.Text = "Install"
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 10
    $System_Drawing_Point.Y = 10+(20*$apps.length)+10
    $button1.Location = $System_Drawing_Point
    $button1.DataBindings.DefaultDataSourceUpdateMode = 0
    $button1.add_Click($handler_button1_Click)
    $form1.Controls.Add($button1)

    $InitialFormWindowState = $form1.WindowState
    $form1.add_Load($OnLoadForm_StateCorrection)
    $form1.ShowDialog()| Out-Null
}

GenerateForm

foreach ($result in $script:results) {
    Write-Host $result
    iex $result
    Write-Host
}