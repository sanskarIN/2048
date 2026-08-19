# Git and GitHub Contributor Handbook

This guide explains the Git workflow used for **2048 Nova**, from installation and identity configuration to commits, branches, syncing, reviewing diffs, recovering from mistakes, and understanding the difference between Git and GitHub.

## 1. Git versus GitHub

### Git

Git is the distributed version-control system installed on your computer. It records commits, branches, tags, file history, merges, and repository state.

### GitHub

GitHub is the hosting/collaboration service where this Git repository is published. GitHub adds issues, pull requests, Actions, repository settings, releases, and web-based collaboration.

You can use Git without GitHub, but this project uses both.

## 2. Install Git

### Windows

With WinGet:

```powershell
winget install --id Git.Git -e
```

### macOS

Apple Command Line Tools include Git:

```bash
xcode-select --install
```

If intentionally managed through Homebrew:

```bash
brew install git
```

### Debian/Ubuntu

```bash
sudo apt-get update
sudo apt-get install -y git
```

### Fedora

```bash
sudo dnf install git
```

### Arch Linux

```bash
sudo pacman -S git
```

## 3. Verify Git

```bash
git --version
```

Find which executable is selected.

Windows:

```powershell
where.exe git
```

macOS/Linux:

```bash
which git
type -a git
```

## 4. Upgrade Git

Use the same supported package/vendor method that installed Git.

Windows/WinGet example:

```powershell
winget upgrade --id Git.Git -e
```

Homebrew example:

```bash
brew update
brew upgrade git
```

Debian/Ubuntu receives Git updates through its configured package repositories and OS lifecycle.

After upgrading:

```bash
git --version
git status
```

## 5. Clone this repository

```bash
git clone https://github.com/sanskarIN/2048.git
cd 2048
```

`clone` creates:

- project files;
- local Git metadata under `.git/`;
- commit history;
- local branch checkout;
- a remote normally named `origin`.

Check remotes:

```bash
git remote -v
```

## 6. Git identity

A commit stores author/committer identity metadata.

For this repository, configure locally when required:

```bash
git config user.name "Sanskar"
git config user.email "sanskarin@outlook.in"
```

Check:

```bash
git config user.name
git config user.email
```

Because `--global` is omitted, these values apply to this repository only.

Use `--global` only when you deliberately want the same identity for all repositories handled by that operating-system user account.

## 7. Repository state

```bash
git status
```

Git can report files as:

- untracked — not yet tracked by Git;
- modified — tracked content changed;
- staged — selected for the next commit;
- deleted — tracked file removed;
- renamed — Git detected/proposed a rename representation.

Short form:

```bash
git status --short
```

## 8. Working tree, index, and commit

Think of Git in three important layers:

1. **working tree** — files you currently edit;
2. **index/staging area** — exact changes selected for the next commit;
3. **commit/history** — permanent recorded snapshot.

This distinction is why `git add` and `git commit` are separate operations.

## 9. Inspect unstaged changes

```bash
git diff
```

Shows line-level changes not yet staged.

Inspect one file:

```bash
git diff -- docs/README.md
```

The `--` separates command options from file paths.

## 10. Stage changes

One file:

```bash
git add docs/README.md
```

Several deliberate files:

```bash
git add docs/README.md docs/FEATURE_REFERENCE.md
```

Avoid automatically using `git add .` when unrelated/generated/private files might be present. Review status first.

## 11. Inspect staged changes

```bash
git diff --staged
```

This is the most important pre-commit review because it shows what the next commit will actually contain.

## 12. Commit

```bash
git commit -m "docs: improve setup guide"
```

`-m` supplies the commit message.

A good project commit:

- represents one coherent change;
- has a clear imperative/description-style message;
- does not mix unrelated formatting, features, docs, and generated artifacts unnecessarily;
- contains no secrets;
- passes applicable checks.

## 13. Why this project uses granular commits

Small meaningful commits improve:

- review;
- rollback;
- blame/history;
- debugging regressions;
- release notes;
- separation between behavior/docs/tests/CI.

“Maximum commits” should still mean **maximum useful granularity**, not empty/no-op commits that add no project value.

## 14. View history

```bash
git log
```

Compact graph:

```bash
git log --oneline --decorate --graph --all
```

Inspect one commit:

```bash
git show <commit-sha>
```

Replace the placeholder with a real commit ID.

## 15. Commit SHA

Every Git commit has an object identifier, commonly called a SHA. Documentation may use a shortened leading portion when it is unambiguous.

The current commit:

```bash
git rev-parse HEAD
```

`HEAD` normally refers to the currently checked-out commit.

## 16. Branches

List branches:

```bash
git branch
```

Create/switch to a maintenance branch:

```bash
git switch -c maintenance/toolchain-upgrade
```

Switch to existing `main`:

```bash
git switch main
```

A branch is a movable pointer to a line of commits.

## 17. Why use a branch for risky upgrades

Toolchain/dependency migrations can touch many files and fail partway through. A branch isolates that work from `main` and makes review/revert easier.

For ordinary direct-maintenance workflows on authorized repositories, still ensure every pushed commit is coherent and validated.

## 18. Fetch

```bash
git fetch origin
```

Downloads remote refs/objects without automatically changing your checked-out working branch.

This is useful when you want to inspect remote changes before integrating them.

## 19. Pull

```bash
git pull --ff-only
```

Conceptually:

1. fetch remote changes;
2. update the current branch only if it can move forward without creating a merge commit.

`--ff-only` refuses when histories diverge, forcing you to decide how to reconcile them instead of receiving an unexpected merge.

## 20. Push

```bash
git push origin main
```

Meaning:

- `push` — send local refs/objects to a remote;
- `origin` — remote name;
- `main` — branch.

A successful push means GitHub received commits. It does **not** mean CI/tests have passed.

## 21. Upstream tracking

For a new branch:

```bash
git push -u origin maintenance/toolchain-upgrade
```

`-u` / `--set-upstream` records the remote tracking branch so later `git push`/`git pull` commands can infer it.

## 22. Remote URL

Check:

```bash
git remote -v
```

Change `origin` only when you intentionally need a different repository:

```bash
git remote set-url origin <repository-url>
```

Do not change the project remote to an unrelated repository merely to fix authentication.

## 23. HTTPS versus SSH authentication

GitHub can authenticate Git operations through supported HTTPS credential flows or SSH keys.

The repository source itself should never contain personal access tokens or private SSH keys.

If authentication fails, repair the credential/SSH configuration rather than embedding a token inside the remote URL committed to documentation/scripts.

## 24. `.gitignore`

`.gitignore` tells Git which untracked paths it should normally ignore.

This repository ignores generated/machine-local/sensitive categories such as build outputs and private signing configuration.

Important: `.gitignore` does not remove a file that is already tracked. If a secret was committed, adding it to `.gitignore` afterward does not erase it from history.

## 25. `.gitattributes`

Controls Git path attributes such as text/line-ending handling. It helps keep cross-platform development consistent.

## 26. `.git/` directory

The hidden `.git/` directory stores local repository metadata/history/refs/config.

Do not edit arbitrary internal files there unless you understand Git internals. Use normal Git commands.

Deleting `.git/` turns the working folder into ordinary files and destroys local repository metadata, although a fresh clone can restore published history.

## 27. Tracked file inventory

```bash
git ls-files
```

This is the canonical no-skip tracked-file list used by `docs/REPOSITORY_FILE_ATLAS.md`.

Filter tests:

```bash
git ls-files 'test/**'
```

Filter docs:

```bash
git ls-files 'docs/**'
```

## 28. Search tracked source

```bash
git grep "2.0.12"
```

`git grep` searches tracked files efficiently.

Extended regex example:

```bash
git grep -n -E 'TODO|FIXME'
```

`-n` prints line numbers; `-E` selects extended regular expressions.

Interpret results: tests/docs can intentionally contain strings that source audits are designed to detect in other contexts.

## 29. Restore an unstaged file

If you want to discard your working-tree changes to a tracked file:

```bash
git restore path/to/file
```

This is destructive to uncommitted edits in that file. Review `git diff` first.

Do not run broad restore commands when you are unsure which work is uncommitted.

## 30. Unstage without discarding file edits

```bash
git restore --staged path/to/file
```

This removes the change from the index while leaving the working-tree edit.

## 31. Revert a committed change safely

For a published commit that should be undone while preserving history:

```bash
git revert <commit-sha>
```

This creates a new commit applying the inverse changes.

Revert is generally safer for shared/public history than rewriting already-pushed commits.

## 32. Reset warning

Commands such as:

```bash
git reset --hard
```

can discard local work. Do not use them as a generic troubleshooting step.

Before any destructive reset, understand:

- target commit;
- staged changes;
- unstaged changes;
- untracked files;
- whether work exists anywhere else.

For this project, prefer explicit restore/revert/branch recovery when possible.

## 33. Stash

Temporary shelf:

```bash
git stash push -m "temporary work"
```

List:

```bash
git stash list
```

Reapply:

```bash
git stash pop
```

A stash is not a substitute for a meaningful long-term commit/backup. Conflicts can occur when reapplying.

## 34. Merge

```bash
git merge <branch-name>
```

Combines another branch's history into the current branch. A fast-forward may move the branch pointer; a divergent history may create a merge commit.

Review and test after conflict resolution.

## 35. Rebase

Rebase rewrites a sequence of commits onto a new base. It can keep linear history but changes commit IDs.

Do not casually rebase published shared commits. Use it only when you understand the collaboration/history consequences.

## 36. Merge conflict

A conflict means Git cannot automatically decide how to combine changes.

Workflow:

1. inspect `git status`;
2. open conflicting files;
3. resolve conflict markers intentionally;
4. run relevant tests/audits;
5. stage resolved files;
6. continue/commit the operation.

Never remove conflict markers by simply choosing one side without understanding the code/docs behavior.

## 37. Tags

List:

```bash
git tag
```

A release tag identifies a particular commit. Tags should be created only when release/version policy says that exact commit represents the release.

Do not tag a commit “stable” while the project's strict stable qualification gate is intentionally incomplete.

## 38. GitHub pull requests

A pull request proposes integrating commits from one branch/ref into another and provides:

- diff review;
- comments;
- CI/check status;
- approvals/review ownership;
- merge controls.

The repository includes `.github/pull_request_template.md` and CODEOWNERS.

## 39. GitHub Issues

Use issues for reproducible bugs, documentation problems, deliberate future-scope proposals, or repository-governance work.

The completed Version 2.0.12 scope should not be silently expanded through undocumented commits; new product features belong to a deliberately scoped future release.

## 40. GitHub Actions

Workflow files live under:

```text
.github/workflows/
```

A push can trigger automation. Do not infer success from the push itself; observe the workflow result.

## 41. Branch protection/rulesets

Branch protection/rulesets are GitHub repository settings, not ordinary tracked source files.

CI/CODEOWNERS can support governance but cannot truthfully replace a missing repository rule.

## 42. Secret scanning mindset

Before committing:

```bash
git diff --staged
```

Look for:

- passwords;
- tokens;
- signing keys;
- keystore files;
- API private keys;
- provisioning/private certificates;
- machine-local absolute secrets;
- personal files unrelated to the project.

If a real secret is accidentally pushed, treat it as compromised and rotate/revoke it. Deleting the line in a later commit is not enough by itself.

## 43. Line endings

Windows commonly uses CRLF and Unix-like systems commonly use LF. `.gitattributes`/Git settings help normalize tracked text.

Do not commit a whole repository as “changed” solely because an editor converted line endings.

Check:

```bash
git diff --stat
git diff
```

## 44. File mode changes

Linux/macOS can track executable-bit changes. If Git shows unexpected mode-only changes, determine whether a script genuinely needs executable permission rather than blindly committing it.

## 45. Rename versus delete/add

Git internally records snapshots and detects renames during comparison. A rename can appear as delete/add depending on similarity/diff settings.

Use clear commits so reviewers can understand intended movement.

## 46. Binary files

Images/keystores/archives are not line-diffed like text. Be careful with generated binary churn.

Private signing binaries must not be committed.

## 47. Commit-message pattern

This repository commonly uses concise prefixes such as:

```text
feat:
fix:
test:
docs:
ci:
style:
chore:
```

Examples:

```text
docs: add deep Android setup guide
test: protect documentation contract
fix: correct current build version in handbook
ci: pin native build toolchain
```

The prefix is a convention for readability, not a substitute for explaining the actual change.

## 48. Pre-push project checks

For Dart/source changes:

```bash
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test
```

Repository contracts:

```bash
dart run tool/repository_audit.dart --json
dart run tool/source_completion_audit.dart --json
```

Inspect:

```bash
git status
git diff --staged
```

## 49. Safely synchronize before work

Typical flow:

```bash
git switch main
git status
git pull --ff-only
```

If `git status` shows uncommitted work, resolve/preserve it before pulling rather than assuming Git can safely combine everything.

## 50. Safe documentation-edit workflow

```bash
git switch main
git pull --ff-only
git status
# edit one coherent document
git diff -- docs/example.md
git add docs/example.md
git diff --staged
git commit -m "docs: improve example guide"
git push origin main
```

If repository policy requires pull requests/protected branches, use a branch/PR instead of direct push.

## 51. What to do when a commit fails because identity is missing

Git may report that it cannot determine your identity.

Configure repository-local values:

```bash
git config user.name "Sanskar"
git config user.email "sanskarin@outlook.in"
```

Then retry the commit.

Do not put identity values into application source code merely to satisfy Git.

## 52. What to do when push is rejected

Possible causes include:

- remote branch has commits you do not have;
- branch protection/rules require a PR/check;
- authentication failed;
- permission is missing;
- non-fast-forward history;
- server policy/security block.

Read the exact error. Do not solve a rejection with forced push unless repository policy and history safety explicitly justify it.

## 53. Force-push warning

`git push --force` can overwrite shared remote history.

Do not use it on `main` as a generic way to fix divergence. Prefer pull/fetch/reconciliation/revert or a reviewed history-rewrite procedure.

## 54. Recover from the wrong branch

If you made uncommitted edits on the wrong branch, do not panic or delete them. Depending on state, you can create a branch at the current commit, stash, or commit the coherent work before moving it.

Use:

```bash
git status
git log --oneline --decorate -10
```

Then decide deliberately.

## 55. Repository-local configuration

View local settings:

```bash
git config --local --list
```

Global settings:

```bash
git config --global --list
```

System/global/local levels can override one another. If behavior is surprising, inspect the effective config with origin information:

```bash
git config --list --show-origin
```

## 56. Help

General:

```bash
git help
```

Command help:

```bash
git help commit
git commit --help
```

Short usage:

```bash
git commit -h
```

Read help before using unfamiliar destructive flags.

## 57. Git is not a backup of uncommitted work

Git protects what has been committed/referenced. Uncommitted files can still be lost through disk failure/destructive commands.

Make coherent commits frequently and push/backup important work according to project policy.

## 58. Related documentation

- [`README.md`](README.md) — setup index.
- [`PREREQUISITES.md`](PREREQUISITES.md) — all tools.
- [`UPGRADING_AND_SUPPORT.md`](UPGRADING_AND_SUPPORT.md) — tool support lifecycle.
- [`../COMMAND_REFERENCE.md`](../COMMAND_REFERENCE.md) — command syntax reference.
- [`../DEVELOPMENT.md`](../DEVELOPMENT.md) — project development workflow.
- [`../REPOSITORY_FILE_ATLAS.md`](../REPOSITORY_FILE_ATLAS.md) — no-skip file inventory.
- [`../../CONTRIBUTING.md`](../../CONTRIBUTING.md) — contribution policy.
