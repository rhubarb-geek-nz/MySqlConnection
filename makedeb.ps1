#!/usr/bin/env pwsh
#
#  Copyright 2023, Roger Brown
#
#  This file is part of rhubarb-geek-nz/MySqlConnection.
#
#  This program is free software: you can redistribute it and/or modify it
#  under the terms of the GNU Lesser General Public License as published by the
#  Free Software Foundation, either version 3 of the License, or (at your
#  option) any later version.
# 
#  This program is distributed in the hope that it will be useful, but WITHOUT
#  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
#  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
#  more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>
#

param(
	$ModuleName = "MySqlConnection",
	$Maintainer = "$Env:MAINTAINER"
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
$ModulesPath = "opt/microsoft/powershell/7/Modules"
$PackageName = "rhubarb-geek-nz-mysqlconnection"

If ( -not( $Env:PSModulePath.Split(":").Contains("/$ModulesPath") ) )
{
	throw "$Env:PSModulePath does not contain /$ModulesPath"
}

If (-not($Maintainer))
{
	throw "MAINTAINER environment not set"
}

trap
{
	throw $PSItem
}

foreach ($Name in "data")
{
	if (Test-Path "$Name")
	{
		Remove-Item "$Name" -Force -Recurse
	} 
}

$Version=( Import-PowerShellDataFile "$ModuleName/$ModuleName.psd1" ).ModuleVersion

$null = New-Item -Path "." -Name "root/$ModulesPath/$ModuleName" -ItemType "directory"

try
{
	Get-ChildItem -Path "$ModuleName" | Foreach-Object {
		$Name = $_.Name
		Copy-Item -Path $_.FullName -Destination "root/$ModulesPath/$ModuleName/$Name"
		chmod -x "root/$ModulesPath/$ModuleName/$Name"
	}

	$Size = ((du -sk root) -split '\s+')[0]

	if (-not($Size))
	{
		throw "du -sk root failed"
	}

	$null = New-Item -Path "root" -Name "DEBIAN" -ItemType "directory"

	$DpkgArch = 'all'

	@"
Package: $PackageName
Version: $Version
Architecture: $DpkgArch
Depends: powershell
Section: misc
Priority: optional
Installed-Size: $Size
Maintainer: $Maintainer
Description: PowerShell $ModuleName Cmdlet
"@ | Set-Content "root/DEBIAN/control"

	dpkg-deb --root-owner-group --build root "${PackageName}_${Version}_${DpkgArch}.deb"

	If ( $LastExitCode -ne 0 )
	{
		Exit $LastExitCode
	}
}
finally
{
	foreach ($Name in "root")
	{
		if (Test-Path $Name)
		{
			Remove-Item "$Name" -Recurse -Force
		}
	}
}
