# Plain
A simple zsh theme by ztstroud

## Segments
### Git
Plain offers information about the current git repository, including the name of the repository, the name of the current
branch, and a brief summary of the status of the repo:

`in <repo_name> <remote_status> on <branch> <status>`

`<repo_name>` is the name of the folder that contains the git repository.

`<remote_status>` shows information about your branch in relation to its tracking branch. It has four different states:
- `^` means that your branch is ahead of its tracking branch
- `v` means that your branch is behind its tracking branch
- `N` means that your branch is both ahead and behind its tracking branch
- There can also be no symbol, which means you are either up to date, or there is no tracking branch

`<branch>` is the name of your current branch, or the short hash of the current commit if you are detached.

`<status>` shows information about the overall status of the local repository. It can include the following symbols:
- `@` means that you have stashed changed
- `>` means that you are in a merge
- `<` means that you are in a rebase
- `%` means that you are in a cherry-pick
- `^` means that you are in a revert

The status also shows information about the index and work tree. The symbols are:
- `~` means that there are modifications (including files being renamed)
- `+` means that files have been added
- `-` means that files have been deleted
- `?` means that there are untracked files
- `!` means that there are unmerged files

Each of these symbols can be one of three colors:
- green means that all the changes are in the index
- blue means that all the changes are in the work tree
- orange means that some changes are in the index, and some are in the work tree

## Options
### Runtime Options
These options can be set at any time

#### `PLAIN_REPORT_TIME_ABOVE`
The minimum number of seconds required for the execution time to appear, defaults to 60.

