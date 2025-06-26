// Copyright (c) Microsoft. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for full license information.

using System;
using System.Diagnostics;

using Microsoft.VisualStudio.Shell;
using Microsoft.VisualStudio.Shell.Interop;

namespace Microsoft.CodeQL
{
    public class OutputWindowTracerListener : TraceListener
    {
        private readonly string paneName;
        private readonly IVsOutputWindow outputWindowService;

        private IVsOutputWindowPane pane;

        public OutputWindowTracerListener(IVsOutputWindow outputWindowService, string name)
        {
            this.outputWindowService = outputWindowService;
            this.paneName = name;
            Trace.Listeners.Add(this);
        }

        public override void Write(string message)
        {
            if (this.EnsurePane())
            {
                    ThreadHelper.JoinableTaskFactory.RunAsync(async () =>
                    {
                        await ThreadHelper.JoinableTaskFactory.SwitchToMainThreadAsync();
                        this.pane.OutputStringThreadSafe(message);
                    }).FileAndForget("OutputWindowEvent");
            }
        }

        public override void WriteLine(string message)
        {
#pragma warning disable VSTHRD010 // Thread check inside this.Write().
            this.Write(Environment.NewLine + message);
#pragma warning restore VSTHRD010
        }

        private bool EnsurePane()
        {
            if (this.pane == null)
            {
#pragma warning disable VSTHRD108 // Assert thread affinity unconditionally.
                    ThreadHelper.ThrowIfNotOnUIThread();
#pragma warning restore VSTHRD108

                var guid = Guid.NewGuid();
                this.outputWindowService.CreatePane(ref guid, this.paneName, fInitVisible: 1, fClearWithSolution: 1);
                this.outputWindowService.GetPane(ref guid, out this.pane);
            }

            return this.pane != null;
        }
    }
}
