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
$PackageName = "rhubarb-geek-nz-$ModuleName"

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
$null = New-Item -Path "." -Name "rpms" -ItemType "directory"

try
{
	Get-ChildItem -Path "$ModuleName" | Foreach-Object {
		Copy-Item -Path $_.FullName -Destination "root/$ModulesPath/$ModuleName"
	}

	@"
Name: $PackageName
Version: $Version
Release: 1
BuildArch: noarch
Requires: powershell
License: LGPL3
Packager: $Maintainer
Summary: PowerShell $ModuleName Cmdlet
Prefix: /$ModulesPath

%description
PowerShell Cmdlet for connection to MySql databases

%files
%defattr(-,root,root)
%dir %attr(555,root,root) /$ModulesPath/$ModuleName
%attr(444,root,root)      /$ModulesPath/$ModuleName/$ModuleName.dll
%attr(444,root,root)      /$ModulesPath/$ModuleName/$ModuleName.psd1
%attr(444,root,root)      /$ModulesPath/$ModuleName/MySqlConnector.dll

"@ | Set-Content "rpm.spec"

	rpmbuild --buildroot "$PSScriptRoot/root" --define "_build_id_links none" --define "_rpmdir $PSScriptRoot/rpms" -bb "$PSScriptRoot/rpm.spec"

	If ( $LastExitCode -ne 0 )
	{
		Exit $LastExitCode
	}

	Get-ChildItem -LiteralPath "rpms" -Filter "*.rpm" -Recurse | Foreach-Object {
		$FileName = $_.Name
		Copy-Item $_.FullName -Destination "$FileName"
	}
}
finally
{
	foreach ($Name in "root", "rpms")
	{
		if (Test-Path $Name)
		{
			Remove-Item "$Name" -Recurse -Force
		}
	}
}
