---
name: git
description: Use when committing, staging, writing a commit message, branching, using git worktrees, opening or reviewing a pull request, merging, rebasing, tagging, initialising a repository or recovering from a git mistake such as a bad commit or a pushed secret. Not for CI workflows (use `ci-cd`).
license: MIT
---

# Git

## The rules that matter most

1. **Look before you stage.** Run `git status --short` before every commit. If a file appears that you
   did not touch in this task, someone else (another session, another agent, the user) is working in
   the tree. Stage your own files by path and leave theirs alone, or ask.
2. **Then stage everything that is yours.** Stage by path every file your task changed, new files
   included. Use `git add -A` only when `git status` shows nothing that is not yours. The failure to
   avoid is a partial commit: `git commit -a` skips new untracked files, and staging one file leaves
   its siblings behind. Both can commit a caller without the module it calls, and the branch stops
   building from a clean clone while your working copy still works. After the commit, check that
   `git status --short` shows none of your files.
3. **Never bypass hooks.** No `--no-verify`. If a hook fails, fix what it found. A hook that is wrong is
   fixed in its own commit.
4. **Never rewrite shared history.** No force-push to `main` or any branch others use. On your own
   branch, use `--force-with-lease`, never bare `--force`.
5. **Commit small and often.** One logical change per commit, and commit before you stop work, even
   when incomplete, so nothing is lost between sessions. Push when your workflow expects it, so work
   is not stranded on one machine. These are recommended defaults: adapt to your project's conventions.
6. **A working tree has one writer at a time.** Anything that stages, commits, checks out, stashes or
   reverts files is a writer, including you. Parallel agents that edit code each get their own worktree
   or clone (see "Parallel work").

## Commit messages

Conventional commits:

```
type(scope): what changed, readable without the scope

Optional body: why, and anything a reviewer cannot see in the diff.
Refs: #123
```

Types: `feat`, `fix`, `test`, `docs`, `refactor`, `perf`, `chore`, `ci`, `build`. Add `!` after the
type (or a `BREAKING CHANGE:` footer) for breaking changes. Scope is the area (`api`, `parser`,
`auth`), optional.

```
feat(search): add date-range filter
fix(auth): reject refresh tokens after rotation
test(cart): add failing case for an empty basket
refactor(billing): extract tax calculation
```

The subject says what the commit does to the code, in the imperative, under about 72 characters. The
body says why. Reference the issue or ticket when there is one.

## Branches

**A common default for a solo project is to commit to `main`**, keeping it green. Follow the
repository's own branching rules where it has them. Use a short-lived branch when:
- a change would leave `main` broken part-way through,
- someone else will review it,
- or it is an experiment you may discard.

Name branches `feat/<topic>`, `fix/<topic>`, `chore/<topic>`. Merge within a day or two and delete the
branch after merge. For a team, protect `main`: changes by pull request with passing checks.

## Parallel work and worktrees

- Before creating isolation, check whether you are already in a worktree (`git worktree list`, or
  `git rev-parse --git-common-dir` differing from `--git-dir`).
- `git worktree add ../repo-topic -b feat/topic` gives a separate working tree on its own branch.
- **Run the test suite in a new worktree before changing anything.** If it fails there, the failure
  is the baseline, not your change. Record it.
- A worktree is not full isolation. It shares `.git/config`, hooks, refs and the object store with the
  main checkout. For work that rewrites config or must not see other branches, use
  `git clone --no-hardlinks` instead.
- Dependencies are not copied. Symlink or reinstall `node_modules`, virtual environments and build
  caches.
- When an agent reverts or mutates source to test something, restore from a byte-exact copy, not
  `git checkout`. A checkout also reverts a concurrent writer's uncommitted work.
- Remove worktrees when done: `git worktree remove <path>`.

## Finishing a branch

When the work is done and its tests pass, offer exactly these four options and wait for a choice:
1. Merge into the base branch locally.
2. Push and open a pull request.
3. Keep the branch as it is for later.
4. Discard it.

Discarding deletes work: list the commits that will be lost and require an explicit yes. Then clean up
the worktree for options 1 and 4.

## Pull requests and review

Read `references/pull-requests.md` when opening or reviewing a pull request: size limits, the
description template, reviewer order, comment conventions and merge strategy. Default merge strategy
is squash.

## New repository

- [ ] `.gitignore` is the first commit, before any other file (baseline in the `security` skill's
      `references/repo-hygiene.md`).
- [ ] `LICENSE`, a `README.md` stub and `.env.example` with every required key.
- [ ] Sensitive-file pre-commit hook installed. `.git/hooks` is not cloned, so document the
      install step, set `core.hooksPath` to a versioned folder or use the `pre-commit` framework.
- [ ] `git status` shows nothing sensitive before the first feature commit.

## Recovering from mistakes

| Situation | Do this |
|---|---|
| Wrong message on the last unpushed commit | `git commit --amend` |
| Forgot a file in the last unpushed commit | `git add <file> && git commit --amend --no-edit` |
| Need to undo a pushed commit | `git revert <sha>` (a new commit), never reset a shared branch |
| Committed to the wrong branch, not pushed | `git branch <new>` then `git reset --keep HEAD~1` on the wrong one |
| Lost a commit after a reset or rebase | `git reflog`, then `git branch rescue <sha>` |
| Pushed a secret | Rotate the secret FIRST. Then follow the `security` skill's leak procedure. |
| Before any risky operation | `git branch backup/<topic>` as a save point. It costs nothing. |

## Gotchas

- **`git add -A` sweeps in other people's work.** Rules 1 and 2 exist because of this. Unrelated files in your
  commit, under a message that does not mention them, are hard to untangle later.
- **`git stash` ignores untracked files** unless you pass `-u`. A stash before a checkout can leave new
  files behind to be overwritten or committed by mistake.
- **A deploy that works is not a complete repository.** Tools that deploy from your working directory
  succeed with uncommitted files. Prove the commit is complete by building from a clean clone.
- **Interactive commands do not work for an agent.** `git add -p`, `git rebase -i` and editors opened by
  git hang. To split changes into several commits, stage by path, or write a patch and apply it with
  `git apply --cached`.
- **Line endings and file mode.** A diff that touches every line, or every file with no visible change,
  is usually `core.autocrlf` or `core.fileMode`. Fix the setting, do not commit the noise.
- **Large binaries.** Once committed they stay in history. Use Git LFS or keep them out.

## Verification

- `git status --short` lists none of your files after the commit.
- `git log --oneline -5` shows the commits you meant, with messages that stand alone.
- For a multi-file change: a fresh clone of the pushed branch builds and passes its tests.
- `gitleaks git .` over the history finds nothing new (older gitleaks: `gitleaks detect --source .`).
