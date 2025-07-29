using Microsoft.CodeQL.Core;
using Microsoft.VisualStudio;
using Microsoft.VisualStudio.Shell;
using Microsoft.VisualStudio.Shell.Interop;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Microsoft.CodeQL
{
    public class MyBuildEventsHandler : IVsUpdateSolutionEvents
    {
        public int UpdateProjectCfg_Begin(IVsHierarchy pHierarchy, IVsCfg pCfg)
        {
            return VSConstants.E_NOTIMPL;
        }

        public int UpdateSolution_Begin(ref int pfCancelUpdate)
        {
            return VSConstants.E_NOTIMPL;
        }

        public int UpdateSolution_Done(int fSucceeded, int fModified, int fCancelCommand)
        {
            bool isProjDirty = true;
            ThreadHelper.JoinableTaskFactory.Run(async () => isProjDirty = await ProjectHelper.IsProjectDirtyAsync());

            if (isProjDirty) // update the buildguid if the code changed 
            {
                Guid guid = Guid.NewGuid();
                CodeQLService.Instance.UpdateBuildInfo(guid.ToString());
            }
            return VSConstants.S_OK;
        }

        public int UpdateSolution_StartUpdate(ref int pfCancelUpdate)
        {
            return VSConstants.E_NOTIMPL;
        }

        public int UpdateSolution_Cancel()
        {
            return VSConstants.E_NOTIMPL;
        }

        public int OnActiveProjectCfgChange(IVsHierarchy pIVsHierarchy)
        {
            return VSConstants.E_NOTIMPL;
        }

        // Implement other methods as needed (can return VSConstants.E_NOTIMPL if unused)
    }
}