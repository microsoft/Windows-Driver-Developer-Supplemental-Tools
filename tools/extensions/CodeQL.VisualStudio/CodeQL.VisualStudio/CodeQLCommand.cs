// Copyright (c) Microsoft. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for full license information.

using Microsoft.CodeQL.Controls;
using Microsoft.CodeQL.Options;
using Microsoft.CodeQL.Views;
using Microsoft.Sarif.Viewer.Interop;
using Microsoft.VisualStudio.Shell;
using Microsoft.VisualStudio.Shell.Interop;
using Microsoft.VisualStudio.Threading;
using System;
using System.Collections.Generic;
using System.ComponentModel.Design;
using System.Diagnostics;
using System.Linq;
using System.Linq.Expressions;
using System.Runtime.InteropServices;
using System.Security.Policy;
using System.Threading.Tasks;
using System.Windows;


namespace Microsoft.CodeQL.Core
{
    internal class CodeQLCommand
    {
        /// <summary>
        /// Command ID for CodeQL analyze.
        /// </summary>
        public const int CodeQLAnalyzeCommandId = 0x0100;

        /// <summary>
        /// Command ID for CodeQL kill process.
        /// </summary>
        public const int CodeQLStopCommandId = 0x0110;

        /// <summary>
        /// Command ID for CodeQL load queries.
        /// </summary>
        public const int CodeQLLoadQueriesCommandId = 0x0111;

        /// <summary>
        /// Command ID for CodeQL install packs.
        /// </summary>
        public const int CodeQLInstallerCommandID = 0x0112;

        /// <summary>
        /// Command ID for CodeQL database create.
        /// </summary>
        public const int CodeQLDatabaseCommandId = 0x133;

        /// <summary>
        /// Command ID for CodeQL combo box.
        /// </summary>
        public const int CodeQLComboId = 0x155;

        /// <summary>
        /// Command ID for CodeQL combo box get list.
        /// </summary>
        public const int ComboGetListId = 0x156;

        /// <summary>
        /// Command menu group (command set GUID).
        /// </summary>
        public static readonly Guid CommandSet = new Guid("D62F3B56-93CF-4AC2-BCD7-ABDE6EF7FE25");

        /// <summary>
        /// VS Package that provides this command, not null.
        /// </summary>
        private readonly Package package;

        private static string _currentDropDownComboChoice;
        private static string[] _discoveredComboChoices;

        /// <summary>
        /// Initializes a new instance of the <see cref="CodeQLCommand"/> class.
        /// Adds our command handlers for menu (commands must exist in the command table file).
        /// </summary>
        /// <param name="package">Owner package, not null.</param>
        private CodeQLCommand(Package package)
        {
            this.package = package ?? throw new ArgumentNullException(nameof(package));

            var commandService = this.ServiceProvider.GetService(typeof(IMenuCommandService)) as OleMenuCommandService;
            if (commandService != null)
            {
                var oleCommand = new OleMenuCommand(
                      this.MenuItemCallback,
                      new CommandID(CommandSet, CodeQLAnalyzeCommandId));
                commandService.AddCommand(oleCommand);

                oleCommand = new OleMenuCommand(
                    this.MenuItemCallback,
                    new CommandID(CommandSet, CodeQLStopCommandId));
                commandService.AddCommand(oleCommand);

                oleCommand = new OleMenuCommand(
                    this.MenuItemCallback,
                    new CommandID(CommandSet, CodeQLLoadQueriesCommandId));
                commandService.AddCommand(oleCommand);

                oleCommand = new OleMenuCommand(
                    this.MenuItemCallback,
                    new CommandID(CommandSet, CodeQLInstallerCommandID));
                commandService.AddCommand(oleCommand);

                // Combo box
                oleCommand = new OleMenuCommand(
                    new EventHandler(this.OnMenuMyDropDownCombo),
                    new CommandID(CommandSet, CodeQLComboId));
                commandService.AddCommand(oleCommand);

                oleCommand = new OleMenuCommand(
                    new EventHandler(this.OnMenuMyDropDownComboGetList),
                    new CommandID(CommandSet, ComboGetListId));
                commandService.AddCommand(oleCommand);
            }
            CodeQLService.CodeQLUpateExePath();
        }

        /// <summary>
        /// Gets the instance of the command.
        /// </summary>
        public static CodeQLCommand Instance
        {
            get;
            private set;
        }

        /// <summary>
        /// Gets the service provider from the owner package.
        /// </summary>
        private IServiceProvider ServiceProvider => this.package;

        /// <summary>
        /// Initializes the singleton instance of the command.
        /// </summary>
        /// <param name="package">Owner package, not null.</param>
        public static void Initialize(Package package)
        {
            Instance = new CodeQLCommand(package);
        }

        private void MenuItemCallback(object sender, EventArgs e)
        {
            if (!CodeQLService.CodeQLIsInstalled())
            {
                CodeQLInstallHelper codeQLInstallHelper = new CodeQLInstallHelper();
                codeQLInstallHelper.ShowDialog();
            }
          
            this.MenuItemCallbackAsync(sender, e).FileAndForget("Microsoft/SARIF/Viewer/CodeQL/Failed"); // FIXME
        }

        /// <summary>
        /// This function is the callback used to execute the command when the menu item is clicked.
        /// See the constructor to see how the menu item is associated with this function using
        /// OleMenuCommandService service and MenuCommand class.
        /// </summary>
        /// <param name="sender">Event sender.</param>
        /// <param name="e">Event args.</param>
        private async System.Threading.Tasks.Task MenuItemCallbackAsync(object sender, EventArgs e)
        {
          
            await ThreadHelper.JoinableTaskFactory.SwitchToMainThreadAsync();

            var menuCommand = (OleMenuCommand)sender;
            switch (menuCommand.CommandID.ID)
            {
                case CodeQLInstallerCommandID:
                    CodeQLInstallHelper codeQLInstallHelper = new CodeQLInstallHelper();
                    codeQLInstallHelper.ShowDialog();
                    break;
                case CodeQLAnalyzeCommandId:
                    bool dbSuccessful = false;
                  
                    if (CodeQLService.Instance.IsCodeQLTaskRunning())
                    {
                        throw new Exception("CodeQL already running"); // FIXME
                    }
                    if (string.IsNullOrEmpty(_currentDropDownComboChoice))
                    {
                        throw new Exception("No query selected");
                    }
                    CodeQLService.Instance.InitTask();

                    Trace.WriteLine("Creating CodeQL database");
                    try
                    {
                        dbSuccessful = await CodeQLService.Instance.GenerateCodeQLDatabaseAsync();
                    }
                    catch (Exception ex)
                    {
                        CodeQLService.Instance.ClearTask();
                        MessageBox.Show(ex.GetType().ToString());
                        VsShellUtilities.ShowMessageBox(Microsoft.VisualStudio.Shell.ServiceProvider.GlobalProvider,
                                                        $"CodeQL database create failed. " + ex.Message + " See output for details.",
                                                        null, // title
                                                        OLEMSGICON.OLEMSGICON_CRITICAL,
                                                        OLEMSGBUTTON.OLEMSGBUTTON_OK,
                                                        OLEMSGDEFBUTTON.OLEMSGDEFBUTTON_FIRST);
                    }
                   
                    if (dbSuccessful
                        && CodeQLService.Instance.IsCodeQLTaskCompleted())
                    {
                        CodeQLService.Instance.InitTask(); // init again since starting a new CodeQL process
                        Trace.WriteLine($"Starting CodeQL analysis using {_currentDropDownComboChoice}");
                        try
                        {
                            var sarifResults = await CodeQLService.Instance.RunCodeQLQueryAsync(_currentDropDownComboChoice.Trim());
                            var sarifViewer = new SarifViewerInterop(Package.GetGlobalService(typeof(SVsShell)) as IVsShell);
                            if (false && sarifViewer.IsSariferExtensionInstalled)
                            {
                                if (!sarifViewer.IsViewerExtensionLoaded)
                                {
                                    sarifViewer.LoadSariferExtension();
                                }
                                await sarifViewer.OpenSarifLogAsync(sarifResults);
                            }
                            else
                            {
                                //TODO 
                                //if (CodeQLGeneralOptions.Instance.AutomaticallyOpenResults) { }
                                Microsoft.VisualStudio.Shell.VsShellUtilities.OpenDocument(this.ServiceProvider, sarifResults);
                            }
                        }
                        catch (Exception ex)
                        {
                            CodeQLService.Instance.ClearTask();
                            VsShellUtilities.ShowMessageBox(Microsoft.VisualStudio.Shell.ServiceProvider.GlobalProvider,
                                                            $"CodeQL analysis failed. " + ex.Message + " See output for details.",
                                                            null, // title
                                                            OLEMSGICON.OLEMSGICON_CRITICAL,
                                                            OLEMSGBUTTON.OLEMSGBUTTON_OK,
                                                            OLEMSGDEFBUTTON.OLEMSGDEFBUTTON_FIRST);
                        }
                    }
                    CodeQLService.Instance.ClearTask();

                    break;
                case CodeQLStopCommandId:
                    CodeQLService.Instance.CancelIfRunningAsync().FileAndForget("Codeql.CancelIfRunning");
                    break;
                case CodeQLDatabaseCommandId:
                    try
                    {
                        if (!CodeQLService.Instance.IsCodeQLTaskCompleted())
                        {
                            throw new Exception("CodeQL already running"); // FIXME
                        }

                        CodeQLService.Instance.InitTask();
                        _ = await CodeQLService.Instance.GenerateCodeQLDatabaseAsync();
                        CodeQLService.Instance.ClearTask();
                    }
                    catch (Exception ex)
                    {
                        CodeQLService.Instance.ClearTask();
                        throw new Exception(ex.ToString()); // FIXME
                    }

                    break;
                case CodeQLLoadQueriesCommandId:
                    await CodeqlRefreshAvailableQueriesAsync();
                    break;
                case CodeQLComboId:
                    break;
                case ComboGetListId:
                    break;
                default:
                    break;
            }
        }

        private void OnMenuMyDropDownCombo(object sender, EventArgs e)
        {
            if (e is OleMenuCmdEventArgs eventArgs)
            {
                IntPtr vOut = eventArgs.OutValue;
                if (vOut != IntPtr.Zero)
                {
                    // when vOut is non-NULL, the IDE is requesting the current value for the combo
                    Marshal.GetNativeVariantForObject(_currentDropDownComboChoice, vOut);
                }
                else
                {
                    _currentDropDownComboChoice = eventArgs.InValue is string newChoice ? newChoice : throw new ArgumentException("Invalid Selection");
                }
            }
            else
            {
                // We should never get here; EventArgs are required.
                throw new ArgumentException("EventArgs are required"); // force an exception to be thrown
            }
        }


        private void OnMenuMyDropDownComboGetList(object sender, EventArgs e)
        {
            if (e is OleMenuCmdEventArgs eventArgs)
            {
                object inParam = eventArgs.InValue;
                IntPtr vOut = eventArgs.OutValue;

                if (inParam != null)
                {
                    throw new ArgumentException("InParamIllegal"); // force an exception to be thrown
                }
                else if (vOut != IntPtr.Zero)
                {
                    _discoveredComboChoices = CodeQLService.Instance.AvailableQueries.ToArray();
                    if (_discoveredComboChoices == null)
                    {
                        _ = ThreadHelper.JoinableTaskFactory.RunAsync(async () => await CodeqlRefreshAvailableQueriesAsync());
                    }

                    if (!_discoveredComboChoices.Contains(_currentDropDownComboChoice))
                    {
                        _currentDropDownComboChoice = _discoveredComboChoices[0];
                    }
                    Marshal.GetNativeVariantForObject(_discoveredComboChoices, vOut);
                }
                else
                {
                    throw new ArgumentException("OutParamRequired"); // force an exception to be thrown
                }
            }
            else
            {
                throw new ArgumentException("InParamIllegal"); // force an exception to be thrown
            }
        }

        public async System.Threading.Tasks.Task CodeqlRefreshAvailableQueriesAsync()
        {
            if (CodeQLService.CodeQLIsInstalled())
            {
                _discoveredComboChoices = await CodeQLService.Instance.FindAvailableQueriesAsync();
                if (_discoveredComboChoices != null && _discoveredComboChoices.Length != 0)
                {
                    _currentDropDownComboChoice = _discoveredComboChoices[0];
                }
            }
        }

        private static InfoBar noCodeQLInfoBar = null;

        public static async System.Threading.Tasks.Task CheckForCodeQLAsync()
        {
            if (!CodeQLService.CodeQLIsInstalled() )
            {
                if(noCodeQLInfoBar == null)
                {
                    noCodeQLInfoBar = new InfoBar(
                        content: new[]
                        {
                                new InfoBarTextSpan("CodeQL not installed. "),
                                new InfoBarButton("Click Here To Install CodeQL"),
                        },
                        (actionItem) =>
                        {
                            CodeQLInstallHelper codeQLInstallHelper = new CodeQLInstallHelper();
                            bool? success = codeQLInstallHelper.ShowDialog();
                            if (success == true)
                            {
                                ThreadHelper.JoinableTaskFactory.Run(async () => { await noCodeQLInfoBar.CloseAsync(); noCodeQLInfoBar = null; });
                            }
                        },
                        null,
                        default);
                }
            }
            else if ((await CodeQLService.Instance.FindAvailableQueriesAsync()).Length == 0 )
            {
                if (noCodeQLInfoBar == null)
                {
                    noCodeQLInfoBar = new InfoBar(
                        content: new[]
                        {
                                new InfoBarTextSpan("No CodeQL Packs Found. "),
                                new InfoBarButton("Click Here To Install CodeQL Packs"),
                        },
                        (actionItem) =>
                        {
                            CodeQLInstallHelper codeQLInstallHelper = new CodeQLInstallHelper();
                            bool? success = codeQLInstallHelper.ShowDialog();
                            if (success == true)
                            {
                                ThreadHelper.JoinableTaskFactory.Run(async () => { await noCodeQLInfoBar.CloseAsync(); noCodeQLInfoBar = null; });
                            }
                        },
                        null,
                        default);
                }
            }
            if (noCodeQLInfoBar != null)
            {
                await noCodeQLInfoBar.ShowAsync();
            }
            await CodeQLCommand.Instance.CodeqlRefreshAvailableQueriesAsync();
        }
    }
}
