# Code scanning

Static analysis for security: data followed from where it comes in to
where it can do harm, flagged where it gets there unchecked. Without it a
request parameter reaches a query, a file name reaches a shell, or a
user's text reaches the page as HTML, and nothing notices until someone
uses it.

## What it holds

That no data from outside (a request, a URL, a file, a message, a
storage value) reaches a sink (a query, a shell, a file path, the page's
HTML, a `eval`) without passing through what makes it safe there. This is
not lint: lint reads a line, and this follows a value through the code.

- It runs in CI on every push to the default branch and every PR, and on
  a schedule, since its rules improve when the code has not changed.
- A finding is fixed, or dismissed with a reason the next scan keeps. A
  dismissal says why the path is safe, not that it is inconvenient.
- It also reads the project's CI workflows, where the tool can, for
  untrusted input reaching a `run:` step.

## Its smallest form

On GitHub, a public repository turns on CodeQL's default setup in its
settings (Advanced Security, CodeQL analysis, Set up, Default), with no
workflow to keep. It finds the languages itself: JavaScript and
TypeScript, Python, Go, Rust, Java and Kotlin, C and C++, C#, Ruby,
Swift, and GitHub Actions workflows. Findings are in the repository's
Security tab, and a PR shows the ones it adds.

Elsewhere, or for a private repository without GitHub's Code Security,
semgrep runs in a workflow:

    - run: pipx run semgrep scan --config auto --metrics=off --error

`semgrep scan` needs no account; `--config auto` fetches rules from its
registry, whose rules are under semgrep's own licence, not an open source
one. semgrep 1 and CodeQL as of October 2026.

## Seen failing

Each is planted on a throwaway branch, seen flagged on its PR, and the
branch deleted:

- a request parameter concatenated into a shell command
- a URL's query string written into an element's `innerHTML`
- for a workflow, a PR's title used directly in a `run:` step

A scan that has never flagged anything is not yet trusted: it may not be
reading the language the project is written in.

## Where it cannot apply

- **A language the tool does not read** says so under _What is not held_,
  and leans on review and its fuzzer.
- **A project with no input from outside** (a pure library of sums) has
  little for this to find. It still runs, since the scan costs nothing to
  keep on, and says what it reads.
