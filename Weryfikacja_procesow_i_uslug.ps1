# Deklaracja zmiennych
$indeks = "16919"
$report_file_path = "C:\wit\Zadanie2\"
$configuration_file_path = "C:\wit\Zadanie2\Services.txt"
$configuration_file_path_proces = "C:\wit\Zadanie2\Processes.txt"

# Iteracja po wszystkich nazwach kontrolerów domeny
Get-ADDomainController -Filter * |select -ExpandProperty name | ForEach-Object {
    
    # przypisanie nazwy kontrolera domeny do zmiennej, żeby w pętli wewnętrznej można było się do niej odwołać przez konrketną zmienną
    $domain_controller = $_

    # określnie ścieżki pliku wyjściowego
    $processes_file_path = "$($report_file_path)$($indeks)_$($_)_procesy.txt"
    
    # Weryfikacja czy plik wyjściowy został już utworzony - jeżeli nie zostanie utworzony, jeżeli tak to jego zawartość zostanie wyczyszczona
    if(!(Test-Path $processes_file_path)){
        New-Item -ItemType File -Path $processes_file_path
    }
    else
    {
        Clear-Content $processes_file_path
    }

    # Rozpoczęcie iteracji po wszystkich procesach, które zostały zapisane w pliku do weryfikacji
    Get-Content $configuration_file_path_proces | ForEach-Object {
        
        # Przypisanie nazwy aktualnie iterowanego procesu do zmiennej
        $Proces = $_

        # Weryfikacja istniejących procesów na kontrolerze domeny
        $check_proces = Invoke-Command -ComputerName $domain_controller -ScriptBlock { param($domain_controller) Get-Process $domain_controller -ErrorAction Ignore}`
        -ArgumentList $Proces | Select-Object ProcessName  
            
            # weryfikacja, czy aktualnie sprawdzany proces istnieje 
            if ($check_proces){

                # zliczenie wystąpień danego procesu
                $count = $check_proces| Measure-Object | Select-Object -Property Count 
                
                # "przerobienie" liczby wystapień na liczbę i przypisanie jej do zmiennej
                $count_print = ($count).Count

                # wpisanie odpowiedniej informacji do pliku wyjściowego
                "Istnieje proces $($Proces), liczba wystąpień $($count_print)" | Out-File -FilePath $processes_file_path -Append
            }
            # określenie zachowania, gdy weryfikowany proces nie istnieje
            else{
                
                # wypisanie odpowiedniej informacji w pliku wyjściowym
                "Brak procesu $($Proces)" | Out-File -FilePath $processes_file_path -Append
            }
    } 
  
}

# Iteracja po wszystkich nazwach kontrolerów domeny
Get-ADDomainController -Filter * |select -ExpandProperty name | ForEach-Object {

    # przypisanie nazwy kontrolera domeny do zmiennej, żeby w pętli wewnętrznej można było się do niej odwołać przez konrketną zmienną
    $domain_controller = $_

    # określnie ścieżki pliku wyjściowego
    $services_file_path = "$($report_file_path)$($indeks)_$($_)_usługi.txt"

     # Weryfikacja czy plik wyjściowy został już utworzony - jeżeli nie zostanie utworzony, jeżeli tak to jego zawartość zostanie wyczyszczona
    if(!(Test-Path $services_file_path)){
        New-Item -ItemType File -Path $services_file_path
    }
    else
    {
        Clear-Content $services_file_path
    }

     # Rozpoczęcie iteracji po wszystkich usługach, które zostały zapisane w pliku do weryfikacji
    Get-Content $configuration_file_path | ForEach-Object {

        # Przypisanie nazwy aktualnie iterowanej usługi do zmiennej
        $Service = $_

        # Weryfikacja istniejących usług na kontrolerze domeny
        $check_service = Invoke-Command $domain_controller -ScriptBlock { param($domain_controller) Get-Service $domain_controller -ErrorAction Ignore } -ArgumentList $Service | Select-Object Name
        
        # weryfikacja, czy aktualnie sprawdzana usługa istnieje
        if($check_service){

            # wypisanie odpowiedniej informacji do pliku wyjściowego
            "Istnieje usługa $($Service)" | Out-File -FilePath $services_file_path -Append
        }
        # określenie zachowania, gdy aktualnie sprawdzana usługa nie istnieje
        else{
            
            # wypisanie odpowiedniej informacji do pliku wyjściowego
            "Brak usługi $($Service)" | Out-File -FilePath $services_file_path -Append
        }
    }
}
