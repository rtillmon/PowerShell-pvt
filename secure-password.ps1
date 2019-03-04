#Script for creating a secure password for use in a script

$Key = (3,30,74,2,5,82,5,11,98,9,17,200,5,13,2,9,21,12,6,3,10,10,15,11) #Create an encryption key.  24 numbers from 1 to 255 comma delimited.
$secure = Read-Host -AsSecureString #Get input from user.  Type the password to be encrypted here.  Saved as a 'secure string' in this variable.
$encrypted = ConvertFrom-SecureString -SecureString $secure -Key $Key #Convert the secure string to an encrypted password and assign the key to it.
$encrypted | Set-Content r-a-hd_enc.txt #Write the encrypted password to a text file that can be reused in future scripts.
$secureadmin = Get-Content .\r-a-hd_enc.txt | ConvertTo-SecureString -Key $Key #Import the encrypted password to a variable to be use when passing creds in scripts.
