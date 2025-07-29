### The queries in general will have the following structure

* PendingStatusError/
    - PendingStatusError.sarif -> Expected result of running PendingStatusError.ql on the sample database
    - PendingStatusError.ql -> The query
    - PendingStatusError.qhelp -> Query documentation using CodeQL styles
    - driver_snippet.c -> A test file containing passing and failing cases.