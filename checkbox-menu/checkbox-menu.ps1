$Script:defaultshortcutsfile="config.md"
$apps = @("choco install vlc","choco install firefox","choco install opera","cup all -y")
$script:results = @()

# validation helpers
function Test-StringEmpty($String){
    return ([string]::IsNullOrEmpty($Local:String) -Or [string]::IsNullOrWhiteSpace($String))
}
function Test-PathExists($String){
    return (-Not (Test-StringEmpty $Local:String) -And (Test-Path $Local:String))
}

# colour terminal output function adapted from http://stackoverflow.com/a/30265949
function Write-Color {
    $color = "White"
    $allColors = ("-Black","-DarkBlue","-DarkGreen","-DarkCyan","-DarkRed","-DarkMagenta","-DarkYellow","-Gray","-Darkgray","-Blue","-Green","-Cyan","-Red","-Magenta","-Yellow","-White")
    foreach($arg in $args) {
        if ($allColors -contains $arg) {$color = $arg.substring(1)}
        else {Write-Host $arg -foreground $color -nonewline}
    }
    Write-Host
}

# main logic
function Initialize-Shortcutsbat($Local:configlocation) {

    Clear-Host

    # if no shortcuts config supplied
    If (Test-StringEmpty $Local:configlocation) {

        # set as same dir as bat file
        $Local:shortcutsfile = ('{0}\{1}' -f $pwd, $Script:defaultshortcutsfile)

    } Else {

        # else use supplied file
        $Local:shortcutsfile = $Local:configlocation

    }

    # check shortcuts config file actually exists
    If (-Not (Test-PathExists $Local:shortcutsfile)) {

        Write-Host
        Write-Color -Magenta (' Config file: "{0}" was not found' -f $Local:shortcutsfile)
        Write-Host

    } Else {

        #
        # config file exists
        #

        # set up defaults for options
        $Local:shortcutsfile = (Resolve-Path $Local:shortcutsfile | %{$_.Path})
        $Local:wd = Split-Path -Path $Local:shortcutsfile               # set the working dir same as shortcuts config file location
        $Local:after = ""                                               # set default command that runs afterwards as empty

        # load config file
        $Local:shortcutstxt = Get-Content "$Local:shortcutsfile"
        
        # overwrite default options 'wd' and 'after'
        Foreach ($Local:line in $Local:shortcutstxt) {

            # if line starts with '##wd='
            If ($Local:line.StartsWith('##wd=')) {

                # use the remainder of the line as the new working dir
                $Local:wd = $Local:line.Substring(5).Trim()

            }

            # if line starts with '##after='
            If ($Local:line.StartsWith('##after=')) {
                
                # use the remainder of the line as 'after'
                $Local:after = $Local:line.Substring(8).Trim()

            }
        }

        # check config has at least one command
        $Local:hascommands = $False
        Foreach ($Local:line in $Local:shortcutstxt) {
            If (-Not (Test-StringEmpty $Local:line) -And -Not $Local:line.StartsWith('#')) {
                $Local:hascommands = $True
                break
            }
        }
        If (-Not $Local:hascommands) {
            
            Write-Host
            Write-Color -Magenta (' Config file: "{0}" does not contain any commands' -f $Local:shortcutsfile)
            Write-Host

        } Else {

            #
            # config file exists
            # config contains at least one command
            # 

            # check that working dir exists
            If (-Not (Test-PathExists $Local:wd)) {

                Write-Host
                Write-Color -Magenta (' Working directory: "{0}" was not found' -f $Local:wd)
                Write-Host

            } Else {

                #
                # config file exists
                # config contains at least one command
                # working directory exists
                # 

                # change directory
                Set-Location "$Local:wd"




                # show the menu
                :mainloop While ($True) {

                    Clear-Host
                    Write-Host

                    # show some configuration info (header)
                    Write-Color -Gray ' shorcuts from:'   "`t`t" -Green "$Local:shortcutsfile"
                    Write-Color -Gray ' working directory:' "`t" -Green "$Local:wd"
                    
                    If ($Local:after -ne "") {
                        Write-Color -Gray ' after each command:' -DarkGreen "`t" '& ' $Local:after
                    }

                    # show numbered menu
                    $Local:count = 0
                    Foreach ($Local:line in $Local:shortcutstxt) {
                        If (-Not (Test-StringEmpty $Local:line) -And -Not $Local:line.StartsWith('##')) {
                            If ($Local:line.StartsWith('#')) {

                                # show section title
                                Write-Host
                                Write-Color "`t" -DarkCyan ($Local:line.Substring(1))

                            } Else {

                                # show numbered command
                                $Local:count++
                                If ($Local:line.Contains('#')) {
                                    $Local:commandtitle = $Local:line.Substring(($Local:line.LastIndexOf('#')+1)).Trim()
                                    $Local:command = $Local:line.Substring(0,$Local:line.LastIndexOf('#')).Trim()
                                    If ($Local:command.Length -ge 60) {
                                        $Local:commandabbrev = $Local:command.Substring(0,60)+"..."
                                    } Else {
                                        $Local:commandabbrev = $Local:command
                                    }


                                    $Local:numoftabs = 4-[Math]::Floor((("{0}" -f $Local:count).Length + 3 + $Local:commandtitle.Length)/8)
                                    $local:tabs = ""
                                    for ($Local:i = 0; $Local:i -lt $Local:numoftabs; $Local:i++) { $Local:tabs += "`t" }
                                    Write-Color "`t" ' ' -Cyan $Local:count -White ': ' -Yellow $Local:commandtitle $Local:tabs -Gray $Local:commandabbrev
                                } Else {
                                    Write-Color "`t" ' ' -Cyan $Local:count -White ': ' -Yellow $Local:line.Trim()
                                }

                            }
                        }
                    }

                    # prompt user for input (either a number from the menu or 'e' for exit or 'r' for reload)
                    Write-Host
                    Write-Color ' Enter menu item number (' -Cyan '1' -White ' to ' -Cyan $Local:count -White ')'
                    $Local:choice = Read-Host -prompt ' '
                    Write-Host

                    # process users input
                    :decide Switch ($Local:choice) {

                        {$_ -match '^^r'} {

                            # reload - starts with 'r'
                            Write-Color -Green (' Reloading config "{0}"' -f $Local:shortcutsfile)
                            Start-Sleep -s 1

                            # recursion
                            Initialize-Shortcutsbat $Script:arguments[0]

                            # execution will only return here if any of the checks fail upon reload, so we must break the mainloop to gracefully exit
                            break mainloop
                        }

                        {$_ -match '^^e'} {

                            # exit - starts with 'e'
                            Write-Color -Green ' Exiting'
                            Start-Sleep -m 100
                            exit
                        }

                        {$_ -match '^^\d+$'} {

                            # choice is a number, so check that number matches a menu item by looping through (as previously)
                            $Local:count = 0
                            Foreach ($Local:line in $Local:shortcutstxt) {

                                # if line not blank and not title or config option add to count
                                If (-Not (Test-StringEmpty $Local:line) -And -Not $Local:line.StartsWith('#')) {
                                    $Local:count++

                                    # if count equals selection
                                    If ($Local:count -eq $Local:choice) {

                                        # remove commandtitle from command
                                        If ($Local:line.Contains('#')) {
                                            $Local:command = $Local:line.Substring(0,$Local:line.LastIndexOf('#')).Trim()
                                        } Else {
                                            $Local:command = $Local:line.Trim()
                                        }

                                        # spawn command in new PowerShell window (as admin)
                                        Write-Color -Green (' Spawning "{0}"' -f $Local:command)
                                        $Local:echocommand = ('Write-Host; Write-Host "PS {0}>{1}"; Write-Host' -f $pwd, $Local:command)
                                        If ($Local:after -eq "") {
                                            Start-Process -FilePath powershell -ArgumentList ('-NoExit -Command "{0}; {1}; Write-Host;"' -f $Local:echocommand, $Local:command)
                                        } Else {
                                            Start-Process -FilePath powershell -ArgumentList ('-Command "{0}; {1}; Write-Host; {2};"' -f $Local:echocommand, $Local:command, $Local:after)
                                        }
                                        
                                        #stop looking for a match (skip over 'not found' message below)
                                        break decide
                                    }
                                }
                            }

                            # the count never reached the user supplied number
                            Write-Color -Magenta (' Menu item number "{0}" not found' -f $Local:choice)

                        }

                        default {

                            # not found
                            Write-Color -Magenta (' Command "{0}" not found' -f $Local:choice)

                        }

                    } # end decide switch statement

                    # wait between menus for 1 second (for message display)
                    Start-Sleep -s 1

                } # end mainloop while loop

            } # end working dir exists

        } # end config has commands

    } # end config exists

} # end Initialize-Shortcutsbat function

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

















# start the checks and mainloop (eventually)
If (-Not $Script:arguments) {$Script:arguments=@(); ForEach ($Local:v in $Args) {$Script:arguments += $Local:v}}
Initialize-Shortcutsbat $Script:arguments[0]

# create gui query
GenerateForm
foreach ($result in $script:results) {
    Write-Host $result
    iex $result
    Write-Host
}




# execution only gets here if any of the checks fail or the mainloop ends
Start-Sleep -s 5
