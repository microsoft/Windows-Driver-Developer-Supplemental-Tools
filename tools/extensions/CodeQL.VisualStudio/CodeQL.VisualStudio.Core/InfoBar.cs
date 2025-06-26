// Copyright (c) Microsoft. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for full license information.

using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Globalization;
using System.Threading;

using Microsoft.VisualStudio;
using Microsoft.VisualStudio.Imaging;
using Microsoft.VisualStudio.Imaging.Interop;
using Microsoft.VisualStudio.Shell;
using Microsoft.VisualStudio.Shell.Interop;
using Microsoft.VisualStudio.Utilities;

using Task = System.Threading.Tasks.Task;

namespace Microsoft.CodeQL.Controls
{
    /// <summary>
    /// Displays a banner with a message for the user.
    /// </summary>
    public class InfoBar : IVsInfoBarUIEvents
    {
        /// <summary>
        /// Gets list of info bars currently being shown.
        /// </summary>
        /// <remarks>
        /// Exposed for test purposes.
        /// </remarks>
        internal static List<InfoBarModel> InfoBars { get; } = new List<InfoBarModel>();

        /// <summary>
        /// Standard spacing between info bar text elements.
        /// </summary>
        public const string InfoBarTextSpacing = "   ";

        private int showCount = 0;

        private readonly IVsInfoBarTextSpan[] content;
        private readonly Action<IVsInfoBarActionItem> clickAction;
        private readonly Action closeAction;
        private readonly ImageMoniker imageMoniker;

        private InfoBarModel infoBarModel;

        private IVsInfoBarUIElement uiElement;
        private uint eventCookie;

        private static readonly ReaderWriterLockSlimWrapper s_infoBarLock = new ReaderWriterLockSlimWrapper(new ReaderWriterLockSlim());


        /// <summary>
        /// Initializes a new instance of the <see cref="InfoBar"/> class.
        /// </summary>
        /// <param name="text">
        /// The text to display.
        /// </param>
        /// <param name="clickAction">
        /// An action to take when a user clicks on an <see cref="IVsInfoBarActionItem"/> (e.g. button) in the info bar.
        /// </param>
        /// <param name="closeAction">
        /// An action to take when the info bar is closed.
        /// </param>
        /// <param name="imageMoniker">The moniker of the image.</param>
        public InfoBar(string text, Action<IVsInfoBarActionItem> clickAction = null, Action closeAction = null, ImageMoniker imageMoniker = default)
            : this(new IVsInfoBarTextSpan[] { new InfoBarTextSpan(text) }, clickAction, closeAction, imageMoniker)
        {
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="InfoBar"/> class.
        /// </summary>
        /// <param name="content">
        /// The content to display.
        /// </param>
        /// <param name="clickAction">
        /// An action to take when a user clicks on an <see cref="IVsInfoBarActionItem"/> (e.g. button) in the info bar.
        /// </param>
        /// <param name="closeAction">
        /// An action to take when the info bar is closed.
        /// </param>
        /// <param name="imageMoniker">The moniker of the image.</param>
        public InfoBar(IVsInfoBarTextSpan[] content, Action<IVsInfoBarActionItem> clickAction = null, Action closeAction = null, ImageMoniker imageMoniker = default)
        {
            this.content = content;
            this.clickAction = clickAction;
            this.closeAction = closeAction;
            this.imageMoniker = imageMoniker.Equals(default(ImageMoniker)) ? KnownMonikers.StatusError : imageMoniker;
        }

        /// <summary>
        /// Shows the info bar in all code windows, unless the user has closed it manually since the last reset.
        /// </summary>
        /// <returns>A <see cref="System.Threading.Tasks.Task"/> representing the asynchronous operation.</returns>
        public async Task ShowAsync()
        {
            await ThreadHelper.JoinableTaskFactory.SwitchToMainThreadAsync();

            if (Interlocked.Increment(ref this.showCount) == 1)
            {
                // It wasn't visible before, but it is now.

                this.infoBarModel = new InfoBarModel(this.content, this.imageMoniker, isCloseButtonVisible: true);

                if (!(ServiceProvider.GlobalProvider.GetService(typeof(SVsShell)) is IVsShell shell)
                    || shell.GetProperty((int)__VSSPROPID7.VSSPROPID_MainWindowInfoBarHost, out object infoBarHostObj) != VSConstants.S_OK
                    || !(infoBarHostObj is IVsInfoBarHost mainWindowInforBarHost))
                {
                    return;
                }

                var infoBarUIFactory = ServiceProvider.GlobalProvider.GetService(typeof(SVsInfoBarUIFactory)) as IVsInfoBarUIFactory;
                this.uiElement = infoBarUIFactory?.CreateInfoBar(this.infoBarModel);
                if (this.uiElement == null)
                {
                    return;
                }

                // Add the InfoBar UI into the WindowFrame's host control.  This will put the InfoBar
                // at the top of the WindowFrame's content
                mainWindowInforBarHost.AddInfoBar(this.uiElement);

                InfoBars.Add(this.infoBarModel);

                // Listen to InfoBar events such as hyperlink click
                this.uiElement.Advise(this, out this.eventCookie);
            }
        }

        /// <summary>Closes the info bar from all views.</summary>
        /// <returns>A <see cref="Task"/> representing the asynchronous operation.</returns>
        public async Task CloseAsync()
        {
            await ThreadHelper.JoinableTaskFactory.SwitchToMainThreadAsync();

            if (Interlocked.Decrement(ref this.showCount) == 0)
            {
                // It was visible before, but it isn't now.

                // Stop listening to infobar events
                this.uiElement.Unadvise(this.eventCookie);

                // Close the info bar to correctly send OnClosed() event to the Shell
                this.uiElement.Close();

                using (s_infoBarLock.EnterWriteLock())
                {
                    InfoBars.Remove(this.infoBarModel);
                }

                this.uiElement = null;
            }
        }

        /// <summary>
        /// Event handler for when the info bar is manually closed by the user.
        /// </summary>
        /// <param name="infoBarUIElement">The info bar object.</param>
        public void OnClosed(IVsInfoBarUIElement infoBarUIElement)
        {
            if (infoBarUIElement == this.uiElement)
            {
                this.closeAction?.Invoke();
                this.CloseAsync().FileAndForget("InfoBarCloseFailure");
            }
        }

        /// <summary>
        /// Event handler for when an action item in the info bar is clicked.
        /// </summary>
        /// <param name="infoBarUIElement">The info bar object.</param>
        /// <param name="actionItem">The action item that was clicked.</param>
        public void OnActionItemClicked(IVsInfoBarUIElement infoBarUIElement, IVsInfoBarActionItem actionItem)
        {
            if (infoBarUIElement == this.uiElement)
            {
                this.clickAction?.Invoke(actionItem);
            }
        }
    }
}
