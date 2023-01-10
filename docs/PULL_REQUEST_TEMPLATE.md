## Checklist for Pull Requests

- [ ] Description is filled out.
- [ ] Only one query or related query group is in this pull request.
- [ ] The version number on changed queries has been increased via the `@version` comment in the file header.
- [ ] All unit tests have been run: ([Test README.md](src\drivers\test\README.md)).
- [ ] Commands `codeql database create` and `codeql database analyze` have completed successfully.
- [ ] A .qhelp file has been added for any new queries or updated if changes have been made to an existing query.