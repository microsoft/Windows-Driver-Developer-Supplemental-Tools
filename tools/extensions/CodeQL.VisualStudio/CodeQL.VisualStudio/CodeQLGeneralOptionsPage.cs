// Copyright (c) Microsoft. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for full license information.

using System;
using System.ComponentModel;
using System.Runtime.InteropServices;
using System.Windows;

using Microsoft.VisualStudio.Shell;

namespace Microsoft.CodeQL.Options
{
    [ComVisible(true)]
    public class CodeQLGeneralOptionsPage : UIElementDialogPage
    {
        private readonly Lazy<CodeQLGeneralOptionsControl> _codeqlViewerOptionsControl;

        public CodeQLGeneralOptionsPage()
        {
            _codeqlViewerOptionsControl = new Lazy<CodeQLGeneralOptionsControl>(() => new CodeQLGeneralOptionsControl(this));
        }

        public string CliPathOption { get; set; } = "";
        public string QueryLocationsOption { get; set; } = "";
        public string MemoryOption { get; set; } = "";
        public string ThreadsOption { get; set; } = "1";
        public string BuildCmdOption { get; set; } = "";

        /// <summary>
        /// Gets the Windows Presentation Foundation (WPF) child element to be hosted inside the Options dialog page.
        /// </summary>
        /// <returns>The WPF child element.</returns>
        protected override UIElement Child
        {
            get
            {
                return _codeqlViewerOptionsControl.Value;
            }
        }

        /// <summary>
        /// This occurs when the User selecting 'Ok' and right before the dialog page UI closes entirely.
        /// This override handles the case when the user types inside an editable combobox and
        /// immediately hits enter causing the window to close without firing the combobox LostFocus event.
        /// </summary>
        /// <param name="e">Event arguments.</param>
        protected override void OnApply(PageApplyEventArgs e)
        {
            base.OnApply(e); // Saves the user's changes.
        }

        /// <summary>
        /// This page is called when VS wants to activate this page.
        /// ie. when the user opens the tools options page.
        /// </summary>
        /// <param name="e">Cancellation event arguments.</param>
        protected override void OnActivate(CancelEventArgs e)
        {
            // The UI caches the settings even though the tools options page is closed.
            // This load call ensures we display data that was saved. This is to handle
            // the case when the user hits the cancel button and reloads the page.
            LoadSettingsFromStorage();

            base.OnActivate(e);
        }
    }
}
