/**************************************************************************
 *
 *  Copyright 2024, Roger Brown
 *
 *  This file is part of rhubarb-geek-nz/MySqlConnection.
 *
 *  This program is free software: you can redistribute it and/or modify it
 *  under the terms of the GNU Lesser General Public License as published by the
 *  Free Software Foundation, either version 3 of the License, or (at your
 *  option) any later version.
 * 
 *  This program is distributed in the hope that it will be useful, but WITHOUT
 *  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 *  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
 *  more details.
 *
 *  You should have received a copy of the GNU Lesser General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>
 *
 */

using System;
using System.Data.Common;
using System.IO;
using System.Management.Automation;
using System.Reflection;
using System.Runtime.Loader;

namespace RhubarbGeekNz.MySqlConnection
{
    [Cmdlet(VerbsCommon.New,"MySqlConnection")]
    [OutputType(typeof(DbConnection))]
    public class NewMySqlConnection : PSCmdlet
    {
        [Parameter(
            Mandatory = true,
            Position = 0,
            ValueFromPipeline = true,
            ValueFromPipelineByPropertyName = true)]
        public string ConnectionString { get; set; }

        protected override void ProcessRecord()
        {
            WriteObject(MySqlConnectionFactory.CreateInstance(ConnectionString));
        }
    }

    internal class AlcModuleAssemblyLoadContext : AssemblyLoadContext
    {
        private readonly string dependencyDirPath;

        public AlcModuleAssemblyLoadContext(string dependencyDirPath)
        {
            this.dependencyDirPath = dependencyDirPath;
        }

        protected override Assembly Load(AssemblyName assemblyName)
        {
            string assemblyPath = Path.Combine(
                dependencyDirPath,
                $"{assemblyName.Name}.dll");

            if (File.Exists(assemblyPath))
            {
                return LoadFromAssemblyPath(assemblyPath);
            }

            return null;
        }
    }

    public class AlcModuleResolveEventHandler : IModuleAssemblyInitializer, IModuleAssemblyCleanup
    {
        private static readonly string dependencyDirPath;

        private static readonly AlcModuleAssemblyLoadContext dependencyAlc;

        private static readonly Version alcVersion;

        private static readonly string alcName;

        static AlcModuleResolveEventHandler()
        {
            Assembly assembly = Assembly.GetExecutingAssembly();
            dependencyDirPath = Path.GetFullPath(Path.Combine(Path.GetDirectoryName(assembly.Location), "lib"));
            dependencyAlc = new AlcModuleAssemblyLoadContext(dependencyDirPath);
            AssemblyName name = assembly.GetName();
            alcVersion = name.Version;
            alcName = name.Name + ".Alc";
        }

        public void OnImport()
        {
            AssemblyLoadContext.Default.Resolving += ResolveAlcModule;
        }

        public void OnRemove(PSModuleInfo psModuleInfo)
        {
            AssemblyLoadContext.Default.Resolving -= ResolveAlcModule;
        }

        private static Assembly ResolveAlcModule(AssemblyLoadContext defaultAlc, AssemblyName assemblyToResolve)
        {
            if (alcName.Equals(assemblyToResolve.Name) && alcVersion.Equals(assemblyToResolve.Version))
            {
                return dependencyAlc.LoadFromAssemblyName(assemblyToResolve);
            }

            return null;
        }
    }
}
