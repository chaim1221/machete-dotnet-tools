param (
  $adminPassword = "@dminPassword22"
)

# note: "@Password1" is literally the password being used on this TEST server
# if scripts were adapted to production usage, an encrypted value would have to be stored and deciphered

# USERS
write-host "Adding users..."
NET USER machete $adminPassword /ADD /Y
NET USER machete_sqlserver $adminPassword /ADD /Y
NET USER ssrs_user "@Password1" /ADD /Y
NET USER casa_user "@Password1" /ADD /Y
NET USER graton_user "@Password1" /ADD /Y
NET USER mtnview_user "@Password1" /ADD /Y
NET USER pomona_user "@Password1" /ADD /Y
NET USER voz_user "@Password1" /ADD /Y
write-host "OK" -f green

# GROUPS
write-host "Adding groups and members..."
NET LOCALGROUP "Administrators" "machete" /ADD
NET LOCALGROUP "Administrators" "machete_sqlserver" /ADD
NET LOCALGROUP "SSRS_USERS" /ADD
NET LOCALGROUP "SSRS_USERS" "casa_user" /ADD
NET LOCALGROUP "SSRS_USERS" "mtnview_user" /ADD
NET LOCALGROUP "SSRS_USERS" "graton_user" /ADD
NET LOCALGROUP "SSRS_USERS" "pomona_user" /ADD
NET LOCALGROUP "SSRS_USERS" "voz_user" /ADD
write-host "OK" -f green
