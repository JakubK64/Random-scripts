# Deklaracja zmiennych
$Indeks = 16919
$base_folder_Path = "C:\wit\"
$folder_path = "C:\wit\$($Indeks)\"
$Secedit_file_path = "$($folder_path)config.txt"
$date = Get-Date -Format yyyyMMdd" "hhmmss
$date_formated = Get-Date -Format yyyy-MM-dd" "hh:mm:ss
$report_path = "$($folder_path)\$date"
$report_file_path = "$($report_path).csv"
$config_file = Get-Content "$($folder_path)Konfiguracja.txt"
$IT_Group_SID = Get-ADGroup -Filter "Name -like 'G_IT'" | Select-Object SID
$Admin_name_pattern = "NewAdministratorName"
$Guest_name_pattern = "NewGuestName"
$check = 0



$Computers_list = Get-ADGroupMember -Identity "Domain Computers" | Select-Object Name
$Computers_list = $Computers_list.Name
$Computers_list | ForEach-Object {
    $current_computer = $_

    # Weryfikacja, czy wskazana ścieżka istnieje
    Invoke-Command -ComputerName $current_computer -ScriptBlock {
        param ($folder_path)
        if(!(Test-Path $folder_path)){
            New-Item -ItemType Directory -Path $folder_path
        }
    } -ArgumentList $folder_path

    # Wyeksportowanie danych z secedit do pliku tekstowego
    Invoke-Command -ComputerName $current_computer -ScriptBlock { 
        param($Secedit_file_path)
        secedit /export /cfg "$($Secedit_file_path)" 
    } -ArgumentList $Secedit_file_path

    # Wczytanie wyeksportowanych danych do zmiennej
    $secedit_config = Invoke-Command -ComputerName $current_computer -ScriptBlock { 
    param ($Secedit_file_path)
    $secedit_config = Get-Content $Secedit_file_path
    $secedit_config
    } -ArgumentList $Secedit_file_path 

    # Mimo wizualnie identycznych wyników, porównanie zawartości zmiennych po wywołaniu powyższych poleceń zawsze zwraca "false"
    #$Admin_name_config = $config_file | Select-String -Pattern $Admin_name_pattern
    #$Admin_name_secedit = $secedit_config | Select-String -Pattern $Admin_name_pattern
    #$Guest_name_config = $config_file | Select-String -Pattern $Guest_name_pattern
    #$Guest_name_config = $secedit_config | Select-String -Pattern $Guest_name_pattern

    # Działający sposób
    # Weryfikacja poprawności zmiany nazwy konta administratora
    # Odnalezienie i odczytanie nazwy konta administratora z pliku konfiguracyjnego
    $config_file | ForEach-Object{
        if($_ -match 'NewAdministratorName'){
            $Admin_name_config = $_   
        }
    }

    # Odnalezienie i odczytanie nazwy konta administratora w istniejących ustawieniach (wyeksportowanych danych z secedit)
    $secedit_config | ForEach-Object{
        if($_ -match "NewAdministratorName"){
            $Admin_name_secedit = $_
        }
    }

    # Weryfikacja poprawności zmiany nazwy konta gościa
    # Odnalezienie i odczytanie nazwy konta gościa z pliku konfiguracyjnego
    $config_file | ForEach-Object{
        if($_ -match 'NewGuestName'){
            $Guest_name_config = $_   
        }
    }

    # Odnalezienie i odczytanie nazwy konta gościa w istniejących ustawieniach (wyeksportowanych danych z secedit)
    $secedit_config | ForEach-Object{
        if($_ -match "NewGuestName"){
            $Guest_name_secedit = $_
        }
    }

    # Metoda nie działa ze względu na brak możliwości wykorzystania funkcji "Substring"
    #$ShutdownPrivilege_config = $config_file | Select-String -Pattern "SeShutdownPrivilege"

    # Weryfikacja uprawnień do robienie Backupów
    # Odnalezienie i odczytanie grup uprawnionych do wykonywania Backupów z pliku konfiguracyjnego
    $config_file | ForEach-Object{
        if($_ -match "SeBackupPrivilege"){
            $BackupPrivilege_config = $_
        }
    } 

    # Odnalezienie i odczytanie grup uprawnionych do wykonywania Backupów z istniejących ustawień (wyeksportowanych danych z secedit)
    $secedit_config | ForEach-Object {
        if($_ -match "SeBackupPrivilege"){
            $BackupPrivilege_secedit = $_
        }
    }

    # Weryfikacja uprawnień do wyłączania komputera
    # Odnalezienie i odczytanie grup uprawnionych do wyłączania komputera z pliku konfiguracyjnego
    $config_file | ForEach-Object{
        if($_ -match "SeShutdownPrivilege"){
            $ShutdownPrivilege_config = $_
        }
    }

    # Odnalezienie i odczytanie grup uprawnionych do wyłączania komputera z istniejących ustawień (wyeksportowanych danych z secedit)
    $secedit_config | ForEach-Object {
        if($_ -match "SeShutdownPrivilege"){
            $ShutdownPrivilege_secedit = $_
        }
    }
    
    # Odczytanie grup, które powinny posiadać uprawnienia do wyłączania komputera z pliku konfiguracyjnego
    $SP_config_groups_all = $ShutdownPrivilege_config.Substring($ShutdownPrivilege_config.IndexOf("=")+2)
    $SP_config_groups = $SP_config_groups_all.Split(",")

    # Odczytanie gurp posiadających uprawnienia do wyłączania komputera z secedit
    $SP_secedit_groups_all = $ShutdownPrivilege_secedit.Substring($ShutdownPrivilege_secedit.IndexOf("=")+2)
    $SP_secedit_groups = $SP_secedit_groups_all.Split(",")

    # Odczytanie grup, które powinny posiadać uprawnienia do robienia Backup-ów z pliku konfiguracyjnego
    $Backup_config_groups_all = $BackupPrivilege_config.Substring($BackupPrivilege_config.IndexOf("=")+2)
    $Backup_config_groups = $Backup_config_groups_all.Split(",")

    # Odczytanie grup posiadających uprawnienia do robienia Backup-ów z pliku konfiguracyjnego
    $Backup_secedit_groups_all = $BackupPrivilege_secedit.Substring($BackupPrivilege_secedit.IndexOf("=")+2)
    $Backup_secedit_groups = $Backup_secedit_groups_all.Split(",")


    # Odczytanie trybu automatycznych aktualizacji
    $Automatic_Updates = Invoke-Command -ComputerName $current_computer -ScriptBlock {
        $Automatic_Updates = Get-ItemProperty HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU -Name AUOptions `
        | Select-Object -ExpandProperty AUOptions
        $Automatic_Updates
    }
    # Odczytanie zakładanego trybu automatycznych aktualizacji z pliku konfiguracyjnego
    $config_file | ForEach-Object{
        if($_ -match "Configure Automatic updating mode"){
            $Automatic_Updates_config = $_
        }
    }
    $Automatic_Updates_config = $Automatic_Updates_config.Substring($Automatic_Updates_config.IndexOf("=")+2)

    # Odczytanie czasu przeprowadzania automatycznych aktualizacji
    $Automatic_Updates_time = Invoke-Command -ComputerName $current_computer -ScriptBlock {
        $Automatic_Updates_time = Get-ItemProperty HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU -Name ScheduledInstallTime `
        | Select-Object -ExpandProperty ScheduledInstallTime
        $Automatic_Updates_time
    }
    # Odczytanie zakładanego czasu przeprowadzania automatycznych aktualizacji z pliku konfiguracyjnego
    $config_file | ForEach-Object{
        if($_ -match "Configure Automatic updating time"){
            $Automatic_Updates_config_time = $_
        }
    }
    $Automatic_Updates_config_time = $Automatic_Updates_config_time.Substring($Automatic_Updates_config_time.IndexOf("=")+2)

    # Odczytanie, czy adres serwera z aktualizacjami został ustawiony
    $Update_server = Invoke-Command -ComputerName $current_computer -ScriptBlock {
        $Update_server = Get-ItemProperty HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU -Name UseWUServer `
        | Select-Object -ExpandProperty UseWUServer
        $Update_server
    }
    # Odczytanie, czy adre serwera z aktualizacjami powinien być ustawiony z pliku konfiguracyjnego
    $config_file | ForEach-Object {
        if($_ -match "Configure WSUS Server Adress"){
            $Update_server_config = $_
        }
    }
    $Update_server_config = $Update_server_config.Substring($Update_server_config.IndexOf("=")+2)

    # Weryfikacja statusu usługi Application Identity
    $App_Identity_status = Invoke-Command -ComputerName $current_computer -ScriptBlock {
        Get-Service -Name AppIDSvc | Select-Object status
    }
    $App_Identity_status = $App_Identity_status.Status
    $App_Identity_status = $App_Identity_status.Value

    # Odczytanie zakładanego statusu usługi Application Identity z pliku konfiguracyjnego
    $config_file | ForEach-Object {
        if($_ -match "Application Identity"){
            $App_Identity_status_config = $_
        }
    }
    $App_Identity_status_config = $App_Identity_status_config.Substring($App_Identity_status_config.IndexOf("=")+2)


    #------------------------------------------------------------------------------------------
    # Generowanie raportu
    $report_file_path = "$($folder_path)$($current_computer)_$($Indeks)_$($date).csv" 
    New-Item -ItemType File -Path $report_file_path 
    "Data wykonania testu: $($date_formated)" | Out-File $report_file_path -Append

    "Nazwa komputera: $($current_computer)" | Out-File $report_file_path -Append

    "Sprawdzenie wykonał: $($env:USERDOMAIN)\$($env:USERNAME)" | Out-File $report_file_path -Append

    "" | Out-File $report_file_path -Append

    "User Rights Asignment" | Out-File $report_file_path -Append

    $SP_config_groups | ForEach-Object {
        $check = 0
        $privilege = $_
        $SP_secedit_groups | ForEach-Object{
            if($privilege -eq $_){
                $Actual_group_name = Get-ADGroup -Filter "SID -like '$($privilege)'" | Select-Object Name
                $Actual_group_name_print = $Actual_group_name.Name
                "Shut down the system: Grupa $($Actual_group_name_print): Zgodne" | Out-File $report_file_path -Append
                $check = 1
            }
        }
        if($check -ne 1){
            $Actual_group_name = Get-ADGroup -Filter "SID -like '$($privilege)'" | Select-Object Name
            $Actual_group_name_print = $Actual_group_name.Name
            "Shut down the system: Grupa $($Actual_group_name_print): Niezgodne" | Out-File $report_file_path -Append
        }
    }

    $Backup_config_groups | ForEach-Object {
        $check = 0
        $privilege = $_
        $Backup_secedit_groups | ForEach-Object{
            if($privilege -eq $_){
                $Actual_group_name = Get-ADGroup -Filter "SID -like '$($privilege)'" | Select-Object Name
                $Actual_group_name_print = $Actual_group_name.Name
                "Back up files and directories: Grupa $($Actual_group_name_print): Zgodne" | Out-File $report_file_path -Append
                $check = 1
            }
        }
        if($check -ne 1){
            $Actual_group_name = Get-ADGroup -Filter "SID -like '$($privilege)'" | Select-Object Name
            $Actual_group_name_print = $Actual_group_name.Name
            "Back up files and directories: Grupa $($Actual_group_name_print): Niezgodne" | Out-File $report_file_path -Append
        }
    }

    "" | Out-File $report_file_path -Append

    "Security Options" | Out-File $report_file_path -Append

    # Porównanie zakładanej i istniejącej nazwy konta administratora
    if($Admin_name_config -eq $Admin_name_secedit){
        "Accounts: Rename Administrator account: Zgodne" | Out-File $report_file_path -Append
    }
    else{
        "Accounts: Rename Administrator account: Niezgodne" | Out-File $report_file_path -Append
    }
    # Porównanie zakładanej i istniejącej nazwy konta administratora
    if($Guest_name_config -eq $Guest_name_secedit){
        "Accounts: Rename Guest account: Zgodne" | Out-File $report_file_path -Append
    }
    else{
        "Accounts: Rename Guest account: Niezgodne" | Out-File $report_file_path -Append
    }

    "" | Out-File $report_file_path -Append

    "WSUS Settings" | Out-File $report_file_path -Append

    # Porównanie zakładanego i istniejącego trybu i czasu automatycznych aktualizacji
    if($Automatic_Updates -eq $Automatic_Updates_config){
        if($Automatic_Updates_time -eq $Automatic_Updates_config_time){
            "Configure Automatic Updates: Zgodne" | Out-File -FilePath $report_file_path -Append
        }
        else{
            "Configure Automatic Updates: Niezgodne" | Out-File -FilePath $report_file_path -Append
        }
    }
    else{
        "Configure Automatic Updates: Niezgodne" | Out-File -FilePath $report_file_path -Append
    }

    # Określenie, czy adres serwera aktualizacji został określony oraz porównanie, czy zgodnie z plikiem konfiguracyjnym powinien być określony
    if($Update_server -eq $Update_server_config){
        "Specify intranet Microsoft update service location: Zgodne" | Out-File -FilePath $report_file_path -Append
    }
    else{
        "Specify intranet Microsoft update service location: Niezgodne" | Out-File -FilePath $report_file_path -Append
    }

    "" | Out-File $report_file_path -Append

    # Określenie, czy usługa Application Indentity została uruchomiona
    if($App_Identity_status -eq $App_Identity_status_config){
        "Application Identity Status: Zgodne" | Out-File -FilePath $report_file_path -Append
    }
    else{
        "Application Identity Status: Niezgodne" | Out-File -FilePath $report_file_path -Append
    }

    # Sprzątanie
    Invoke-Command -ComputerName $current_computer -ScriptBlock {
        param($Secedit_file_path)
        Remove-Item -Path $Secedit_file_path
    } -ArgumentList $Secedit_file_path

    #Invoke-Command -ComputerName $current_computer -ScriptBlock {
    #    param($folder_path)
    #    Remove-Item -Path $folder_path
    #} -ArgumentList $folder_path

    #Invoke-Command -ComputerName $current_computer -ScriptBlock {
    #    param($base_folder_path)
    #    Remove-Item -Path $base_folder_path
    #} -ArgumentList $base_folder_path
}
