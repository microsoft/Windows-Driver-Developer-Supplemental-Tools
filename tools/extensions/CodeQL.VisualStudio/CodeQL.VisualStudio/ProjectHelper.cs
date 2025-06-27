// Copyright (c) Microsoft. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for full license information.

using System;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Threading.Tasks;

using EnvDTE;

using EnvDTE80;

using Microsoft.VisualStudio.Setup.Configuration;
using Microsoft.VisualStudio.Shell;

namespace Microsoft.CodeQL
{
    /// <summary>
    /// Helper class for working with EnvDTE projects.
    /// </summary>
    internal static class ProjectHelper
    {
        private const uint VSITEMID_ROOT = unchecked((uint)-2);
        private const int VSHPROPID_ExtObject = -2027;
        private static readonly Guid WEB_PROJECT_GUID = new Guid("{E24C65DC-7377-472b-9ABA-BC803B73C61A}");
        private static readonly Guid VC_PROJECT_GUID = new Guid("{8BC9CEB8-8B4A-11D0-8D11-00A0C91BC942}");
        private static readonly Guid VB_PROJECT_GUID = new Guid("{F184B08F-C81C-45F6-A57F-5ABD9991F28F}");
        private static readonly Guid CSHARP_PROJECT_GUID = new Guid("{FAE04EC0-301F-11D3-BF4B-00C04F79EFBC}");
        private static readonly Guid SOLUTIONFOLDER_PROJECT_GUID = new Guid("{66A26720-8FB5-11D2-AA7E-00C04F688DDE}");

        private static readonly Guid MISCFILES_PROJECT_GUID = new Guid(EnvDTE.Constants.vsProjectKindMisc);

        private static readonly Guid VC_PROJECTITEM_GUID = new Guid(CodeModelLanguageConstants.vsCMLanguageVC);
        private static readonly Guid VB_PROJECTITEM_GUID = new Guid(CodeModelLanguageConstants.vsCMLanguageVB);
        private static readonly Guid CSHARP_PROJECTITEM_GUID = new Guid(CodeModelLanguageConstants.vsCMLanguageCSharp);

        internal static bool IsVCProject(Project project)
        {
            ThreadHelper.ThrowIfNotOnUIThread();
            return IsProjectKind(project, VC_PROJECT_GUID);
        }

        internal static bool IsVBProject(Project project)
        {
            ThreadHelper.ThrowIfNotOnUIThread();
            return IsProjectKind(project, VB_PROJECT_GUID);
        }

        internal static bool IsCSharpProject(Project project)
        {
            ThreadHelper.ThrowIfNotOnUIThread();
            return IsProjectKind(project, CSHARP_PROJECT_GUID);
        }

        internal static bool IsWebProject(Project project)
        {
            ThreadHelper.ThrowIfNotOnUIThread();
            return IsProjectKind(project, WEB_PROJECT_GUID);
        }

        internal static bool IsSolutionFolderProject(Project project)
        {
            ThreadHelper.ThrowIfNotOnUIThread();
            return IsProjectKind(project, SOLUTIONFOLDER_PROJECT_GUID);
        }

        internal static bool IsMiscellaneousFilesProject(Project project)
        {
            ThreadHelper.ThrowIfNotOnUIThread();
            return IsProjectKind(project, MISCFILES_PROJECT_GUID);
        }

        internal static bool IsVCProjectWithCLRSupport(Project project)
        {
            ThreadHelper.ThrowIfNotOnUIThread();
            bool result = false;
            if (IsVCProject(project))
            {
                ConfigurationManager cfgManager = project.ConfigurationManager;
                if (cfgManager != null)
                {
                    Configuration activeConfig = cfgManager.ActiveConfiguration;
                    if (activeConfig?.Properties != null)
                    {
                        Properties properties = activeConfig.Properties;

                        Property property = properties.Item("CLRSupport");
                        if (property?.Value != null)
                        {
                            // If we can't parse value of this property than we will return by default 'false'
                            bool.TryParse(property.Value.ToString(), out result);
                        }
                    }
                }
            }

            return result;
        }
        internal static bool IsProjectKind(Project project, Guid projectKindGuid)
        {
            ThreadHelper.ThrowIfNotOnUIThread();
            return projectKindGuid == new Guid(project.Kind);
        }

        internal static bool IsVCProjectItem(ProjectItem projectItem)
        {
            ThreadHelper.ThrowIfNotOnUIThread();
            return GetProjectItemLanguage(projectItem) == VC_PROJECTITEM_GUID;
        }

        internal static bool IsVBProjectItem(ProjectItem projectItem)
        {
            ThreadHelper.ThrowIfNotOnUIThread();
            return GetProjectItemLanguage(projectItem) == VB_PROJECTITEM_GUID;
        }

        internal static bool IsCSharpProjectItem(ProjectItem projectItem)
        {
            ThreadHelper.ThrowIfNotOnUIThread();
            return GetProjectItemLanguage(projectItem) == CSHARP_PROJECTITEM_GUID;
        }

        internal static bool IsSupportedForAspProjectItem(EnvDTE.ProjectItem projectItem)
        {
            ThreadHelper.ThrowIfNotOnUIThread();
            Guid langGuid = GetProjectItemLanguage(projectItem);
            bool supportedForAsp = langGuid == CSHARP_PROJECTITEM_GUID || langGuid == VB_PROJECTITEM_GUID || langGuid == Guid.Empty;
            return supportedForAsp;
        }

        internal static Guid GetProjectItemLanguage(ProjectItem projectItem)
        {
            ThreadHelper.ThrowIfNotOnUIThread();
            FileCodeModel fileCodeModel = projectItem.FileCodeModel;
            return fileCodeModel == null ? Guid.Empty : new Guid(fileCodeModel.Language);
        }

        internal static ProjectItem FindProjectItem(ProjectItems projectItems, string lookupName)
        {
            ThreadHelper.ThrowIfNotOnUIThread();
            int count = projectItems.Count;

            for (int i = 1; i <= count; i++)
            {
                ProjectItem projectItem = projectItems.Item(i);

                if (string.Equals(lookupName, projectItem.Name, StringComparison.OrdinalIgnoreCase))
                {
                    return projectItem;
                }
            }

            return null;
        }

        internal static string GetProjectFullPath(EnvDTE.Project project)
        {
            ThreadHelper.ThrowIfNotOnUIThread();
            string projectFullPath = null;

            if (project != null)
            {
                try
                {
                    // When accessing Project DTE, it might always blow up, for example when project failed to load,
                    // it is represented by an object which will throw NotImplemented on many DTE calls, etc
                    projectFullPath = project.FullName;
                }
                catch (Exception e)
                {
                    if (e is ArgumentException || e is COMException)
                    {
                        // Sometimes if the project failed to load we might get E_INVALIDARG here from DTE
                        Debug.Fail("Error while trying to obtain project full path. \n" + e.ToString());
                    }
                    else
                    {
                        throw;
                    }
                }
            }

            return projectFullPath;
        }

        internal static Project GetActiveProject()
        {
            ThreadHelper.ThrowIfNotOnUIThread();
            DTE2 dte = (DTE2)Microsoft.VisualStudio.Shell.Package.GetGlobalService(typeof(DTE));
            Array activeSolutionProjects = dte.ActiveSolutionProjects as Array;
            if (activeSolutionProjects.Rank <= 0 || activeSolutionProjects.GetLength(0) <= 0)
            {
                return null;
            }
            else if (activeSolutionProjects.Length > 1)
            {
                return null;
            }

            return activeSolutionProjects.GetValue(0) as Project;
        }

        internal static string GetProjectFileName(Project project)
        {
            ThreadHelper.ThrowIfNotOnUIThread();
            string fileName = null;
            if (project != null)
            {
                try
                {
                    fileName = System.IO.Path.GetFileName(project.FullName);
                }
                catch (Exception e)
                {
                    if (e is ArgumentException || e is COMException)
                    {
                        // Sometimes if the project failed to load we might get E_INVALIDARG here from DTE
                        Debug.Fail("Error while trying to obtain project name. \n" + e.ToString());
                    }
                    else
                    {
                        throw;
                    }
                }
            }

            return fileName;
        }

        internal static string GetProjectDirectory(Project project)
        {
            ThreadHelper.ThrowIfNotOnUIThread();
            string directory = null;
            if (project != null)
            {
                try
                {
                    directory = System.IO.Path.GetDirectoryName(project.FullName);
                }
                catch (Exception e)
                {
                    if (e is ArgumentException || e is COMException)
                    {
                        // Sometimes if the project failed to load we might get E_INVALIDARG here from DTE
                        Debug.Fail("Error while trying to obtain project directory. \n" + e.ToString());
                    }
                    else
                    {
                        throw;
                    }
                }
            }

            return directory;
        }

        internal static Configuration GetProjectActiveConfiguration(Project project)
        {
            ThreadHelper.ThrowIfNotOnUIThread();
            if (IsVCProject(project))
            {
                ConfigurationManager cfgManager = project.ConfigurationManager;
                if (cfgManager != null)
                {
                    return cfgManager.ActiveConfiguration;
                }
            }
            return null;
        }
        internal static string GetProjectPropertyValue(Project project, string propertyName)
        {
            ThreadHelper.ThrowIfNotOnUIThread();
            Configuration activeConfig = GetProjectActiveConfiguration(project);
            if (activeConfig != null && activeConfig?.Properties != null)
            {
                Properties properties = activeConfig.Properties;

                Property property = properties.Item(propertyName);
                if (property?.Value != null)
                {
                    // If we can't parse value of this property than we will return by default 'false'
                    return property.Value.ToString();
                }
            }
            return null;
        }

        internal static string GetVisualStudioFolder()
        {
            SetupConfiguration sc = new SetupConfiguration();
            return sc.GetInstanceForCurrentProcess().GetInstallationPath();
        }

        internal static async System.Threading.Tasks.Task<bool> IsProjectDirtyAsync()
        {
            await ThreadHelper.JoinableTaskFactory.SwitchToMainThreadAsync();

            Project project = GetActiveProject();
            if (project != null)
            {
                return project.IsDirty;
            }
            return true;
        }

        internal static async System.Threading.Tasks.Task BuildProjectAsync()
        {
            await ThreadHelper.JoinableTaskFactory.SwitchToMainThreadAsync();

            Project project = GetActiveProject();
            if (project != null )
            {
                if (project.IsDirty)
                {
                    TaskCompletionSource<bool> buildTcs = new TaskCompletionSource<bool>();
                    DTE2 dte = (DTE2)Microsoft.VisualStudio.Shell.Package.GetGlobalService(typeof(DTE));
                    BuildEvents buildEvents = dte.Events.BuildEvents;
                    buildEvents.OnBuildDone += (scope, action) =>
                    {
                        buildTcs.TrySetResult(true);
                    };
                    dte.ExecuteCommand("Build.BuildSelection");
                    await buildTcs.Task;
                }
            }
            else
            {
                throw new Exception("No project");
            }
        }

        internal static async System.Threading.Tasks.Task ShowProgressAsync(string text)
        {
            await ThreadHelper.JoinableTaskFactory.SwitchToMainThreadAsync();
            DTE2 dte = (DTE2)Microsoft.VisualStudio.Shell.Package.GetGlobalService(typeof(DTE));
            dte.StatusBar.Text = text;
            dte.StatusBar.Animate(true, 0);
        }
        internal static async System.Threading.Tasks.Task HideProgressAsync()
        {
            await ThreadHelper.JoinableTaskFactory.SwitchToMainThreadAsync();
            DTE2 dte = (DTE2)Microsoft.VisualStudio.Shell.Package.GetGlobalService(typeof(DTE));
            dte.StatusBar.Clear();
        }
    }
}
