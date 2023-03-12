#!/usr/bin/env pwsh
#
#  Copyright 2023, Roger Brown
#
#  This file is part of rhubarb-geek-nz/MySqlConnection.
#
#  This program is free software: you can redistribute it and/or modify it
#  under the terms of the GNU General Public License as published by the
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
	$ModuleName = "MySqlConnection"
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

trap
{
	throw $PSItem
}

$env:SOURCEDIR="$ModuleName"
$env:MYSQLVERS=( Import-PowerShellDataFile "$ModuleName/$ModuleName.psd1" ).ModuleVersion

foreach ($List in @(
	@("no","09D88E16-6180-42C0-A6F8-BDEE5F0D9E3A","netstandard2.0","x86","ProgramFilesFolder","2.2.5"),
	@("yes","ECC9A102-0161-4B4C-803C-FC241BE784C1","netstandard2.0","x64","ProgramFiles64Folder","2.2.5")
))
{
	$env:MYSQLISWIN64=$List[0]
	$env:MYSQLUPGRADECODE=$List[1]
	$env:MYSQLFRAMEWORK=$List[2]
	$env:MYSQLPLATFORM=$List[3]
	$env:MYSQLPROGRAMFILES=$List[4]

	If ( $env:MYSQLVERS -eq $List[5] )
	{
		$MSINAME = "$ModuleName-$env:MYSQLVERS-$env:MYSQLPLATFORM.msi"

		foreach ($Name in "$MSINAME")
		{
			if (Test-Path "$Name")
			{
				Remove-Item "$Name"
			} 
		}

		& "${env:WIX}bin\candle.exe" -nologo "$ModuleName.wxs"

		if ($LastExitCode -ne 0)
		{
			exit $LastExitCode
		}

		& "${env:WIX}bin\light.exe" -nologo -cultures:null -out "$MSINAME" "$ModuleName.wixobj"

		if ($LastExitCode -ne 0)
		{
			exit $LastExitCode
		}
	}
}
