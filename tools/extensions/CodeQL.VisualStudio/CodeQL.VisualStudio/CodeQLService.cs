// Copyright (c) Microsoft. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for full license information.

using EnvDTE;
using Microsoft.CodeAnalysis.Sarif;
using Microsoft.CodeQL.Options;
using Microsoft.Sarif.Viewer.Interop;
using Microsoft.VisualStudio.CodeAnalysis.CodeQL.Runner;
using Microsoft.VisualStudio.Shell;
using Microsoft.VisualStudio.Shell.Interop;
using Microsoft.VisualStudio.Threading;
using Microsoft.VisualStudio.VSHelp;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace Microsoft.CodeQL.Core
{
   
    internal class CodeQLService : IDisposable
    {
        private static CodeQLService _instance = null;
        private CancellationTokenSource _cancelToken;
        private TaskCompletionSource<bool> _taskCompleted;

        // service per project? 


        private class BuildInfo
        {
            public BuildInfo()
            {
                BuildGuid = "-1";
                SourceId = -1;
                ProjectName = null;
            }
            public int SourceId;
            public string BuildGuid;
            public string ProjectName;

            public class LogEntry
            {
                public DateTime timestamp { get; set; }
                public Source source { get; set; }
                public string plaintextMessage { get; set; }
                public string severity { get; set; }
            }

            public class Source
            {
                public string id { get; set; }
                public string name { get; set; }
            }
            // override equals

        }

        private BuildInfo _buildInfo;

        public string SelectedQuery { get; set; }


        public void UpdateBuildInfo(string buildGuid, string projectName = null)
        {
            _buildInfo.BuildGuid = buildGuid;
            if (projectName != null)
            {
                _buildInfo.ProjectName = projectName;
                _buildInfo.SourceId = ProjectHelper.CreateNumericalHash(projectName);
            }
            else
            {
                _buildInfo.ProjectName = ProjectHelper.GetActiveProjectName();
                _buildInfo.SourceId = ProjectHelper.CreateNumericalHash(_buildInfo.ProjectName);
            }
        }

        public void Dispose()
        {
            if (_taskCompleted != null)
            {
                _taskCompleted.TrySetResult(true);
                _taskCompleted = null;
            }
            if (_cancelToken != null)
            {
                _cancelToken.Dispose();
                _cancelToken = null;
            }
        }
        /// <summary>
        /// Gets the instance of the service.
        /// </summary>
        public static CodeQLService Instance
        {
            get
            {
                if (_instance == null)
                {
                    _instance = new CodeQLService();
                }
                return _instance;
            }
            private set { }
        }

        private CodeQLService()
        {
            _taskCompleted = null;
            _cancelToken = null;
            _buildInfo = new BuildInfo();
        }

        public bool IsCodeQLTaskRunning()
        {
            return _taskCompleted != null && !_taskCompleted.Task.IsCompleted;
        }

        public bool IsCodeQLTaskCompleted()
        {
            return _taskCompleted != null && _taskCompleted.Task.IsCompleted && !_taskCompleted.Task.IsCanceled;
        }

        public void ClearTask()
        {
            _taskCompleted = null;
            _cancelToken = null;
            ThreadHelper.JoinableTaskFactory.Run(() => ProjectHelper.HideProgressAsync());
        }

        public void InitTask()
        {
            _taskCompleted = new TaskCompletionSource<bool>(false);
            _cancelToken = new CancellationTokenSource();
        }

        public async Task CancelIfRunningAsync()
        {
            if (_cancelToken != null && !_cancelToken.IsCancellationRequested)
            {
                _cancelToken.Cancel();
            }

            if (_taskCompleted != null && !_taskCompleted.Task.IsCompleted)
            {
                _taskCompleted.TrySetCanceled();
            }
            await ProjectHelper.HideProgressAsync();
        }
      
        public async Task<ObservableCollection<string>> FindAvailableQueriesAsync()
        {
            List<string> packList = await CodeQLRunner.Instance.FindPacksAsync(CodeQLGeneralOptions.Instance.AdditionalQueryLocations);
            List<string> queryList = await CodeQLRunner.Instance.FindQueriesAsync(packList, queriesNSuites: false);
            return new ObservableCollection<string>(queryList.ToHashSet());
        }


        public async Task UpdateDatabaseBuildInfoAsync()
        {
            await CodeQLRunner.Instance.AddDBDiagInfoAsync(ProjectHelper.GetProjectDirectory(ProjectHelper.GetActiveProject()),
                _buildInfo.BuildGuid, 
                _buildInfo.SourceId);
        }

        private async Task<string> GetDatabaseBuildGuidAsync()
        {
            string dbInfo = await CodeQLRunner.Instance.GetDBDiagAsync();

            var entries = JsonConvert.DeserializeObject<List<BuildInfo.LogEntry>>(dbInfo);
            var ret = entries
            .Where(e => e.source?.name == "CodeqlVSExt" && !string.IsNullOrEmpty(e.plaintextMessage))
            .Select(e => e.plaintextMessage)
            .ToList().FirstOrDefault();
            if(ret == null)
            {
                return "";
            }
            return ret;
        }

        public async System.Threading.Tasks.Task InstallCodeQLPacksAsync(HashSet<string> packs, bool prerelease)
        {
            await CodeQLRunner.Instance.InstallDefaultPacksAsync(packs, prerelease);
        }

        public async System.Threading.Tasks.Task InstallCodeQLAsync(string version, string installPath, bool addToPath, HashSet<string> packs, bool preReleasePacks)
        {
            if (string.IsNullOrEmpty(installPath))
            {
                installPath = "C:\\codeql-home\\";
            }
            if (!Directory.Exists(installPath))
            {
                Directory.CreateDirectory(installPath);
            }
            if(Directory.Exists(System.IO.Path.Combine(installPath, "codeql")))
            {
                // If codeql already exists, delete it
                try
                {
                    Directory.Delete(System.IO.Path.Combine(installPath, "codeql"), true);
                }
                catch(Exception ex)
                {
                    throw new Exception("Failed to delete existing CodeQL directory: " + ex.Message, ex);
                }
            }

            if (!Version.TryParse(version, out _))
            {
                throw new Exception("Version Error");
            }

            using (var client = new HttpClient())
            {
                string url = "https://github.com/github/codeql-cli-binaries/releases/download/v" + version + "/codeql.zip";
                HttpResponseMessage response = await client.GetAsync(url);
                response.EnsureSuccessStatusCode();
                using (FileStream fs = new FileStream(System.IO.Path.Combine(installPath, "codeql.zip"), FileMode.Create))
                {
                    await response.Content.CopyToAsync(fs);
                }
            }
            System.IO.Compression.ZipFile.ExtractToDirectory(System.IO.Path.Combine(installPath, "codeql.zip"), installPath);

            await InstallCodeQLPacksAsync(packs, preReleasePacks);

            await FindAvailableQueriesAsync();
            if (addToPath)
            {
                Environment.SetEnvironmentVariable("PATH", Environment.GetEnvironmentVariable("PATH", EnvironmentVariableTarget.User) + ";" + System.IO.Path.Combine(installPath, "codeql"), EnvironmentVariableTarget.User);
            }
        }


        public static void CodeQLUpdateExePath()
        {
            CodeQLRunner.UpdateCodeQLExePath( CodeQLGeneralOptions.Instance.CliPath ?? "" );
        }

        public static bool CodeQLIsInstalled()
        {
           return CodeQLRunner.IsInstalled();
        }

        public async System.Threading.Tasks.Task<string> RunCodeQLQueryAsync(string query)
        {

            await ThreadHelper.JoinableTaskFactory.SwitchToMainThreadAsync();
            string visualStudioShellPath = ProjectHelper.GetVisualStudioFolder();
            Project project = ProjectHelper.GetActiveProject();
            string projectArch = ProjectHelper.GetProjectPropertyValue(project, "Platform");
            string projectDirectory = ProjectHelper.GetProjectDirectory(project);

            string startCommand = "\"" + Path.Combine(visualStudioShellPath, @"VC\Auxiliary\Build\vcvarsall.bat") + "\" " + projectArch + " && cd /d \"" + projectDirectory + "\" &&";

            List<string> queriesList;
            if (query.EndsWith(".qls") || query.EndsWith("ql"))
            {
                queriesList = File.Exists(query)
                    ? new List<string>() { query }
                    : throw new ArgumentException("Query file does not exist: " + query);
            }
            await ProjectHelper.ShowProgressAsync("Analyzing CodeQL Database...");
            string sarifResults = await CodeQLRunner.Instance.RunCodeQLQuerySetAsync(query, _cancelToken.Token, 
                ram: CodeQLGeneralOptions.Instance.MemoryUsage, 
                threads: CodeQLGeneralOptions.Instance.Threads, 
                additionalSearchPath: CodeQLGeneralOptions.Instance.AdditionalQueryLocations);

             _ = _taskCompleted.TrySetResult(true);
            return sarifResults;
        }

        private void CodeQLOutput(string message)
        {
            Trace.WriteLine(message);
        }

        public async System.Threading.Tasks.Task<bool> GenerateCodeQLDatabaseAsync()
        {
            await ProjectHelper.ShowProgressAsync("Generating CodeQL Database...");
            // don't need to create again if the project is clean and a database exists. 
          
            string arch = "";
            string configName = "";
            string projectName = "";
            await ThreadHelper.JoinableTaskFactory.RunAsync(async () =>
            {
                await ThreadHelper.JoinableTaskFactory.SwitchToMainThreadAsync();
                await ProjectHelper.BuildProjectAsync();
                // TODO check if build failed 
                Project activeProject = ProjectHelper.GetActiveProject();
                Configuration config = ProjectHelper.GetProjectActiveConfiguration(activeProject);

                arch = config.PlatformName;
                configName = config.ConfigurationName;
                projectName = Path.GetFileName(activeProject.UniqueName);
                string projectDir = ProjectHelper.GetProjectDirectory(activeProject);
                string startCommand = "\"" + Path.Combine(ProjectHelper.GetVisualStudioFolder(), @"VC\Auxiliary\Build\vcvarsall.bat") + "\" " + arch + " && cd /d \"" + projectDir + "\" &&";

                CodeQLRunner.Instance.Initialize(projectDir, startCommand, CodeQLOutput);
            });

            if (await ProjectHelper.IsProjectDirtyAsync())
            {
                // TODO check build guid //  _buildInfo.BuildGuid.Equals((await GetDatabaseBuildGuidAsync()))
                string buildCmd = string.Empty;
                if (!string.IsNullOrWhiteSpace(CodeQLGeneralOptions.Instance.CustomBuildCommand))
                {
                    buildCmd = CodeQLGeneralOptions.Instance.CustomBuildCommand;
                }
                else
                {
                    buildCmd = "msbuild " + projectName + " /t:rebuild /p:Configuration=" + configName + " /p:Platform=" + arch;
                }

                await CodeQLRunner.Instance.GenerateDatabaseAsync(buildCmd, _cancelToken.Token, ram: CodeQLGeneralOptions.Instance.MemoryUsage, threads: CodeQLGeneralOptions.Instance.Threads);
                await UpdateDatabaseBuildInfoAsync();
            }
            _taskCompleted.TrySetResult(true);
            return true;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        public string GetCodeQLVersion()
        {
           return ThreadHelper.JoinableTaskFactory.Run( async ()=> await CodeQLRunner.Instance.GetCodeQLVersionAsync());
        }
    }
}
