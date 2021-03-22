$current_domain = (Get-ADDomain).DistinguishedName 
$current_domain = $current_domain.Replace("DC=","") 
$current_domain = $current_domain.Replace(",",".") 
$domain_DC1 = $current_domain.Substring(0,$current_domain.IndexOf(".")) 
$domain_DC2 = $current_domain.Substring($current_domain.LastIndexOf(".")+1) 
$nr_indeksu = 16919 
$path_directory = "C:\WIT\ID06TC2\16919" 
$path_OUcsv = "$($path_directory)\new_OU_16919.csv" 
$path_OU_empty = "$($domain_DC1),$($domain_DC2),$($nr_indeksu)" 
$path_OU_IT = "$($path_OU_empty),IT" 
$path_OU_ADM = "$($path_OU_empty),ADM" 

$path_userdata_html = "$($path_directory)\userdata_$($nr_indeksu).html"
$path_inactive_users_accounts = "$($path_directory)\inactive_users_accounts_$($nr_indeksu).html" 
$path_users_password = "$($path_directory)\users_Passwords_NE_$($nr_indeksu).html"
$path_OU_in_domain = "$($path_directory)\OU_in_$($current_domain)_$($nr_indeksu).html" 


$User1_name = "Jan" 
$User1_surname = "Góra" 
$User2_name = "Olga" 
$User2_surname = "Jóźwiak"
$User3_name = "Piotr" 
$User3_surname = "Łęgowski" 
$User4_name = "Ewa" 
$User4_surname = "Mańka" 
$User5_name = "Anna" 
$User5_surname = "Polak" 
$User6_name = "Łukasz"
$User6_surname = "Źdźbło" 
$path_Users_csv = "$($path_directory)\new_users_16919.csv" 
$path_Users_csv_pass = "$($path_directory)\new_users_16919_with_pass.csv"
$Name_Col_1 = "Domain_name_part_1" 
$Name_Col_2 = "Domain_name_part_2"
$Name_Col_3 = "OU_index"
$Name_Col_4 = "Department" 
$Name_Col_5 = "Name" 
$Name_Col_6 = "Surname"
$Header_csv_user_path = "$($Name_Col_1),$($Name_Col_2),$($Name_Col_3),$($Name_Col_4),$($Name_Col_5),$($Name_Col_6)" 



$path_groups_csv = "$($path_directory)\new_groups_16919.csv" 
$name_group_IT = "G_IT_16919" 
$name_group_ADM = "G_ADM_16919" 
$name_group_HR = "G_HR_16919" 
$path_OU_HR = "$($path_OU_empty),KADRY" 

$ManagedBy = "CN=Administrator,CN=Users,DC=ocean,DC=local" 
$ServerName = "SHARK" 
$country = "PL" 
$office = "WIT Warszawa" 
$my_group_nr = "ID06TC2" 

$OU_path_domain_base = "DC=$($domain_DC1),DC=$($domain_DC2)" 
$OU_path_index_clear = "OU=$($nr_indeksu),DC=$($domain_DC1),DC=$($domain_DC2)" 
$OU_path_index_IT = "OU=IT,$($OU_path_index_clear)" 
$OU_path_index_ADM = "OU=ADM,$($OU_path_index_clear)" 
$OU_path_group_index_base = "OU=$($nr_indeksu),OU=$($my_group_nr),$($OU_path_domain_base)" 
$OU_path_group_index_IT = "OU=IT,$($OU_path_group_index_base)" 
$OU_path_group_index_ADM = "OU=ADM,$($OU_path_group_index_base)" 
$OU_path_group_index_HR = "OU=KADRY,$($OU_path_group_index_base)" 
$OU_path_group_base = "OU=$($my_group_nr),DC=$($domain_DC1),DC=$($domain_DC2)" 

#Remove-ADOrganizationalUnit -Identity $OU_path_group_base -Recursive -Confirm:$false
#Remove-ADOrganizationalUnit -Identity "OU=16919,$($OU_path_domain_base)" -Recursive -Confirm:$false

"$($path_OU_empty)" | Out-File $path_OUcsv 
"$($path_OU_IT)" | Out-File $path_OUcsv -Append 
"$($path_OU_ADM)" | Out-File $path_OUcsv -Append 

"$($Header_csv_user_path)" | Out-File $path_Users_csv
"$($path_OU_IT),$($User1_name),$($User1_surname)" | Out-File $path_Users_csv -Append
"$($path_OU_IT),$($User2_name),$($User2_surname)" | Out-File $path_Users_csv -Append 
"$($path_OU_HR),$($User3_name),$($User3_surname)" | Out-File $path_Users_csv -Append 
"$($path_OU_HR),$($User4_name),$($User4_surname)" | Out-File $path_Users_csv -Append 
"$($path_OU_ADM),$($User5_name),$($User5_surname)" | Out-File $path_Users_csv -Append 
"$($path_OU_ADM),$($User6_name),$($User6_surname)" | Out-File $path_Users_csv -Append 

Import-Csv $path_Users_csv -Encoding Default | ForEach-Object { 
    $newPass = '' 
    
    1..16| ForEach-Object { 
    $newPass += [char](Get-Random -Minimum 48 -Maximum 122) 
    } 
    $_ | Add-Member -MemberType NoteProperty -Name "Password" -Value $newPass -PassThru 
} | Export-Csv $path_Users_csv_pass -Encoding Default 

"$($path_OU_IT),$($name_group_IT)" | Out-File $path_groups_csv 
"$($path_OU_ADM),$($name_group_ADM)" | Out-File $path_groups_csv -Append 
"$($path_OU_HR),$($name_group_HR)" | Out-File $path_groups_csv -Append 

$OU_db = Import-Csv "$($path_OUcsv)" -Header "Domain_name_part_1","Domain_name_part_2","OU_index","Department" -Encoding Default 
$USER_db = Import-Csv "$($path_Users_csv_pass)" -Encoding Default
$GROUPS_db = Import-Csv "$($path_groups_csv)" -Header "Domain_name_part_1","Domain_name_part_2","OU_index","Department","Group_Name" -Encoding Default 

if(!(Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$OU_path_index_clear'")) 
{ 
    New-ADOrganizationalUnit `
    -Name:"$($nr_indeksu)" `
    -Path:"$($OU_path_domain_base)" `
    -ProtectedFromAccidentalDeletion:$false `
    -Server:"$($ServerName)"
} 

$OU_db | ForEach-Object { 
    $name = "$($_.Department)"
    $index = $_.OU_Index
    $DomainName1 = $_.Domain_name_part_1 
    $DomainName2 = $_.Domain_name_part_2 

    if(!($name)){} 
    else 
    { 
        if(!(Get-ADOrganizationalUnit -Filter "DistinguishedName -eq 'OU=$name,$OU_path_index_clear'")) 
        {             
            New-ADOrganizationalUnit `
            -Name:"$($name)" `
            -Path:"OU=$($index),DC=$($DomainName1),DC=$($DomainName2)" `
            -ProtectedFromAccidentalDeletion $false `
            -Server:"$($ServerName)"
        }
    }
}

if(!(Test-Path "AD:\$($OU_path_group_base)")) 
{ 
    New-ADOrganizationalUnit `
    -Name:"$($my_group_nr)" `
    -Path:"$($OU_path_domain_base)" `
    -ProtectedFromAccidentalDeletion:$false `
    -Server:"$($ServerName)"
} 

if(!(Test-Path "AD:\$($OU_path_group_index_base)"))
{ 
    New-ADOrganizationalUnit `
    -Name:"$($nr_indeksu)" `
    -Path:"$($OU_path_group_base)" `
    -ProtectedFromAccidentalDeletion:$false `
    -Server:"$($ServerName)"
} 

$USER_db | ForEach-Object { 

$password = $_.Password 
$name = $_.Name
$surname = $_.Surname 
$department = $_.Department 
$OUindex = $_.OU_index 
$DomainName1 = $_.Domain_name_part_1 
$DomainName2 = $_.Domain_name_part_2 
$path_User = "OU=$($department),OU=$($OUindex),OU=$($my_group_nr),DC=$($DomainName1),DC=$($DomainName2)" 

$name = $name.Replace("ą","a") 
$name = $name.Replace("ć","c")
$name = $name.Replace("ę","e")
$name = $name.Replace("ł","l")
$name = $name.Replace("ń","n") 
$name = $name.Replace("ó","o") 
$name = $name.Replace("ś","s") 
$name = $name.Replace("ź","z") 
$name = $name.Replace("ż","ż") 
$surname = $surname.Replace("ą","a")
$surname = $surname.Replace("ć","c") 
$surname = $surname.Replace("ę","e") 
$surname = $surname.Replace("ł","l") 
$surname = $surname.Replace("ń","n") 
$surname = $surname.Replace("ó","o") 
$surname = $surname.Replace("ś","s") 
$surname = $surname.Replace("ź","z")
$surname = $surname.Replace("ż","ż") 
$name = $name.Replace("Ą","A") 
$name = $name.Replace("Ć","C") 
$name = $name.Replace("Ę","E")
$name = $name.Replace("Ł","L") 
$name = $name.Replace("Ń","N") 
$name = $name.Replace("Ó","O") 
$name = $name.Replace("Ś","S") 
$name = $name.Replace("Ź","Z") 
$name = $name.Replace("Ż","Z") 
$surname = $surname.Replace("Ą","A") 
$surname = $surname.Replace("Ć","C") 
$surname = $surname.Replace("Ę","E") 
$surname = $surname.Replace("Ł","L") 
$surname = $surname.Replace("Ń","N") 
$surname = $surname.Replace("Ó","O") 
$surname = $surname.Replace("Ś","S") 
$surname = $surname.Replace("Ź","Z")
$surname = $surname.Replace("Ż","Z") 
 
if(!(Test-Path "AD:\OU=$($department),$($OU_path_group_index_base)")) 
{ 
    New-ADOrganizationalUnit `
    -Name:$department `
    -Path:"OU=$($OUindex),OU=$($my_group_nr),DC=$($DomainName1),DC=$($DomainName2)" `
    -ProtectedFromAccidentalDeletion:$false `
    -Server:"$($ServerName)"
} 
New-ADUser `
-SamAccountName:"$($name).$($surname)" `
-DisplayName:"$($name) $($surname)" `
-Department:"Dzial$($department)_$($OUindex)" `
-EmailAddress:"$($name).$($surname)_$($OUindex)@$($current_domain)" `
-Office:"$($office)" `
-Path:"$($path_User)" `
-Country:"$($country)" `
-Server:"$($ServerName)" `
-Surname:"$($surname)" `
-GivenName:"$($name)" `
-Type:"$($user)" `
-Name:"$($name) $($surname)"

Set-ADAccountPassword `
-Identity:"CN=$($name) $($surname),$($path_User)" `
-NewPassword:(ConvertTo-SecureString -AsPlainText "$($password)" -Force) `
-Reset:$true `
-Server:"$($ServerName)"

Enable-ADAccount `
-Identity:"CN=$($name) $($surname),$($path_User)" `
-Server:"$($ServerName)"
} 

$GROUPS_db | ForEach-Object { 
    $GDomain1 = $_.Domain_name_part_1 
    $GDomain2 = $_.Domain_name_part_2 
    $GIndex = $_.OU_index 
    $GDepartment = $_.Department 
    $GGroupName = $_.Group_Name 

     
    New-ADGroup `
    -GroupCategory:"Security" `
    -GroupScope:"Global" `
    -Name:"$($GGroupName)" `
    -Path:"OU=$($GDepartment),OU=$($GIndex),OU=$($my_group_nr),DC=$($GDomain1),DC=$($GDomain2)" `
    -SamAccountName:"$($GGroupName)" `
    -Server:"$($ServerName)"

    $Path_group_dir = "OU=$($GDepartment),OU=$($GIndex),OU=$($my_group_nr),DC=$($GDomain1),DC=$($GDomain2)" 
    $Path_group_name = "CN=$($GGroupName),OU=$($GDepartment),OU=$($GIndex),OU=$($my_group_nr),DC=$($GDomain1),DC=$($GDomain2)" 

    Get-ADUser -Filter * -SearchBase $Path_group_dir | ForEach-Object {
        $Path = $_.DistinguishedName 
        $Path = $Path.Substring(0,$Path.IndexOf(","))
        Add-ADPrincipalGroupMembership -Identity:"$($Path),$($Path_group_dir)" -Server:"$($ServerName)" -MemberOf:"$($Path_group_name)"  
    }
}


Get-ADUser -Filter * -Properties WhenCreated,LastLogonDate `
| Select-Object GivenName,Surname,DistinguishedName,SID,WhenCreated,LastLogonDate `
| ConvertTo-Html `
| Out-File $path_userdata_html  

Get-ADUser -Filter * -Properties LastLogonDate `
| Select-Object GivenName,Surname,DistinguishedName,LastLogonDate `
| ConvertTo-Html `
| Out-File $path_inactive_users_accounts

Get-ADUser -Filter * `
| Select-Object GivenName,Surname,DistinguishedName `
| ConvertTo-Html `
| Out-File $path_users_password

Get-ADOrganizationalUnit -Filter * `
| Select Name,DistinguishedName `
| ConvertTo-Html `
| Out-File $path_OU_in_domain

