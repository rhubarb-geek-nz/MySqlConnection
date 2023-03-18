# MySqlConnection

Very simple `PowerShell` module for creating a connection to a `MySql` database.

Build using the `package.ps1` script.

Install by copying into a directory on the [PSModulePath](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_psmodulepath)

Create a test database.

```
$ docker run -p 3306:3306/tcp -e MYSQL_ROOT_PASSWORD=mysql mysql
```

Run the `test.ps1` to confirm it works.

```

VERSION()
---------
8.0.32

```
