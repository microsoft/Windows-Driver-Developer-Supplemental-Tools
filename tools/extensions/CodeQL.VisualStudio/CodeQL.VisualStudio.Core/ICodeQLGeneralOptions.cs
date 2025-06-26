// Copyright (c) Microsoft. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for full license information.

namespace Microsoft.CodeQL.Options
{
    internal interface ICodeQLGeneralOptions
    {
        string CliPath { get; }
        string AdditionalQueryLocations { get; }
        string MemoryUsage { get; }
        string Threads { get; }
        string CustomBuildCommand { get; }
    }
}
