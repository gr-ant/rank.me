$database = import-csv -LiteralPath $PSScriptRoot\rate.csv

$table = "$PSScriptRoot\rate.csv"

function get-images($links){

gc .\Desktop\prisoners.txt | %{
Remove-Item -LiteralPath $PSScriptRoot\content.txt
(Invoke-WebRequest "$_").content |Out-File $PSScriptRoot\content.txt
$content = gc $PSScriptRoot\content.txt

$content | %{if($_ -like '*"og:image" content*'){


$image = ($_ -replace '<meta property="og:image" content="','' -replace '" />','')

$name = $image -replace 'http://cagedladies.com/wp-content/uploads/',''

Invoke-WebRequest $image -OutFile $PSScriptRoot\Images\$name

}}}}

function get-randompics($folder){

$list = gci $folder

$choices =@()
(import-csv -LiteralPath $PSScriptRoot\rate.csv) | %{if((($_.likes -as [int])+($_.dislikes -as [int])) -eq 0){$choices+=($_.name).tostring()}}
write-host $choices.Length
$num1 = Get-Random -Minimum 0 -Maximum ($choices.length - 1)
$num2 = Get-Random -Minimum 0 -Maximum ($choices.length - 1)
while($num2 -eq $num1){$num2 = Get-Random -Minimum 0 -Maximum ($list.length - 1)} 

$pic1 = $list | select -ExpandProperty fullname | where{'fullname -like "$choices[$num1]"'}
$pic2 = $list | select -ExpandProperty fullname | where{'fullname -like "$choices[$num2]"'}

return $list[$num1].FullName,$list[$num2].FullName
}

function start-form(){

<# This form was created using POSHGUI.com  a free online gui designer for PowerShell
.NAME
    Untitled
#>

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$Form                            = New-Object system.Windows.Forms.Form
$Form.ClientSize                 = New-Object System.Drawing.Point(871,624)
$Form.text                       = "Jail-Rate"
$Form.TopMost                    = $true
$form.StartPosition              = "CenterScreen"
$form.BackColor                  = "White"

$PictureBox1                     = New-Object system.Windows.Forms.PictureBox
$PictureBox1.width               = 326
$PictureBox1.height              = 288
$PictureBox1.location            = New-Object System.Drawing.Point(80,151)
$PictureBox1.imageLocation       = "$pic1"
$PictureBox1.SizeMode            = [System.Windows.Forms.PictureBoxSizeMode]::zoom
$PictureBox2                     = New-Object system.Windows.Forms.PictureBox
$PictureBox2.width               = 326
$PictureBox2.height              = 288
$PictureBox2.location            = New-Object System.Drawing.Point(472,151)
$PictureBox2.imageLocation       = "$pic2"
$PictureBox2.SizeMode            = [System.Windows.Forms.PictureBoxSizeMode]::zoom

$label1                          = New-Object system.Windows.Forms.Label
$label1.text                     = ((get-item -LiteralPath $pic1).BaseName -replace '-',' ').substring(0,((get-item -LiteralPath $pic1).BaseName -replace '-',' ').indexof(" "))
$label1.AutoSize                 = $false
$label1.width                    = 75
$label1.height                   = 20
$label1.location                 = New-Object System.Drawing.Point(223,449)
$label1.Font                     = New-Object System.Drawing.Font('palatino',10)

$label2                          = New-Object system.Windows.Forms.Label
$label2.text                     = ((get-item -LiteralPath $pic2).BaseName -replace '-',' ').substring(0,((get-item -LiteralPath $pic2).BaseName -replace '-',' ').indexof(" "))
$label2.AutoSize                 = $False
$label2.width                    = 75
$label2.height                   = 20
$label2.location                 = New-Object System.Drawing.Point(625,448)
$label2.Font                     = New-Object System.Drawing.Font('palatino',10)

$btnExit                         = New-Object system.Windows.Forms.Button
$btnExit.text                    = "Close"
$btnExit.width                   = 60
$btnExit.height                  = 30
$btnExit.location                = New-Object System.Drawing.Point(412,488)
$btnExit.Font                    = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$Form.controls.AddRange(@($PictureBox1,$PictureBox2,$label1,$label2,$btnExit))

$PictureBox2.Add_Click({

    $name = (get-item $pic2).basename
    $database | %{if($_.name -eq $name){$_.likes = ($_.likes -as [int]) +1}}
    

    $name2 = (get-item $pic1).basename
    $database | %{if($_.name -eq $name2){$_.dislikes =($_.dislikes -as [int]) + 1}}
    Remove-Item $PSScriptRoot\rate.csv

    $database | Export-Csv -NoTypeInformation -LiteralPath $PSScriptRoot\rate.csv

    $form.Dispose()
    
    Add-Content $PSScriptRoot\History.csv -Value "$((Get-Date -Format "ddMMyyHHmm")),$name,$((get-item $pic1).basename)"
    
    init
    
})

$PictureBox1.Add_Click({

    $name = (get-item $pic1).basename
    $database | %{if($_.name -eq $name){$_.likes = ($_.likes -as [int]) +1}}

    $name2 = (get-item $pic2).basename
    $database | %{if($_.name -eq $name2){$_.dislikes =($_.dislikes -as [int]) + 1}}
    Remove-Item $PSScriptRoot\rate.csv

    $database | Export-Csv -NoTypeInformation -LiteralPath $PSScriptRoot\rate.csv
    $form.dispose()

    Add-Content $PSScriptRoot\History.csv -Value "$((Get-Date -Format "ddMMyyHHmm")),$name,$((get-item $pic2).basename)"

    init

})
$btnExit.Add_Click({$form.Dispose()  })

$form.ShowDialog()}

function init{$pic1,$pic2 = get-randompics -folder $PSScriptRoot\Images

$username | Add-Content $PSScriptRoot\History.csv
start-form -pic1 $pic1 -pic2 $pic2}

init