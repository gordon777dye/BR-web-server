---
title: HELP
file: HELP.md
category: 70-commands
subcategory: 70-commands/information
kind: command
related: [HELP$, HELPTREE, HELPTREE2, OPTION, 9503, 9504, 9505]
corrections:
  - "BR 5.03, 2026-11-22: REGEX added to the COMMANDS set (HELP COMMANDS REGEX, or HELP REGEX), showing ../file-directory/ECMA_REGEX.md, and SEARCH added to the commands the index lists."
  - "New page (BR 5.0, 2026-11-21): the use of the HELP command, taken from br/docs/HELP.md with the implementation notes (messages, threads, the file service, the build) left out. The two-line account in windows-cursor/spec.md#br-tree-help said a help tab 'changes page without coming forward'; on Windows the client now brings the browser window forward, as described under 'The help tab' below."
---

# HELP — show a br_tree topic

`HELP` at the command line shows the br_tree topic for what you type after it. F1 and Ctrl-Y show the
topic for the word at the cursor, or for the error at an ERROR halt, and a program shows a topic with
[`HELP$(folder$, anchor$, "BROWSE")`](../../10-language/data-manipulation/system-functions/spec.md#help$).
This page covers `HELP` as typed. It describes how BR's help works with
[`OPTION 85`](../../00-configuration/config-directives/OPTION_(Config).md) **off**, which is the
default. With `OPTION 85` on, BR uses the older `.wbh` help files instead, which this page does not
cover (see [Help facility](../../20-io-screen/windows-cursor/spec.md#help-facility)). A program's own
field help (`INPUT FIELDS … HELP`) is not br_tree's and does not come here.

## Where the topic appears

- **In your web browser**, when br_tree2 (the HTML edition of br_tree) is found. BR opens one help tab
  and moves it to each new topic; if you close it, the next topic opens a new one. The status line says
  *Help is open in your browser* and the console is not touched. A tab left open by the last session
  is found again when BR restarts (see [The help tab](#help-tab)).
- **On the console** otherwise: when there is no br_tree2, no such page, or a client that cannot open a
  browser (the Unix console client has none). The page is turned into text and shown 23 rows at a time.
  The arrow keys, Page Up/Down and Home/End move; F2 or Esc leaves, and what was drawn stays on the
  console.

The pages come from the BR server through the client, so a client on another machine shows help the
same way.

<a id="command-line"></a>
## The HELP command line

`HELP` on its own lists what it covers, a set of words at a time. Type the words after it to narrow
down to a topic, for example `HELP COMMANDS LIST` or `HELP LIBRARIES FILEIO`. Most words of a set are
keywords; `REGEX`, among the commands, is the regular expressions `SEARCH` takes
([ECMA_REGEX.md](../file-directory/ECMA_REGEX.md)), and `HELP REGEX` alone shows it too. Tab, Enter and the
arrow keys work together on that list:

- **Tab** lists the words that fit where the cursor is and leaves the line as it is. The right and left
  arrows then put the next or prior word on the line (the list stays above it), Space shows the next
  screenful of a long list, and typing a letter narrows the list.
- **Enter** on a line whose last word is only the start of one or more words does the same as Tab: it
  lists them, puts the line back with the cursor at its end, and leaves the arrows and Space working on
  that list. On a whole word it shows the page. On a word with no page it says so on a row of its own
  and puts the line back as you typed it, with the cursor where it was. So Enter is a safe way to ask
  "is this the end of the path yet?" after using the arrows.
- **Backspace** at the end of a word takes the whole word. The cursor is then where a word begins, and
  the arrows offer the words that fit there: the right arrow the first, the left the last, and on from
  there. The list is not printed again; Tab shows it.
- An arrow key when no list is active is the plain cursor arrow.

<a id="help-tab"></a>
## The help tab (browser)

- **One tab.** Each new topic moves the same tab to the new page, and on Windows the browser's window
  is brought to the front when it does. Windows allows this because BR has just handled your
  keystroke. It cannot choose the tab: if another tab is the active one in that browser window, that
  is what shows, and you switch to the help tab yourself. Elsewhere the status line is the only sign.
- **A closed tab** is noticed, and the next topic opens a new one, which comes to the front by itself.
- **Across sessions.** BR remembers the address of its help tab. If you leave the tab open and restart
  BR, the first help request finds the same tab again and moves it, rather than opening another. It
  waits up to five seconds for the tab to answer; a tab that does not (closed, or a hidden tab the
  browser is slow to wake) is replaced by a new one, and if the old one wakes up later it simply joins
  the new one. Two BRs running at once each have their own tab, and the second does not disturb what
  the first saved.
- **Many tabs.** A browser lets all its tabs together keep only six connections to one address, so BR
  keeps at most two help tabs moveable by F1. When a third is opened, the oldest stops being moved. It
  still shows its page, and its links still work, but help no longer navigates it. Close tabs you no
  longer need, especially any left over from an older build of BR, which may keep reconnecting.

## Where the trees are found

- **br_tree**, the Markdown reference, is where topics are looked up. BR finds it through
  [`CONFIG HELPTREE`](../../00-configuration/config-directives/spec.md#helptree), then
  `ENV$("BR_TREE")`, then a `br_tree` or `context/br_tree` folder in BR's current folder and the two
  above it, then the same around the folder BR was started in and BR's own folder. Error **9503** says
  it was not found.
- **br_tree2**, the HTML edition the browser shows, is found through
  [`CONFIG HELPTREE2`](../../00-configuration/config-directives/spec.md#helptree2), then
  `ENV$("BR_TREE2")`, then beside br_tree. Each place may be the tree itself or the folder holding it,
  as long as `_index.html` and `style.css` are at its root. It is made from br_tree by
  `context/dev/tools/gen_brtree_html.exe` and mirrors it file for file (`x.md` is `x.html`), keeping
  every anchor, so a topic found in br_tree carries straight across.

Both are found once and remembered. `CONFIG HELPTREE CLEAR` and `CONFIG HELPTREE2 CLEAR` make BR search
again. Both statements are refused in a restricted session.

## What the browser connects to

The pages are served by the client on your own machine, not by a website:

- It listens on `127.0.0.1` (loopback) only, over plain HTTP. Browsers treat loopback as a secure
  origin, and nothing leaves the machine. The BR connection between client and server is TLS as
  always.
- It serves only br_tree2's pages, nothing else from disk, and answers only `GET`. A secret token, 128
  random bits, is the first part of every address, so another machine or a web page cannot guess a
  working address. It also answers only requests addressed to `127.0.0.1` or `localhost`, which stops
  a web page from reaching it by another name.
- **The token and port are now kept from one session to the next**, so that a tab left open can find
  BR again. They are in `helpweb.state`, in BR's per-account local program directory
  (`%LOCALAPPDATA%\ADS` on Windows), beside the other per-account files. So the token protects against
  other accounts, other machines and web pages, but not against another process running as the same
  account, which can read that file. The token also stays in the browser's history and open tabs for
  as long as they do.
- The saved port is used again when it is free; if another BR already has it, the new session takes a
  new port and token and leaves the saved file alone.
- If a page is slow because BR is busy in a long statement, the browser shows a short "BR is busy —
  reload in a moment" page after about 30 seconds.

## From a program

`HELP$(folder$, anchor$, "BROWSE")` shows a topic the way F1 does and returns the same location. Any
third argument other than `"BROWSE"` is error **410**, and a third argument with `OPTION 85` on is error
**9505**.

## Trying it

- F1 on a statement, on a command and at an ERROR halt; `HELP COMMANDS LIST`.
- F1 several times: one tab moves. Close the tab and press F1: a new tab opens.
- Leave the tab open, restart BR, and press F1: the same tab moves and no new one opens.
- `CONFIG HELPTREE2` pointed at nothing: help is shown on the console with its keys, F2 and Esc.

## See also

- [Help facility](../../20-io-screen/windows-cursor/spec.md#help-facility) — the older `.wbh` help, `HELP$`, `ON HELP`, and the short account of br_tree help
- [`HELPTREE` and `HELPTREE2`](../../00-configuration/config-directives/spec.md#helptree)
- [`HELP$`](../../10-language/data-manipulation/system-functions/spec.md#help$)
- [information](spec.md) — the other information commands
