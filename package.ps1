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
$BINDIR = "bin/Release/netstandard2.0/publish"
$ModuleName = "MySqlConnection"

trap
{
	throw $PSItem
}

$xmlDoc = [System.Xml.XmlDocument](Get-Content "$ModuleName.nuspec")

$Version = $xmlDoc.SelectSingleNode("/package/metadata/version").FirstChild.Value
$CompanyName = $xmlDoc.SelectSingleNode("/package/metadata/authors").FirstChild.Value
$ModuleId = $xmlDoc.SelectSingleNode("/package/metadata/id").FirstChild.Value

foreach ($Name in "obj", "bin", "$ModuleId")
{
	if (Test-Path "$Name")
	{
		Remove-Item "$Name" -Force -Recurse
	} 
}

dotnet publish $ModuleName.csproj --configuration Release

If ( $LastExitCode -ne 0 )
{
	Exit $LastExitCode
}

$null = New-Item -Path "$ModuleId" -ItemType Directory

foreach ($Filter in "MySql*")
{
	Get-ChildItem -Path "$BINDIR" -Filter $Filter | Foreach-Object {
		if ((-not($_.Name.EndsWith('.pdb'))) -and (-not($_.Name.EndsWith('.deps.json'))))
		{
			Copy-Item -Path $_.FullName -Destination "$ModuleId"
		}
	}
}

@"
@{
	RootModule = '$ModuleName.dll'
	ModuleVersion = '$Version'
	GUID = '204158b2-4c7b-4282-b326-33f0876c500d'
	Author = 'Roger Brown'
	CompanyName = 'rhubarb-geek-nz'
	Copyright = '(c) Roger Brown. All rights reserved.'
	FunctionsToExport = @()
	CmdletsToExport = @('New-$ModuleName')
	VariablesToExport = '*'
	AliasesToExport = @()
	PrivateData = @{
		PSData = @{
		}
	}
}
"@ | Set-Content -Path "$ModuleId/$ModuleId.psd1"

(Get-Content "./README.md")[0..2] | Set-Content -Path "$ModuleId/README.md"

nuget pack "$ModuleName.nuspec"

If ( $LastExitCode -ne 0 )
{
	Exit $LastExitCode
}
