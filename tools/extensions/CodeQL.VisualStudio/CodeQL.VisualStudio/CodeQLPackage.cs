// Copyright (c) Microsoft. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for full license information.

using EnvDTE80;
using Microsoft.CodeAnalysis.Sarif;
using Microsoft.CodeQL.Core;
using Microsoft.CodeQL.Options;
using Microsoft.VisualStudio;
using Microsoft.VisualStudio.ComponentModelHost;
using Microsoft.VisualStudio.Shell;
using Microsoft.VisualStudio.Shell.Events;
using Microsoft.VisualStudio.Shell.Interop;
using Microsoft.VisualStudio.Text.Tagging;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.ComponentModel.Design;
using System.Configuration;
using System.IO;
using System.Runtime.InteropServices;
using System.Threading;
using Task = System.Threading.Tasks.Task;

namespace Microsoft.CodeQL
{
    /// <summary>
    /// This is the class that implements the package exposed by this assembly.
    /// </summary>
    [PackageRegistration(UseManagedResourcesOnly = true, AllowsBackgroundLoading = true)]
    [InstalledProductRegistration("#110", "#112", ThisAssembly.AssemblyFileVersion, IconResourceID = 400)] // Info on this package for Help/About
    [Guid(PackageGuidString)]
    [ProvideMenuResource("Menus.ctmenu", 1)]
    [ProvideAutoLoad(VSConstants.UICONTEXT.SolutionExists_string, PackageAutoLoadFlags.BackgroundLoad)]
    [ProvideOptionPage(typeof(CodeQLGeneralOptionsPage), CodeQLCategoryName, CodeQLPageName, 0, 0, true)]
    public sealed class CodeQLPackage : AsyncPackage
    {
        private readonly List<OleMenuCommand> menuCommands = new List<OleMenuCommand>();

        //private OutputWindowTracerListener outputWindowTraceListener;

        /// <summary>
        /// OpenSarifFileCommandPackage GUID string.
        /// </summary>
        public const string PackageGuidString = "19BD102D-9450-4BF2-A08A-DA4704F146AB";
        public const string CodeQLCategoryName = "CodeQL";
        public const string OptionPageName = "General";
        public const string CodeQLPageName = "General";
        public const string ColorsPageName = "Colors";
        public const string OutputPaneName = "CodeQL";

        public const string CodeQLOptionCategoryName = "CodeQL";
        public const string CodeQLOptionPageName = "General";


        public static readonly Guid PackageGuid = new Guid(PackageGuidString);

        public static bool IsUnitTesting { get; set; } = false;

        public static Configuration AppConfig { get; private set; }

        private struct ServiceInformation
        {
            /// <summary>
            /// Function that will create an instance of this service.
            /// </summary>
            public Func<Type, object> Creator;

            /// <summary>
            /// Indicates whether to promote the service to parent service containers.
            /// </summary>
            /// <remarks>
            /// For our purposes, true indicates whether the service is visible outside this package.
            /// </remarks>
            public bool Promote;
        }

        //private CodeQLFileMonitor codeqlFileMonitor;
        private OutputWindowTracerListener outputWindowTraceListener;


        /// <summary>
        /// Initialization of the package; this method is called right after the package is sited, so this is the place
        /// where you can put all the initialization code that rely on services provided by VisualStudio.
        /// </summary>
        /// <param name="cancellationToken">
        /// A <see cref="CancellationToken"/> that can be used to cancel the initialization of the package.
        /// </param>
        /// <param name="progress">
        /// A provider to update progress.
        /// </param>
        /// <returns>A <see cref="Task"/> representing the asynchronous operation.</returns>
        protected override async Task InitializeAsync(CancellationToken cancellationToken, IProgress<ServiceProgressData> progress)
        {
            await base.InitializeAsync(cancellationToken, progress).ConfigureAwait(continueOnCapturedContext: true);

            // Mitigation for Newtonsoft.Json v12 vulnerability GHSA-5crp-9r3c-p9vr
            JsonConvert.DefaultSettings = () => new JsonSerializerSettings { MaxDepth = 64 };

            await ThreadHelper.JoinableTaskFactory.SwitchToMainThreadAsync();

            // initialize Option first since other components may depends on options.
            await CodeQLGeneralOptions.InitializeAsync(this).ConfigureAwait(false);

            if (await this.GetServiceAsync(typeof(SVsOutputWindow)).ConfigureAwait(continueOnCapturedContext: true) is IVsOutputWindow output)
            {
                this.outputWindowTraceListener = new OutputWindowTracerListener(output, OutputPaneName);
            }

            var componentModel = await this.GetServiceAsync(typeof(SComponentModel)) as IComponentModel;
            Assumes.Present(componentModel);

            CodeQLCommand.Initialize(this);

            //this.codeqlFileMonitor = new CodeQLFileMonitor();

            if (await this.IsSolutionLoadedAsync())
            {
                // Async package initialized after solution is fully loaded according to
                // [ProvideAutoLoad(VSConstants.UICONTEXT.SolutionExistsAndFullyLoaded_string, PackageAutoLoadFlags.BackgroundLoad)]
                // SolutionEvents.OnAfterBackgroundSolutionLoadComplete will not be triggered until the user opens another solution.
                // Need to manually start monitor in this case.
                await CodeQLCommand.CheckForCodeQLAsync();
            }

            SolutionEvents.OnBeforeCloseSolution += this.SolutionEvents_OnBeforeCloseSolution;
            SolutionEvents.OnAfterCloseSolution += this.SolutionEvents_OnAfterCloseSolution;
            SolutionEvents.OnAfterBackgroundSolutionLoadComplete += this.SolutionEvents_OnAfterBackgroundSolutionLoadComplete;
            SolutionEvents.OnBeforeOpenProject += this.SolutionEvents_OnBeforeOpenProject;

            IVsSolutionBuildManager buildManager = (IVsSolutionBuildManager)ServiceProvider.GlobalProvider.GetService(typeof(SVsSolutionBuildManager));
            buildManager.AdviseUpdateSolutionEvents(new MyBuildEventsHandler(), out _);

            return;
        }

        private void SolutionEvents_OnBeforeOpenProject(object sender, EventArgs e)
        {
            // start watcher when the solution is opened.
            //this.codeqlFileMonitor?.StartWatching();
        }

        private void SolutionEvents_OnAfterCloseSolution(object sender, EventArgs e)
        {
            ThreadHelper.ThrowIfNotOnUIThread();

            using (OleMenuCommandService mcs = this.GetService<IMenuCommandService, OleMenuCommandService>())
            {
                foreach (OleMenuCommand menuCommand in menuCommands)
                {
                    mcs.RemoveCommand(menuCommand);
                }
            }

            this.menuCommands.Clear();
        }


        private static IVsShell vsShell;

        private static IVsShell VsShell
        {
            get
            {
                ThreadHelper.ThrowIfNotOnUIThread();
                if(vsShell == null)
                {
                    vsShell = Package.GetGlobalService(typeof(SVsShell)) as IVsShell;
                }

                return vsShell;
            }
        }

        private async System.Threading.Tasks.Task<bool> IsSolutionLoadedAsync()
        {
            await JoinableTaskFactory.SwitchToMainThreadAsync();
            if (!(await GetServiceAsync(typeof(SVsSolution)) is IVsSolution solutionService))
            {
                return false;
            }

            solutionService.GetProperty((int)__VSPROPID.VSPROPID_IsSolutionOpen, out object value);
            return value is bool isSolOpen && isSolOpen;
        }

        private void SolutionEvents_OnBeforeCloseSolution(object sender, EventArgs e)
        {
            // stop watcher when the solution is closed.
            //this.codeqlFileMonitor?.StopWatching();
            var fileSystem = new FileSystem();
            try
            {
                // Best effort delete, no harm if this fails.
                fileSystem.FileDelete(Path.Combine(GetDotSarifDirectoryPath(), "scan-results.sarif"));
            }
            catch (Exception) { }
        }

        private void SolutionEvents_OnAfterBackgroundSolutionLoadComplete(object sender, EventArgs e)
        {
            // start to watch when the solution is loaded.
            //this.codeqlFileMonitor?.StartWatching();

            // check codeql is installed and there are available packs
            this.JoinableTaskFactory.Run(async () => await CodeQLCommand.CheckForCodeQLAsync());
        }

        private static string GetSolutionDirectoryPath()
        {
            var dte = (DTE2)Package.GetGlobalService(typeof(EnvDTE.DTE));
            string solutionFilePath = dte.Solution?.FullName;
            return !string.IsNullOrWhiteSpace(solutionFilePath)
                ? Path.GetDirectoryName(solutionFilePath)
                : null;
        }

        /// <summary>
        /// Gets the .sarif directory that is used for this solution.
        /// </summary>
        /// <returns>A string of where the .sarif directory for this solution is.</returns>
        private static string GetDotSarifDirectoryPath()
        {
            return Path.Combine(GetSolutionDirectoryPath(), ".sarif");
        }
    }
}
