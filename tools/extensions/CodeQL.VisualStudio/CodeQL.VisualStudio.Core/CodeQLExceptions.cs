// Copyright (c) Microsoft. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for full license information.

using System;

namespace Microsoft.VisualStudio.CodeAnalysis.CodeQL.Exceptions
{

    public class CodeQLAlreadyRunningException : Exception
    {
        public CodeQLAlreadyRunningException()
        {
        }

        public CodeQLAlreadyRunningException(string message)
            : base(message)
        {
        }

        public CodeQLAlreadyRunningException(string message, Exception inner)
            : base(message, inner)
        {
        }
    }
    public class DatabaseNotFinalizedException : Exception
    {
        public DatabaseNotFinalizedException()
        {
        }

        public DatabaseNotFinalizedException(string message)
            : base(message)
        {
        }

        public DatabaseNotFinalizedException(string message, Exception inner)
            : base(message, inner)
        {
        }
    }
    public class CodeQLPacksNotFoundException : Exception
    {
        public CodeQLPacksNotFoundException()
        {
        }

        public CodeQLPacksNotFoundException(string message)
            : base(message)
        {
        }

        public CodeQLPacksNotFoundException(string message, Exception inner)
            : base(message, inner)
        {
        }
    }
    public class CodeQLExeNotFoundException : Exception
    {
        public CodeQLExeNotFoundException()
        {
        }

        public CodeQLExeNotFoundException(string message)
            : base(message)
        {
        }

        public CodeQLExeNotFoundException(string message, Exception inner)
            : base(message, inner)
        {
        }
    }
    public class CodeQLException : Exception
    {
        public CodeQLException()
        {
        }

        public CodeQLException(string message)
            : base(message)
        {
        }

        public CodeQLException(string message, Exception inner)
            : base(message, inner)
        {
        }
    }

    public class CodeQLExceptionHandler
    {


    }
}
