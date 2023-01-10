## Checklist for Pull Requests

[ ] Description filled out.
[ ] One query or related query group per PR.
[ ] Increase version number on changed queries via the `@version` comment in the file header.
[ ] Run all unit tests ([Test Command](src\drivers\test\build_create_analyze_test.cmd)).
[ ] Run `codeql database create` and `codeql database analyze` successfully.
[ ] Add a .qhelp file for any new queries or update it if you are introducing changes to an existing query.