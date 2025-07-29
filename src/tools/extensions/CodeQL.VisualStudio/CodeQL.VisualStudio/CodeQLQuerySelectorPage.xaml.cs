// Copyright (c) Microsoft. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for full license information.

using Microsoft.CodeQL.Core;
using Microsoft.VisualStudio.Shell;
using Microsoft.VisualStudio.Shell.Interop;
using System;
using System.Collections.Generic;
using System.Collections.Immutable;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;
namespace Microsoft.CodeQL.Views
{
    /// <summary>
    /// Interaction logic for CodeQLQuerySelectorPage.xaml.
    /// </summary>
    public partial class CodeQLQuerySelectorPage : INotifyPropertyChanged
    {
        private static ObservableCollection<string> _discoveredQueryPacks = new ObservableCollection<string>();

        public ObservableCollection<string> DiscoveredQueryPacks
        {
            get => _discoveredQueryPacks;
            set
            {
                if (_discoveredQueryPacks == value)
                    return;

                _discoveredQueryPacks = value;
                OnPropertyChanged();
            }
        }

        bool _hasActivated = false;
        public CodeQLQuerySelectorPage()
        {
            Owner = Application.Current.MainWindow;
            InitializeComponent();
            DataContext = this;
        }

        private void ComboBox_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {

        }

        private void ListBox_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
        }

        protected override void OnActivated(EventArgs e)
        {
            if (_hasActivated)
            {
                return;
            }
            _hasActivated = true;
           
            if(!string.IsNullOrEmpty(CodeQLService.Instance.SelectedQuery))
            {
                queryListBox.SelectedItem = CodeQLService.Instance.SelectedQuery;
            }
            if(_discoveredQueryPacks.Count == 0)
            {
                LoadAvailableQueriesAsync().FileAndForget("Microsoft/SARIF/Viewer/CodeQL/Failed");
            }
        }

        public event PropertyChangedEventHandler PropertyChanged;

        protected virtual void OnPropertyChanged([CallerMemberName] string propertyName = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }

        private void ButtonOK_Click(object sender, RoutedEventArgs e)
        {
            CodeQLService.Instance.SelectedQuery = queryListBox.SelectedItem as string;

            this.DialogResult = true;
            this.Close();
        }
        private void ButtonCancel_Click(object sender, RoutedEventArgs e)
        {
            this.DialogResult = false;
            this.Close();
        }
        private void ButtonRefresh_Click(object sender, RoutedEventArgs e)
        {
            _discoveredQueryPacks = new ObservableCollection<string>();
            LoadAvailableQueriesAsync().FileAndForget("Microsoft/SARIF/Viewer/CodeQL/Failed");
        }

        private async Task LoadAvailableQueriesAsync()
        {
            if (CodeQLService.CodeQLIsInstalled())
            {
                if(_discoveredQueryPacks.Count == 0)
                {
                    RefreshBar.Visibility = Visibility.Visible;
                    DiscoveredQueryPacks = await CodeQLService.Instance.FindAvailableQueriesAsync();
                    RefreshBar.Visibility = Visibility.Hidden;
                }
            }
        }
    }

}
