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

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
$BINDIR = "bin/Release/netstandard2.1/publish"

trap
{
	throw $PSItem
}

foreach ($Name in "obj", "bin", "MySqlConnection", "MySqlConnection.zip")
{
	if (Test-Path "$Name")
	{
		Remove-Item "$Name" -Force -Recurse
	} 
}

dotnet publish MySqlConnection.csproj --configuration Release

If ( $LastExitCode -ne 0 )
{
	Exit $LastExitCode
}

$null = New-Item -Path "MySqlConnection" -ItemType Directory

foreach ($Filter in "MySql*")
{
	Get-ChildItem -Path "$BINDIR" -Filter $Filter | Foreach-Object {
		Copy-Item -Path $_.FullName -Destination "MySqlConnection"
	}
}

Compress-Archive -Path "MySqlConnection" -DestinationPath "MySqlConnection.zip"
