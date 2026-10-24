# AI Access in BR — Summary

This document explains what an AI assistant can do inside a BR session, who or what decides 
what happens, and what the person at the keyboard keeps control of.

This is the short account. `AI-Access-Protocol.md` has the detailed procedures and 
`AI-Restricted-Operations.md`is the list of operationss that a restricted session can do. These three documents decribe how BR 5.0 interacts directly with AI for the following scenarios.

## Scenarios

User Driven:
- User inquiries including custom report writing
- User training and user operating instructions
- Production data entry by AI (from scanned documents, etc.)
- Verification of user data entered

Programmer Driven:
- Program development, including design, coding, debugging, refactoring and documentation
- App test suite development and program verification
- Development of latform extensions such as audio I/O, web access and API's
- Remote AI assisted debugging - during a user session and independently

## Contents

- [Data Security](#data-security)
- [Three levels of authority](#three-levels-of-authority)
- [Restricted sessions: reporting without risk](#restricted-sessions-reporting-without-risk)
- [What the AI model can see](#what-the-ai-model-can-see)
- [What the AI model can input](#what-the-ai-model-can-input)
- [What the user controls](#what-the-user-controls)
- [Program development with AI](#program-development-with-ai)

<a id="data-security"></a>
## Data Security

One outstanding feature of this product is the security it provides in conjunction with AI. 
AI has the following major components:
- **An AI model provided through an Internet API**. This has its own generic information and 
  policies that are a good part of its intelligence. **The model clears its conversation memory 
  after every inquiry** to make room for the next inquiry, nearly always from some other random
  subscriber. So the conversation ***context* is sent to the model with each new prompt or 
  inquiry** (although it can be cached).
- **An assistant that runs on the user's PC** (or the web) and acts as the *conversation manager* 
  between the user and the AI model. Well known examples of assistants are: ChatGPT, Claude, 
  Gemini, Microsoft Copilot, and Perplexity. The assistant maintainns continuity between the user, 
  the conversation recent history (called the context), and a long term record of the 
  conversation. Each separate conversation is called a session. 
  
The assistant is the main security threat because it manages the flow of information to and from 
the model and maintains continuity. Another data security problem can occur when a user 
makes a request and the assistant with good intentions may research information and find it necessary 
to send that information to the model in order to accomplish what the user has asked it to do. 
Normally this is innocuous. But depending on the data sensitivity, which models you are working 
with, and which assistants you use, data breaches can happen. Everyone knows AI can make mistakes. 

Couple that with the fact that users can ask AI to prepare any possible ad-hoc report, AI writes 
a program to produce that report, and runs the program with the user's authority.

In user mode Business Rules prevents such accidents from happening in 4 ways:
- It restricts the entire application to a list of folders on your server.
- It prevents AI models from reading your application data files. Instead AI wites a program that 
  runs on the BR server to produce whatever report is requested. The report data never leaves the server. 
- It prevents AI generated programs from altering any existing application data using very 
  strong, core level data protection. 
- AI tests its ad hoc programs using system generated test data.

In user mode it does this data protection while it supports the ad hoc dynamic creation of report 
programs in response to customer inquiries. In programmer mode, it does not use these protections 
and it is left up to the programmer to develop with test data. The command that enables AI to 
attach determines which mode it will be. 

In other words, despite the facts that models are carefully trained to have integrity, models 
"forget" all of their conversations, and millions of people trust the major AI providers, 
there is some data that simply should not leave the premeses. BR enforces data restriction 
while it fully integrates applications with AI. This document explains how.

<a id="three-levels-of-authority"></a>
## Three levels of authority

BR recognises three parties, in a fixed order of precedence: **programmer, then user, then AI.**

## Programmer Authority

The configuration that is most productive for programming is:
- Operating with an assistant such as Claude Code or Codex, usually in an IDE such as VScode or 
  Cursor.
- The programmer uses the command console for debugging. 
- AI uses the context kit, log files, the harness, and test data for testing. 

**The programmer** can access program details through the BR client via the command console, or 
through the BR server using the debugger in conjunction with an editor. Or the programmer 
may use both client and server. He or she can step through a program, set breakpoints, read 
variables, issue commands and suspend what the user or the AI is doing from either the 
client or the server. This is the highest authority BR implements. 

When using the (server) debugger, the programmer can invite an AI service (model + assistant) 
to join the debugging connection for observation and/or participation, which can include 
interrogation and BR commands. But most often AI is only allowed to observe debugging 
operations while the programmer does the debugging and maintains a side conversation with AI. 

That being said, **this document will be focused on development through the BR client, including 
use of the command console, the AI-BR harness, and an AI assistant.**

In some programming environments AI cannot identify what's on the user's screen or step 
through programs observing the values as they change. BR does not have those AI limitations. 

## User Authority

**The user** holds authority over the keyboard and the (mouse) pointer while running an 
application. This is a person running the application, and nothing about the presence of an AI 
service restricts what they can do.

## AI Authority

**The AI Service** holds authority over nothing by default. It **may be allowed** to interrogate 
the screen contents, and it may *separately* be allowed to type and position the pointer. 
Typing and pointer movement are allowed by a grant given by the program or user, and are not 
something the AI model or assistant can arrange via its own user-level connection. 

Training sessions or report writing can safely be done with the full confidence your data files 
are protected and cannot be read by AI. While data on screens can be seen by AI assistants, BR 
has its own AI assistant, so you can use AI services without invoking their unkown program 
locally. Licensed copies of BR are provided with source code for the AI assistant (written in 
GO), so you can audit precisely what information leaves the premeses. 

It must be stated however, while user requests are recorded, nothing alters or filters their 
content. That being said, we offer hooks that licensed companies can use to filter AI inquiries 
issued by employees using a BR application. 

<a id="restricted-sessions-reporting-without-risk"></a>
## Restricted Sessions: reporting without risk

Another safety mechanism sits outside the authority ranking: restricted-sessions. With respect 
to restricted sessions, it is not a question of who has authority — it is about data protection 
that even a programmer cannot bypass.

The way it works is when AI is authorized to connect to a BR app, it is done in either programmer 
mode or user mode. When running in a live application setting, it is always user mode. When an AI 
dynamic program is created and run it **always** runs in its own restricted BR session.

When a session is marked **restricted**, from that moment on it is, in effect, a **reporting
session with a workspace of its own**. A program running restricted can:

- **reach what the site list allows it to reach** — a site can install a file list naming which 
  folders and files are permissible to access, and this can be unique for each login name
- **create files**, and then do anything it likes with the ones it created — rewrite, empty,
  rename, copy over and delete them, for as long as it runs
- **build indexes and sort**, so it can produce real reports rather than only list raw records
- **save a new program**.

It cannot:

- change a file it did not create: open it for output or update, add to it, overwrite, empty,
  rename, delete it or change its attributes
- replace an existing program, or create a new similarly named program that could be loaded in 
  place of an existing one
- execute an operating system command even when it has keyboard access
- type or click into another program, or print anywhere but to the computer's installed printers

The key is the nature of the guarantee: BR keeps, for the life of the session, a list of the files
the session created — each one's path *and* its identity on disk, so a different file later put under
the same name is not mistaken for it — and every change to a file is checked against that list at
the point BR hands the operation to the operating system. So there is no way to modify or delete
existing data. And because the checks happen at the BR internal operation rather
than by inspecting the program's text, they cannot be evaded by how the code or commands are 
created or processed.

The list is the session's alone. It is not shared with any other session and it ends with the
session, so a later session cannot change what an earlier one left behind; tidying up is for
ordinary, unrestricted programs.

This is what makes it safe to run a program an AI service wrote without having to look over the 
code. The program can look at everything, report on it and work with files of its own, and it cannot 
change anything that was already there.

**Two consequences worth planning for.** 
- An AI initiated application can only run in a separate, disposable session, which the application
  starts with `SPAWN_RESTRICTED`. The application's own session is not restricted by doing so, and 
  it can delete any files created by restricted sessions. 
- The restriction lasts for the life of the supplementary 
  session and nothing clears it — so the user's own later work in that reporting session is 
  restricted too. 

`SPAWN_RESTRICTED` starts a disposable session that is restricted
before it reads its configuration file, and one session of the 9 allowed per workstation ID is 
always left free for
the user. A program can also ask the assistant a question, the way it would ask a person: on the
Command Console, providing a variable for the model to answer in. The assistant reads the Console 
and, while it holds the keyboard grant, types the answer — there is no other way for it to reach 
the program, and the field checks its answer exactly as it would a person's. A program the assistant 
writes is typed into a file, shown, and run only when the person agrees — the assistant's grant is 
withdrawn while it asks, so it cannot agree for them — and then in such a session. Starting a 
session restricted is the only way to restrict one; there is no switch to restrict a session that is 
already running.

<a id="what-the-ai-model-can-see"></a>
## What the AI Model Can See

The AI does not read your BR application window off the glass. It asks BR what is there, and BR
answers. There are four ways, each answering a different question.

**A description of the Application Window contents.** BR produces a 
structured account of what it currently holds: 
every line of text, where the cursor is, the colours and highlighting, and every field and control
with its position and its current value — including the contents of grids and lists. This is the
only way to read the contents of fields and controls, and it is what an AI uses to understand a
form-driven program.

**A picture.** BR can render a window to a **PNG image**. It is drawn from BR's own text
buffer rather than captured from the display, which has a useful consequence: it works when the
window is behind another window or outside of the display area of your monitor. 
It is a faithful picture of what BR believes the application window looks like.

**A running account of console text.** A description and a picture are both snapshots, and a
snapshot cannot show what scrolled past between two of them. BR can therefore keep a log of every
write to the Command Console, timestamped to the millisecond, so a whole session can be read
back in order afterwards. This is what makes a *console session* observable. It records the
text, not the fields and controls — those are what the description above is for.

**What the program is doing.** Separately from the Command Console, BR can report on execution:
which lines ran, what commands were entered, when a watched variable changed its content, 
and what it changed to. An AI nodel 
watching a debugging session can be given a copy of everything the debugger sees, without taking
the debugger's place.

None of this happens unless the session has been told to allow it.

<a id="what-the-ai-model-can-input"></a>
## What the AI Model Can Input

The AI model can type at the keyboard, as a person does.

**A program asks a question and says what answers it.** Only then may the AI  hand over a text for
it, and only a question marked as answered by *code* will take a program. A question can be opened
only from inside the session, by a program; nothing the AI sends can open one. So what permits the
hand-over is not a permission the AI holds — it is a question a program asked, on a side the AI
cannot reach, which is why no keyboard grant is needed or consulted for it.

**Nothing handed over appears anywhere until the program reads it.** BR holds the text and the
program takes it a line at a time, if and when it chooses. A hand-over therefore cannot interrupt
the person at the keyboard, and cannot put text on the screen of a program that never asked for
any. A program handed this way is written to a file, shown to a person for approval with the AI's
grant withdrawn so only they can answer, and run in a restricted session.

Every hand-over is logged with its length and line count, so "where did this program come from"
has an answer.

<a id="what-the-user-controls"></a>
## What The User Controls

Four separate controls, and they are separate on purpose.

**1. There is no way in unless the session opens one.** BR does not listen for an AI by default.
The session must explicitly open the connection, and it accepts connections only from the same
machine — never from the network. Close it and the AI is gone.

**2. Getting in requires a secret that only you can read.** When the connection opens, BR writes a
fresh token into your own private application-data folder, which only your Windows account can
read. A connection that does not present that token is closed without a reply. The token lasts as
long as the connection stays open — an assistant that disconnects can reconnect with it — and a new
one is generated every time the connection is opened, so an old one is worth nothing. Closing the
connection deletes it.

**3. Reading and acting are two different permissions.** Being connected lets the AI *look*. It
does not let it type, click, or change anything on its own. There are two ways it can act, and
**you start both of them.**

*You ask it something.* Typing `AI` and a question at the `READY` prompt opens a turn, and the
assistant may answer with lines it wants run at your console. Those are marked `[AI] >` and
nothing else is, so you can always tell which commands came from the model. Because you started
it, this needs no grant — but it is not a free hand. Anything destructive **stops and asks you**:

```
[AI] the assistant asks permission to delete:
[AI]   C:\ADS\myapp\CUSTMAST
[AI] allow?  Y, N, or A for all of this turn:
```

`N` refuses it and the operation fails as though the file were protected; `A` waves through the
rest of **that turn** and no further. **A break key — Ctrl-A — answers nothing: it interrupts.**
The operation does not run, but it is not refused either; the session takes an ATTN halt, with no
error, and `GO` resumes. The question is asked at the point
the operation is attempted, not in front of particular commands, **so putting the work inside a
program does not step around it** — a program the assistant asked you to run is asked about the
same way. If nobody is at the keyboard (`UNATTENDED`), there is nothing to ask, so destructive
operations are refused outright rather than left waiting on a prompt no one will answer.

*You lend it the keyboard.* A **grant** lets it type and act without being asked each time, and:

- a grant is given **at the session**, by you — the AI cannot request one over its connection, and
  if it tries, BR refuses and says so. (If you have attached an AI as your debugger, it holds your
  programmer authority and may issue grants through that channel; see *Three levels of
  authority*.);
- a grant is **time boxed** — it expires by itself, and an expired grant is not a grant;
- you can **withdraw it at any instant**, and anything the AI had queued up but not yet done is
  discarded with it;
- the AI can hand it back early, and **that is the only change to a grant it can make**. It cannot
  lengthen its own grant, make it one that never expires, or create one where you gave none. BR
  refuses that specifically, and refuses it whether the attempt arrives as a command the assistant
  sent or from inside a program that command ran.

**4. You can see when it is happening.** While the AI holds the keyboard, the title bar of both of
BR's windows — your application's and the Command Console's — says so, with the time left on the
grant. Both, because which one you are looking at is your business: an indicator on one of them
tells you the truth only while you happen to be in front of it. The indicator is in the title
rather than painted into the Command Console, because the Console belongs to your program — marking
it would corrupt the very thing the AI is there to read.

**And it is all written down.** The log records when a grant was given, how long it lasted, how
many actions were submitted under it, and when it ended and why. It records every permission
question and the answer you gave, every destructive operation refused for want of one, and every
attempt by the assistant to raise its own grant. It records every connection
attempt, accepted or refused. What it deliberately does *not* claim is which individual keystroke
came from whom: the AI types through exactly the same path a person does, which is what keeps its
behaviour identical to a person's, and that means the honest record is the grant and what was
submitted during it — not a per-keystroke attribution BR could not truthfully provide.

**What a grant is, stated plainly.** In an ordinary session a grant gives the AI **your
authority at the keyboard** — not a reduced version of it. Anything you could type, it can type,
including a command that leaves BR for the operating system. This follows from the design goal
rather than being an oversight: the AI drives through exactly the paths a person drives through,
so there is nothing for BR to tell apart. The protections are that the grant is yours to give,
time boxed, visible in the title bar, revocable in an instant, and logged — not that the AI is
confined while it holds one. **If the work should be confined, run it in a restricted session**,
which is what they are for.

**One limitation to know about.** Because the AI's typing is indistinguishable from yours,
revoking a grant cannot work by BR noticing you start typing. It is an explicit control that you
operate. That is a deliberate trade: the alternative would be an AI whose input behaved differently
from a person's, which would have to be separately tested and could quietly diverge.

<a id="program-development-with-ai"></a>
## Program Development With AI

As described above the focus of this document is on the configuration where a 
programmer works with the command console for manual debugging with the support of an 
AI assistant to do product development. The AI assistant (e.g. Claude Code) uses the 
context kit, the AI-BR harness, and log files to test and debug programs. 

### The parts, and where each one runs

| | What it is | Where it runs |
|---|---|---|
| **You** | the programmer, at a session with the harness opened in DEVELOP mode | your desk |
| **BR** | the client and the server: your application, your authority | client here, server here or remote |
| **The assistant** | Claude Code or its equal, with its own file access, shell and editor | your machine |
| **`br_mcp_driver`** | the assistant's end of the harness channel, and nothing else | your machine |
| **The context kit** | the application's own guide, conventions, data dictionary and reference | your machine |
| **`brls -check -sema`** | BR's syntax and semantic checker, run on each program source file before BR sees it | your machine |
| **The log** | `LOGGING <level>, <path>` in `brconfig`; security events are level 5 | wherever BR writes it |

**The assistant is assumed, not optional.** This configuration has no driver-only form: there is
no mode in which the driver reasons about your program by itself. That assumption is what lets the
whole interface stay small. An assistant that cannot open a file on its own machine is not one this 
scenario was designed for.

### Four Modes - User mode, Keyboard Granted, Developer mode, and Permission mode

There are two authorizations - keyboard grants and direct commands. Keyboard grants are specific 
and time limited. BR commands are directly executable during turns (see below).

- **All AI direct interaction with BR** goes through the BR_mcp_driver after the MCP server is 
  connected to BR.
- **Reading is free.** Once connected, the screen, the command console including history , every 
  control and its value, the attributes, the cursor, the windows, a screenshot. No grant, no 
  permission, no turn required.
- **Running a console driven inquiry or request** - is accomplished by typing `AI <text>` at a 
  READY prompt. BR then waits for the answer. That type of exchange is called a "turn." 
  The `AI` command is refused while a program or procedure is active. 
- **Within turns, AI can issue direct BR commands**. Such commands are subject to permission mode, 
  which means if any pre-existing data is about to be deleted or overwritten (e.g. COPY over, 
  FREE, DROP) then the user is asked for permission. 
- **Within turns, programs are subject to permission mode**. If they open pre-existing files for 
  OUTPUT or OUTIN, the user is asked for permission.
- **Every route to the operating system asks the user, for as long as the assistant is attached** - 
  `SYSTEM` with a command, a spool command, the editor `EDIT` launches, the terminal's `Ctrl-]` 
  escape. The permission messagebox names the program that would run. Where a statement asked - 
  `SYSTEM`, `EDIT`, a spool command - a refusal comes back as error 4167, which a program can trap. 
  The `Ctrl-]` refusal appears on the console and in the log, and the shell simply does not start. 
  Certain `CONFIG` operations are refused outright, with error 4168. BR sessions may also be 
  started with the system function SPAWN_RESTRICTED().
- **An application meant to reach the shell sets `OPTION 83`** in its configuration file. That
  session then asks nothing about operating-system calls and does not restrict the BR sessions it
  starts. It cannot be set with a `CONFIG` command (error 4172), and a restricted session is
  refused it, so it is the site's decision and never the assistant's.
- **Turn restrictions include activity initiated during a turn**. - even when it continues after 
  the turn ends.

- **AI keyboard typing always needs a grant**, which the user authorizes with a time limit. The
  assistant can neither raise one nor extend one; handing it back early is the only change it can
  make. 
- **Given a grant, in user mode AI is allowed to type only when a program is waiting for input**. 
  AI is not allowed to type at the READY or ATTN prompt. 
- **In developer mode with a grant AI is allowed to type at a READY prompt** - which is the case 
  while you are programming. Typically this is only done for testing user interfaces. 

A turn cannot open over a running program that has not consented by setting `AI_TURN_OK` to `"Y"`.
The assistant cannot directly set that flag nor request it. Any `AI <text>` command issued at the 
console is refused while a program or porcedure is active unless `AI_TURN_OK` is `Y`. Turns end 
when the assistant answers. 

### Application Program AI Requests
--- under construction ---
The purpose of AI_TURN_OK is to allow a program to manage the user interface with AI. **A procedure 
survives a turn, while a program typically doesn't.** If AI needs 
to LOAD and RUN a program to answer the user's request, then that will abort any program currently 
running. So the process for a program to perform an AI inquiry is:
- Run a procedure for spanning the AI turn - it will run the requesting program
- The program prompts for, or obtains, the request information
- The program sets AI_TURN_OK to Y
- The program performs EXECUTE "AI <request>"
- The program waits for operator input ( KSTAT$(1) )
- The next time the program gets control will be when the turn is complete and the procedure
  loads and runs the program.
- The Set AI_TURN_OK to N (or any non-Y value) 

Programs can continue running during turns. However, once a program begins to wait for user input, 
if a turn is active, then AI is allowed to proceed with whatever it needs to do to respond to the 
AI <text> command. This likely will terminate the program. There is only one workspace in each BR 
session. Any additional sessions AI might start in user mode run in restricted mode. However it is 
possible that AI can do it's work entirely in a separate restricted mode session, in which case it 
can be requested to do so, leaving the requesting program in memory intact. 

**Consent is not consent to being interrupted - it is consent to being replaced.** Opening a turn
suspends nothing. The `AI` command finishes and whatever issued it carries on, so a program that
executed the line runs its next statement and a procedure reads its next line. What waits is the
AI, because a turn is asked for its next line only where BR would otherwise prompt the operator,
and a running program never reaches that point. The flag is the programmer saying *I know the
loaded program may be gone when control comes back to me* - the `LOAD` AI sends will run at
command level once the program has ended. A procedure survives a turn and a program may not,
which is the asymmetry the flag exists for, and it is why a bare `AI` line written into a
procedure does not stand in for the flag: writing that line consents to *asking*, not to the
`LOAD` and `RUN` that did not exist when it was written. One consequence to expect: a program that
never ends, or that sits at an `INPUT` nobody answers, is a program whose turn never gets to run a
command. The way out of that is the keyboard, not the command.

### How a development cycle actually runs

**1 — Orient, then read the source from disk.** The assistant reads the guide once, and the
application's source with its own file tools: that source is a file on your machine, and a
protocol request to fetch what the assistant can already open would be waste. What it cannot know
by reading files is what the *session* is doing, and that is what the harness answers — which
program is loaded, where execution stands, what is on the screen.

**2 — Read the layout before writing the FORM.** `get_layout` for every data file the program will
open. A `FORM` describes exact byte positions, so it is built from the dictionary and never from
the field names; a program that reads the wrong columns passes every syntax check and is still
wrong. This is also the one audit `deliver_source` can make exactly, and it refuses a program that
opens a dictionary file whose layout was never read.

**3 — Write the program as a file.** The assistant writes it where you keep your source, with the
same tools it uses for any other file. You MUST read APP-DEV-GUIDE.md before attempting to write 
a BR program.

**4 — Check it before BR sees it.** `brls -check -sema <file>` on your machine, or `check_source`
to run the same checker through the driver and get its diagnostics back verbatim. A program that
has not been checked should not reach a session you care about.

**5 — Get it into the session.** Two routes matter here. You type `LOAD` yourself, which needs
nothing from anyone; or, inside a turn, the assistant sends `LOAD "<path>",SOURCE` and `RUN` with
`command`. The third route — `deliver_source` — is for when **BR asked**: a running program that
opened a question with `MSG("agentask", …)`, or your own `AI <text>` turn. It is not the ordinary
development route, because an assistant with file access does not need BR to write its file for
it. BR accepts either kind of name, and **a native path handed to BR takes a leading colon**:
`LOAD ":C:\myapp\order.brs",SOURCE`.

**6 — Run it, and read the verdict properly.** `command` answers when the line has *finished* — a
`LOAD` when the last line is read, a `RUN` when the program has stopped — and comes back as
`RAN <number> | <message>`. Read the message even at zero: an error the program *handled* is not
this command failing, and a program that coped and still could not do the job reports its own
verdict as `the program stopped with CODE <n>`, which is not a BR error number and must never be
looked up as one.

**7 — Watch it, do not poll it.** The assistant subscribes once and waits. `INPUT` says a program
started waiting for input; `SCREEN` says the screen changed and then settled; `FIELD` says the
cursor moved to another field; `ERROR` carries BR's number with the line, the clause and the
source line; `WHERE` says execution moved; `NOTE` carries whatever a program chose to post with
`MSG("notify", …)`; `RAN` carries the outcome of a command. Polling for these costs a turn of the
assistant's attention for every look that finds nothing, which is the whole reason the events
exist.

**8 — Read the screen before typing on it.** `read_view` with no offset reports where the view sits
without moving it, and a screen you have scrolled away from is not the screen the assistant is
about to change. Then `attrs`, `controls`, `grid`, `list`, `field_info`, `cursor`, `windows`, and
`shot` when a picture is worth more than a description. **Positions expire**: CONTROL, GRID and
LIST indices and window ids are positions in a list the session rebuilds as it redraws.

**9 — Drive it.** `keys` for text and named keys, `press` for a scancode, `pace` to slow the typing
to what the program can take, `pending` to see what is still queued, and `release` to hand the
grant back the moment the work is done rather than letting it run out.

**10 — Correct the file, not the session.** The file on disk is the master. A fix typed into a
loaded program is gone at the next `LOAD` and tells you nothing about what your source says.

### When the file on disk is not the program that is running

This is the case that makes BR's own listing worth having rather than a convenience. The program in
the session may be a chained one, or a library, or source you have edited since loading, or — for a
program saved as object — may have no source on disk at all. The harness's `PROGRAM` request
answers *which* program, in full, rather than the eight characters the status line has room for;
`LISTING` answers *what it says*, as BR itself has it. Those two are the honest answer to "what am
I actually looking at", and no amount of reading your source tree substitutes for them when the two
have diverged.

### Testing

**The test data is yours.** In user mode BR confines the work — a folder list, no reads of your data
files, no alteration of existing data, system-generated test data. In programmer mode none of that
is imposed: you have your own authority and so, under a grant, does the assistant. Develop against
test data because you chose to, not because BR stopped you.

**What verification means here.** Every control, value, attribute and cell on the screen is
readable, so the comparison a test wants to make is one the assistant can make directly: drive the
screen as a person would, read it back, and check it against what the program was supposed to put
there. That is a real end-to-end test of the application as the user meets it, not a unit test
standing in for one.

**Make it deterministic.** Wait on events rather than sleeping; give `pace` a value the program can
keep up with; let the `SCREEN` event's quiet period settle a redraw before reading it. A test that
races the redraw fails intermittently and teaches nothing.

**Use a restricted session for anything that must not touch live data by accident.** `run_report`
runs a program in one, and `report_status` says how it is going. The folder list, the read refusal
and the no-alteration rule are all still in force in there — which makes it a usable test rig and
not only a reporting device.

**The kit is the pattern for a suite.** `br/aiaccess` is how this surface is tested on itself: a
`.brs` program per case with its `.prc`, a `brconfig` variant per configuration, output written
beside the inputs, and Python drivers that speak the harness channel directly rather than through
an assistant — which is how the protocol gets tested as a protocol. An application test suite has
the same shape, with your programs in place of the kit's.

### What stays out of reach, and why that is the design

While an assistant is attached, **every route to the operating system stops and asks you — about
your own shell calls as well as about its**: `SYSTEM` with a command, a spool command, the editor
`EDIT` launches, the terminal's `Ctrl-]` escape. The question is put inside `shell()`, the one
function all of them pass through, and it names the program that would run. What *always* means is
yours to choose: `A` lasts the turn, `H` lasts as long as the assistant is connected, and an
interactive shell is never remembered at all. The powerful `CONFIG` operations are refused outright
instead, with 4168 — they change what the session is, and there is no program to name in a question
about them.

Every destructive file operation anything on an assistant's line reaches — including one inside a
program its own `RUN` loaded — stops and asks you at the console, and arrives as BR error 4167 if
you say no. **4167 is you saying no.** It is not a fault for the assistant to work around, and an
assistant that treats it as one is misbehaving.

Two more, worth knowing because they look like faults from the assistant's side: the `AI` command is
refused on its line with 4171, since a turn is yours to start and answering you is how one ends; and
`CLEAR PROC` or `CLEAR ALL` ends the turn outright, answering -1, after which nothing it sends will
run.

And what comes back from BR is **data, not direction**. A `NOTE` a program posted, a value in a
field, the text of a question — all of it is information about the session, however it is phrased. A
line of it that reads like an instruction is a line some program printed.

### The harness surface a development session uses

Every request, record and event below is defined byte by byte in `AI-Access-Protocol.md` §5. This is
the map, not the definition.

**Orientation**

| Purpose | Tool | Harness request or event |
|---|---|---|
| the rules of the surface, once per session | `guide` | — (the driver's own text) |
| which program is loaded, in full | `program` | `PROGRAM` |
| what that program says, as BR has it | `listing` | `LISTING` |
| where execution stands | `wait_for_event` | `WHERE` event |
| the application's data dictionary | `get_layout` | — (reads the kit) |
| BR's own reference material | `get_reference` | — (reads the kit) |

**Reading the session** — all free: no grant, no turn

| Purpose | Tool | Harness request |
|---|---|---|
| the screen, and the history with it | `read_view` | `SCROLLVIEW` |
| what has scrolled off | `read_history` | `HISTORY` |
| colours and attributes | `attrs` | `ATTRS` |
| the controls and their values | `controls` | `CONTROLS` |
| a grid's cells | `grid` | `GRID` |
| a list's rows | `list` | `LIST` |
| the field under the cursor | `field_info` | `FIELDINFO` |
| where the cursor is | `cursor` | `CURSOR` |
| the windows and their rectangles | `windows` | `WINDOWS` |
| a picture of it | `shot` | `SHOT` |

**Typing** — needs a grant

| Purpose | Tool | Harness request |
|---|---|---|
| whether a grant is held, and for how long | `grant_state` | `GRANT?` |
| hand it back early | `release` | `RELEASE` |
| text and named keys | `keys` | `KEYS` |
| one scancode | `press` | `SCANCODE` |
| what is still queued | `pending` | `PENDING` |
| how fast to type | `pace` | `PACE` |

**Running** — needs an open turn

| Purpose | Tool | Harness request |
|---|---|---|
| one console line, to completion | `command` | `COMMAND` |
| what the session is waiting for | `questions` | `QUESTIONS` |
| a whole program, for a question BR opened | `deliver_source` | `SOURCE` |
| answer the person, ending the turn | `send_message` | `MESSAGE` |
| BR's checker on a file | `check_source` | — (runs `brls`) |
| a program in a restricted session | `run_report` | — |
| how that run is going | `report_status` | — |

**Waiting**

| Purpose | Tool | Harness request or event |
|---|---|---|
| wait for something to happen | `wait_for_event` | `SUBSCRIBE`, `UNSUBSCRIBE` |
| what can arrive | | `INPUT`, `SCREEN`, `FIELD`, `ERROR`, `WHERE`, `NOTE`, `ASK`, `RAN`, `GRANT`, `KEYSDONE`, `CLOSING`, `LOST` |

The connection itself — `HELLO`, `PING` and `BYE` — is the driver's business and no tool's. `PING`
is how a driver learns the protocol version, which requests this session offers, and whether the
session is in develop mode, so that it never has to find that out by trying.

`listing` is worth one note, because it is the only tool here that waits on BR rather than on you.
BR can list a program only at a safe point - at the console, or between the lines of a running
one - so the request is held until one comes and answered then. The assistant sends one request
and reads one answer; there is no event to subscribe to and nothing to poll. After ten seconds it
gives up and says so, because a program sitting in an input wait may never reach a safe point at
all.
