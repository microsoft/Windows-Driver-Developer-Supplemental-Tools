// Copyright (c) Microsoft. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for full license information.

using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

using EnvDTE;

using Microsoft.CodeAnalysis.Sarif;
using Microsoft.CodeQL.Options;
using Microsoft.VisualStudio.CodeAnalysis.CodeQL.Runner;
using Microsoft.VisualStudio.Shell;
using Microsoft.VisualStudio.Shell.Interop;
using Microsoft.VisualStudio.Threading;


namespace Microsoft.CodeQL.Core
{
    internal class CodeQLService : IDisposable
    {
        private static CodeQLService _instance = null;
        private CancellationTokenSource _cancelToken;
        private TaskCompletionSource<bool> _taskCompleted;

        /// <summary>
        /// Dictionary of query names to be displayed in the UI, and their full path.
        /// </summary>  
        private readonly Dictionary<string, string> _queryDict;
        public List<string> AvailableQueries 
        { 
            get 
            {
                if (_queryDict != null)
                {
                    return _queryDict.Keys.ToList();
                }
                return new List<string>();
            }
            set { }
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
            _queryDict = new Dictionary<string, string>();
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

        public void CancelIfRunning()
        {
            if (_taskCompleted != null && _cancelToken != null)
            {
                if (!_cancelToken.IsCancellationRequested)
                {
                    _cancelToken.Cancel();
                }

                if (!_taskCompleted.Task.IsCompleted)
                {
                    _ = _taskCompleted.TrySetCanceled();
                }
            }
            ThreadHelper.JoinableTaskFactory.Run(() => ProjectHelper.HideProgressAsync());
        }
        private void HandleKeyCollision(string existingKey, string newValue)
        {
            if (_queryDict[existingKey].Equals(newValue))
            {
                return;
            }
            StringBuilder replacementKey = new StringBuilder();
            StringBuilder newValueKey = new StringBuilder();
            List<string> existingValueParts = _queryDict[existingKey].Split('/').ToList();
            List<string> newValueParts = newValue.Split('/').ToList();
            while ((existingValueParts.Count > 0 && newValueParts.Count > 0) && 
                existingValueParts.Last().Equals(newValueParts.Last()))
            {
                replacementKey.Insert(0, "/" + existingValueParts.Last() );
                existingValueParts.RemoveAt(existingValueParts.Count - 1);
                newValueKey.Insert(0, "/" + newValueParts.Last());
                newValueParts.RemoveAt(newValueParts.Count - 1); 
            }

            // add remaining unique value
            if (newValueParts.Count > 0 && existingValueParts.Count > 0) {
                newValueKey.Insert(0, newValueParts.Last());
                replacementKey.Insert(0, existingValueParts.Last());

                // if at a version, try to get the qlpack for it which should be the preceding two segments
                if(Version.TryParse(newValueParts.Last(), out _) && newValueParts.Count > 2)
                {
                    newValueKey.Insert(0, newValueParts.ElementAt(newValueParts.Count - 3) +"/" + 
                        newValueParts.ElementAt(newValueParts.Count - 2) + "/");
                }
                if (Version.TryParse(existingValueParts.Last(), out _) && existingValueParts.Count > 2)
                {
                    replacementKey.Insert(0, existingValueParts.ElementAt(existingValueParts.Count - 2) + "/" + 
                        existingValueParts.ElementAt(existingValueParts.Count - 2) + "/");
                }
            }
            else
            {
                throw new Exception("Unable to find new key");
            }

            if (newValueKey.ToString().Equals(replacementKey.ToString()))
            {
                throw new Exception("Unable to find new key");
            }
            _queryDict.Remove(existingKey);
            if (!_queryDict.ContainsKey(replacementKey.ToString()))
            {
                _queryDict.Add(replacementKey.ToString(), string.Join("/", existingValueParts));
            }
            if (!_queryDict.ContainsKey(replacementKey.ToString()))
            {
                _queryDict.Add(newValueKey.ToString(), newValue);
            }
        }

        public async Task<string[]> FindAvailableQueriesAsync()
        {
            List<string> packList = await CodeQLRunner.Instance.FindPacksAsync(CodeQLGeneralOptions.Instance.AdditionalQueryLocations);
            List<string> queryList = await CodeQLRunner.Instance.FindQueriesAsync(packList, queriesNSuites: false);
            foreach (string query in queryList)
            {
                string key = query.Replace("\\", "/").Split('/').Last();
                if (_queryDict.ContainsKey(key))
                {
                    HandleKeyCollision(key, query);
                }
                else
                {
                    _queryDict.Add(key, query.Replace("\\", "/"));
                }
            }

            return _queryDict.Keys.ToArray();
        }

        public void AddAdditionalQueries(List<string> queries)
        {
            foreach (string query in queries)
            {
                string key = query.Replace("\\", "/").Split('/').Last();
                if (!_queryDict.ContainsKey(key))
                {
                    _queryDict.Add(key, query.Replace("\\", "/"));
                }
            }
        }

        public void RemoveQuery(string query)
        {
            string key = query.Replace("\\", "/").Split('/').Last();
            if (_queryDict.ContainsKey(key))
            {
                _queryDict.Remove(key);
            }
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
                Directory.Delete(System.IO.Path.Combine(installPath, "codeql"), true);
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

        public static void CodeQLUpateExePath()
        {
            CodeQLRunner.UpdateCodeQLExePath( CodeQLGeneralOptions.Instance.CliPath ?? "" );
        }
        public static bool CodeQLIsInstalled()
        {
           return CodeQLRunner.IsInstalled();
        }

        public async System.Threading.Tasks.Task RunCodeQLQueryAsync(string query)
        {
            if (!_queryDict.TryGetValue(query, out string querySet)) 
            {
                throw new ArgumentException("Query file does not exist: " + query);
            }

            await ThreadHelper.JoinableTaskFactory.SwitchToMainThreadAsync();
            string visualStudioShellPath = ProjectHelper.GetVisualStudioFolder();
            Project project = ProjectHelper.GetActiveProject();
            string projectArch = ProjectHelper.GetProjectPropertyValue(project, "Platform");
            string projectDirectory = ProjectHelper.GetProjectDirectory(project);

            string startCommand = "\"" + Path.Combine(visualStudioShellPath, @"VC\Auxiliary\Build\vcvarsall.bat") + "\" " + projectArch + " && cd /d \"" + projectDirectory + "\" &&";

            List<string> queriesList;
            if (querySet.EndsWith(".qls") || querySet.EndsWith("ql"))
            {
                queriesList = File.Exists(querySet)
                    ? new List<string>() { querySet }
                    : throw new ArgumentException("Query file does not exist: " + querySet);
            }
            await ProjectHelper.ShowProgressAsync("Analyzing CodeQL Database...");
            string sarifResults = await CodeQLRunner.Instance.RunCodeQLQuerySetAsync(querySet, _cancelToken.Token, 
                ram: CodeQLGeneralOptions.Instance.MemoryUsage, 
                threads: CodeQLGeneralOptions.Instance.Threads, 
                additionalSearchPath: CodeQLGeneralOptions.Instance.AdditionalQueryLocations);
            try
            {
                //await ErrorListService.ProcessLogFileWithTracesAsync(sarifResults, ToolFormat.None, promptOnLogConversions: true, cleanErrors: true, openInEditor: false).ConfigureAwait(continueOnCapturedContext: false);
                //new DataService().CloseEnhancedResultData(cookie: 0);
            }
            catch (InvalidOperationException)
            {
                VsShellUtilities.ShowMessageBox(Microsoft.VisualStudio.Shell.ServiceProvider.GlobalProvider,
                                                string.Format(Resources.LogOpenFail_InvalidFormat_DialogMessage, Path.GetFileName(sarifResults)),
                                                null, // title
                                                OLEMSGICON.OLEMSGICON_CRITICAL,
                                                OLEMSGBUTTON.OLEMSGBUTTON_OK,
                                                OLEMSGDEFBUTTON.OLEMSGDEFBUTTON_FIRST);
            }

            _ = _taskCompleted.TrySetResult(true);
        }

        private void CodeQLOutput(string message)
        {
            Trace.WriteLine(message);
        }

        public async System.Threading.Tasks.Task<bool> GenerateCodeQLDatabaseAsync()
        {
            await ProjectHelper.ShowProgressAsync("Generating CodeQL Database...");

            string arch = "";
            string configName = "";

            await ThreadHelper.JoinableTaskFactory.RunAsync(async () =>
            {
                await ThreadHelper.JoinableTaskFactory.SwitchToMainThreadAsync();

                await ProjectHelper.BuildProjectAsync();
                // TODO check if build failed 
                Project activeProject = ProjectHelper.GetActiveProject();
                Configuration config = ProjectHelper.GetProjectActiveConfiguration(activeProject);

                arch = config.PlatformName;
                configName = config.ConfigurationName;

                string projectDir = ProjectHelper.GetProjectDirectory(activeProject);
                string startCommand = "\"" + Path.Combine(ProjectHelper.GetVisualStudioFolder(), @"VC\Auxiliary\Build\vcvarsall.bat") + "\" " + arch + " && cd /d \"" + projectDir + "\" &&";

                CodeQLRunner.Instance.Initialize(projectDir, startCommand, CodeQLOutput);
            });
            string buildCmd = string.Empty;
            if (!string.IsNullOrWhiteSpace(CodeQLGeneralOptions.Instance.CustomBuildCommand))
            {
                buildCmd = CodeQLGeneralOptions.Instance.CustomBuildCommand;
            }
            else
            {
                buildCmd = "msbuild /t:rebuild /p:Configuration=" + configName + " /p:Platform=" + arch;
            }


            await CodeQLRunner.Instance.GenerateDatabaseAsync(buildCmd, _cancelToken.Token, ram: CodeQLGeneralOptions.Instance.MemoryUsage, threads: CodeQLGeneralOptions.Instance.Threads );
            _taskCompleted.TrySetResult(true);
            return true;
        }
    }
}
