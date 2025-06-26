// Copyright (c) Microsoft. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for full license information.

using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Management;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Documents;

using Microsoft.VisualStudio.CodeAnalysis.CodeQL.Exceptions;

using Newtonsoft.Json.Linq;

namespace Microsoft.VisualStudio.CodeAnalysis.CodeQL.Runner
{
    /// <summary>
    /// The CodeQLRunner class is responsible for running CodeQL commands and managing the analysis process.
    /// </summary>
    public sealed class CodeQLRunner
    {
        /// <summary>
        /// TaskCompletionSource for process exit event. 
        /// </summary>
        public TaskCompletionSource<bool> eventHandled;

        /// <summary>
        /// Exit code of last process to finish.
        /// </summary>
        public int LastExitCode = 0;

        /// <summary>
        /// Path to most recently created Database.
        /// </summary>
        public string DatabasePath = string.Empty;

        /// <summary>
        /// Gets or sets where the databases will be placed.
        /// </summary>
        public string DatabaseDirectory { get; set; }

        /// <summary>
        /// Gets or sets where codeql will be installed.
        /// </summary>
        public string InstallDirectory { get; set; }

        /// <summary>
        /// Directory where analysis is being performed.
        /// </summary>
        private string analysisDir;

        /// <summary>
        /// Optional output windows pane.
        /// </summary>
        private Action<string> outputFunc;

        /// <summary>
        /// cmd command for build environment setup.
        /// </summary>
        private string buildEnv;

        /// <summary>
        /// TaskCompletionSource for process exit event.
        /// </summary>
        private static string codeQLExe;

        /// <summary>
        /// Private instance of the CodeQLRunner class.
        /// </summary>
        private static CodeQLRunner _instance;


        /// <summary>
        /// Default path to CodeQL executable.
        /// </summary>
        private static readonly string defaultCodeQLPath = "C:\\codeql-home\\codeql\\codeql.exe";

        private static readonly Dictionary<string, List<string>> defaultPacks = new Dictionary<string, List<string>>()
        {
            { "C++",
                new List<string>{
                    "codeql/cpp-queries",
                    "codeql/cpp-all"
                }
            },
            { "C#",
                new List<string>{
                    "codeql/csharp-queries",
                    "codeql/csharp-all"
                }
            },
            { "go",
                new List<string>{
                    "codeql/go-queries",
                    "codeql/go-all"
                }
            },
            { "Java",
                new List<string>{
                    "codeql/java-queries",
                    "codeql/java-all"
                }
            },
            { "javascript",
                new List<string>{
                    "codeql/javascript-queries",
                    "codeql/javascript-all"
                }
            },
            { "python",
                new List<string>{
                    "codeql/python-queries",
                    "codeql/python-all"
                }
            },
            { "ruby",
                new List<string>{
                    "codeql/ruby-queries",
                    "codeql/ruby-all"
                }
            },
            { "rust",
                new List<string>{
                    "codeql/rust-queries",
                    "codeql/rust-all"
                }
            },
            { "swift",
                new List<string>{
                    "codeql/swift-queries",
                    "codeql/swift-all"
                }
            },
            { "Windows Drivers",
                new List<string>{
                    "microsoft/windows-drivers",
                    "microsoft/cpp-queries",
                    "codeql/cpp-all"
                }
            }
        };

        public void Initialize(string sourceDir = "", string buildEnv = "", Action<string> outputFunc = null)
        {
            analysisDir = sourceDir;
            if (!Directory.Exists(analysisDir))
            {
                throw new Exception("Analysis directory does not exist: " + analysisDir);
            }
            this.outputFunc = outputFunc;
            this.buildEnv = buildEnv;
        }

        public static bool UpdateCodeQLExePath(string newPath)
        {
            if (Directory.Exists(newPath) && File.Exists(Path.Combine(newPath, "codeql.exe")))
            {
                codeQLExe = newPath;
            }
            else if (Path.GetFileName(newPath).ToLower().Equals("codeql.exe"))
            {
                codeQLExe = Path.GetDirectoryName(newPath);
            }
            else
            {
                return false;
            }
            return true;
        }

        /// <summary>
        /// Gets the instance of the service.
        /// </summary>
        public static CodeQLRunner Instance
        {
            get
            {
                if (_instance == null)
                {
                    _instance = new CodeQLRunner();
                }
                return _instance;
            }
            private set { }
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="CodeQLRunner"/> class.
        /// </summary>
        private CodeQLRunner()
        {
            codeQLExe = GetInstalLocation();
            if (string.IsNullOrEmpty(codeQLExe))
            {
                throw new Exception("CodeQL not installed");
            }
        }

  


        /// <summary>
        /// Installs a CodeQL pack asynchronously.
        /// </summary>
        /// <param name="pack">The CodeQL pack to install.</param>
        /// <param name="version">The version of the CodeQL pack to install.</param>
        /// <returns>A <see cref="Task"/> representing the asynchronous operation.</returns>
        public async Task InstallPackAsync(string pack, bool prerelease, bool forceInstall = false)
        {
            string output = await RunCodeQLProcAsync("pack download " + pack + 
                (forceInstall ? " --force" : "") + 
                (prerelease ? " --allow-prerelease" : "") + 
                " -v");
            foreach (string line in output.Split(
                               new string[] { "\r\n", "\r", "\n" },
                               StringSplitOptions.None))
            {
                if (line.Contains("Unzipping package to"))
                {
                    string path = line.Replace("Unzipping package to ", string.Empty).Replace("'", string.Empty).Trim();
                    _ = await RunCodeQLProcAsync("pack ci " + path);
                }
            }
        }

        private List<string> EnumerateDefaultPacks(HashSet<string> packs)
        {
            var result = new List<string>();
            foreach (string pack in packs)
            {
                var temp = new List<string>();
                if (defaultPacks.TryGetValue(pack, out temp))
                {
                    result.AddRange(temp);
                }
            }
            return result;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        /// <exception cref="CodeQLPacksNotFoundException"></exception>
        public async Task InstallDefaultPacksAsync(HashSet<string> packs, bool prerelease )
        {
            List<Task> tasks = new List<Task>();
            foreach (string pack in EnumerateDefaultPacks(packs))
            {
                tasks.Add(InstallPackAsync(pack, prerelease, true));
            }
            await Task.WhenAll(tasks);
        }


        /// <summary>
        /// Runs a CodeQL command asynchronously.
        /// </summary>
        /// <param name="cmd">The command to run.</param>
        /// <param name="workingDir">The working directory for the command.</param>
        /// <returns>A <see cref="Task"/> representing the asynchronous operation.</returns>
        /// <exception cref="InvalidOperationException">Thrown if process fails.</exception>
        public async Task<string> RunCodeQLProcAsync(string cmd, string workingDir = null)
        {
            var proc = new System.Diagnostics.Process();
            proc.StartInfo.FileName = codeQLExe;
            proc.StartInfo.Arguments = cmd;
            proc.StartInfo.RedirectStandardOutput = true;
            proc.StartInfo.RedirectStandardError = false;
            proc.StartInfo.UseShellExecute = false;
            proc.StartInfo.CreateNoWindow = true;
            if (workingDir != null)
            {
                proc.StartInfo.WorkingDirectory = workingDir;
            }

            _ = proc.Start();
            string output = await proc.StandardOutput.ReadToEndAsync();
            proc.WaitForExit();
            return proc.ExitCode != 0
                ? throw new InvalidOperationException("Process error: " + proc.ExitCode + " " + cmd + " " + output)
                : output;
        }

        /// <summary>
        /// Finds all queries in a list of CodeQL packs.
        /// </summary>
        /// <param name="qlpacks">The list of CodeQL packs to search.</param>
        /// <param name="queriesNSuites">If true, searches for queries. If false, searches for suites.</param>
        /// <returns>A <see cref="Task"/> representing the asynchronous operation.</returns>
        public async Task<List<string>> FindQueriesAsync(List<string> qlpacks, bool queriesNSuites = true)
        {
            var queries = new List<string>();

            // make async
            var tasks = new List<Task>();
            foreach (string pack in qlpacks)
            {
                tasks.Add(Task.Run(async () => queries.AddRange(await FindQueriesAsync(pack, queriesNSuites))));
            }

            await Task.WhenAll(tasks);
            return queries;
        }

        /// <summary>
        /// Finds all queries in a CodeQL pack.
        /// </summary>
        /// <param name="qlpack">The CodeQL pack to search.</param>
        /// <param name="queriesNSuites">If true, searches for queries. If false, searches for suites.</param>"
        /// <returns>A <see cref="Task"/> representing the asynchronous operation.</returns>
        public async Task<List<string>> FindQueriesAsync(string qlpack, bool queriesNSuites = true)
        {
            string output = await RunCodeQLProcAsync("pack packlist " + qlpack + " --format=json");
            var queries = new List<string>();
            // TODO do this with a json parser
            foreach (string line in output.Split(
                                    new string[] { "\r\n", "\r", "\n" },
                                    StringSplitOptions.None))
            {
                string ext = !queriesNSuites ? ".qls" : ".ql";
                if (line.Trim().Trim(new char[] { ',', '\"' }).Trim().EndsWith(ext))
                {
                    string query = line.Replace("\"", string.Empty).Replace("\\\\", "/").Replace("\\", "/").Trim(',').Trim();
                    queries.Add(query);
                }

            }

            return queries; // TODO do this with json
        }

        /// <summary>
        /// Finds all CodeQL packs installed on the system.
        /// </summary>
        /// <returns>A <see cref="Task"/> representing the asynchronous operation.</returns>
        /// <exception cref="InvalidOperationException">Thrown when the process fails.</exception>
        public async Task<List<string>> FindPacksAsync(string additionalSearchPath = null)
        {
            string useSearchPath = string.IsNullOrWhiteSpace(additionalSearchPath) ? string.Empty : "--search-path=" + additionalSearchPath + " ";
            string output = await RunCodeQLProcAsync("resolve packs --show-hidden-packs --format=json " + useSearchPath);
            var packs = new List<string>();
            foreach (string line in output.Split(
                                    new string[] { "\r\n", "\r", "\n" },
                                    StringSplitOptions.None))
            {
                if (line.Contains("legacy-upgrades"))
                {
                    continue;
                }

                if (line.Contains("\"path\"") && line.Contains("qlpack.yml"))
                {
                    packs.Add(line.Replace("\"path\" : ", string.Empty).Replace("\"", string.Empty).Replace("\\\\", "/").Replace("\\", "/").Trim());
                }
            }

            return packs; // TODO do this with json
        }


        /// <summary>
        /// Gets the installation location of CodeQL.
        /// </summary>
        /// <returns>The installation path of CodeQL.</returns>
        /// <exception cref="CodeQLExeNotFoundException">Thrown when CodeQL is not found.</exception>
        public static string GetInstalLocation()
        {
           
            if(!string.IsNullOrEmpty(codeQLExe) && System.IO.File.Exists(codeQLExe))
            {
                return codeQLExe;
            }
            else if (System.IO.File.Exists(defaultCodeQLPath))
            {
                return defaultCodeQLPath;
            }
            else
            {
                var proc = new System.Diagnostics.Process();

                proc.StartInfo.FileName = "cmd.exe";
                proc.StartInfo.Arguments = "/C " + "codeql resolve extractor --language=cpp";
                proc.StartInfo.RedirectStandardOutput = true;
                proc.StartInfo.RedirectStandardError = true;
                proc.StartInfo.UseShellExecute = false;
                proc.StartInfo.CreateNoWindow = true;

                _ = proc.Start();
                string output = string.Empty;
                while (!proc.StandardOutput.EndOfStream)
                {
                    output = proc.StandardOutput.ReadLine() ?? string.Empty;
                }

                proc.WaitForExit();

                if (output == null || string.IsNullOrEmpty(output))
                {
                    return string.Empty;
                }

                if (proc.ExitCode != 0)
                {
                    return string.Empty;
                }

                // output should be the extractor location for cpp, need the exe location one directory up
                string[] outputParts = output.Split(Path.PathSeparator);
                string path = string.Join(Path.PathSeparator.ToString(), outputParts.Take(outputParts.Length - 1)) + "codeql.exe";

                return !System.IO.File.Exists(path) ? string.Empty : path;
            }
        }

        public static bool IsInstalled()
        {
            return !string.IsNullOrEmpty(GetInstalLocation());
        }

        /// <summary>
        /// Handles the process exit event.
        /// </summary>
        /// <param name="sender"> sender.</param>
        /// <param name="e">EventArgs.</param>
        private void ProcessExited(object sender, System.EventArgs e)
        {
            _ = eventHandled.TrySetResult(true);
        }

        /// <summary>
        /// Counts the number of lines of source code in the database.
        /// </summary>
        /// <returns>A <see cref="Task"/> representing the asynchronous operation.</returns>
        /// <exception cref="Exception"> Exception </exception>
        public async Task<int> CountDBSourceCodeLinesAsync()
        {
            string output = await RunCodeQLProcAsync("database print-baseline codeql_db", workingDir: analysisDir);
            foreach (string line in output.Split(Environment.NewLine.ToCharArray()[0]))
            {
                if (line.EndsWith("cpp."))
                {
                    int lines = int.Parse(line.Replace("Counted a baseline of", string.Empty).Replace("lines of code for cpp.", string.Empty).Trim());
                    return lines;
                }

                // TODO other languages
            }

            throw new Exception("Database not found or no source code found");
        }

        /// <summary>
        /// Adds diagnostic information to the database.
        /// </summary>
        /// <param name="message"> Diagnostic info to add to database. </param>
        /// <param name="sourceId"> SourceID to use. </param>
        /// <returns>A <see cref="Task"/> representing the asynchronous operation.</returns>
        public async Task AddDBDiagInfoAsync(string message, int sourceId)
        {
            _ = await RunCodeQLProcAsync("database add-diagnostic --plaintext-message=\"" + message + "\" --source-id=" + sourceId.ToString() + " --source-name=CodeqlVSExt", workingDir: analysisDir);
        }

        /// <summary>
        /// Generates a CodeQL database diagnostics report.
        /// </summary>
        /// <returns>A <see cref="Task"/> representing the asynchronous operation.</returns>
        public async Task<string> GetDBDiagAsync()
        {
            return await RunCodeQLProcAsync("database export-diagnostics .\\codeql_db\\ --format=raw", workingDir: analysisDir);
        }

        /// <summary>
        /// Runs a command in a new cmd process.
        /// </summary>
        /// <param name="strCmdText">The command to run.</param>
        /// <param name="proccessExitedFunc">Callback function to handle process exit events.</param>
        /// <param name="ct">Cancellation token to cancel the operation.</param>
        /// <returns>A <see cref="Task"/> representing the asynchronous operation.</returns>
        public async Task RunCMDProcAsync(string strCmdText, Action<object, System.EventArgs> proccessExitedFunc, CancellationToken ct)
        {
            using (var codeqlProc = new System.Diagnostics.Process())
            using (ct.Register(() =>
            {
                if (codeqlProc != null)
                {
                    KillProcessAndChildren(codeqlProc.Id);
                }
                _ = eventHandled.TrySetCanceled();
            }))
            {
                codeqlProc.StartInfo.FileName = "cmd.exe";
                codeqlProc.StartInfo.Arguments = "/C " + "\"" + strCmdText + "\"";
                codeqlProc.StartInfo.UseShellExecute = false;
                codeqlProc.StartInfo.CreateNoWindow = true;
                codeqlProc.StartInfo.RedirectStandardError = false;

                if (outputFunc != null)
                {
                    codeqlProc.StartInfo.RedirectStandardOutput = true;
                    codeqlProc.StartInfo.RedirectStandardError = true;
                    codeqlProc.StartInfo.RedirectStandardInput = true;
                    codeqlProc.OutputDataReceived += (sender, e) =>
                    {
                        if (!string.IsNullOrEmpty(e.Data))
                        {
                            outputFunc(e.Data);
                        }
                    };
                    codeqlProc.ErrorDataReceived += (sender, e) =>
                    {
                        if (!string.IsNullOrEmpty(e.Data))
                        {
                             outputFunc(e.Data);
                        }
                    };
                }
                else
                {
                    codeqlProc.StartInfo.RedirectStandardOutput = false;
                }

                codeqlProc.EnableRaisingEvents = true;
                codeqlProc.Exited += new EventHandler(proccessExitedFunc);

                _ = codeqlProc.Start();
                if (outputFunc != null)
                {
                    codeqlProc.BeginOutputReadLine();
                    codeqlProc.BeginErrorReadLine();
                }

                _ = await Task.WhenAny(eventHandled.Task);

                if (codeqlProc.ExitCode != 0)
                {
                    if (ct != null && ct.IsCancellationRequested)
                    {
                        if (outputFunc != null)
                        {
                            outputFunc( "CodeQL process killed");
                        }
                    }
                    else
                    {
                        throw new CodeQLException("CodeQL Error. Process exited with code " + codeqlProc.ExitCode);
                    }
                }
            }
        }

        /// <summary>
        /// Kills a process and all its child processes.
        /// </summary>
        /// <param name="pid">The process ID to kill.</param>
        private void KillProcessAndChildren(int pid)
        {
            // Cannot close 'system idle process'.
            if (pid == 0)
            {
                return;
            }

            var searcher = new ManagementObjectSearcher(
                    "Select * From Win32_Process Where ParentProcessID=" + pid);
            ManagementObjectCollection moc = searcher.Get();
            foreach (ManagementObject mo in moc)
            {
                KillProcessAndChildren(Convert.ToInt32(mo["ProcessID"]));
            }

            try
            {
                var proc = System.Diagnostics.Process.GetProcessById(pid);
                proc.Kill();
            }
            catch (ArgumentException)
            {
                // Process already exited.
            }
        }

        /// <summary>
        /// Generates a CodeQL database for the specified project file.
        /// </summary>
        /// <returns>The path to the generated database.</returns>
        /// <exception cref="Exception">Thrown if the analysis directory does not exist.</exception>
        public async Task GenerateDatabaseAsync(string buildCommand, CancellationToken ct, string ram = null, string threads = null, Action<object, System.EventArgs> proccessExitedFunc = null)
        {
            if (ct.IsCancellationRequested)
            {
                return;
            }

            eventHandled = new TaskCompletionSource<bool>();

            if (proccessExitedFunc == null)
            {
                // use default if none provided
                proccessExitedFunc = ProcessExited;
            }

            string strCmdText = string.Empty;
            string dbPath = Path.Combine(analysisDir, "codeql_db");
            string useThreads = string.IsNullOrWhiteSpace(threads) ? "" : " --threads=" + threads + " ";
            string useRam = string.IsNullOrWhiteSpace(ram) ? "" : " --ram=" + ram + " " ;

            string[] procArr =
            {
                codeQLExe, "database",
                "create", "\"" + dbPath + "\"",
                "--force-overwrite",
                "--language=cpp",
                "--source-root=" + "\"" + analysisDir + "\"",
                "--command=" + "\"" + buildCommand + "\"",
                useThreads,
                useRam
            };
            strCmdText = string.Join(" ", procArr);
            if (!string.IsNullOrWhiteSpace(buildEnv))
            {
                strCmdText = buildEnv + " " + strCmdText;
            }

            await RunCMDProcAsync(strCmdText, proccessExitedFunc, ct);

        }

        /// <summary>
        ///
        /// </summary>
        /// <returns>A <see cref="Task"/> representing the asynchronous operation.</returns>
        public async Task<string> RunCodeQLQuerySetAsync(string query, CancellationToken ct, string ram = null, string threads = null, string additionalSearchPath = null, Action<object, System.EventArgs> proccessExitedFunc = null)
        {
            if (ct.IsCancellationRequested)
            {
                return null;
            }

            eventHandled = new TaskCompletionSource<bool>();

            string strCmdText = string.Empty;
            if (proccessExitedFunc == null)
            {
                // use default if none provided
                proccessExitedFunc = ProcessExited;
            }

            string dbPath = Path.Combine(analysisDir, "codeql_db");
            if (!Directory.Exists(dbPath))
            {
                throw new DatabaseNotFinalizedException("Database not created");
            }
            else
            {
                string lastLine = System.IO.File.ReadLines(Path.Combine(dbPath, "codeql-database.yml")).Last();
                if (!lastLine.Contains("true"))
                {
                    throw new DatabaseNotFinalizedException("CodeQL database error");
                }
            }

            string resultsDir = Path.Combine(analysisDir, ".sarif");
            if (!Directory.Exists(resultsDir))
            {
                _ = Directory.CreateDirectory(resultsDir);
            }

            string resultsPath = Path.Combine(resultsDir, "results.sarif");
            string useThreads = string.IsNullOrWhiteSpace(threads) ? "": " --threads=" + threads + " ";
            string useRam = string.IsNullOrWhiteSpace(ram) ? "": " --ram=" + ram + " ";
            string useSearchPath = string.IsNullOrWhiteSpace(additionalSearchPath) ? string.Empty : " --search-path=" + additionalSearchPath + " ";

            string[] procArr =
            {
                codeQLExe, "database",
                "analyze", "\"" + dbPath + "\"",
                "-v",
                "--format=sarifv2.1.0",
                "--output=" + "\"" + resultsPath + "\"",
                useThreads, 
                useRam,
                query,
                useSearchPath
            };

            strCmdText = string.Join(" ", procArr);
            if (!string.IsNullOrWhiteSpace(buildEnv))
            {
                strCmdText = buildEnv + " " + strCmdText;
            }

            await RunCMDProcAsync(strCmdText, proccessExitedFunc, ct);
            return resultsPath;
        }
    }
}
