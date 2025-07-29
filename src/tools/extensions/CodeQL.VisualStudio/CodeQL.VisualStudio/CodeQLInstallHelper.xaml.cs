// Copyright (c) Microsoft. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for full license information.

using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;

using Microsoft.CodeQL.Core;
using Microsoft.VisualStudio.CodeAnalysis.CodeQL.Exceptions;
using Microsoft.VisualStudio.CodeAnalysis.CodeQL.Runner;

using Newtonsoft.Json.Linq;

namespace Microsoft.CodeQL.Views
{
    /// <summary>
    /// Interaction logic for CodeQLInstallHelper.xaml.
    /// </summary>
    public partial class CodeQLInstallHelper : Window
    {
        private readonly HashSet<string> _languagePacks;

        public CodeQLInstallHelper()
        {
            _languagePacks = new HashSet<string>();
            Owner = Application.Current.MainWindow;
            InitializeComponent();
            DataContext = this;
            cliExpander.IsExpanded = true;
            packsExpander.IsExpanded = true;
            if (CodeQLService.CodeQLIsInstalled())
            {
                OverwriteExistingCheckbox.IsEnabled = true;
                CurrentVersionTextBlock.Text = CodeQLService.Instance.GetCodeQLVersion();
            }
        }

        /// <summary>
        /// Handles the event when the create DVL button is clicked.
        /// </summary>
        /// <param name="sender">
        /// The sender of this event.
        /// </param>
        /// <param name="e">
        /// The Event Arguments.
        /// </param>
        private void ButtonInstall_Click(object sender, RoutedEventArgs e)
        {
            bool overwrite = OverwriteExistingCheckbox.IsChecked ?? false;

            // install codeql and packs
            if (!string.IsNullOrEmpty(___TextBoxVersion_.Text) &&
                (overwrite || CurrentVersionTextBlock.Text == "None" ))
            {
                InstallWindow iw = new InstallWindow(
                  version: ___TextBoxVersion_.Text,
                  path: ___TextBoxPath_.Text,
                  addToPath: AddToPathCheckBox.IsChecked ?? false,
                  _languagePacks,
                  PreReleaseCheckBox.IsChecked ?? false
              );
                iw.Owner = this;
                iw.DataContext = this;
                iw.backgroundWorker.RunWorkerAsync();
                this.DialogResult = iw.ShowDialog();
                Close();
            }
            // just install packs
            else if(_languagePacks.Count > 0)
            {
                InstallWindow iw = new InstallWindow(
                    _languagePacks
                );
                iw.Owner = this;
                iw.DataContext = this;
                iw.backgroundWorker.RunWorkerAsync();
                this.DialogResult = iw.ShowDialog();
                Close();
            }
            else
            {
                throw new Exception("No Selection");
            }
        }


        /// <summary>
        /// Handles the event when the cancel button is clicked.
        /// </summary>
        /// <param name="sender">
        /// The sender of this event.
        /// </param>
        /// <param name="e">
        /// The Event Arguments.
        /// </param>
        private void ButtonCancel_Click(object sender, RoutedEventArgs e)
        {
            this.DialogResult = false;
            Close();
        }
        public async Task<string> GetLatestVersionAsync()
        {
            using (var client = new HttpClient())
            {
                client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/vnd.github+json"));
                client.DefaultRequestHeaders.Add("User-Agent", "codeql-action");

                var request = new HttpRequestMessage(HttpMethod.Get, "https://api.github.com/repos/github/codeql-action/releases/latest");

                HttpResponseMessage response = await client.SendAsync(request);

                if (response.IsSuccessStatusCode)
                {
                    string content = await response.Content.ReadAsStringAsync();
                    JObject json = JObject.Parse(content);
                    return ((string)json["tag_name"]).Replace("codeql-bundle-v", "");
                }
                else
                {
                    return string.Empty;
                }
            }
        }
        private async Task SetVersionCheckBoxTextAsync()
        {
            ___TextBoxVersion_.Text = await GetLatestVersionAsync();
        }


        private void UseLatestCheckBox_Unchecked(object sender, RoutedEventArgs e)
        {
            ___TextBoxVersion_.IsEnabled = !UseLatestCheckBox.IsChecked ?? true;
            ___TextBoxVersion_.Text = "";
        }


        private void UseLatest_Checked(object sender, RoutedEventArgs e)
        {
            ___TextBoxVersion_.IsEnabled = !UseLatestCheckBox.IsChecked ?? true;
            _ = SetVersionCheckBoxTextAsync();
        }

        private void TextBoxVersion_TextChanged(object sender, TextChangedEventArgs e)
        {
            UpdateInstallButton();
        }

        private void LanguagePack_Checked(object sender, RoutedEventArgs e)
        {
            CheckBox checkBox = (CheckBox)sender;
            if (checkBox.IsChecked ?? false)
            {
                _languagePacks.Add(checkBox.Content.ToString());
            }
            else
            {
                _languagePacks.Remove(checkBox.Content.ToString());
            }

            UpdateInstallButton();
        }

        private void OverwriteExisting_Checked(object sender, RoutedEventArgs e)
        {
            UpdateInstallButton();
        }

        private void UpdateInstallButton()
        {
            if (_languagePacks.Count > 0 && CodeQLService.CodeQLIsInstalled())
            {
                // just installing packs
                buttonInstall.IsEnabled = true;
            }
            else if (Version.TryParse(___TextBoxVersion_.Text, out _))
            {
                // installing cli, maybe packs
                bool overwrite = OverwriteExistingCheckbox.IsChecked ?? false;
                if (overwrite || CurrentVersionTextBlock.Text == "None")
                {
                    buttonInstall.IsEnabled = true;
                }
                else
                {
                    buttonInstall.IsEnabled = false;
                }
            }
            else
            {
                buttonInstall.IsEnabled = false;
            }
        }
    }

    public partial class CodeQLPackInstallHelper : CodeQLInstallHelper
    {
        public CodeQLPackInstallHelper() : base()
        {
            cliExpander.IsExpanded = false;
            packsExpander.IsExpanded = true;
        }
    }
}
