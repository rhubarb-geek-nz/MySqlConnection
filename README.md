# MySqlConnection

Very simple `PowerShell` module for creating a connection to a `MySql` database.

Build using the `package.ps1` script to create the `MySqlConnection.zip` file.

Install by unzipping into a directory on the [PSModulePath](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_psmodulepath)

Run the `test.ps1` to confirm it works.

```

VERSION()
---------
8.0.32

```
The following scripts can be used to make formal packages for specific RID.

| Script | RID | Installation Directory |
| ------ | --- | ---------------------- |
| makemsi.ps1 | win | c:\Program Files\PowerShell\Modules\MySqlConnection |
| makeosx.ps1 | osx | /usr/local/share/powershell/Modules/MySqlConnection |
| makedeb.ps1 | linux | /opt/microsoft/powershell/7/Modules/MySqlConnection |
| makerpm.ps1 | linux | /opt/microsoft/powershell/7/Modules/MySqlConnection |
