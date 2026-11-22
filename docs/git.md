# git
Module: [`config/core/git.sh`](/config/core/git.sh) · Depends on: `git`, `fzf`

Shorthands for everyday git, built around **worktrees**: every branch lives in
its own directory, and switching branches means moving to its directory instead
of checking it out in place.

## Commands
| Command               | Does                                                       |
| --------------------- | ---------------------------------------------------------- |
| `g h` / `g`           | Show usage (also shown on unknown commands)                 |
| `g c <url> [dir]`     | Clone as a bare repo + worktree layout, `cd` into it        |
| `g c -c <args...>`    | Plain `git clone <args...>`                                 |
| `g ci [-f] [-c]`      | Pick a branch with fzf and `cd` to its worktree             |
| `g a [paths...]`      | Stage changes (untracked whole, tracked hunk by hunk)       |
| `g cm <msg>`          | Signed commit (`git commit -S -m`)                          |
| `g s`                 | `git status`                                                |
| `g st` / `sl` / `sp`  | `git stash` / `stash list` / `stash pop`                    |
| `g p` / `pu` / `pt`   | Push / push, setting upstream to `origin/<branch>` only if not already set / push tags |
| `g wn [-c] <branch> [base]` | Create a branch in a new worktree, `cd` into it       |
| `g w`                 | List worktrees                                              |
| `g wr [-f]`           | Pick a worktree with fzf and remove it                      |
| `g wp`                | Prune stale worktree metadata                               |
| `git-change-key`      | Interactively pick the GPG signing key for this repository  |

## Layout
`g c` produces:
```
project/
  .bare/        # the repository itself
  .git          # one line: "gitdir: ./.bare"
  main/         # worktree for the default branch
  feature-x/    # created on demand by `g ci`
```
- `.bare/` keeps git's internals apart from the worktrees, so a branch named
  `hooks` or `refs` cannot collide with them.
- The `.git` *file* lets every git command (and `g`) work from `project/`
  without `--git-dir`.
- Branch names have `/` replaced by `-` in directory names
  (`feature/x` → `feature-x/`).

Regular (non-bare) repositories work too: their worktrees are created beside
the repository, in `<repo>.worktrees/<branch>/`.

## Details
### `g c`
1. `git clone --bare` into `<dir>/.bare`, and writes the `.git` file.
2. Enables `origin/*` tracking (bare clones skip it), then fetches.
3. Keeps only the default branch locally, tracking `origin/<default>`;
   other branches are created with tracking when first switched to.
4. Adds the default branch's worktree and `cd`s into it.

Refuses to run if `<dir>` already exists. Extra `git clone` flags are only
accepted by `g c -c`.

### `g ci`
- Lists local and `origin/*` branches, previewing each one's log.
- Remote branches are fetched at most every `GIT_FETCH_TIMEOUT` seconds
  (default 300). The timestamp is shared by all worktrees. `-f` forces a fetch.
- If a worktree already has the branch, `cd` there; otherwise
  `git worktree add` it (remote-only branches get a local tracking branch).
- Keeps your relative subdirectory if it exists in the target worktree.
- `-c` falls back to `git checkout` in the current worktree.

### `g wn`
- Creates `<branch>` from `[base]` (default `HEAD`, i.e. the current branch;
  any commit-ish works, e.g. `origin/main` or a tag) in its own worktree and
  `cd`s into it, keeping your relative subdirectory.
- The new branch has no upstream; the first `g pu` sets it to
  `origin/<branch>`.
- Refuses invalid names and branches that already exist locally or on
  `origin` (switch to those with `g ci`).
- `-c` falls back to `git switch -c` in the current worktree.

### `g a`
- No arguments means the current directory; arguments are any git pathspec
  (files, directories, globs).
- Untracked files are added whole. Modifications, deletions and mode changes
  go through a single `git add --patch` session.
- Errors out on paths matching no files (typos, ignored files).

### `g wr`
Steps out of the selected worktree first if you are inside it. Extra arguments
go to `git worktree remove` (e.g. `-f` for worktrees with local changes).

## Configuration
| Variable                   | Default                         | Meaning                           |
| -------------------------- | ------------------------------- | --------------------------------- |
| `GIT_FETCH_TIMEOUT`        | `300`                           | Seconds between automatic fetches |
| `GIT_FETCH_TIMESTAMP_FILE` | `git-fetch.timestamp`           | Name, inside the shared git dir   |
| `GIT_EXTENSION_FILE`       | `~/.config/git-extras.config`   | Key → `user.name` map for `git-change-key` |

## Notes
- Moving a project directory breaks worktree links (git stores absolute
  paths); run `git worktree repair` from `project/`, or set
  `git config worktree.useRelativePaths true` (git ≥ 2.48) beforehand.
- `git-change-key` sets `user.*` with `--local`, so it applies to all
  worktrees of the repository.
