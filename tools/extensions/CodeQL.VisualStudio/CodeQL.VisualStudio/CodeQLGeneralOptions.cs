// Copyright (c) Microsoft. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for full license information.

using System;
using System.Collections.Generic;
using System.Windows.Controls;

using Microsoft.VisualStudio.Shell;

namespace Microsoft.CodeQL.Options
{
    internal class CodeQLGeneralOptions : ICodeQLGeneralOptions
    {
        private readonly string cliPathDefaultValue = "C:/codeql-home/codeql/";
        private readonly string additionalQueryLocationsDefaultValue = "";
        private readonly string memoryUsageDefaultValue = "";
        private readonly string threadsDefaultValue = "1";
        private readonly string customBuildCommandDefaultValue = "";
        private readonly AsyncPackage package;

        private readonly CodeQLGeneralOptionsPage optionPage;

     
        /// <summary>
        /// Initializes a new instance of the <see cref="CodeQLGeneralOptions"/> class.
        /// Get visual studio option values.
        /// </summary>
        /// <param name="package">Owner package, not null.</param>
        private CodeQLGeneralOptions(AsyncPackage package)
        {
            this.package = package ?? throw new ArgumentNullException(nameof(package));
            this.optionPage = (CodeQLGeneralOptionsPage)this.package.GetDialogPage(typeof(CodeQLGeneralOptionsPage));
        }

        private CodeQLGeneralOptions() { }
        public string CliPath => this.optionPage?.CliPathOption ?? cliPathDefaultValue;
        public string AdditionalQueryLocations => this.optionPage?.QueryLocationsOption ?? additionalQueryLocationsDefaultValue;
        public string MemoryUsage => this.optionPage?.MemoryOption ?? memoryUsageDefaultValue;
        public string Threads => this.optionPage?.ThreadsOption ?? threadsDefaultValue;
        public string CustomBuildCommand => this.optionPage?.BuildCmdOption ?? customBuildCommandDefaultValue;


        public readonly Dictionary<string, bool> OptionStates;

        /// <summary>
        /// Gets the instance of the command.
        /// </summary>
        public static CodeQLGeneralOptions Instance { get; private set; }

        /// <summary>
        /// Initializes the singleton instance of the <see cref="CodeQLGeneralOptions"/> class.
        /// </summary>
        /// <param name="package">Owner package, not null.</param>
        /// <returns>A <see cref="System.Threading.Tasks.Task"/> representing the asynchronous operation.</returns>
        public static async System.Threading.Tasks.Task InitializeAsync(AsyncPackage package)
        {
            // Switch to the main thread
            await ThreadHelper.JoinableTaskFactory.SwitchToMainThreadAsync(package.DisposalToken);

            Instance = new CodeQLGeneralOptions(package);
        }

        public static void InitializeForUnitTests()
        {
            Instance = new CodeQLGeneralOptions();
        }

        public bool IsOptionEnabled(string optionName)
        {
            if (this.OptionStates.TryGetValue(optionName, out bool state))
            {
                return state;
            }

            return false;
        }
    }
}
