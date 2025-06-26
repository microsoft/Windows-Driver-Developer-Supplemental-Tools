// Copyright (c) Microsoft. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for full license information.

using System;
using System.Windows.Controls;

namespace Microsoft.CodeQL.Options
{
    /// <summary>
    /// Interaction logic for SarifGeneralOptionsControl.xaml.
    /// </summary>
    public partial class CodeQLGeneralOptionsControl : UserControl
    {
        /// <summary>
        /// A handle to the options page instance that this control is bound to.
        /// </summary>
        private readonly CodeQLGeneralOptionsPage generalOptionsPage;

        public CodeQLGeneralOptionsControl(CodeQLGeneralOptionsPage page)
        {
            InitializeComponent();
            generalOptionsPage = page;
            this.DataContext = generalOptionsPage;
        }
    }
}
