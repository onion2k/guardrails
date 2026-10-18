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

- It runs in the full check, with its rules fetched fresh each run, since
  they improve when the code has not changed.
- A finding is fixed, or dismissed with a reason the next scan keeps. A
  dismissal says why the path is safe, not that it is inconvenient.

## Its smallest form

The scan is semgrep, run locally in the full check:

    uvx semgrep scan --config p/default --metrics=off --error

`pipx run semgrep scan` with the same flags does the same. The rules are
a named pack from semgrep's registry, fetched each run: `--config auto`
picks packs for the project itself, but only with metrics on, and refuses
`--metrics=off`. A finding is dismissed with `nosemgrep: <rule>` in a
comment of the language, on the line or the line above, and the comment
says why the path is safe:

    // nosemgrep: javascript.browser.security.raw-html-concat.raw-html-concat -- the text is the project's own, from its content files

`semgrep scan` needs no account. The pack comes from semgrep's registry,
whose rules are under semgrep's own licence, not an open source one. semgrep 1 as of October 2026 (1.181 tried).

## Seen failing

Each is planted in the working tree, seen flagged, and taken out. A
fault is written the way the pack's rules read it, which is narrower
than the bug: the query string joined to a literal and assigned to
`innerHTML` is flagged, and the bare assignment of the same string is
not.

- a URL's query string, joined to a literal, written into an element's
  `innerHTML` (`raw-html-concat`)
- a request parameter concatenated into a shell command, in a handler of
  the framework the project uses

A scan that has never flagged anything is not yet trusted: it may not be
reading the language the project is written in.

## Where it cannot apply

- **A language the tool does not read** says so under _What is not held_,
  and leans on review and its fuzzer.
- **A project with no input from outside** (a pure library of sums) has
  little for this to find. It still runs, since the scan costs little
  to run, and says what it reads.
