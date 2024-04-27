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

param($ProjectName,$IntermediateOutputPath,$OutDir,$PublishDir)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$compatiblePSEdition = 'Core'
$PowerShellVersion = '7.2'

function Get-SingleNodeValue([System.Xml.XmlDocument]$doc,[string]$path)
{
    return $doc.SelectSingleNode($path).FirstChild.Value
}

trap
{
	throw $PSItem
}

$xmlDoc = [System.Xml.XmlDocument](Get-Content "$ProjectName.csproj")

$ModuleId = Get-SingleNodeValue $xmlDoc '/Project/PropertyGroup/PackageId'
$Version = Get-SingleNodeValue $xmlDoc '/Project/PropertyGroup/Version'
$ProjectUri = Get-SingleNodeValue $xmlDoc '/Project/PropertyGroup/PackageProjectUrl'
$Description = Get-SingleNodeValue $xmlDoc '/Project/PropertyGroup/Description'
$Author = Get-SingleNodeValue $xmlDoc '/Project/PropertyGroup/Authors'
$Copyright = Get-SingleNodeValue $xmlDoc '/Project/PropertyGroup/Copyright'
$AssemblyName = Get-SingleNodeValue $xmlDoc '/Project/PropertyGroup/AssemblyName'
$CompanyName = Get-SingleNodeValue $xmlDoc '/Project/PropertyGroup/Company'

$moduleSettings = @{
	Path = "$IntermediateOutputPath$ModuleId.psd1"
	RootModule = "$AssemblyName.dll"
	ModuleVersion = $Version
	Guid = '204158b2-4c7b-4282-b326-33f0876c500d'
	Author = $Author
	CompanyName = $CompanyName
	Copyright = $Copyright
	Description = $Description
	PowerShellVersion = $PowerShellVersion
	CompatiblePSEditions = @($compatiblePSEdition)
	FunctionsToExport = @()
	CmdletsToExport = @("New-$ProjectName")
	VariablesToExport = '*'
	AliasesToExport = @()
	ProjectUri = $ProjectUri
}

New-ModuleManifest @moduleSettings

Import-PowerShellDataFile -LiteralPath "$IntermediateOutputPath$ModuleId.psd1" | Export-PowerShellDataFile | Set-Content -LiteralPath "$PublishDir$ModuleId.psd1"

(Get-Content "./README.md")[0..2] | Set-Content -Path "$PublishDir/README.md"

If (-not($IsWindows))
{
	Get-ChildItem -Path $PublishDir -File | Foreach-Object {
		chmod -x $_.FullName
		If ( $LastExitCode -ne 0 )
		{
			Exit $LastExitCode
		}
	}
}
