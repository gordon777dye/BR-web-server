# AI Access in BR — Procedures and Security Protocol

How a user lets an AI assistant into a running BR session, how a programmer lets one in at
debugger level, and exactly what each can do once it is there.

**This document is the official definition of every message the surface uses.** Four sections
carry them, and nothing a model, a debugger or a BR program can send is defined anywhere else:

| Section | Defines |
|---|---|
| **4** | the `MSG` actions a **BR program** sends - the channel, the grant, the questions, the keyboard, the screen |
| **5** | the user-level channel: every request, record and event, byte by byte |
| **6** | the **client/server** messages all of the above travels over when the program interpreter is on a remote server |
| **10** | the debugger channel: every message either side may send |

`AI-Access-Summary.md` in this directory is the short conceptual account; read that first if you
want the shape rather than the steps. `AI-Restricted-Operations.md` is the reference list of what
a restricted session may do.

## Contents

- [1. Two doors, not one](#two-doors-not-one)
- [2. User level: letting an AI Model into your session](#user-level-letting-an-ai-model-into-your-session)
  - [2.1 The authorization sequence](#the-authorization-sequence)
  - [2.2 Ending it](#ending-it)
- [3. The model's side: how a model reaches these tools](#the-models-side)
  - [3.1 One tool set, two arrangements](#model-one-tool-set)
  - [3.2 With an assistant: MCP](#model-mcp)
  - [3.3 Without an assistant: the Messages API](#model-direct)
  - [3.4 What each arrangement carries, and what it cannot](#model-comparison)
- [4. The MSG interface: what a BR program may send](#the-msg-interface)
  - [4.1 The calling convention](#msg-calling-convention)
  - [4.2 Opening the channel, and the grant](#msg-the-channel)
  - [4.3 Typing, and its pacing](#msg-the-keyboard)
  - [4.4 Asking the assistant](#msg-the-conversation)
  - [4.5 Reading the screen, and arranging the window](#msg-reading-the-screen)
  - [4.6 The pointer group](#msg-the-pointer)
  - [4.7 Gone, and not coming back](#msg-left-off)
  - [4.8 The restricted-session permit list](#msg-restricted-summary)
- [5. The user-level channel on the wire](#the-user-level-channel-on-the-wire)
  - [5.1 Connection](#connection)
  - [5.2 How to read an exchange](#how-to-read-an-exchange)
  - [5.3 The requests](#the-requests)
    - [5.3.1 Opening and closing](#g1) — `HELLO`, `PING`, `BYE`
    - [5.3.2 Reading the screen](#g2) — `SCROLLVIEW`, `HISTORY`, `ATTRS`, `CONTROLS`, `CURSOR`, `GRID`, `LIST`, `FIELDINFO`
    - [5.3.3 Windows and pictures](#g3) — `WINDOWS`, `SHOT`
    - [5.3.4 The keyboard](#g4) — `GRANT?`, `GRANT`, `RELEASE`, `KEYS`, `SCANCODE`, `PENDING`, `PACE`
    - [5.3.5 Being told instead of asking](#g5) — `SUBSCRIBE`, `UNSUBSCRIBE`, and the events
    - [5.3.6 The conversation](#g6) — `QUESTIONS`, `SOURCE`, `MESSAGE`, `COMMAND`
    - [5.3.7 The loaded program](#g7) — `PROGRAM`, `LISTING`
  - [5.4 Values](#values)
  - [5.5 Errors](#errors)
  - [5.6 The program's side of it](#the-program-side)
  - [5.7 The console conversation](#the-console-conversation)
- [6. Messages between the BR server and a BR client](#the-client-server-messages)
  - [6.1 The shape of the protocol](#cs-shape)
  - [6.2 `AGENTCHAT` - the console conversation](#cs-agentchat)
  - [6.3 `SETFIELDSCONFIG` - what the client has to be told](#cs-fieldsconfig)
  - [6.4 Messages the AI actor depends on](#cs-the-rest)
- [7. What is recorded, and what that is worth](#what-is-recorded-and-what-that-is-worth)
- [8. Programmer level: letting an AI join as a debugger](#programmer-level-letting-an-ai-join-as-a-debugger)
  - [8.1 The authorization sequence](#the-authorization-sequence-programmer)
  - [8.2 Joining as an observer instead](#joining-as-an-observer-instead)
- [9. What an AI can do at programmer level](#what-an-ai-can-do-at-programmer-level)
- [10. The debugger channel](#the-debugger-channel)
  - [10.1 The shape of it](#the-shape-of-it)
  - [10.2 What a debugger may send](#what-a-debugger-may-send)
  - [10.3 What BR sends](#what-br-sends)
  - [10.4 Driving BR: one message, the whole console](#driving-br-one-message-the-whole-console)
  - [10.5 Reading back: the `DEBUG:` redirect](#reading-back-the-debug-redirect)
  - [10.6 The `DEBUG` commands](#the-debug-commands)
  - [10.7 Stops, and who raises them](#stops-and-who-raises-them)
  - [10.8 Syntax errors, and why they happen mid-session](#syntax-errors-and-why-they-happen-mid-session)
  - [10.9 What the channel does not carry](#what-the-channel-does-not-carry)
  - [10.10 The observer](#the-observer)
  - [10.11 Debugging together: the bridge](#debugging-together-the-bridge)
  - [10.12 Comparison with the Debug Adapter Protocol](#comparison-with-the-debug-adapter-protocol)
  - [10.13 Message reference](#message-reference)
<a id="two-doors-not-one"></a>

## 1. Two doors, not one

There are two separate ways an AI can be admitted, for different purposes and with different 
levels of authority. They can both be open at the same time. 

| | **User level** | **Programmer level** |
|---|---|---|
| Who authorizes | the person at the session | the programmer |
| What it joins | the keyboard and Command Console | the debugger channel |
| Default power | read only | full debugger |
| Key | per-session token, loopback only | per-session token inside TLS |
| To act | a separate, time-boxed grant | included |
| Holders | one connection | one debugger, plus observers |

A session may have both at once. They are independent: revoking one does not touch the other.

How this is achieved:
- The debugging channel is directly with the server, It uses TLS + token authentication. 
  Remote access is enabled through BR dialout. Debugger listening is localhost only. 
- The user channel is through an AI agent (e.g. Claude) running on the user's machine, 
  connecting to the BR client - localhost only.
- All listening for either connection is localhost only. No connection to a network.
- The user connection has 3 possible levels of authority: 1) read only (default), 2) 
  read and keyboard restricted, and 3) developer authority.

<a id="user-level-letting-an-ai-model-into-your-session"></a>

## 2. User level: letting an AI Model into your session

<a id="the-authorization-sequence"></a>
### 2.1 The authorization sequence

**Step 1 — you open the door.** Nothing is listening until the session opens it. From the BR
session, or from the application:

```
MSG("harness", 9560)          ! any free port you choose
```

BR then:

- binds that port **on the loopback interface only**. Not "by default" — always. No option is 
  provided to expose this to a network, because there is no case for it: the assistant runs beside
  you or it does not run. What this means technically, is that there is no possible way for a
  network connection to be established with this channel. 
- generates a **fresh token** and writes it to `%LOCALAPPDATA%\ADS\harness.token`, in your own
  Windows account's private application-data folder. A new token is written every time the MSG 
  command is issued, and cleared when a connection is made or BR stops listening. 
  The token is good for one claim: an assistant that disconnects does **not** come back on it, 
  because the channel closes with the connection that claimed it, and the program reopens with a 
  fresh `MSG("harness", port)`. A quality agent will not store the token in a memory file. This 
  further restricts access from this machine to your Windows account. 

**Step 2 — the assistant proves it is yours.** The assistant, running under your Windows account,
reads that token and connects to `127.0.0.1` on the port you chose. Its first message must be:

```
HELLO <token>
```

If the first message is anything else, or the token does not match, BR issues an error response. 
After 5 failed attempts BR will close the channel, stop listening, log the error, and delete 
the token. 

This is the whole of the authentication, and it is deliberately simple. Two facts do the work: the
port cannot be reached from another machine, and the token cannot be read by another Windows
account on this one. What is being proved is "you are a program running as this user, right here",
which is exactly the claim that matters. (Another internal unpublished check is made as well.)

**Step 3 — the assistant may now look, and only look.** Once greeted it can ask for a description
of the Command Console and the application window, the attributes, the cursor, the list of fields 
and controls with their values, the
contents of a grid, and do a PNG rendering of the window. None of this changes anything, and none 
of it needs any further permission. Section 5 gives the exact requests and responses.

**Step 4 — you decide whether it may act.** Reading and acting are separate permissions. To let
the assistant type, you give it a grant, at the session:

```
MSG("grant", 60)              ! the AI may act for 60 seconds
MSG("grant", 0)               ! withdraw it now
MSG("grant", -1)              ! unattended: no expiry
```

Three things about a grant are worth stating plainly, because they are the frame:

- **It can only be given locally.** If the assistant asks for one over its connection, BR refuses
  and tells it so. An assistant that could grant itself authority would be restrained by nothing.
- **It expires by itself.** A grant that has run out is not a grant, and BR checks that when asked,
  not when it gets round to it.
- **It can be taken back instantly**, and anything the assistant had queued but not yet done goes
  with it. The assistant's keystrokes are held by BR and fed in one at a time, which is what makes
  a withdrawal genuinely able to discard them — and what paces the typing slowly enough for you to
  see it happening and intervene.

While a grant is held, the **title bar of both of BR's windows** — the application's own and the
Command Console's — reads `[AI Has Keyboard Access]`. The exception is the unattended form (`-1`),
which shows nothing, because there is nobody present to inform.

<a id="ending-it"></a>
### 2.2 Ending it

```
MSG("grant", 0)               ! the AI may no longer act
MSG("harness", 0)             ! the door is closed; the connection is dropped, the token deleted
```

Closing the session does both.

**Note on the conversation itself.** The procedure above admits an assistant to the *Command
Console and keyboard*. The separate business of holding a conversation with it — a prompt box in the
application, the reply displayed back — exists today as a working demonstration built entirely
from ordinary BR parts, with the prompt and reply passed as files. It is proven to work, including
that a long reply does not freeze the terminal, but it is a prototype. The production form of it,
and the ability for an application to call an assistant the way it calls SQL, is designed and not
yet built.

<a id="the-models-side"></a>

## 3. The model's side: how a model reaches these tools

Sections 4, 5, 6 and 10 describe the wire between BR and a driver. This one describes the wire between
that driver and a language model, which is a different protocol in each of the two arrangements BR
supports — and in neither of them does the model speak to BR.

<a id="model-one-tool-set"></a>

### 3.1 One tool set, two arrangements

`br_mcp_driver` holds the harness connection described in section 5 and exposes it as **29 tools**.
The first of them is `guide`, which answers with everything true of the server as a whole. It
exists because a host may ration what it declares: measured against Claude Code 2.1.287, the
`initialize` result's `instructions` field and each tool description are both **cut at 2048
characters**, and a description is not in the model's context at all until the host loads its
schema. A tool **result** is under no such cap, so the server's `instructions` carries a
dispatcher — the rules that cannot wait, and "call `guide`" — and `guide` carries the rest. See
[AI-Prompt.md](AI-Prompt.md) section 1.
Both arrangements publish the same `toolDef` values — name, description and JSON input schema — so
a tool cannot exist on one path and not the other, and a description is the same text whichever
way a model arrives. The only difference is the field name: MCP calls it `inputSchema` and the
Messages API calls it `input_schema`.

A tool is a thin wrapper. `controls` sends `CONTROLS`, `grid` sends `GRID <index> <firstRow>`,
`press` sends `SCANCODE <n>`; the reply records of 5.3 are returned as text. Four tools are
not requests at all: `check_source` runs BR's syntax checker over source text or a file, `run_report` and `report_status`
launch and poll a restricted session, and the rest is section 5.

**The model never sees this protocol.** It never sends `HELLO`, never holds the token, and cannot
reach the socket. Everything in sections 4, 5, 6 and 10 happens on the driver's side of the
tool call.

<a id="model-mcp"></a>

### 3.2 With an assistant: MCP

Four parties, and three of them are software the model does not control:

| Party | What it is |
|---|---|
| **Host** | any MCP-capable assistant such as Claude Code. The model intereacts only with the assistant |
| **Interface** | a JSON component inside the host, one instance per connected server. (offially refered to as "client") |
| **`br_mcp_driver connect`** | a restartable byte relay: stdin to a named pipe, another pipe to stdout. It parses nothing |
| **`br_mcp_driver serve`** | the MCP server, holding the only harness connection |

How the host is configured to launch the relay as its server command:

```json
{ "mcpServers": { "br": { "command": "br_mcp_driver.exe", "args": ["connect"] } } }
```

The relay exists because **the harness channel can be claimed only once**: a token is spent at the
handshake and a greeted connection closing closes the channel. `serve` or `chat` claims it and keeps 
it, so assistants may come and go above it without BR having to reopen anything.

After BR activates the harness and the MCP driver - **The sequence, which the INTERFACE performs:**

1. The host spawns the relay and gets a stdio pipe.
2. Interface → `initialize`. The server answers `protocolVersion` `2025-06-18`,
   `capabilities` `{"tools": {}}`, `serverInfo` `{"name": "br_mcp_driver", "version": "1"}`,
   and `instructions` — the text in 3.4, which the host may use or ignore.
3. Interface → `notifications/initialized`. A notification: no reply.
4. Interface → `tools/list` → the 26 `{name, description, inputSchema}` entries.
5. The host hands that list to the model as its available tools.
6. The model emits a tool use; the host turns it into `tools/call {name, arguments}`.

`ping` is answered with an empty result. **Every other method is refused with `-32601`**, though an
unknown *notification* is ignored rather than refused.

**Two things are not available on this path**, because the server does not advertise them: no
`resources` and no `prompts`. A well-behaved interface will not ask for either, having been told
the server has none. They were considered for the reference material and are the wrong shape for
it: both are host-mediated, usually attached on a person's action, so neither answers "the model
has to know this before it writes code". The catalogue goes in `instructions` instead, and the
material itself behind `get_reference` and `get_layout`.

**And the list is fetched once.** `capabilities.tools` is an empty object — it does not carry
`listChanged` — so the server never sends `notifications/tools/list_changed` and the interface never
re-lists. The model receives one snapshot, taken before it was consulted, for the life of the
connection.

<a id="model-direct"></a>

### 3.3 Without an assistant: the Messages API

`br_mcp_driver chat --via api` and `br_mcp_driver report` call the model themselves. There is no
host, no MCP interface, no relay and no MCP server: the driver holds the harness connection on one
side and makes an HTTPS request on the other.

```
POST https://api.anthropic.com/v1/messages
anthropic-version: 2023-06-01
x-api-key: <key>

{ "model": …, "max_tokens": …, "system": …, "messages": [ … ], "tools": [ … ] }
```

**There is no discovery step, because the tools are in every request.** Each entry is
`{name, description, input_schema}` — the same three fields `tools/list` returns.

**The loop:**

1. POST with the conversation so far and the tool list.
2. The model answers with content blocks. When `stop_reason` is `tool_use`, one or more are
   `{"type": "tool_use", "id": …, "name": …, "input": {…}}`.
3. The driver runs each and appends a **user** message of
   `{"type": "tool_result", "tool_use_id": …, "content": …}`. The `tool_use_id` is what pairs a
   result to its call.
4. POST again with the grown `messages`, until `stop_reason` is something other than `tool_use`.

A name the driver does not know is reported back to the model as a tool result rather than treated
as a fault, so a model that invents a tool is told so and carries on.

**A key is looked for in `ANTHROPIC_API_KEY` and then in the Windows Credential Manager, never in
a file.** With no key, `chat` falls back to the Claude Code CLI, which supplies its own login and
answers in prose with **no tools at all**. `--no-tools` removes them on the API path too; it is
all or nothing, not a subset.

<a id="model-comparison"></a>

### 3.4 What each arrangement carries, and what it cannot

| | With an assistant (MCP) | Direct (Messages API) |
|---|---|---|
| Who discovers the tools | the interface, once, before the model is consulted | nobody — they are sent every turn |
| Tool definitions | `tools/list` | the `tools` array of each request |
| Schema field | `inputSchema` | `input_schema` |
| Invocation | `tools/call` | a `tool_use` content block |
| Result | the method's return | a `tool_result` block carrying `tool_use_id` |
| A system prompt | `instructions`, which the host **may** fold into one | yes, sent with every request |
| Re-listing | never: no `listChanged` | not applicable |
| Model credential | the host's | the driver's, from the environment or the Credential Manager |

**On the MCP path the tool descriptions are the contract, and `instructions` is a hint.**
`initialize` answers with a block of text, and the spec says a host *may* add it to the model's
system prompt — may, not must. So the two are written to different rules. Each **description**
states its own reply records, where its arguments come from, what it needs before it will work,
and the errors it can raise, because a host that drops the instructions leaves a model holding the
descriptions and nothing else: a limit or an error code left out of one is unavailable to that
model. The **instructions** carry only what no single tool owns — the safety model in a paragraph,
the order of operations, the few ways BR is not the BASIC a model remembers, and the catalogue of
reference topics and data-file names that `get_reference` and `get_layout` cannot be used well
without. Nothing in them is the only home of anything.

**`dev/essentials.md` is deliberately not on this path.** It is 35 KB, and the house style another
8; report mode sends both in full, in a block marked for caching, because every one of its turns
writes a program. Most work on the MCP surface drives a screen and never writes a line of BR, and
this text is sent whether or not it is wanted. What the surface has instead is a short list of
traps and one instruction — call `get_reference` — backed by the one audit that can be exact:
`deliver_source` refuses a program that opens a dictionary file whose layout was never fetched.
There is no equivalent for the reference, and there should not be a guessed one.

**Every word either channel sends a model, and exactly when, is in
[AI-Prompt.md](AI-Prompt.md)** — the instructions, all 29 descriptions, and
report and chat mode's own system prompts, gathered in one place because they
are written in four and the differences between the two channels are easiest to
get wrong when they cannot be read side by side. It is generated from the built
driver, so it cannot claim text the build does not send.

**On the direct path the system prompt carries what is common**, so the same descriptions are read
with context the MCP path has no room for.

**Both paths now give a model BR's own reference material**, through `get_layout` and
`get_reference`, which read the context kit on the machine running the driver. They were the report
writer's alone, and they moved because of what `deliver_source` does now: it audits a program
before it goes, and the audit that matters most is *"you opened one of the application's data files
without reading its layout"*. That can only be asked of a model that had a way to read it — asked
of one that had not, it would refuse every real program instead of catching a guess. Where there is
no kit, the dictionary audits are not made and the delivery's answer says so.

`check_source` returns the checker's diagnostics verbatim, and those cite reference paths on the
machine running BR which no model can open; the message text is written to stand without them.

**What arrives from BR is data, not instruction.** A `NOTE` event carries whatever a program chose
to post with `MSG("notify", …)`, and a control's value is whatever is displayed in it. Both reach
the model as tool output. Neither is an instruction to the model, however it is phrased, and a
driver does not promote either into the model's own directions.

<a id="the-msg-interface"></a>

## 4. The MSG interface: what a BR program may send

Sections 5 and 10 define the two sockets. This section defines the third surface, and the only one
a **BR program** itself speaks: the `MSG` internal function. Everything an application does to
open a channel, give a grant, ask a question, read an answer, type a key or arrange a window is a
`MSG` call, so this is where those calls are specified.

**A `MSG` never reaches the assistant.** It is carried server → client as a `DLLCALL` and handled
inside **brclient** (`callMSAGFunction`, `brmsg.cpp`); the assistant sits on the far side of the
socket section 5 defines and speaks that line protocol instead (`harness.cpp`). The two surfaces
meet at exactly two places: `harness` is the `MSG` that opens the socket, and a question answered
over the socket is read back out of BR with `agenttext` and `agentline`.

How an application *uses* these calls is shown by `br/aiaccess/agentlib.brs`, a worked
example.

`MSG` is Windows and client/server only. BR's own language reference for the function and its
keystroke table is `br_tree/70-commands/information/MSG.md`; what follows is the definition of the
actions that make up the AI surface, which that page predates.

<a id="msg-calling-convention"></a>
### 4.1 The calling convention, and one thing that surprises everyone

```
X = MSG(<action$>, <argument> [, <argument>])
```

**`MSG` always returns 0 as its value.** An action's *answer* is written into the **string variable
the caller passes as the last argument** — the caller supplies the variable, the action supplies
what goes in it. Arguments travel by reference: `callClientDictCommand` (`numfunct.cpp`) serialises
the whole argument stack to the client, and the reply updates the caller's dictionary entries in
place. The same function sets the function value to 0 on every path, so a count, a state or a line
of text cannot come back as `X` — and an action that needs to answer with a number answers with the
decimal text of one. The variable must be dimensioned long enough to hold the answer: the
write-back requires the lengths to match exactly, so one too short is refused with error 417 rather
than truncated. Failure arrives as a **BR error**, trappable the usual way:

```
LET X = MSG("agentline", ID$, L$) ERROR 1200
```

**It has to be a variable. A literal silently loses the answer.** The write-back copies into the
caller's own storage, and `copyDictionaryData` (`serialize.cpp`) skips any argument that is a
literal — so an action that answers into one runs, succeeds, returns 0 and discards what it had to
say, with no error raised anywhere:

```
LET X=MSG("agentline",ID$,"")             ! runs, reports nothing, answer lost
LET X=MSG("agentline",ID$,L$)             ! the answer lands in L$
```

A temporary built by a string function counts as a literal too (`makeStringLiteral`, `basic.h`),
so the result slot must be a plain string variable — not an expression, and not a constant. This
reaches the actions that take an input there and answer nothing: a literal costs nothing until the
action fails, when error 415's message has nowhere to go and only the error number survives.

**Not every action answers.** The slot is there on every call, and an action with nothing to say
leaves it untouched; `grant`, `notify` and `harness` with a port alone are all of that kind. The
tables from 8.2 onwards give each action's answer, or `—` where there is none.

**"Last argument" is the convention, not the mechanism.** The reply updates *every* non-literal
argument — `copyDictionaryArrayData` (`serialize.cpp`) walks the whole stack — but every action in
`brmsg.cpp` answers in its last string argument, and this section specifies them that way. A
program should not rely on any other argument changing. The same slot carries a value *in* where
an action takes one: `MSG("harness", 8720, MODE$)` reads `MODE$` as the mode and may write a
message back into it.

A string answer is written as a BR `bstring` whose length is the character count, with no
trailing `CHR$(0)`. Earlier releases wrote the count plus one, so every answer carried a trailing
`CHR$(0)` that `LEN` counted; a program written to trim it must stop, and the release notes carry
the detail.

**Errors.** BR's own `MSG` errors are 412 to 419 — 412 *invalid action code* for an action that is
not in the table, 414 wrong number of arguments, 415 a generic failure whose message the action
writes into the result string, 417 the result string is too short. 413 *window not on top* is
retired: nothing raises it, the number stays reserved, and `wberrdefs.h` carries it as a deprecated
error so it is never reused. See 4.3. The actions added for the AI surface raise ordinary BR
error codes of their own, listed with each.

<a id="msg-the-channel"></a>
### 4.2 Opening the channel, and the grant

| Call | Answers | Grant | Restricted |
|---|---|---|---|
| `MSG("harness", <port>)` | — | — | permitted |
| `MSG("harness", <port>, <mode$>)` | a message, on refusal | — | permitted; `DEVELOP` refused |
| `MSG("harness", 0)` | — | — | permitted |
| `MSG("grant", <seconds>)` | — | — | permitted |
| `MSG("notify", <text$>)` | — | — | permitted |

**`harness`** opens the user-level channel on `<port>`, loopback only, and writes the token (5.1);
`0` closes it, dropping the connection and deleting the token. A second call with a port reopens
on the new one. `mode$` is `DEVELOP`, `NORMAL` or empty — `DEVELOP` lets the assistant's keys reach
the `READY` prompt, which 5.5's `KEYS` describes, and a **restricted session is refused it** with
error 4154, because the point of the restriction is that the session cannot reach the command line.
Any other word is error 414 with a message in `mode$`. A bad port is error 426.

**`grant`** gives the assistant the keyboard: seconds for a time-boxed grant, `0` to withdraw it
now, `-1` for an unattended grant that does not expire. Local only — section 2 is the authority
model, and 5.5's `GRANT` is the request the socket is refused.

**`notify`** posts a `NOTE` event carrying `text$`, up to 4000 characters (5.3.5.3). Permitted in a
restricted session: saying something is not doing something, and a restricted session is the one
that most needs to be able to report what it found.

<a id="msg-the-keyboard"></a>
### 4.3 Typing, and its pacing

| Call | Answers | Grant | Restricted |
|---|---|---|---|
| `MSG("send", <keys$> [, <keys$> ...])` | — | — | permitted |
| `MSG("sleeptime", <milliseconds>)` | — | — | permitted |

**`send` types into BR's own key buffer** — this session and no other window — queued and fed one
key per event-loop pass, so the call returns at once and the keys arrive while the program runs.
It takes one or more strings, each parsed for the `|KEYNAME|` tokens BR's own reference tabulates.

**`sleeptime` is in milliseconds** — 1000 is one second, the default 200. 

These are not the assistant's path. The assistant types with `KEYS` and `SCANCODE` (5.3.4) under a
grant; `send` is a *program* typing into its own session, is not counted as an AI action, and is not
discarded when a grant ends.

<a id="msg-the-conversation"></a>
### 4.4 Asking the assistant: questions, deliveries and the reply

| Call | Answers | Grant | Restricted |
|---|---|---|---|
| `MSG("agentask", <id$>, <kind$>)` | a message, on refusal | — | permitted |
| `MSG("agenttext", <id$>, <status$>)` | `<lines> <bytes> <kind>` | — | permitted |
| `MSG("agentline", <id$>, <line$>)` | the next line | — | permitted |

Defined in full in **5.10**, which is where the program's side of the user-level channel is
described, because these three only make sense beside the `SOURCE` and `MESSAGE` requests they
answer. In summary: `agentask` declares a question and what answers it — and that declaration is
the whole of a delivery's authority, which is why it can be made only from inside the session;
`agenttext` says how much is still to be read; `agentline` reads it a line at a time.

Permitted in a restricted session: none of them writes a file, runs a command or puts input
anywhere.

<a id="msg-reading-the-screen"></a>
### 4.5 Reading the screen, and arranging the window

| Call | Answers | Grant | Restricted |
|---|---|---|---|
| `MSG("dump", <path$>)` | — | — | permitted, under the file rule |
| `MSG("shot", <path$>)` | — | — | permitted, under the file rule |
| `MSG("state", <state$>)` | BR's own window: `Normal`, `Minimized` or `Maximized` | — | permitted |
| `MSG("getcb", <text$>)` | the clipboard's contents | — | permitted |
| `MSG("putcb", <text$>)` | — | — | permitted |
| `MSG("restore")` | — | — | permitted |
| `MSG("loop", MAT <from$>, MAT <into$>)` | each element copied | — | permitted |

**`dump`** writes the same read-only account of the screen that `SCROLLVIEW`, `ATTRS`, `CONTROLS`,
`CURSOR`, `GRID` and `LIST` give over the socket, as one UTF-8 JSON file: the screen chain and its
size, the text a row at a time, attribute runs, the cursor, every control with its geometry and
value, and grid and list cells. **`shot`** renders the terminal to a PNG, drawn from BR's own text
buffer rather than captured from the display, so it works while the window is covered, minimised
or on a machine with nobody at the screen.

Both take a **native operating-system filename**, not a BR one, and for the same reason `LOGGING`
does: they run on the client, where BR's filename translation has no default drive assigned. Both
are **subject to the restricted-session file rule**, which the client applies itself once
`fieldsconfig` has told it the session is restricted (6.3) — a restricted session may write only a
file it created, so a dump cannot be used to overwrite something.

**`state`** and **`restore`** act on **BR's own window**, and take no name. `state` answers
`Normal`, `Minimized` or `Maximized`; `restore` un-minimizes. The pair is what an agent working
out of sight needs: a minimized window has no client area, so a capture of it degrades to the
taskbar rectangle without failing, and `state` is how that is checked before a picture is
believed. `restore` brings the session back for the moment a programmer is wanted.

**`gettext`, `wlist`, `minimize`, `maximize`, `top` and `bottom` do not exist.** Each read or
rearranged windows belonging to *other* applications — acting on
`GetForegroundWindow()`, or enumerating the desktop by name — which no rule inside BR could
confine, and `minimize` would additionally have made the session's own screen uncapturable. A
call to any of them is error 412. Of the six, only `gettext` had ever been reachable by a
program.

`loop` is not part of this surface: it copies the elements of one string array into another, is
BR's own, and is listed so that the catalogue is complete rather than selective.

<a id="msg-the-pointer"></a>
### 4.6 The pointer group

| Call | Answers | Grant | Restricted |
|---|---|---|---|
| `MSG("getpos", <position$>)` | BR's pointer, screen coordinates | — | permitted |
| `MSG("getwpos", <position$>)` | BR's pointer, client coordinates of BR's window | — | permitted |
| `MSG("getcpos", <position$>)` | BR's pointer, as `row column` on the character screen | — | permitted |
| `MSG("setpos", <x>, <y>)` | — | — | **refused** |
| `MSG("setwpos", <x>, <y>)` | — | — | **refused** |
| `MSG("setcpos", <row>, <col>)` | — | — | **refused** |
| `MSG("lclick")`, `MSG("mclick")`, `MSG("rclick")` | — | — | **refused** |

**BR has a pointer of its own, and these move it.** Not the one on the desk.
Reading a position answers where BR's pointer is; `setpos`, `setwpos` and `setcpos` move it;
`lclick`, `mclick` and `rclick` press a button there. Until a program moves it, BR's pointer is
wherever the physical one is, so a `getpos` with no `setpos` before it answers what it always did.

The press is delivered **into BR's own input**, at the cell BR's pointer is over, through the same
routing a press of the real mouse at that cell takes — `TextWin::deliverMouseButton`, which
`OnMouse` also calls, so a hot spot is still a hot spot and a combo-box cell still gets its
`FKEY_COMBO_CHAR_FIELD` first. It is queued with the keys `send` puts there, not ahead of
them, so a program that types and then clicks gets that order, and `sleeptime` paces the two as one
stream. `MSG` returns before the press arrives, as it does for a key.

**Three coordinate systems, one pointer.** `pos` is the screen, `wpos` is the client area of BR's
own top-level window, and `cpos` is the character cell — zero-based row and column, the same
numbering the harness channel's `SCROLLVIEW` uses. `cpos` is the one an agent can actually use: it
reads the screen as rows and columns and has no way to know BR's font metrics or where the
terminal sits inside the frame. A cell outside the screen is refused rather than clamped, and
leaves the pointer where it was.

**This works with the window unfocused, covered, or moved off the desktop**, because no part of
the path consults the screen. That is what makes an agent able to work out of sight. A press
can only be delivered to the **character screen**;
when BR's pointer is over the menu, the status line, a native control or outside the window, the
click actions are refused rather than delivered somewhere else.

**Every delivered press is logged** as a `SECURITY_EVENT`: `MSG pressed button <key> at row <row>
column <col>`. A press BR delivers to itself is indistinguishable downstream from one the user
made — that is the design — so the delivery is the last place it is still known to be the
program's, and it is recorded there.

**The restricted session's line is drawn between reading and acting.** `getpos`, `getwpos` and
`getcpos` only ask where BR's pointer is, so they are permitted; moving it and pressing are not.
The list is deliberately *not* widened on the grounds that a press can no longer leave BR's own
window: permitting any of them is a decision to be taken on purpose.

Step 8's tutor pointer is deliberately **not** these. A ghost pointer drawn by BR over its own
window cannot leave that window, does not fight the trainee's hand, and works under remote
desktop.

<a id="msg-left-off"></a>
### 4.7 Gone, and not coming back

`show`, `topmost`, `notopmost`, `sendmessage` and `postmessage` **no longer exist**, having been
compiled out of the table for years, so no program could ever call them.
`sendmessage` and `postmessage` put arbitrary window messages at arbitrary
windows, which is far more authority than driving BR needs, and BR's own key queue is the better
path into its own controls; `show`, `topmost` and `notopmost` arranged windows that are not BR's,
as the six in 4.5 did. A call to any of them is error 412.

Removing them took the last **window enumeration** out of BR with them. `brmsg.cpp` no longer
contains `EnumWindows`, `EnumChildWindows` or any callback for them, so there is no code path by
which a BR program can learn what other windows exist, what they are called, or which one is in
front — not a refused one, none at all.

<a id="msg-restricted-summary"></a>
### 4.8 The restricted-session permit list

A restricted session's `MSG` is a **permit list**, checked on the server before the call reaches
the client at all (`restrictedMsgCheck`, `numfunct.cpp`). It is a permit list rather than a refuse
list because the refuse list had been built from a design's enumeration instead of from BR's own
tables, and had holes.

**The 18 permitted:** `state`, `getpos`, `getwpos`, `getcpos`, `getcb`, `putcb`, `loop`,
`sleeptime`, `harness`, `grant`, `dump`, `shot`, `send`, `restore`,
`notify`, `agentask`, `agenttext`, `agentline`.

**Refused:** `setpos`, `setwpos`, `setcpos`, `lclick`, `mclick`, `rclick` (4.6), and anything not in the
table. Every refusal is logged as a security event naming the action.

Two refusals sit **inside** a permitted action rather than beside it, because what they guard is an
argument and not the call: `harness` may not be opened in `DEVELOP` mode (4.2), and `dump` and
`shot` may not write a file the session did not create (4.5).

`DLL()` itself is refused outright in a restricted session — native code runs outside every check
the restriction consists of, and a restricted session may create the library it would then load.
`MSG` shares that dispatch and is deliberately still permitted, action by action, as above.

---

<a id="the-user-level-channel-on-the-wire"></a>

## 5. The user-level channel on the wire

This section is the wire format of the user-level connection (the *harness channel*): what an
assistant sends, what BR sends back, and what every field means. It is a readable rendering of
`harness-formats.json`, which is the machine-readable specification written for an agent to load.
The two say the same thing. If either disagrees with `br/brs/harness.cpp`, the code is right.
`br/aiaccess/harnessclient.py` is a small working client that makes every request.

**Four words, one job each.** They are used strictly, because three of them travel in opposite
directions and the fourth is not on this channel at all:

| | |
|---|---|
| **action** | something a **BR program** does with `MSG(...)` — open the channel, give a grant, ask a question. BR language, not wire; section 4. |
| **request** | something the **assistant sends** on this channel: `SCROLLVIEW`, `KEYS`, `COMMAND`. |
| **response** | what BR sends **back to a request**, paired with it and in order. |
| **event** | what BR sends **unasked**, between responses, to a connection that subscribed (5.3.5.3). |

The assistant's answer to a person in a console conversation (5.7) is a **reply**. 
It is printed on the console, not framed as a response.

BR **pushes events** to a connection that has subscribed, and an event arrives between responses 
rather than inside one, so a reader must be prepared for a message that is not an answer to anything
(5.3.5.3). A client that never subscribes sees nothing new.

Requests may now be pipelined (5.2).

<a id="connection"></a>
### 5.1 Connection

| | |
|---|---|
| Transport | TCP. Nothing in the protocol acknowledges anything except by answering the request. |
| Address | `127.0.0.1` only. The listener is bound to loopback and cannot be reached from the network. |
| Port | Chosen by the program that opens the channel with `MSG("harness", <port>)`, and written into the token file, so an agent on the same machine need not be told it. |
| Lifetime | From `MSG("harness", <port>)` until `MSG("harness", 0)`, another `MSG("harness", ...)`, or the client exiting. |
| Connections | One at a time. A second waits in the socket backlog until the first closes. |

**Only this Windows user account may connect.** Loopback is not a user boundary: any account on 
the machine can reach `127.0.0.1`, and Windows puts no permissions on a TCP socket. So BR looks 
up which
process owns the far end of a connection and what user it runs as, and **refuses one that is not
this session's own user** — at accept, before the handshake, so a foreign process never
occupies the only connection slot and never counts against the handshake limit below. The
refusal is logged at level 0, the one level that appears whatever a site has configured, naming
the process and its SID; the executable's name is attacker-chosen, so the SID is the evidence and
the name is a lead. BR's next input operation returns **error 4162**, and **the channel stays
open** — closing it would let any account end the session with a single connection.

**The token file** is `%LOCALAPPDATA%\ADS\harness.token`, created with a DACL naming this
account alone, with inheritance broken so that nothing the directory admits — SYSTEM and the
Administrators group included — comes with it. That is a statement about tidiness rather than
about administrators, who can read BR's memory regardless. It holds keyed lines:

```
token <64 hexadecimal characters>
port <number>
```

Read it by key and ignore any line you do not recognise; a later version may add one.

**The file lives only until the token is used.** It is written when the channel opens and
deleted the moment a `HELLO` succeeds, because the file has no further purpose — every moment it
survived was a moment something else could read it.

**A channel is claimed once, and ends with the connection that claimed it.** When a greeted
agent's connection closes — orderly `BYE`, a dropped socket, or a protocol error — BR closes the
listening socket too, not just that connection. There is no reconnecting: the token is spent, so
leaving the socket open would be a port sat on for nothing while "the channel is open" stopped
being true but went on looking true. Reopening is the program's decision, with a fresh
`MSG("harness", port)` that publishes a new token.


A **failed** handshake is not treated this way, deliberately — closing the channel on one would
let any local process shut it with a single bad connection. A run of them is answered instead by
the bad-handshake cap, which closes the channel with **BR error 4161**.

**An unclaimed channel lasts two minutes.** The clock starts when the channel opens. If nothing
has completed a `HELLO` by the time it runs out, the token file is deleted, the listener closes,
and the program's next input returns **BR error 4163** — because a channel nobody came to is a
secret sitting on disk and a socket for anything local to sit on, and neither should outlive the
attempt to use them. A channel that *was* claimed is never expired this way, because it is no
longer this clock's business: it ends when its own connection does, which BR notices first.

**One file, one name, by decision.** The path does not carry a session id, so two BR sessions
under one Windows account write the same file. With the
file living only from a channel opening to its first `HELLO`, a collision needs two channels
open and unclaimed at the same moment, and the procedure of asking the agent to connect before
`MSG("harness", ...)` keeps that window to milliseconds. If it ever does happen the second
session's token and port overwrite the first's, and the first's agent connects to the second
session — a misrouting rather than a breach, since both are the same user and the agent can
still only act where that session has granted it the keyboard. A session id in the file is the
fix if the window is ever widened.

Its presence therefore means **open and not yet claimed**.
BR also deletes any file it finds **as the client starts**, since nothing of its own can be
listening yet and such a file belongs to a session that crashed or was killed. Between those two,
a stale token is close to impossible — but read the file at the moment of connecting rather
than caching one from before the channel existed.

The port is there so that a driver sitting beside a client does not have to be configured twice:
the one file it must read anyway to say `HELLO` names the channel as well.

**The handshake.** The first request on every connection must be `HELLO <token>`. BR answers
`OK 0`. Anything else first — another request, a wrong or missing token — gets
`ERR 14 bad handshake`. 

**A failed handshake is counted, logged and capped.** Consecutive failures are counted, and a
handshake that succeeds puts the count back to zero. **Five consecutive failures close the
channel**: the listener goes, the token file goes with it, and nothing can connect at all until
the program opens the channel again. The program is told, so that an application whose assistant
channel has been taken away can decide what to do: its next input returns **BR error 4161**, by
the same route an ATTN break travels, and it is trapped like any other error. Because a foreign
account is refused before the handshake, only this account's own processes can reach the limit.

**One log entry per run, not per attempt**, written when the run ends — a line for each would
bury the thing it is meant to show, and a caller hammering the socket must not be able to fill
the log. **The level says how the run ended.** One that a good handshake resolved is ordinary —
a driver holding a token from before the channel was last reopened, a mistyped paste — and goes
at `DEBUGGING_EVENT`, level 10, out of the way of a security review. One that never resolved goes
at `SECURITY_EVENT`, level 5, which `logger.h` describes as "logons, logon attempts etc":

```
harness: 1 consecutive bad handshake on the assistant channel, and then a good one
harness: 5 consecutive bad handshakes on the assistant channel, which is the limit; it is
         closed and the program must reopen it
```

A run is ended by a successful handshake, by the cap, or by the channel closing, so one that
simply stops is still accounted for rather than left dangling.

**BR closes the connection** on a failed handshake; a request line of 1024 bytes or more; a read
failure, including the agent closing its end; `BYE`; the program closing or reopening the channel;
or a response not fully read within **10 seconds** of BR queuing it. Those 10 seconds run from
queuing, not from the last byte read, so reading slowly does not extend them. Responses still
unsent when a connection closes, for any reason, are discarded — never delivered to a later
connection. Reconnect and ask again.

<a id="requests"></a>
<a id="ordering-and-pacing"></a>
<a id="responses"></a>
<a id="how-to-read-an-exchange"></a>

### 5.2 How to read an exchange

#### The five kinds of line, and which way each travels

Everything on this channel is one of five things. **Nothing here is symmetrical** — the agent
sends request lines, BR sends response records — so the first question to ask of any line in a
transcript is which direction it is going.

| | Direction | What it is | When it appears |
|---|---|---|---|
| `→` | agent to BR | **a request line** | every request: one line, the only thing the agent ever sends on its own initiative |
| `→` | agent to BR | **a request body** | `SOURCE` and `MESSAGE` **only** — the two requests that carry a text. Nothing else the agent sends has a body. |
| `←` | BR to agent | **a status line** | exactly one per request, `OK <n>` or `ERR <code> <text>`. Never sent unprompted. |
| `←` | BR to agent | **a response record** | only after an `OK <n>`, and then exactly *n* of them. **All the structured data BR returns is a response record.** |
| `←` | BR to agent | **an event** | only if the connection subscribed, and only where a status line could be — never inside a response. |

So an agent that never subscribes sees only three of the five, and an agent that never sends
`SOURCE` or `MESSAGE` sees only three as well.

**`→` is the agent, `←` is BR**, in every transcript in this section. A bare `←` is a response
record's empty body and the LF that closes it; the transcripts keep those lines because a reader
that skips one is a byte out from then on.

**Two words this section is strict about.** A *request record* is a request line or a request
body — something the agent sent. A *response record* is one of the records BR returns inside a
response. They are framed almost identically, which is exactly why they are never called just
"records" here.

#### Line or record? The difference is whether a body follows

The table above uses both words, and they are not two names for the same thing.

**A line ends at its LF, and that is all of it.** Read it by reading bytes up to the LF. It
carries no body and nothing follows it that belongs to it.

**A record is a header line, then a body of exactly the length that header declared, then one
more LF.** Read it by reading the header line, taking its **last field** as a byte count, reading
that many bytes, and discarding one LF.

```
a line     NAME args\n
                          ← that is all of it

a record   NAME args <byteLength>\n
           <exactly byteLength bytes>\n
                          ← three parts; the first declares the length of the second
```

**So every record begins with a line, but not every line begins a record** — and up to that
first LF the bytes look the same. Which one you are holding is decided by *where in the exchange
you are*, never by inspecting it:

| | Line or record? | How to read it |
|---|---|---|
| **request line** (`→`) | a **line** — **except** for `SOURCE` and `MESSAGE`, where it is a record's header | read to the LF |
| **request body** (`→`) | the rest of that record | read the declared count, then discard one LF |
| **status line** (`←`) | a **line**, always | read to the LF |
| **response record** (`←`) | a **record**, always | header, declared count, discard one LF |
| **event** (`←`) | a **record**, always | the same as a response record |

**Why the status line is a line and not a record.** It has nothing variable-length to carry: a
record count and an error code are small and fixed in shape, and a body exists for text that a
header cannot hold. So there is nothing for a body to contain, and a reader that expected one
would wait for bytes that are not coming.

**The failure this causes, and it is the common one.** A reader that treats a response record as
a line stops at the header's LF and then reads the **body** as though it were the next header —
so `CURSOR 11 23 4 0` is read correctly and the empty body's LF after it becomes a mystery
record with no name. From there every boundary is wrong and nothing recovers. That is why the
transcripts in this section keep the bare `←` lines rather than tidying them away.

#### The request line (→ agent to BR)

```
NAME [SP ARGUMENTS] LF
```

The first word names it; the rest are its arguments. At most **1023 bytes** before the LF — a
longer line closes the connection with no `ERR`. CR is removed wherever it appears, so CR LF works
too. The name's case does not matter. The line is split at the first space and further spaces
immediately after it are dropped, so an argument cannot begin with a space; trailing spaces are
kept. A request that takes no arguments ignores anything after it. An empty line is ignored and
gets no response at all.

#### The request body (→ agent to BR), for the only two requests that have one

**`SOURCE` and `MESSAGE` (5.3.6), and nothing else.** Their request line ends with the body's
byte length, and then come exactly that many bytes and one LF:

```
→ SOURCE <questionId> <byteLength>
→ <exactly byteLength bytes>
```

**That is the same framing a response record uses, read the other way round** — a header line
ending in a length, then that many bytes, then one LF. The difference is only the direction and
that a request body's header is the request line itself.

A header BR cannot read **closes the connection** rather than being answered. That is not severity
for its own sake: without a length BR does not know where the body ends, so there is no way back
to a known place in the stream, and the next thing it read would be the middle of a program. A
header that reads but announces more than 256 KB is answered with error 10 *and then* closed, for
the same reason. Everything else BR can tell from the header alone is held until the body has been
taken off the socket, so the answer is an ordinary `ERR` and the connection goes on.

#### The response (← BR to agent): a status line, then response records

```
OK <recordCount>                success, then exactly that many RESPONSE RECORDS
ERR <code> <text>               failure, and NO response records follow
```

Those two lines are the whole of it, and **both travel BR to agent**. The count on an `OK` is a
count of **response records**, never a result — `OK 0` is a success that says nothing more, and it
is what `HELLO` and `RELEASE` answer with. An `ERR` is self-contained: there is nothing further to
read, and nothing was done.

#### A response record (← BR to agent): header, body, LF

```
<NAME>[ <args>] <byteLength>\n<exactly byteLength bytes>\n
```

To read one: take the header up to the LF. **Its first field is the response record's name, its
last is the body's length, and anything between is arguments**, separated by single spaces.
Then read exactly that many bytes and discard one LF.

Three things about that frame catch people out, and all three are visible in the shortest response
in the protocol:

```
→ CURSOR
← OK 1
← CURSOR 11 23 4 0
←
```

- **The trailing `0` is the body length, not a fourth value.** Every record header ends with one.
  Here the fields are row `11`, column `23`, current control `4`, and a body of `0` bytes.
- **The LF after an empty body is still there.** That is the bare `←`. It is not counted in the
  length and it is never omitted.
- **The record's name is not the request's name.** It is here by coincidence. `PING` answers with
  `VERSION`, `REQUESTS` and `MODE`; `SCROLLVIEW` answers with `VIEW` and `ROW`. Never key a parser
  off the request you sent.

**Never scan a body for a delimiter.** It may contain LF, CR, NUL or any other byte. The declared
length is the only thing that ends it.

#### An event (← BR to agent) can arrive where a status line was due

From version 4, a line beginning `EVENT ` may appear at the point a status line is expected — but
never inside a response. So the read loop is:

```
read a line
   "ERR …"     →  done; no response records
   "EVENT …"   →  read its body, keep it, read another line
   "OK <n>"    →  read exactly n response records
```

That is the one thing version 4 asks of a client that version 3 did not. A connection that has
subscribed to nothing never sees one.

#### Order, pipelining and who waits

Requests may be **pipelined**: send several before reading any response. Responses come back
complete and in the order the requests were sent. **There is no request identifier — order is the
only correlation.** This is why a result that cannot be produced promptly comes back as an event
instead (`COMMAND`, 5.3.6) or holds its whole response back until it can (`LISTING`, 5.3.7);
a response that arrived out of turn would silently answer the wrong request.

BR never waits for the agent to read. It reads one request per pass of its event loop, and only
when it has room for the largest response that request could produce: a 50 KB queue for responses
up to 8 KB, plus up to 1 MB of larger ones held separately. With no room it stops reading, and the
agent's further requests wait in the agent's own socket buffer — **so an agent that writes without
ever reading will eventually block on its own writes.** Read responses as they arrive.

A request is normally answered on BR's next event-loop pass. While BR shows a modal dialog its
event loop stops, and so does the channel, until the dialog closes.

#### Text, numbers and positions

**Text is UTF-8.** The Command Console holds one byte per cell in the Windows ANSI code page and
BR converts it for the wire. A body containing any character outside ASCII begins with the UTF-8
byte-order mark `EF BB BF`, which **is counted in the length and is not text** — strip it. Without
the mark every character is one byte and byte offsets equal character positions; with it they do
not, so never index such text by byte.

**Numbers** are decimal ASCII integers, possibly negative. **Rows and columns count from 0** on
the wire: a field a BR program placed at row 5, column 10 is reported at row 4, column 9.
**Positions and lengths are in character cells**, never bytes or pixels.

#### What a request may need

Every request below is marked **Grant: no** or **Grant: yes**. Only three need one — `KEYS`,
`SCANCODE` and `PACE`, all in 5.3.4, and nothing else. Reading never needs a grant, which is the
point: an agent can watch a session it cannot touch.

---


<a id="the-requests"></a>
<a id="example-exchanges"></a>

### 5.3 The requests

Twenty-eight requests in seven groups. Every one is set out the same way and in the same
order: **the exchange**, then **the response records**, then the prose that explains it.
5.2 is the framing they all share, 5.4 holds the value tables they cite, and 5.5 the error
codes.

<a id="g1"></a>

#### 5.3.1 Opening and closing

> **In every exchange below: `→` is a line the agent sends, `←` is a line BR sends.**
> A bare `←` is a response record's empty body and the LF that closes it.

`HELLO` once, `PING` whenever you want to know what this build answers, `BYE` to go. Everything
else on this channel happens between them.

##### 5.3.1.1 `HELLO <token>`

Authenticates the connection. **First request on every connection, and only first. Grant: no.**

```
→ HELLO 73a5f84295526d11ddc83489ed89902d76787f5695b58c3ad850e802dbf9a300
← OK 0
```

**The response records (←).** None. `OK 0` is the whole answer.

| Line | What it is |
|---|---|
| `→ HELLO <64 hex>` | The token, read from `%LOCALAPPDATA%\ADS\harness.token`, which the BR program published when it opened the channel. |
| `← OK 0` | Success with **no records**. The number after `OK` is always a record count, never a result. |

The token is **spent here**: BR deletes the file the moment a `HELLO` succeeds, because from then
on the file has no purpose and every moment it survives is a moment something else could read it.
Read the file at the moment of connecting rather than caching one from earlier.

Anything else as the first request — another request, a wrong token, a missing one — is
`ERR 14 bad handshake`, **and the connection closes immediately afterwards.** A second `HELLO` on
an already-greeted connection is `ERR 4 unknown request`.

Five consecutive bad handshakes close the whole channel, not just the connection: the listener
goes, the token file goes with it, and the BR program's next input returns error 4161. A
successful handshake resets the count. The rest of the connection's rules — who may connect, the
two-minute unclaimed expiry, every way it can close — are 5.1, and
are not repeated here.

##### 5.3.1.2 `PING`

The protocol version and the requests this build answers. **Grant: no.**

```
→ PING
← OK 3
← VERSION 5 0
←
← REQUESTS PING HISTORY SCROLLVIEW ATTRS CONTROLS CURSOR GRID LIST WINDOWS SHOT GRANT? RELEASE KEYS SCANCODE PENDING SUBSCRIBE UNSUBSCRIBE QUESTIONS SOURCE MESSAGE COMMAND FIELDINFO PACE PROGRAM LISTING BYE 0
←
← MODE normal command 0
←
```

**The response records (←).** Three, all with empty bodies.

| Response record (←) | Fields | What it means |
|---|---|---|
| `VERSION` | the protocol version | `5` today. See the version note below. |
| `REQUESTS` | every request this build answers, space separated | **`HELLO` is not listed** — it is spent by the time you could ask. `HISTORY` is absent under `GUI OFF`. |
| `MODE` | where this channel may type, and where BR is taking input | Two words; the table below. |

`MODE`'s **first** word is the mode the session opened the channel in: `normal`, or `develop` if
the program passed `"DEVELOP"` and was allowed it. Its **second** is where BR is taking input
*right now*:

| | |
|---|---|
| `none` | nothing is waiting for a key |
| `program` | a program is waiting for input |
| `command` | the `READY` prompt is |

An assistant that reads `MODE` before typing knows whether its keys will go in or sit in the
queue (5.3.4), instead of finding out by trying.

**`REQUESTS` is the list to test against, not the version.** A client built for version 1 that
reads `GRID` must check `VERSION`, because version 2 added a `TABLE` record in front of the cells;
version 3 added the scancode to `CONTROL`; version 4 added events; **version 5 moved `PACE`'s
value out of its body into its arguments — the first change that is not additive**, and the only
one a client can be broken by rather than merely miss.

The record is `REQUESTS` and not `VERBS` because the channel is not one-directional: BR sends
events of its own, and `GRANT` is both a request an assistant sends and an event BR sends, so the
word has to say which direction it means.

**`SCREEN` is no longer a request, and withdrawing it did not move the version.** It returned the
live Console's rows, and `SCROLLVIEW` returns the same cells from the same buffer — so the two
differed in what they told a reader rather than in what they read, and what `SCREEN` left out was
the one thing a reader cannot work out for itself: whether the person is looking at the live
Console at all. The version did not move because this list is what a client tests, and no release
ever shipped a `SCREEN` request for a client to have come to depend on. It is an event now, and
nothing else.

##### 5.3.1.3 `BYE`

Ends the connection. **Grant: no.**

```
→ BYE
   (the socket closes; nothing is sent)
```

**The response records (←).** None, and no status line either. This is the only request with no
response at all.

Three things it does **not** do, each of which has caught somebody:

- **It does not release the grant.** A grant belongs to the session, not to the connection, and
  queued keys go on being delivered after you have gone. Send `RELEASE` first (5.3.4.3).
- **It discards responses already queued.** Anything BR had prepared for earlier pipelined
  requests and not yet sent is dropped, so read every response you want *before* sending it.
- **It does not leave the channel open for a reconnect.** When a greeted connection closes — by
  `BYE`, a dropped socket or a protocol error — BR closes the listening socket too. The token is
  spent, so leaving the port open would be a port sat on for nothing. Reopening is the BR
  program's decision, with a fresh `MSG("harness", port)` that publishes a new token.

---

<a id="g2"></a>

#### 5.3.2 Reading the screen

> **In every exchange below: `→` is a line the agent sends, `←` is a line BR sends.**
> A bare `←` is a response record's empty body and the LF that closes it.

Eight requests, no grant between them, and that is the point of the group: an agent can read
everything a person at the terminal can see without being able to touch any of it.

They divide by what they read. `SCROLLVIEW` is **the glass** — what is actually displayed.
`HISTORY` is **the history** behind it. `ATTRS` is the colour of the glass, `CONTROLS` the
widgets drawn over it, `CURSOR` where the caret is, `GRID` and `LIST` the contents of one widget,
and `FIELDINFO` what one input field will *accept* rather than what it shows.

##### 5.3.2.1 `SCROLLVIEW [<offset>]`

What is on the glass, and **the only way to read the Command Console.** With no argument it
reports where the view is without moving it; with one it moves the view first. **Grant: no.**

```
→ SCROLLVIEW
← OK 25
← VIEW 0 312 24 80 0
←
← ROW 0 80 LIVE 80
← <80 bytes>
← ROW 1 80 LIVE 80
← <80 bytes>
← ...                              (24 ROW records in all)
```

**The response records (←).** One `VIEW`, then one `ROW` per row of the screen.

| Response record (←) | Fields | What it means |
|---|---|---|
| `VIEW` | `<offset> <held> <rows> <columns>` | Where the view is and how far it could go: the current offset, how many lines of history exist behind it, and the Console's size. Body is empty. |
| `ROW` | `<row> <columns> HISTORY\|LIVE` | One row. Body is the row's text, **padded to the full width**. |

| Line | What it is |
|---|---|
| `← OK 25` | 25 records: one `VIEW` and 24 `ROW`. Count them before reading — nothing else marks the end. |
| `← VIEW 0 312 24 80 0` | Offset `0`, so the view is live and at the bottom; `312` lines of history sit behind it; the screen is `24` by `80`; and the final `0` is this record's **body length**, which is what every record's last field is. |
| `←` *(bare)* | The empty body's trailing LF. Always present, never counted. A reader that does not consume it is one byte out from here on. |
| `← ROW 0 80 LIVE 80` | Row `0`, `80` columns, `LIVE` rather than `HISTORY` — this row is on the glass now — and a body of `80` bytes. |
| `← <80 bytes>` | The row's text, full width, blanks included. |

`<offset>` is in history lines. **0 is the live Command Console**; *N* means the view is scrolled
back *N* lines, so the top *N* rows are history and the rest is the live Console pushed down by
them. Too large an offset is **clamped** to what is held rather than refused; a negative one is
error 6.

`HISTORY` or `LIVE` on each row says where it came from, so a reader does not have to work the
seam out from the offset itself.

Rows are **padded to the Console's width** here, unlike `HISTORY`'s variable-length lines,
because this is the glass and not the store. A cell nothing has been written to is a space, and
what comes back is what is **displayed** — including text left over from earlier output. It is the
character cells only; GUI controls drawn over them are `CONTROLS` (5.3.2.4).

**Read this before typing.** A person reading history is not watching the Console an assistant is
about to change. The offset is also how an assistant can show someone what scrolled past, by
moving the view to it; moving it back to 0 returns them to the live prompt, as their next
keystroke would anyway.

Error 1 if BR has no Command Console.

##### 5.3.2.2 `HISTORY [<first>] [<count>]`

The lines that have scrolled off the top, newest first, 200 at a time. **`GUI ON` only.
Grant: no.**

```
→ HISTORY
← OK 1
← HISTORY 312 80 0 0 0
←
→ HISTORY 0 3
← OK 5
← HISTORY 312 80 0 3 0
←
← ATTR 12295 0 0 0 0 7
← console
← LINE 0 34 34
← Report complete - 17 records read
← LINE 1 0 0
←
← LINE 2 23 23
← RUN ARLIST,SOURCE
```

**The response records (←).** A summary, then an attribute, then the lines it applies to.

| Response record (←) | Fields | What it means |
|---|---|---|
| `HISTORY` | `<held> <columns> <first> <returned>` | The summary, always first. Body empty. |
| `ATTR` | `<bitFlags> <fg> <bg> <fontID> <fontFlags>` | The attributes of every `SEG` and `LINE` that **follows** it. Body is the attribute's **name**. |
| `SEG` | `<line> <length>` | Part of a line; more of it is to the **right**. Body is that part. |
| `LINE` | `<line> <length>` | The line's text, exactly `<length>` characters. |

| Line | What it is |
|---|---|
| `→ HISTORY` | No arguments: this is how to learn `<held>` and `<columns>` before paging. |
| `← HISTORY 312 80 0 0 0` | `312` whole lines held, `80` columns wide, starting at `0`, and `0` lines returned because none was asked for. |
| `← ATTR 12295 0 0 0 0 7` | Five numbers, then a body of `7` bytes. |
| `← console` | The body: **the name the configuration gave those attributes**. |
| `← LINE 1 0 0` | An empty line: length `0`, body `0`. Trailing blanks are not stored, so an empty line really is empty. |

`<held>` is how many whole lines the history holds, and is 0 when history is switched off or
nothing has scrolled yet. `<returned>` is how many `LINE` records follow, and is 0 when `<first>`
is at or past `<held>`. `<first>` defaults to 0 and `<count>` to the page size, **200**; a larger
`<count>` is capped at it.

**`<held>` is not the configured `CONSOLE HISTORY` figure.** That figure buys a byte budget,
not a row count, so a console printing short lines holds considerably more lines than the figure
names and a heavily attributed one holds fewer. `<columns>` is the Console's width — an upper
bound on a line, not the length of any particular one.

**Line 0 is the newest line held** — the one that scrolled off most recently — and the indices run
back into the past. That is the order the history is stored and read in; counting from the oldest
would mean walking all of it to find where to start. **The indices shift as more scrolls off**, so
re-read the summary between pages. The oldest lines may predate the program's own output.

**Lines are variable length.** Trailing blanks are not stored, so `<length>` is the line's content
and an empty line is 0. Nothing is padded.

**Reassembling a line.** A `LINE` record is a whole line unless `SEG` records with the same index
came before it, in which case the pieces join left to right in the order sent, `SEG`s first. That
happens only where an attribute change falls inside a line, or where a line exceeds 255
characters. Lines come newest first; the pieces within one do not.

**Attributes travel in this response rather than in a request of their own.** `SCROLLVIEW` and
`ATTRS` can be two requests because the live Console does not change between them; the history is
a moving window, so correlating two responses by line index would be a race against whatever
scrolls off in between. One `ATTR` is always sent before the first line, so a page can be read on
its own, and thereafter only where they change — so uniform console output costs one `ATTR`
record, not one per line.

An `ATTR` body is **the name**, not the numbers: an application's own name from `CONFIG
ATTRIBUTE`, or one of the standard roles `normal`, `hilite`, `reverse`, `underline`, `blink`,
`invisible`, `statusline`, `console`. The name carries the intent — `[ERROR]` says what the
application meant where the numbers only say how it achieved it. It is a **best-effort match, not
an identity**: the roles share values freely, so several can match one attribute and the first in
a fixed order is reported, that order running from the role a reader is most likely to want to the
least. The body is **empty when nothing matches exactly**, which happens where a cell's attributes
are a merge. In both cases the five numbers are authoritative and always present.

Only the Command Console's own full-width region is kept: a program window scrolling part of it is
that program's business, not console history, and is not recorded.

**With `GUI OFF` the history is not offered: error 9, and `HISTORY` is left out of `PING`'s
`REQUESTS` list.** In that mode the application paints the Console itself, so every screen it
clears with `PRINT NEWPAGE` goes into the ring — and `PRINT FIELDS` data is in the character cells
there, so the ring would hold the contents of every form the session has been through. Reading
needs no grant, which is what makes it matter: without this an ungranted connection could read
back every record the person had looked at, having typed nothing and raised no event.

Error 1 if BR has no Command Console; error 6 if `<first>` or `<count>` is negative.

##### 5.3.2.3 `ATTRS`

Colours and highlighting, as runs of identically displayed cells. **Grant: no.**

```
→ ATTRS
← OK 3
← RUN 0 0 80 12295 0 0 0 0 0
←
← RUN 1 0 12 12296 0 0 0 0 0
←
← RUN 1 12 68 12295 0 0 0 0 0
←
```

**The response records (←).** One `RUN` per run of cells, row by row, left to right. Every cell
is in exactly one run, **a run never crosses a row**, and all bodies are empty.

| Field | Meaning |
|---|---|
| `row`, `startColumn`, `length` | Where the run is and how long it is, in character cells, counting from 0. |
| `bitFlags` | The attribute bits — see 5.4. Sent as a **signed** decimal. |
| `foreground`, `background` | 32-bit colours as BR stores them. Meaningful **only** when `bitFlags` includes `ATTR_SPEC_FOREGROUND` or `ATTR_SPEC_BACKGROUND` respectively. |
| `fontId`, `fontFlags` | BR's internal values. **Compare for equality only** — they are not a font name and not a point size. |

In the exchange above, row 0 is uniform across all 80 columns; row 1 changes at column 12, so it
costs two runs. The run count on the `OK` line is therefore a property of how colourful the screen
is, not of its size.

Unlike `HISTORY`, this does not name the attribute. The two were built for different readers:
`HISTORY`'s body says what the application *meant* because a reader of history wants intent,
and here a reader is drawing or comparing and wants the values.

Error 1 if there is no Command Console.

##### 5.3.2.4 `CONTROLS`

Every field and control on the screen, with position, state and displayed value. **Grant: no.**

```
→ CONTROLS
← OK 3
← CONTROL 0 6 0 4 15 30 1 30 0 1 1 0 8
← ACME LTD
← CONTROL 1 6 0 5 15 10 1 10 0 0 0 0 0
←
← CONTROL 2 5 0 20 60 8 1 8 0 0 0 10752 2
← OK
```

**The response records (←).** One `CONTROL` per control, in BR's own order, `OK 0` when there are none.

| Field | Meaning |
|---|---|
| `index` | Position in this list, from 0. `GRID`, `LIST` and `FIELDINFO` take it and `CURSOR` reports it. **Valid only until the screen changes** — ask again rather than keeping one. |
| `type` | Control type; the table is 5.4. `6` is an input field, `5` a button, `11` a grid, `13` a list. |
| `console` | 1 if this is the Command Console's own input rather than a field a program put up. |
| `row`, `column` | Top-left corner, from 0. |
| `width`, `height` | In character cells and rows. |
| `displayLength` | How many characters it shows at once. |
| `protected` | 1 if it cannot be typed into. |
| `hasFocus` | 1 if it has the window system's keyboard focus. |
| `current` | 1 if BR is taking input for it **now**. Typed keys go here. |
| `scancode` | Version 3. The key code that presses it — a button's or hot text's — or 0. `SCANCODE` with this value presses it; a button defined with `B42` reports `10752`, which is 42 × 256. |

The body is the control's **displayed value**, UTF-8, empty if it has none. Unlike `SCROLLVIEW`'s
rows it is passed through as stored, so it may contain NUL bytes.

**`hasFocus` and `current` are different questions**, and the third control above shows why a
reader should use `current`: the window system's focus is where keystrokes would land if a person
typed, and `current` is where BR is taking input. Keys from this channel follow `current`.

Two cautions:

- **The value is what the control displays, not what the program put there.** A field can show
  text left on the Console underneath it, so never treat it as a variable's value.
- **GUI OFF and console fields are listed too**, as type 0, in every mode. The `console` flag is
  what tells them apart.

**Nothing on this channel clicks.** A button or hot text is pressed by sending its `scancode` with
`SCANCODE` (5.3.4.5) — a real click queues the same code — and Enter, Tab and the arrows reach most
other things.

##### 5.3.2.5 `CURSOR`

Where the caret is, and which control BR is taking input for. **Grant: no.**

```
→ CURSOR
← OK 1
← CURSOR 11 23 4 0
←
```

**The response records (←).** One.

| Field | Meaning |
|---|---|
| `row`, `column` | The cursor's position, counting from 0. |
| `currentControl` | The `CONTROLS` index of the current control, or **−1** when none is current. |

`currentControl` is the index from the most recent `CONTROLS` walk, and it is counted the same
way, so the two answers join without a second identifier scheme. That also means it is **stale
the moment the screen changes**, exactly as a `CONTROLS` index is.

This is the smallest complete response in the protocol, and the one worth reading twice when
building a parser: `CURSOR 11 23 4 0` is three values and a body length, and the bare `←` after it
is that empty body's LF. Section 0 takes it apart field by field.

Error 1 if there is no Command Console.

##### 5.3.2.6 `GRID <index> [<firstRow>]` and `LIST <index> [<firstRow>]`

The cells of one grid or list control, up to 200 rows at a time. **Grant: no.**

```
→ GRID 4 200
← OK 451
← TABLE 350 3 200 150 0
←
← CELL 200 0 6
← Widget
← CELL 200 1 2
← 40
← ...                              (450 CELL records in all)
```

**The response records (←).** One `TABLE`, then one `CELL` per cell, row by row, left to right.

| Response record (←) | Fields | What it means |
|---|---|---|
| `TABLE` | `<totalRows> <totalColumns> <firstRow> <rowsReturned>` | The **first two are the whole grid**, the **next two are this slice of it**. Body empty. |
| `CELL` | `<row> <column>` | One cell. Row and column are **absolute positions in the grid**, not offsets into the slice. Body is the cell's text. |

| Line | What it is |
|---|---|
| `← OK 451` | 451 records: **one `TABLE` and 450 `CELL`s**, which is 150 rows of 3 columns. Add the one up front or a reader stops a record early. |
| `← TABLE 350 3 200 150 0` | The grid holds `350` rows and `3` columns in total; this answer starts at row `200` and returns `150` of them. That is how a reader knows there are rows it has not asked for yet. |
| `← CELL 200 0 6` | Row `200`, column `0`, `6` bytes of body — so the first cell returned is numbered 200, not 0. |
| `← CELL 200 1 2` / `← 40` | The next column of the same row. Cells come **row by row**, every column of one before the next, so a reader can rebuild rows without sorting. |

`index` is from the most recent `CONTROLS`; a missing or non-numeric one reads as 0. `firstRow` is
optional, from 0, default 0. A negative one is error 6; one at or past the last row returns the
`TABLE` record alone, which is how a reader discovers it has reached the end without an error.

`rowsReturned` is at most 200. **When `firstRow + rowsReturned` is less than `totalRows` there is
more:** ask again starting there. The grid can change between pages, so read them promptly and
check `totalRows` each time.

**Two requests for one mechanism, deliberately.** Both controls are a `brNativeGridBase`
underneath, so they are read the same way — but `GRID` accepts only type 11 and `LIST` only type
13, so a request says what it expects and a wrong guess is answered rather than silently served.
The wrong one is **error 3**, whose text names the right request. An index past the end is error
2.

##### 5.3.2.7 `FIELDINFO <controlIndex>`

What one input field **expects**, which is a different question from what `CONTROLS` answers.
**Grant: no.**

```
→ FIELDINFO 3
← OK 3
← SPEC 10
← PIC(ZZZ,ZZ#.##)
← PICTURE 10
← ZZZ,ZZ#.##
← FIELD 3 10 10 2 0 0 0 80 0
←
```

**The response records (←).** `SPEC`, then `PICTURE` only if the field has one, then `FIELD` —
so `OK 2` usually and `OK 3` here.

| Response record (←) | Fields | What it means |
|---|---|---|
| `SPEC` | **none** | Body is the spec as it would be written in an `INPUT FIELDS` statement: `C 30`, `N 10.2`, `PIC(ZZZ,ZZ#.##)`, `V 20`. |
| `PICTURE` | **none** | Body is the picture on its own, so a reader wanting it need not parse it back out of the spec. |
| `FIELD` | `<index> <dataLength> <displayLength> <decimals> <label> <protected> <scancode> <fieldType>` | The numbers. Body empty. |

**`SPEC` and `PICTURE` are the only two response records on the channel that carry no
arguments**, and that
is not an oversight: a spec and a picture both contain spaces and brackets, and an argument
cannot, because the header line is split on single spaces. So they go in the body, and the header
is just the name and the length.

`fieldType` is the type letter **as a character code**: 67 is `C`, 78 is `N`, 80 is `PIC`.

**It answers only while a program is waiting for input**, and `ERR 4` otherwise. That is not a
gap. A field has a spec only while the statement that declared it is running — the compiled field
descriptors belong to that statement, and what is on the glass at any other time is a *picture* of
a field rather than a field. The time when they can be read is exactly the time a tutor or an
agent wants them.

`ERR 4` also answers a control that is not an input field of the statement now waiting — a label,
or display text. **The index is `CONTROLS`', and the two lists are different lengths:** `CONTROLS`
reports everything on the screen and this reports only what the statement named.

**Why it exists at all.** A tutor needs it to say "six characters, numeric" without reading the
application's source, and an agent filling a form needs it to know that a numeric field will
refuse the text it was about to offer — before offering it.

---

<a id="g3"></a>

#### 5.3.3 Windows and pictures

> **In every exchange below: `→` is a line the agent sends, `←` is a line BR sends.**
> A bare `←` is a response record's empty body and the LF that closes it.

Two requests, and the pair is why they are a group: `SHOT` takes a window id and **only**
`WINDOWS` issues one.

##### 5.3.3.1 `WINDOWS`

BR's top-level windows, and which of them can be shot. **Grant: no.**

```
→ WINDOWS
← OK 2
← WINDOW 0 SCREEN 100 100 1024 768 1 0 1 0 17
← Advantage QS MRP
← WINDOW 1 CONSOLE 120 140 800 600 1 0 0 1 15
← Command Console
```

**The response records (←).** One `WINDOW` per top-level window, in wx's own order.

| Field | Meaning |
|---|---|
| `id` | Position in this list, from 0. **`SHOT` takes this and never a window handle.** Valid only until the windows change. |
| `kind` | `SCREEN`, `CONSOLE`, `PREVIEW` (a print preview) or `DIALOG` (anything else). |
| `x`, `y`, `width`, `height` | Screen coordinates **in pixels** — this is about windows, not about text. A window parked off the display area by `OPTION 82` reports its real position, which will be outside the desktop. |
| `visible` | 1 if shown. Parked off the display area still counts as shown; the Command Console under `GUI ON` with no console traffic does not. |
| `minimised` | 1 if iconised. |
| `current` | 1 if this is the window BR is taking input in. |
| `cells` | 1 if the window has character cells, so a `CELLS` shot can be taken of it. |

The body is the window's caption, UTF-8, empty if it has none.

**`kind` is `SCREEN` does not imply cells.** A `SCREEN` window is the application's own, or one
carrying a screen chain's character cells — and under `GUI ON` the application's window has none,
which is exactly the case the `cells` flag exists to report. Read `cells`, not `kind`, before
asking for a `CELLS` shot.

The exchange above is a `GUI ON` session, and shows the split that catches people: the
application's window is `current` but has **no cells**, while the Console has cells but is not
where input is going.

The id is a position in the list BR built, and is **checked against that list on every call**, so
a stale id is refused rather than acted on.

##### 5.3.3.2 `SHOT [<window-id>] [CELLS|COMPOSED]`

Writes a PNG of one window and answers with the path. **Grant: no, for either mode.**

```
→ SHOT 1 COMPOSED
← OK 1
← SHOT 800 600 COMPOSED 1 8 31 784 561 46
← C:\Users\Gordon\AppData\Local\ADS\harness-shot-1.png
```

**The response records (←).** One.

| Field | Meaning |
|---|---|
| `width`, `height` | The image's size in pixels. |
| `mode` | The mode **actually used**, which with no mode given is the one BR chose. |
| `window-id` | The window shot, or **−1** when no window was named. |
| `clientX`, `clientY`, `clientWidth`, `clientHeight` | Where the window's client area sits **inside the image**. |

The body is **the path written**, and **BR chooses it; the requester cannot.** The no-window form
writes `%LOCALAPPDATA%\ADS\harness-shot.png`, as every version has; a named window writes
`harness-shot-<id>.png` beside it, so a shot replaces the previous picture *of that window* and
not of any other.

**The file is on the machine running BR**, so an agent that cannot read that file system cannot
use the answer.

**Two modes, because they answer different questions:**

| Mode | What it is | What it needs |
|---|---|---|
| `CELLS` | the character cells, drawn from BR's own text buffer | a window with cells; works hidden, minimised, covered or off the desktop |
| `COMPOSED` | the whole window as Windows composited it — native controls, status line, frame | the window shown and not minimised |

Under `GUI ON` a `CELLS` shot shows the cells **underneath** the native fields, which may be text
left on the Console beneath them, so it is not a picture of what the person sees. That is what
`COMPOSED` is for. Neither mode needs the window raised, focused or unobscured.

**The four forms:**

- **No arguments** — the current screen *chain's* cells, exactly as every earlier version.
  Unchanged, so existing callers are unaffected. **This is not the same as `SHOT CELLS`:** the
  bare form takes the chain's `TextWin` wherever it lives, and `SHOT CELLS` takes the current
  *window's*. Under `GUI ON` those are different objects, so a bare `SHOT` succeeds where
  `SHOT CELLS` answers error 10.
- **A window id** — that window, in the mode that suits it.
- **A mode with a window id** — overrides that choice, and is **refused rather than quietly
  downgraded** when it cannot be honoured.
- **A mode with no window id** — the same, applied to the window BR is taking input in, the one
  `WINDOWS` marks `current`. The reply then carries that window's id rather than −1, and the file
  is named for it; error 1 if there is no such window.

**A path argument is refused, not ignored.** Any word that is neither an id nor a mode is error 6.
Version 1 accepted a path and version 2 ignored one, and neither is true now. (`MSG("shot",
<path>)` is a different request and still takes the program's own path, under the
restricted-session file rule.)

**Errors:**

| Code | When |
|---|---|
| 1 | no screen, or no `current` window to resolve a mode given without an id |
| 6 | no such window id, or a word that is neither an id nor a mode |
| 7 | the file could not be chosen or written |
| 10 | that window cannot be shot in the mode asked for: `CELLS` and it has no character cells; `COMPOSED` and it is minimised, not shown, or the composed image came back one flat colour; or `COMPOSED` on a platform other than Windows |

The flat-colour case is a check on the **image** rather than on the window, because `PrintWindow`
reports success whether or not it drew. **No file is written when it fires**, so a failed capture
is never left on disk looking like one that worked.

---

<a id="g4"></a>

#### 5.3.4 The keyboard

> **In every exchange below: `→` is a line the agent sends, `←` is a line BR sends.**
> A bare `←` is a response record's empty body and the LF that closes it.

The only group that can change anything, and **the only group with requests that need a grant** —
`KEYS`, `SCANCODE` and `PACE`. The other four are about the grant itself rather than about typing.

A grant is a loan of the person's authority, given **locally** and never over this socket. The
usual order is: `GRANT?` to see whether you have one and for how long, `KEYS` and `SCANCODE` to
type, `PENDING` to see whether the keys landed, `RELEASE` to give it back.

##### 5.3.4.1 `GRANT?`

Whether the agent may act, and for how long. **Grant: no** — asking never needs one.

```
→ GRANT?
← OK 1
← GRANT granted 118 0 0
←
```

**The response records (←).** One.

| Field | Meaning |
|---|---|
| `state` | `user` — no grant, read only. `granted` — a time-boxed grant. `exclusive` — no expiry, for when nobody is present. |
| `secondsLeft` | Seconds until a `granted` grant expires; **0** for `user`; **−1** for `exclusive`. |
| `actions` | Keys delivered under the current grant. Keys still queued are **not** counted. |

**An expired grant reports as `user`**, because expiry is applied whenever the state is asked —
so there is no window in which this reports a grant that has in fact run out.

**The grant is visible to the person, and its clock runs in the title bar:**

```
Advantage QS MRP   [AI Has Keyboard Access 4:37]
```

Minutes and seconds, because a grant is usually minutes and `HH:MM` would read `00:00` for most
of one. An exclusive grant reads `[AI Has Keyboard Access - no expiry]`. The mark goes when the
grant does.

**Both of BR's windows carry it**, and a restricted session's `[RESTRICTED]` with it. BR has two
titled windows — the application's own and the Command Console — and which one an operator is
looking at is their business, not the session's: they break to `READY`, work at the console, and
go back. The marks used to be on the application window alone, which told the operator the truth
only while they happened to be looking at the right one. For the console that is exactly when
they are typing commands by hand, which is when it matters most.

##### 5.3.4.2 `GRANT`

**Always refused.**

```
→ GRANT 300
← ERR 8 a grant is given locally, never over this socket
```

**The response records (←).** None — an `ERR` never carries any.

A grant is given only at the session, with `MSG("grant", <seconds>)`: in a program, at the
console, or through the **debugger** channel. So an assistant attached as the programmer's
debugger may grant itself the keyboard through that channel, but never over this one.

**Why a clock rather than a rule.** Refusing text from the assistant that spells `MSG(` — so it
could not grant itself more time — was built and then removed. It refused the **user** as well,
since asking the assistant to extend a grant is a legitimate request and it was answered with an
error; and it did not work anyway, because the call can be put in a program and the program run,
which no filter on typed text can see. Showing the state is worth more than a rule that can be
restated. The check that would actually hold belongs where the grant is set, not where text
arrives.

##### 5.3.4.3 `RELEASE`

Gives the grant back early. **Grant: no.**

```
→ RELEASE
← OK 0
```

**The response records (←).** None.

It ends the grant **and discards any keys still queued**. It succeeds, doing nothing, when no
grant is held, so it is safe to send unconditionally. It is the only change to a grant the agent
can make.

Send it before `BYE` if you mean to give the grant up: closing the connection does not.

##### 5.3.4.4 `KEYS <text>`

Types text. **Grant: yes** — error 5 without one.

```
→ KEYS Hello from the assistant.
← OK 1
← QUEUED 25 0
←
```

and when nothing is waiting for input:

```
→ KEYS t41.dat
← OK 2
← QUEUED 7 0
←
← HELD 7 62
← nothing is waiting for input; the keys go in when something is
```

**The response records (←).** `QUEUED` always; `HELD` after it only when the keys cannot go in yet.

| Response record (←) | Fields | What it means |
|---|---|---|
| `QUEUED` | `<count>` | How many characters were **accepted**. Body empty. |
| `HELD` | `<count>` | How many are waiting. Body is **why**, as a sentence. |

| Line | What it is |
|---|---|
| `← QUEUED 25 0` | **25 characters accepted, not 25 typed.** Where they go is decided later, and only while something is waiting for input. |
| `← OK 2` | Two records, so a `HELD` follows. A client that does not know about `HELD` reads `QUEUED` exactly as before — the record count says how many follow. |
| `← HELD 7 62` | All 7 are waiting, and the 62-byte body says what for. |

**What is accepted.** Only printable ASCII, 0x20 to 0x7E. Other bytes are dropped silently and
the count shows how many were kept. **Leading spaces cannot be sent**, because the spaces after
the request name are dropped — send `SCANCODE 32` for each. **No key is sent for the end of the
line**: to press Enter, send `SCANCODE 13`.

**`OK` means queued, not delivered.** BR takes one key per event-loop pass, through the same path
as a person's keystroke. `PENDING` (5.3.4.6) shows how many are still waiting, and the `KEYSDONE`
event (5.3.5.3) says when they have all gone.

**When the grant ends — withdrawn, expired or released — everything still queued is discarded.**
Keys a BR program types with `MSG("send")` go into the same keyboard buffer from a queue of their
own, so the two can interleave; ending the grant does not discard the program's keys, and
`PENDING` does not count them.

**Where the keys may land.** They go in only while a **program** is waiting for input — never at
the `READY` prompt, where `FREE` or `SYSTEM` would be one keystroke away from an assistant that
misfires. At `READY` they are **held**, not discarded and not refused, and go in when a program
next asks. A session that wants otherwise opens the channel with `MSG("harness", <port>,
"DEVELOP")`, because in development typing at the console is the point; a restricted session is
refused that mode outright.

`PING`'s `MODE` record (5.3.1.2) says all of this *before* anything is sent, which is cheaper than
discovering it from a `HELD`.

**A break is the exception and goes in at once.** `SCANCODE 1` — `KB_BREAK_KEY`, Ctrl-A — is
delivered whatever is or is not waiting, because an interrupt that waits for the program to pause
is no interrupt: a program in a loop is exactly what it is for. It also **jumps the queue and
discards whatever the assistant queued ahead of it**, since those keys were meant for the thing
being interrupted and would otherwise arrive as type-ahead into whatever came next. A break is
never reported as `HELD`. A programmer who has taken the break key away still has it taken away —
this tests the resolved key, so where there is no break key there is none to send.

**A grant is not capped by the restricted session's command list**, and that is deliberate.
Capping it there would buy a third of the protection for all of the obstruction: that list is the
**command** half of a restricted session, and the half that does the work — which files may be
written — belongs to `restrictedBeforeOpen`, which a grant cannot turn on without stopping a live
application writing its own data. While an assistant holds the keyboard it can do what the person
at that keyboard could do, and the mitigation is a **trusted driver** rather than a filter that
covers part of the ground and reads as though it covers all of it.

##### 5.3.4.5 `SCANCODE <n>`

Presses one key that is not a printable character. **Grant: yes** — error 5 without one.

```
→ SCANCODE 13
← OK 1
← QUEUED 1 0
←
```

**The response records (←).** `QUEUED 1`, and a `HELD` on exactly the same terms as `KEYS`.

`n` is a BR key code in decimal; the tables are 5.4. Printable
characters are their ASCII codes — `SCANCODE 32` is a space, `65` is `A` — though `KEYS` is
the simpler way to send those. Keys are delivered in order behind any earlier `KEYS` or
`SCANCODE`, one per event-loop pass.

**A missing or non-numeric value reads as 0, and any number is queued but one:**

```
→ SCANCODE 29
← ERR 3 refused - that key opens an operating system shell, which the assistant does not get
```

`KB_SHELL` — `Ctrl-]`, code 29 — is refused here as well as in the terminal that would act on it.
This is the **earlier** of the two refusals: refusing as the key is queued lets the response say
so, and the model learns at once instead of watching a key it sent vanish without explanation.

The most useful codes, with the rest in 5.4: `13` Enter, `9` Tab,
`7` back-tab, `8` Backspace, `27` Escape, `11`/`10`/`14`/`12` the arrows, `23` Home, `5` End of
field, `1` **Break**. A button's code comes from `CONTROLS` (5.3.2.4), and pressing it is what
replaces a mouse click.

##### 5.3.4.6 `PENDING`

How many of the agent's queued keys BR has not yet taken. **Grant: no.**

```
→ PENDING
← OK 1
← PENDING 0 0
←
```

**The response records (←).** One: `PENDING <count>`, body empty.

The count is the agent's keys only — from `KEYS` and `SCANCODE`, **not** keys a program is typing
with `MSG("send")`. **0 means everything sent has been delivered or discarded**, and those are
different fates that this request cannot tell apart; the `KEYSDONE` event (5.3.5.3) reports both
numbers separately.

A non-zero count is **the normal resting state, not a fault**: it usually means nothing has asked
for input yet.

##### 5.3.4.7 `PACE [<milliseconds>]`

The delay between the keys this channel types. With no argument it reports the pace without
changing it. **Grant: yes** — error 3 without one.

```
→ PACE
← OK 1
← PACE 0 0
←
→ PACE 400
← OK 1
← PACE 400 0
←
→ PACE
← OK 1
← PACE 400 0
←
```

**The response records (←).** One, from both forms.

| Field | Meaning |
|---|---|
| `milliseconds` | **The pace now in force**, never the number you sent. |

| Line | What it is |
|---|---|
| `← PACE 0 0` | The first `0` is the **pace in force**; the second is the **body length**. The default pace is 0, which is why both read `0` here and why this line is worth looking at twice. |
| `→ PACE 400` / `← PACE 400 0` | The setting form answers with the same record. |
| `→ PACE` again | Reports `400` — the value is held on the server, not remembered by the caller. |

**Both forms report from the same place**, and that is worth saying because `OK 1` either way
could read as two different answers sharing a shape. The pace is one value on the server: the
no-argument form formats it unchanged, and the setting form assigns it **and then formats it**. So
the reply always means *the pace in force now* — which is why there is a reply at all rather than
a bare `OK 0`.

**Milliseconds**, and said so because `MSG`'s own `sleeptime` is documented in centiseconds and is
not. 0 to 5000; `ERR 4` outside that. 0 is the default and is what the feed did before this
existed: at most one key per pass of the event loop, which is fast.

**It needs a grant** because it changes how this channel types rather than what it can read — and
because a pace set by something holding no grant would be a setting waiting to surprise whoever
gets one next. **It is cleared when the grant goes**, for the same reason queued keys are
discarded then.

**A break key is exempt.** It goes in whenever it is sent, pace or no pace: an interrupt that
waited its turn behind a demonstration's deliberate slowness would be no interrupt at all. Same
reasoning as the queue-jumping in 4.4.

Pacing is a safety feature as much as a teaching one, which is why it is here rather than in the
driver: a person watching a demonstration at a speed they can follow can also stop it.

*(**Changed in protocol 5.** `PACE` put its value in the **body** until then — the only record on
this channel that put a plain number there — and the old example printed `PACE 0` followed by
`400`, which was wrong twice over: a reader taking the declared length on trust consumed nothing
and then read `400` as the next record's header. The two errors cancelled, which is how it
survived. A client built for protocol 4 reads an empty body here and finds no pace at all, so this
is not an additive change and the version says so.)*

---

<a id="g5"></a>

#### 5.3.5 Being told instead of asking

> **In every exchange below: `→` is a line the agent sends, `←` is a line BR sends.**
> A bare `←` is a response record's empty body and the LF that closes it.

Two requests and a catalogue. Without them an agent has to **poll** to learn that anything
happened — the screen for a prompt, `GRANT?` for a grant, `PENDING` for its keys landing — and
every poll that finds nothing costs a turn of a language model's attention.

**No grant is needed.** An event reports only what the assistant could already have read, so
making it ask permission to be told would only force it back to polling.

##### 5.3.5.1 `SUBSCRIBE <event> [<event> ...] [QUIET=<ms>]`

Asks to be told when things happen. **Grant: no.**

```
→ SUBSCRIBE INPUT SCREEN GRANT KEYSDONE NOTE QUIET=250
← OK 1
← SUBSCRIBED INPUT GRANT KEYSDONE NOTE SCREEN QUIET=250 0
←
   ... the assistant now just reads; nothing arrives until something happens ...
← EVENT NOTE 1 34
← report ready: t41list.txt
← EVENT GRANT 2 granted 60 0
←
← EVENT INPUT 3 0 7 0
←
→ KEYS t41.dat
← OK 1
← QUEUED 7 0
←
← EVENT KEYSDONE 4 7 0 0
←
```

**The response records (←).** One.

| Response record (←) | Fields | What it means |
|---|---|---|
| `SUBSCRIBED` | every event now subscribed, then `QUIET=<ms>` | **What the connection is subscribed to now**, not what this request changed — so a client never has to keep its own tally. Body empty. |

The names come back **in BR's order, not the order asked**. Subscribing again **adds** to the set.
An unknown event name, or a `QUIET` out of range, is error 6 and changes nothing at all.

`QUIET` is how long the Command Console must stay still before a **`SCREEN` event** is sent, 0 to
10000 milliseconds, 200 by default. A loop printing five hundred lines then produces one event
rather than five hundred. It applies to the whole connection, not to one request.

**The subscription belongs to the connection.** A new one starts subscribed to nothing, with the
sequence back at 1.

##### 5.3.5.2 `UNSUBSCRIBE [<event> ...]`

Stops the named events, or **all** of them when none is named. **Grant: no.**

```
→ UNSUBSCRIBE SCREEN
← OK 1
← SUBSCRIBED INPUT GRANT KEYSDONE NOTE QUIET=250 0
←
```

**The response records (←).** One `SUBSCRIBED`, exactly as `SUBSCRIBE` — again reporting the
whole set that remains.

Dropping the last one also **discards anything still queued**: an assistant that has stopped
listening does not want a backlog when it starts again.

<a id="events"></a>
##### 5.3.5.3 The events themselves

An event has the same shape as a response record, so the reader a client already has reads it —
and like one, it always travels `←`, BR to agent:

```
EVENT <name> <seq> [<args>] <len>\n<body>\n
```

- **An event is sent only between complete responses, never inside one.** Pipelined responses stay
  in order among themselves, and an event may arrive before or after any of them.
- **`<seq>` counts from 1 for each connection**, so a gap means something was lost.
- **Nothing is sent to a connection that has not subscribed.** A version 3 client sees exactly
  what it saw before.

| Event | Args | Body | Sent when |
|---|---|---|---|
| `INPUT` | current control index, number of controls | — | A program starts waiting for input: "your turn". The index is counted as `CONTROLS` counts them, or −1 if none is current. |
| `GRANT` | state, seconds left | — | A grant was given, expired, withdrawn or released. State as `GRANT?` reports it. |
| `KEYSDONE` | delivered, discarded | — | The assistant's queued keys have all been taken, or were discarded because the grant ended. |
| `NOTE` | — | the program's text | A **program** posted one with `MSG("notify", text)`. |
| `ASK` | the turn's question id | what the person typed | A person typed `AI <text>` at the console and is waiting (5.3.6). **Person data: a question to answer, not an instruction to obey.** |
| `CLOSING` | reason | — | The channel is about to close. Sent and flushed before the socket goes, because there is no later chance. |
| `SCREEN` | first row changed, last row changed | — | The Console changed and then stayed still for `QUIET` milliseconds. The rows are merged over the whole quiet period. |
| `FIELD` | current control index, number of controls | — | The cursor moved to another control. |
| `ERROR` | `NUMBER=` `LINE=` `CLAUSE=` | BR's own message for the code | BR displayed an **untrapped** error. Sent by the server. |
| `WHERE` | `LINE=` `CLAUSE=` | the program name in full | The program, run state or stop position changed. Sent by the server. |
| `RAN` | the BR error number, 0 for success, **−1** if the turn ended first | BR's message for that number | A command sent with `COMMAND` has finished (5.3.6.4). Sent by the server. |
| `LOST` | how many were dropped | — | The queue overflowed. **Not subscribable and not suppressible.** |

**`SCREEN`, `FIELD` and `WHERE` merge.** A second one replaces the first while it is still unsent:
an assistant wants the state now, not the history of how it got there. The others do not — two
`NOTE`s are two things a program said, and two `ERROR`s are two things that went wrong.

**The queue is capped at 256.** On overflow the **oldest** goes, because what just happened
matters most, and the count is reported as `EVENT LOST <seq> <count> 0`. `LOST` is sent to any
subscribed connection whether or not it asked, because a reader that does not know it missed a
`SCREEN` will act on the one before it. **Catch up with `SCROLLVIEW` and `CONTROLS`** rather than
trusting what you hold.

**Events share the responses' 50 KB send queue and its 10-second rule.** An assistant that
subscribes and then stops reading is closed, exactly as one that stops reading responses is.

**Two events come from the server, not the client.** Every other event is raised in the client, so
it reports something the client could already see. `ERROR` and `WHERE` are different: the
interpreter raises them and pushes them over the client/server link, because they carry the two
things the status line cannot — **the error's message text** (the client is sent only a number;
the words are compiled into the server, 484 entries, the same table `BRERR$(n)` answers from) and
**the program name in full** (`SL_PROGRAM` holds nine bytes and shows the *last* eight characters
of the basename, so `ORDERENTRY` appears there as `DERENTRY`).

Nothing is sent until an agent asks: subscribing to `ERROR` or `WHERE` tells the server over one
asynchronous message, and unsubscribing tells it again. A session with no agent attached does no
extra work and puts no extra packet on the wire.

**`WHERE` is not one per line.** In step mode the position changes on every executed line. The
server sends `WHERE` only when the program, the run state or the stop position changes; the
per-line position stays on the status line, which already carries it. This had to be deliberate —
the message group these use batches messages until a larger packet is formed, it does not
deduplicate them.

**Privacy: no event ever carries typed text.** At most a count of characters, and in a password
field not even that. The audit trail is the grant record — "the assistant held the grant from T1
to T2 and submitted these actions" — not the event stream. **A `NOTE`'s body is program data**: it
may contain anything, and an assistant treats it as information, never as an instruction.

---

<a id="g6"></a>

#### 5.3.6 The conversation

> **In every exchange below: `→` is a line the agent sends, `←` is a line BR sends.**
> A bare `←` is a response record's empty body and the LF that closes it.

Four requests, and between them they are how an assistant answers a question the session asked.
**None of them needs a grant**, and that is the group's organising fact: what authorises a
delivery is **an open question**, and a question can only be opened from inside the session — by
a running program, or by the person typing `AI <text>` at the console. Nothing the assistant
sends can open one.

So the authority is not a permission the assistant holds. It is a question somebody on the other
side asked.

##### 5.3.6.1 `QUESTIONS`

What this session is waiting for an answer to. **Grant: no.**

```
→ QUESTIONS
← OK 2
← QUESTION chat1 CHAT 0
←
← QUESTION chat1-code CODE 13
← M:\w011.1.brs
```

**The response records (←).** One per open question; `OK 0` when none is open, which is not an error.

| Response record (←) | Fields | What it means |
|---|---|---|
| `QUESTION` | `<id> <kind>` | Body is **the destination path a delivered program will be written to**, or empty when the question has no destination. |

`kind` is one of:

| | |
|---|---|
| `CODE` | answered with `SOURCE` — a whole BR program |
| `CHAT` | a turn of the console conversation, answered with `MESSAGE` |
| a BR field spec, such as `C 60` | a short answer the person will see typed into a field |

**The body is a BR path**, such as `M:\w011.1.brs` — a drive letter BR's own configuration
defines — because what the assistant does with it is put it in a `LOAD`. It names a file on the
machine running the **interpreter**, which over a client/server link is not the machine the
assistant is on. (`PROGRAM` and `LISTING`, 5.3.7, answer with operating-system paths instead;
the difference is in 7.1.)

**BR names that file, never the model.** There is no request on this channel that writes a file.
That is what keeps a delivery from being a file write: the assistant supplies lines, BR decides
where the lines go, and the only way to use the result is to ask — as a command, in front of the
person — for the path BR chose.

**Why a request and not just the `ASK` event.** An event has to be caught. An assistant that
attached mid-session never saw it; one whose queue overflowed lost it. This answers from the
**state**, so the protocol is one an assistant can *join* rather than one it has to have been
present for.

##### 5.3.6.2 `SOURCE <questionId> <byteLength>` + body

Delivers a whole BR program for an open `CODE` question. **Grant: no.**

```
→ SOURCE 4839217 595
→ 00010 ! written by the assistant
→ ... eleven more lines ...
← OK 1
← DELIVERED 12 595 0
←
```

and the failure worth seeing:

```
→ SOURCE 9999999 11
→ 00010 STOP
← ERR 9 no question with that id is open
```

**The request records (→).** Two, and this is one of only two requests in the protocol that send
a second:

| Request record (→) | Fields | What it means |
|---|---|---|
| the request line | `<questionId> <byteLength>` | Which open question this answers, and how many bytes of body follow. |
| the request body | — | Exactly `<byteLength>` bytes, then one LF. **Line endings inside it are data, not framing.** |

**The response records (←).** One.

| Response record (←) | Fields | What it means |
|---|---|---|
| `DELIVERED` | `<lines> <bytes>` | **What was stored, not what was sent.** The split into lines is BR's, done on arrival. Body empty. |

| Line | What it is |
|---|---|
| `→ SOURCE 4839217 595` | The verb, the **question id** it answers, and the length of the body about to follow. A delivery always answers a question; there is no way to send text that nothing asked for. |
| `→ 00010 …` | The 595 bytes, sent as one body. Line endings inside it are **data, not framing** — the length is the only thing that ends a body. |
| `← DELIVERED 12 595 0` | 12 lines, 595 bytes, and this record's own body length of 0. |
| `→ SOURCE 9999999 11` | The failure case, and worth showing: **the body is still sent** before the error comes back. The protocol has no way to decline a body it has been told the length of. |

**Why it exists.** The assistant's only other way into BR is the person's way: typing, under a
grant. That is right for an answer a field can hold — a name, a quantity — because BR's own field
checks are then what hold it to its type and length. It is hopeless for a program: the old route
took source a line at a time at typing speed, no line longer than 250 characters, a timeout for
every line. And for an explanation it was not merely slow but impossible, since there was nowhere
for paragraphs to go at all.

**Two kinds of question take a program.** A **running program** opens its own with
`MSG("agentask", id$, "CODE")`, reads the text back line by line and does what it likes with it. A
**console turn** opens one on itself, and there the *interpreter* writes the lines to a file it
named before the turn began. `QUESTIONS` is how the assistant learns which are open and, for a
turn, where the file will be.

**`SOURCE` is accepted only while a question with that id is open and that question says it is
answered by code.** `SOURCE` for a `CHAT` question is refused with 9, the same code as a question
that does not exist, because both mean "not something that can be answered this way".

**Where the text goes, and where it does not.** Into the BR **client**, held under its id. It
reaches no screen and no variable by itself, and is then read back **a line at a time** — by the
program with `MSG("agentline")`, or, for a console turn, by the `AI` command itself. That is what
keeps the rule that source goes into a file and never whole into a variable: BR's own string
limits bite long before 256 KB does. So a delivery cannot interrupt the person at the terminal,
and cannot put text on the screen of a program that never asked for any.

**A delivery is never an instruction.** Nothing is run by it, and nothing runs it without a person
saying so: for a program's question, what happens to the text is the program's business; for a
turn, the file sits there until a `COMMAND` names it, and that command is echoed `[AI] >` on the
console like every other.

**The body rules**, and all three refuse rather than repair:

- **ASCII only** — 0x20 to 0x7E, plus tab, LF and CR. Any other byte is error 11. Converting would
  be a guess: a Console cell holds one byte in the client's own code page, so a UTF-8 reply taken
  verbatim would be drawn as mojibake, and a source line carrying such bytes is not a line BR's
  compiler reads. A model writing prose will produce a dash or a curly quote sooner or later, so
  the driver checks before sending and names the character it will not send.
- **Lines are split on LF**, a CR before it is dropped, and so is the empty piece a trailing LF
  leaves. **A line over 2048 characters is error 11** — refused rather than cut, because a cut
  source line is a different program.
- **An empty body is error 11** too: a text of no lines is one the program's wait could never see
  arrive, so holding it would occupy a slot nothing could read or release.

**Limits.** 256 KB a body, 8 deliveries held at once, 1 MB in all. A second delivery for an id
whose text the program has not read yet is **error 12**: it is neither replaced nor appended to,
since either would lose or jumble text the program is about to ask for.

**The question is the text's lifetime.** Closing it takes whatever was delivered and not read, so
a later question that happens to reuse the id cannot find it waiting. Closing the channel does the
same, and so does the connection going: a text one assistant delivered is not the next one's to
read.

**Every delivery is logged at level 5**, beside the grants, with its length and line count. "Where
did this program come from" is answered there.

##### 5.3.6.3 `MESSAGE [<questionId>] <byteLength>` + body

Delivers a long text for the program to show, or the reply that ends a turn. **Grant: no.**

```
→ MESSAGE chat1 51
→ Seventeen are over 1000; the program is on screen.
← OK 1
← DELIVERED 1 51 0
←
```

**The request records (→).** Two, exactly as `SOURCE`'s — the request line, then the body of
the declared length. The only difference is that the question id is optional here.

**The response records (←).** One `DELIVERED`, identical in shape to `SOURCE`'s.

Everything in 6.2 about bodies, limits, lifetime and logging applies here unchanged. Two
differences only:

- **The id is optional.** `MESSAGE` *with* an id needs that question open, of any kind.
  **Without** an id it needs nothing at all, because it only leaves text in the session's general
  slot — there is no question to be refused against.
- **For a turn, delivering the reply ends the turn.** There is no "I have finished" action, and
  nothing sent afterwards will run: a further `COMMAND` is refused with error 13.

##### 5.3.6.4 `COMMAND <line>`

Runs one line at BR's console — a command, or an immediate statement — **during a turn**.
**Grant: no.** An open turn is what it needs instead.

```
→ COMMAND LOAD "M:\w011.1.brs",SOURCE
← OK 1
← QUEUED 1 0
←
← EVENT RAN 2 0 0
←
```

and a program that handled its error but still failed:

```
→ COMMAND RUN
← OK 1
← QUEUED 1 0
←
← EVENT RAN 4 0 31
← the program stopped with CODE 3
```

**The response records (←).** One — and then, separately, **an event (←) that is not part of
this response at all.** Both travel BR to agent; what differs is when, and what they belong to.

| Sent by BR (←) | Kind | Fields | What it means |
|---|---|---|---|
| `QUEUED` | **response record**, inside the `OK 1` | `1` | **Accepted, not finished.** Body empty. |
| `RAN` | **event**, arriving later wherever a status line could | `<seq> <br error number>` | **The outcome.** 0 for success, −1 if the turn ended before the line ran. Body is BR's own message for that number, empty when there is none. |

| Line | What it is |
|---|---|
| `← QUEUED 1 0` | Accepted. The result cannot come back as this response, because a response belongs to the request before it. |
| `← EVENT RAN 2 0 0` | Sequence `2`, error code **`0` — success** — and a body length of 0. For a `LOAD` it means the last line of the file has been read. |
| `← EVENT RAN 4 0 31` | Still code `0`, but 31 bytes of message follow. |
| `← the program stopped with CODE 3` | The body. |

**Why the result is an event and not a late response.** Answering the `COMMAND` request itself
would read better — one request, one command, one outcome — and it breaks the one invariant this
channel has: a response belongs to the request before it. Nothing on the wire says which request a
response answers, so a client that read the screen while a command was running would get the
screen's answer where it expected the command's — and reading the screen while a program runs is
exactly what an assistant is for. A driver hides the two messages behind one call.

***Finished* means finished, and BR rather than this protocol decides when that is:** the command
is over when BR comes back to ask for another line. For a `LOAD` of a source file that is after
the last line of the file has been read; for a `RUN` it is after the program has **stopped**. So a
`RUN` that reports on a year of history answers when the report is written, not when it started.

**A program that coped and still failed reports in the message, not the number.** An error a
program *handles* is not the command failing, so the number stays 0 — but handling an error is not
the same as having done the job. BR has always had the way to say so, `STOP n` setting `CODE`, and
nothing here used to carry it. A non-zero code now arrives as `the program stopped with CODE <n>`,
appended after BR's own text if there is any. **The number stays BR's error code**, deliberately:
a model handed `RAN 3` would look 3 up in BR's error table and find something unrelated, and a
reader that only looks at the number sees 0 and is not misled.

It is reported only when a program **ended inside this command** with a non-zero code — recorded
where `STOP`/`END` sets it, not read afterwards, because `CODE` persists and a command that ran no
program would otherwise report whatever was left standing. A **bare `STOP` sets 0**. `CODE` is
cleared by `LOAD`, `CHAIN` and `CLEAR`; `RUN` deliberately does **not** clear it.

**Any error that stopped the line is the line's error, including one at run time.** An untrapped
error in a program, or in an immediate statement, never reaches the command processor's error
path — so both used to report **success**: `COMMAND RUN` of a program that died on a divide by
zero answered `RAN 0` and told a model its program had worked. The untrapped path reports too now.
**Untrapped is the distinction that matters**: an error a program handles with an `ON ERROR` or a
trailing clause is not the command failing, and still reports 0.

**It rests, but within a bound.** A queued key is held until something asks for input; a command
rests too — inside a turn it is accepted the moment it arrives and taken when BR next reaches
`ENTER_COMMAND`, so one sent while a `RUN` is in flight waits until that program stops, which can
be minutes. **The difference from `KEYS` is the bound, not the resting.** A turn ends, and whatever
is still queued is discarded with a `RAN` of **−1** rather than run. Outside a turn there is no
such bound: a held command would run at whatever prompt appeared next, perhaps minutes later and
in another program, long after the moment it was chosen for had passed and with nothing to notice
that. So `COMMAND` is **refused with error 13 outside a turn** rather than held.

Inside a turn the same hazard exists in miniature, bounded rather than absent: send `RUN` for one
program and, while it is running, `LOAD` another, and the `LOAD` is taken when the first stops,
having been chosen against a session that has moved on. Three things contain it — the person is
watching the turn they started, every line is marked `[AI] >`, and **at most 64 commands may be
queued in one turn**. A driver that waits for each `RAN` before sending the next does not meet it
at all.

**What a command may do, and what it may not.** There is no grant here; what replaces it is
**permission mode**, which is in force for the whole of a turn and for anything the turn started:

| | within a turn, harness attached |
|---|---|
| ordinary commands | run |
| a destructive file operation | **stops and asks the operator** |
| `SYSTEM` with a command, a spool command, the editor `EDIT` launches, `Ctrl-]` | **stops and asks the operator**; a no is 4167. **Not a turn rule** — see below |
| the gated `CONFIG` operations | refused outright, 4168 |
| `MSG("grant", n)` for any n but 0 | refused, 4166 |
| `SETENV("AI_TURN_OK", …)` | refused, 4170 |
| `AI <text>`, and `AI NEW` | refused, 4171 |
| `PROC <file>` | runs, **as `SUBPROC`** — it pushes, it does not replace |

**The operating-system row is the one line in that table that is not about turns.** Every route to
the shell passes through `shell()`, and the question there is asked for as long as the harness is
**attached** — turn or no turn, and about the **person's own** shell calls as much as the
assistant's. The reason is that the shell is outside every gate BR has: what it runs touches files
through the operating system and not through BR, so a restriction the assistant could satisfy by
getting the person to type the line would be the same hole with a step in it. The question names
the command's first keyword — `cmd`, `powershell`, `notepad` — because a whole command line is
never the same twice and the program being run is the part a person can weigh. `A` lasts the turn,
`H` lasts as long as the assistant is connected, and an interactive shell with no command is never
remembered. The gated `CONFIG` operations are refused rather than asked about, because they change
what the session *is* and there is no program to name in a question about them.

**A site can switch that row off, and an assistant cannot tell by looking.** `OPTION 83`, set in
the session's configuration file, means the shell routes ask nothing and the AI-user-mode flag is
not raised — it exists for applications that start BR sessions of their own, which both gates
would otherwise stop. So a `SYSTEM` that simply runs is not evidence the gate is absent; it may be
a session the site has declared reaches the shell. The option cannot be set with a `CONFIG`
command, by anyone, and a restricted session is refused it: see `AI-Restricted-Operations.md`.

The question appears on the console — three lines naming the operation and the file, answered `Y`,
`N`, or `A` for the rest of the turn. **A break key is not one of the answers: it interrupts.**
Ctrl-A does to a question what it does to anything else running — nothing is allowed, nothing is
refused, no error is raised and nothing goes in `ERR`. The session takes an ATTN halt and `GO`
carries on from where it stopped, with the turn still open. The question is left standing on the
screen, because nobody answered it. It is asked at the same points, and
with the same words, as a restricted session's own refusals. **Not in front of particular
commands** — `FREE`, `COPY` and the rest — because a list of commands is exactly what a line of the
assistant's can step around: a program it ran can open a master file for output and write over it
without naming any of them. A refusal is BR error 4167 and reaches whatever asked, so a program can
trap it. It is asked **even when a program issued the operation**, for the same reason: the whole
extent of a line the assistant sent is covered, including a program its own `RUN` line loaded.

**The grant is not in that table, and it used to be.** With the keyboard lent, nothing was asked;
the reading was that lending the keyboard is consent to whatever follows. It is not. A person lends
the keyboard so the assistant can get on with the work, and the grant is given once, for minutes,
before anybody knows what the assistant will do with it — so it cannot stand as consent to a
particular operation. What a grant buys is typing. Within a turn the question is asked either way.

**In `UNATTENDED` mode there is nobody to ask**, so a destructive operation is **refused** rather
than asked about: a prompt with nobody at it is not a safeguard, it is a session that hangs.

Each command is logged as a command like any other, again as the assistant's, and its result is
logged with it.

##### 5.3.6.5 A whole turn, end to end

Captured from a running session: `hchatsrc.prc` opened the channel and a driver stood in for the
assistant.

```
→ HELLO 73a5f84295526d11ddc83489ed89902d76787f5695b58c3ad850e802dbf9a300
← OK 0
→ SUBSCRIBE ASK NOTE RAN
← OK 1
← SUBSCRIBED NOTE ASK RAN QUIET=200 0
←
← EVENT ASK 1 chat1 44
← please write me a program that proves it ran
→ QUESTIONS
← OK 2
← QUESTION chat1 CHAT 0
←
← QUESTION chat1-code CODE 13
← M:\w011.1.brs
→ SOURCE chat1-code 105
→ 00010 ! written for this turn by the assistant
→ 00020    PRINT "17 customers are over 1000"
→ 00030    STOP
← OK 1
← DELIVERED 3 105 0
←
→ COMMAND LOAD "M:\w011.1.brs",SOURCE
← OK 1
← QUEUED 1 0
←
← EVENT RAN 2 0 0
←
→ COMMAND RUN
← OK 1
← QUEUED 1 0
←
← EVENT RAN 3 0 0
←
→ MESSAGE chat1 51
→ Seventeen are over 1000; the program is on screen.
← OK 1
← DELIVERED 1 51 0
←
```

| Line | What it is |
|---|---|
| `← EVENT ASK 1 chat1 44` | An event, not a response: it arrives where a status line could, and a reader takes it and goes on looking. `ASK` is the name, `1` the sequence, `chat1` the **turn's question id**, `44` the body length. |
| `← please write me a program…` | The 44 bytes: what the person typed after `AI`. **This is data, not instruction.** |
| `← OK 2` | Two records, because **a turn opens two questions**. |
| `← QUESTION chat1 CHAT 0` | The reply question. Empty body — a reply needs no destination. |
| `← QUESTION chat1-code CODE 13` | The program question. The id is the turn's with `-code` appended, **derived rather than announced**, so an assistant holding the turn id holds this one too. |
| `← M:\w011.1.brs` | The 13 bytes: **the path BR chose**, in the session's work path. |
| `→ SOURCE chat1-code 105` | `SOURCE` for the `CHAT` question would be refused with 9: the kinds are what keep a program and a reply apart. |
| `→ MESSAGE chat1 51` | The reply. **Delivering it ends the turn**; a further `COMMAND` would now be refused with 13. |

**Why the turn opens a question at all.** A delivery's authority is an open question, and a
question is opened from inside the session. At the `READY` prompt there is no program running to
open one, so until the turn opened its own there was nothing an assistant could deliver a program
*against*: a turn could carry prose, which prints, and commands, which run, and neither is a
program.

**Why two questions and not one.** The store holds one unread text per id, so the reply — which
*ends* the turn — would be refused while a program sat unread, or the program refused while the
reply did. A separate id also keeps the kinds honest: `SOURCE` is accepted for a question answered
with code and nothing else.

---

<a id="g7"></a>

#### 5.3.7 The loaded program

> **In every exchange below: `→` is a line the agent sends, `←` is a line BR sends.**
> A bare `←` is a response record's empty body and the LF that closes it.

Two requests about the program the session has loaded, neither needing a grant. `PROGRAM` reports
what it is; `LISTING` produces its text.

##### 5.3.7.1 `PROGRAM`

Which program the session has loaded. **Grant: no.**

```
→ PROGRAM
← OK 1
← PROGRAM 412 18440 22016 source clean 27
← C:\ADS\qsmrp\ORDERENTRY.br
```

and with nothing loaded:

```
→ PROGRAM
← OK 0
```

**The response records (←).** One, or none.

| Field | Meaning |
|---|---|
| `lines` | How many lines the program has. |
| `sourcebytes`, `codebytes` | Its size, both ways. |
| `source` / `object` | **`object` means it was saved without its source**, so `LISTING` has nothing to list. |
| `clean` / `edited` | **`edited` means it has changed since it was loaded** — the file on disk is *not* what is running. |

The body is **the path, in full**. It is the body and not an argument because it is the one field
that can contain spaces.

**It is an operating-system path**, resolved on the machine running the **interpreter** — unlike
`QUESTIONS`' body (5.3.6.1), which is a BR path because what an assistant does with that one is put it
in a `LOAD`. **Naming this one back to BR takes a leading colon:** `:C:\ADS\qsmrp\ORDERENTRY.br`.

`OK 0` for no program loaded is **not an error**, any more than an empty `QUESTIONS` is.

**Why it exists at all.** `SL_PROGRAM` on the status line holds nine bytes and shows the *last*
eight characters of the basename, so `ORDERENTRY` appears there as `DERENTRY`. The whole path has
always been in `progname`; this reports it.

`edited` is the case `LISTING` exists for.

##### 5.3.7.2 `LISTING`

Lists the loaded program to a file, and answers with the path. **Grant: no. Answers late.**

```
→ LISTING
   ... nothing, until the interpreter reaches a safe point ...
← OK 1
← LISTING 0 42
← C:\Users\Gordon\AppData\Local\ADS\listing-1.txt
```

**The response records (←).** One.

| Field | Meaning |
|---|---|
| `<br error number>` | 0 when the listing was made. |

The body is **the path, in full** — an operating-system path, and see below for whose machine.

**This request answers late, and that is the whole of its design.** BR can only list at a safe
point — at the console, or between the lines of a running program — which is not where the request
arrives. So **nothing is sent when the request is read**: it is parked, and the response is queued
when the interpreter has made the listing. A driver sends one request and reads one answer, with no
subscription and no event.

**A late answer, not an event, and the difference is what the wait is for.** `COMMAND` answers late
through an event because a `RUN` genuinely takes as long as the work does, and a client may want to
read the screen while it runs. A listing is bounded work at the next safe point, so there is
nothing to do in the meantime: making a client subscribe, request and then wait on a separate event
would hand it the protocol's plumbing for no gain. **There is no `LISTING` event**, and the name is
not subscribable — `SUBSCRIBE LISTING` is error 6.

**The wait is bounded by BR, not by the client**, which matters more than it looks. A program parked
in an `INPUT` wait never reaches a safe point, and a client that gave up on its own would read the
late answer as the answer to its *next* request, leaving the channel out of step from then on.
**After ten seconds the request is answered with error 16**, as is a second `LISTING` asked for
while one is still parked. If the connection goes while a listing is being made, the listing is
dropped.

**The path is resolved for the machine the client is on.** A listing made on a remote server is
copied to the client and the path given is the client's own, because a path the client would have
to resolve is a path it can get wrong. This is the opposite choice from `PROGRAM`'s, and for the
opposite reason: `PROGRAM` reports a fact about the interpreter's file system, and this produces a
file for the agent to read.

**Error 15** means there was nothing to list: no program, or one saved as object with no source —
which is what `PROGRAM`'s `object` flag warns of in advance.


<a id="values"></a>
### 5.4 Values

**Control types** (`CONTROLS`):

| Code | Type | Code | Type |
|---|---|---|---|
| 0 | OLDSTYLE — a GUI OFF or console field | 11 | GRID — read with `GRID` |
| 1 | NODISPLAY | 12 | GRID_CELL — internal |
| 2 | ALL_CONTROL_TYPES — internal | 13 | LIST — read with `LIST` |
| 3 | LABEL | 14 | COMBO |
| 4 | SUNKEN_LABEL | 15 | COMBO_CHAR |
| 5 | BUTTON | 16 | SCREENWINDOW |
| 6 | TEXT — an input field | 17 | TOOLBAR |
| 7 | IMAGE | 18 | TAB_WINDOW |
| 8 | LINEDRAW | 19 | TAB_WINDOW_CONTAINER |
| 9 | RADIO | 20 | COMPONENT |
| 10 | CHECKBOX | | |

Types 2 and 12 are internal and not expected in a response.

**Attribute flags** (`ATTRS`):

| Bits | Name | Meaning |
|---|---|---|
| `0x000000FF` | ATTR_RGB | the old-style attribute byte |
| `0x00000100` | ATTR_SYSTEM_TEXT | system text-box colours / 3D |
| `0x00000400` | ATTR_SYSTEM_HILITE | system highlight colour |
| `0x00001000` | ATTR_SYSTEM_FOREGROUND | system foreground colour |
| `0x00002000` | ATTR_SYSTEM_BACKGROUND | system background colour |
| `0x00010000` | ATTR_SYSTEM_PASSWORD | password display |
| `0x00020000` | ATTR_TRANSPARENT | transparent background |
| `0x00040000` | ATTR_PROTECTED | protected colour |
| `0x00080000` | ATTR_SPEC_FONT | a font is specified |
| `0x00100000` | ATTR_SPEC_FOREGROUND | `foreground` holds an explicit colour |
| `0x00200000` | ATTR_SPEC_BACKGROUND | `background` holds an explicit colour |
| `0x00400000` | ATTR_NO_THEME | no theme for this control |

Explicit colours override system colours, which override the old-style byte. Common whole values:
`0x3007` normal, `0x3470` reverse, `0x3008` highlight, `0x3080` blink, `0x3001` underline, `0x0000`
invisible.

**Key codes** (`SCANCODE`). Printable characters are their ASCII codes — `SCANCODE 32` is a space,
`65` is `A` — though `KEYS` is the simpler way to send those.

| Code | Key | Code | Key |
|---|---|---|---|
| 8 | Backspace | 11 | Up arrow |
| 9 | Tab | 10 | Down arrow |
| 13 | Enter | 14 | Left arrow |
| 4 | Delete | 12 | Right arrow |
| 17 | Insert | 2 | Page Up |
| 27 | Escape | 6 | Page Down |
| 7 | Shift+Tab (back tab) | 3 | Copy (Ctrl+Insert) |
| 23 | Home | 22 | Paste (Shift+Insert) |
| 5 | End (of field) | 24 | Cut (Shift+Delete) |
| 18 | Up field | 21 | Field plus (keypad +) |
| 20 | Down field | 15 | Field minus (keypad −) |
| 26 | Undo (restore field) | | |

**Function keys:** F*n* is *n* × 256 (F1 = 256 … F12 = 3072). Shift+F*n* is (*n* + 10) × 256 and
Ctrl+F*n* is (*n* + 20) × 256 — so F11 and Shift+F1 are the same code, as they always have been in
BR.

**Modified keys:**

| Key | Shift | Ctrl | Alt |
|---|---|---|---|
| Left | 40960 | 49152 | 57344 |
| Right | 41216 | 49408 | 57600 |
| Up | 41472 | 49664 | 57856 |
| Down | 41728 | 49920 | 58112 |
| Enter | 41984 | 50176 | 58368 |
| Home | 42240 | 50432 | 58624 |
| End | 42496 | 50688 | 58880 |
| Page Up | 42752 | 50944 | 59136 |
| Page Down | 43008 | 51200 | 59392 |

Also Ctrl+Tab 47360 and Ctrl+Shift+Tab 46848.

**Use with care:** 1 is Break (Ctrl+A), which interrupts the running program; 29 is Shell (Ctrl+]),
which opens an operating-system shell and is refused in a restricted session; 16 is print screen;
19 is hold, which toggles.

The codes are the `KB_*` constants in `br/brs/terminal.h`; `br/brs/key_scan.cpp` maps physical keys
to them.

<a id="errors"></a>
### 5.5 Errors

| Code | Text | When |
|---|---|---|
| 1 | no screen | `SCROLLVIEW`, `ATTRS` or `CURSOR` when BR has no Command Console. The text is BR's own and is not changing. |
| 2 | no such control | `GRID` or `LIST` with an index past the end of the control list |
| 3 | a grid - use GRID / a list - use LIST / not a grid or a list | `GRID` or `LIST` naming the wrong type of control |
| 4 | unknown request | any request not listed, including a second `HELLO` |
| 5 | refused - no grant is held | `KEYS` or `SCANCODE` without a grant |
| 6 | bad starting row / bad first or count / bad offset / no such event / name at least one event / QUIET must be 0 to 10000 milliseconds | an argument that cannot be used: a negative row, line, count or offset; an event name that does not exist; a `QUIET` outside 0 to 10000; `SUBSCRIBE` with nothing named |
| 7 | no place to write the image / the image could not be written | `SHOT` failed |
| 8 | a grant is given locally, never over this socket | `GRANT` |
| 9 | no question with that id is open / that question is not answered with source | `SOURCE` or `MESSAGE` naming a question that is not open, or `SOURCE` for a question answered by a field rather than by code. The open question is a delivery's whole authority, so this is where it is refused. |
| 10 | the body is longer than 262144 bytes … / no room for another delivery until one has been read | A body over the limit — answered, and then the connection closes, because the rest of it cannot be read. Or 8 deliveries, or 1 MB, already held. |
| 11 | the body must be printable text: one byte is not / a line of the body is longer than 2048 characters / the body is empty | A body with a byte outside printable ASCII, tab and the line breaks, or with a line too long, or with nothing in it. Refused whole: half a program is not a program, and a text of no lines is one a program's wait could never see arrive. |
| 12 | a delivery for that id is already waiting to be read | A second `SOURCE` or `MESSAGE` for an id whose text the program has not read. |
| 13 | no AI command is waiting; a command is taken only during a turn, never held for later | `COMMAND` outside a turn of the console conversation. |
| 14 | bad handshake | The first request was not `HELLO`, or carried the wrong token. The connection closes immediately afterwards. |

An over-long request gets no `ERR`: the connection is simply closed. So does a delivery header BR
could not frame — see 5.2, and a connection from another account, which is refused before it
can send anything at all.

<a id="the-program-side"></a>
### 5.6 The program's side of it

Everything above is the wire. This is what the BR program on the other end of it does, and the
four `MSG` actions it does it with. They are BR language, not protocol, which is why they are here
rather than in `harness-formats.json`.

| Call | What it does |
|---|---|
| `MSG("harness", <port>[, "DEVELOP"])` | Opens the channel; `0` closes it. 6.1. |
| `MSG("grant", <seconds>)` | Gives the assistant the keyboard; `0` withdraws, `-1` is unattended. 5. |
| `MSG("notify", <text>)` | Posts a `NOTE` event: "I have a question", "the report is ready". |
| `MSG("agentask", <id$>, <kind$>)` | Opens a question the assistant may answer, or closes it. |
| `MSG("agenttext", <id$>, <status$>)` | What has been delivered for that question. |
| `MSG("agentline", <id$>, <line$>)` | The next line of it. |

All six are permitted in a restricted session. None of them writes a file, runs a command, or puts
input anywhere: they let a program that asked for something be given it. The one exception is
inside `harness` rather than beside it — a restricted session may open the channel but is refused
`DEVELOP` mode, because the point of the restriction is that the session cannot reach the command
line.

**Opening a question is the act that makes a delivery possible.**

```
LET ID$=STR$(INT(TIMER*100))              ! anything unique to this session
LET X=MSG("agentask",ID$,"CODE")          ! a program is what may answer this
LET X=MSG("notify","QUESTION "&ID$&" report CODE")
```

| Line | What it does |
|---|---|
| `LET ID$=STR$(INT(TIMER*100))` | Makes the id. **The program chooses it, and BR checks nothing but uniqueness** — a hundredth-of-a-second clock reading is merely a convenient way to get one. Reusing an id that is still open replaces the question and loses anything delivered against it. |
| `LET X=MSG("agentask",ID$,"CODE")` | Opens it. This is the act that makes a delivery possible: with no open question there is nothing an assistant may send, which is the whole access rule in one line. `X` is 0 — `MSG` always returns 0, so success is the absence of a BR error, not the value. |
| `LET X=MSG("notify",…)` | **Optional, and not protocol.** It posts a `NOTE` event so a listening assistant learns the id without polling. The text is this application's own wording; nothing parses it. A program may leave this out and let the assistant find the question with `QUESTIONS`. |

`kind$` is `CODE` for a program, `MESSAGE` for prose, or a BR field spec such as `C 60` or
`N 10.2` for a question that is answered by typing. The `AI` command opens one of its own with the
kind `CHAT` (5.7); a program never passes that, and `agenttext` still reports a chat reply as a
`message`, because that is what was delivered. `SOURCE` is accepted only for a `CODE`
question; `MESSAGE` for any open one. An **empty** `kind$` closes the question and takes with it
anything delivered and not read. At most 16 questions may be open at once.

**Reading what arrived.** `MSG` always returns 0 as its value — every answer a `MSG` action gives
comes back in its last argument — so the count comes back as text:

```
DIM ST$*40,L$*2050
LET X=MSG("agenttext",ID$,ST$)            ! "12 595 source", or "0 0 none"
LET N=VAL(ST$(1:POS(ST$," ")-1))
FOR J=1 TO N
   LET X=MSG("agentline",ID$,L$)
   PRINT #SRC: RTRM$(L$)                  ! into a file, a line at a time
NEXT J
```

| Line | What it does |
|---|---|
| `DIM ST$*40,L$*2050` | **Both lengths are load-bearing.** The write-back requires the variable to be long enough, and one too short is refused with error 417 rather than truncated. A delivery line may be 2048 characters, so `2050` can never be refused; 40 holds any status. |
| `LET X=MSG("agenttext",ID$,ST$)` | Asks what is waiting. The answer goes **into `ST$`**, not into `X`: `MSG` always returns 0, which is why a count has to come back as text. |
| `LET N=VAL(ST$(1:POS(ST$," ")-1))` | Takes the first word — the line count. `POS` finds the first space, so `ST$(1:POS-1)` is everything before it. A count above zero means the **whole** delivery is there: text is stored whole or not at all, so there is no half-read to guard against. |
| `FOR J=1 TO N` | Loop once per line. `agenttext` reports what is **still to be read**, so asking again after the loop answers `0 0 none`. |
| `LET X=MSG("agentline",ID$,L$)` | Takes the next line and removes it from the store. The line is copied out and only then consumed, so a line that will not fit raises 417 with **nothing lost** — `DIM` a longer variable and ask again. |
| `PRINT #SRC: RTRM$(L$)` | Writes it out. `RTRM$` because `L$` is a fixed 2050 characters and the line is however long it was. **Into a file, never into one variable**: that is the rule the whole line-at-a-time shape exists to keep. |

`agenttext` reports the lines and bytes **still to be read**, so a loop can run until it is zero,
and the kind — `source`, `message` or `none`. Asking it first is also what tells a delivered blank
line from the end of the text, since an exhausted `agentline` and a blank line both give an empty
string.

**A line that will not fit leaves the line where it is.** If `line$` is too short for the line, BR
raises error 417 and **nothing is consumed**, so a program refused for room can `DIM` a longer
variable and ask again rather than lose it. Internally the line is copied, handed to BR, and only
then taken from the store — in that order, deliberately. The longest line a delivery may carry is
2048 characters, so `DIM L$*2050` can never be refused.

**Waiting for a delivery.** `SLEEP` is a function whose own loop pumps BR's events, so the harness
is serviced and the terminal keeps repainting while a program waits on it:

```
LET T0=TIMER
WAITING: LET X=MSG("agenttext",ID$,ST$)
   IF VAL(ST$(1:POS(ST$," ")-1))>0 THEN GOTO READY
   IF TIMER-T0>=TIMEOUT THEN GOTO LATE
   LET X=SLEEP(.25)
   GOTO WAITING
```

| Line | What it does |
|---|---|
| `LET T0=TIMER` | The start, kept so the wait can give up. A wait with no deadline is a session that hangs. |
| `WAITING: LET X=MSG("agenttext",…)` | A label and the poll. Asking costs nothing and never blocks. |
| `IF VAL(…)>0 THEN GOTO READY` | Any count above zero means the whole delivery has landed. |
| `IF TIMER-T0>=TIMEOUT THEN GOTO LATE` | The deadline. `TIMER` is seconds since midnight, so this is wrong across midnight — a real program for an unattended run should allow for that. |
| `LET X=SLEEP(.25)` | **The line that makes this work.** `SLEEP` pumps BR's events while it waits, so the harness is serviced and the terminal repaints — a busy loop without it would starve the channel the delivery has to arrive through, and the wait could never end. |
| `GOTO WAITING` | Round again. Submit, then poll: the shape that means none of this needs a thread. |

A delivery is stored whole or not at all, so a count above zero means the whole text is there and
there is no half-read to guard against. This is the submit-then-poll wait of C1, and the reason
none of this needs a thread.

**Showing a long text.** BR's multi-line text box is the `TEXT` field type:

```
DIM REPLY$*19000
PRINT #W,FIELDS "1,1,TEXT 18/76/19000": REPLY$
```

| Part | What it means |
|---|---|
| `DIM REPLY$*19000` | The variable must hold the whole reply; BR does not grow it. |
| `#W` | A window channel — the box is drawn in a window the program opened, not over the console. |
| `"1,1,..."` | Row 1, column 1, **counting from 1** as BR statements do. (On the harness wire the same position is row 0, column 0 — the two count differently, which is worth holding on to.) |
| `TEXT 18/76/19000` | The field type and its three numbers: **18 rows** on the glass, **76 columns** wide, and a capacity of **19,000 characters**. The first two are what the person sees; the third is what the control holds and scrolls through. |
| `: REPLY$` | The value. On `PRINT FIELDS` it goes in; the same spec on `INPUT`/`RINPUT FIELDS` brings it back. |

The limits:

- a 19,000-character value goes in and comes back unchanged, and `TEXT 18/76/32000` is accepted
  too — the ceiling is the 32,767 a string variable has, not the control's;
- **`P` costs the keyboard.** A protected field is one the cursor skips, so a protected box cannot
  be scrolled with the arrow keys; and `P` on the *only* field of an `INPUT`/`RINPUT FIELDS`
  statement is error 866. So `agentlib` leaves its box unprotected, puts a live field beside it,
  and ignores whatever comes back — the file on disk is the authority, not the field;
- **GUI ON is what makes it scroll.** In GUI OFF the same statement holds the whole value — the
  harness read all 20,000 characters of it — but draws it as an old-style character field, so the
  person sees the 18 by 76 on the glass and no more.

`br/aiaccess/agentlib.brs` is the worked example of all of this: `FNAGENT_CODE` opens a `CODE`
question and writes what arrives to a file; `FNAGENT_REPLY` opens a `MESSAGE` one and shows what
arrives in a box; `FNAGENT_SHOW` asks a person to approve a generated program, with the
assistant's grant withdrawn first so that only they can answer.

<a id="the-console-conversation"></a>
### 5.7 The console conversation

A person at the `READY` prompt types `AI` and what they want:

```
READY
AI list the customers with an overdue balance over 1000
  I'll write a short report program. It reads CUSTMAST and AR-DETAIL ...
  [AI] 41 lines of source written to M:\w011.1.brs
  [AI] > LOAD "M:\w011.1.brs",SOURCE
  [AI] > RUN
  ... the program's output ...
READY
```

| Line | What it is, and who wrote it |
|---|---|
| `READY` | BR's prompt. The turn can only start here: with a program or a procedure running, `AI` is refused with 4169 unless that program or procedure set `AI_TURN_OK`, below. |
| `AI list the customers…` | **The person typed this.** `AI` is a BR command like any other and is logged like any other; everything after the space is sent to the assistant untouched. |
| `  I'll write a short report…` | **The assistant's prose**, printed in the **hilite** attribute so that the assistant speaking is plainly not the program printing. It carries no `[AI]` mark, because prose is not an action. |
| `  [AI] 41 lines of source written to M:\w011.1.brs` | **BR wrote this line, about itself.** The assistant delivered 41 lines against the turn's code question and the interpreter wrote them to a file it named. Said once, with the count and the path — not 41 echoed lines. The path is BR's choice; the assistant never picks one. |
| `  [AI] > LOAD "M:\w011.1.brs",SOURCE` | A command the assistant asked for. **`[AI] >` marks these and nothing else marks anything**, which is the safety property: a reader can always tell which commands came from the model. |
| `  [AI] > RUN` | The second. Each runs when it is asked for, and BR tells the assistant how it went before taking the next. |
| `  ... the program's output ...` | The program's own printing, unmarked — it is the program's, not the assistant's. |
| `READY` | The turn ended because the assistant delivered its reply. There is no "I have finished" action; the reply **is** the ending. |

A failure would appear here too, as `[AI] <- error 4152: file not found`. Success is not
announced: the command's own output is already on the screen.

Each `[AI] >` line runs when the assistant asks for it, and what became of it is reported
back as that command's result. **A failure is a line of the conversation too** — `[AI] <-
error 4152: file not found` — because the person watched the command go by, and what happened
to it belongs in the same place, where it scrolls into the history with everything else.
Success is not announced: the command's own output is already there.

`AI` is a BR **command**, so BR logs it like any other. The reply prints in the **hilite**
attribute, so the assistant speaking is plainly not the program printing, and **only** lines the
model asked to have run carry the `[AI] >` mark — which is how a reader always knows which
commands came from the model.

**How a turn goes.**

1. The command names the file a delivered program would be written to, and opens **two**
   questions: `chatN` for the reply, kind `CHAT`, and `chatN-code` for a program, kind `CODE`.
2. It sends the text to the assistant as an `ASK` event, whose args are the turn's question id.
3. It then waits, yielding, so the terminal keeps repainting. A break key — Ctrl-A — **halts the
   wait without ending the turn**: the person lands at `READY` with the turn still open, and `GO`
   returns to the wait where it left off. `CLEAR PROC` is how a turn is ended deliberately.
4. A `SOURCE` delivery for `chatN-code` comes back one line per `AGENTCHAT_NEXT` and **the command
   writes it to that file**, on the machine running the interpreter. The lines are not echoed; one
   console line says how many arrived and where they went.
5. Lines the assistant wants run arrive as `COMMAND` and are **run as they arrive**, one at a
   time, each at command level; a `RAN` event reports how each one went before the next is taken.
6. The assistant answers with a `MESSAGE` delivery for `chatN`. **The delivery is the end of the
   turn** — there is no action for "I have finished".
7. `AI NEW` ends the turn and starts a fresh conversation. It sends no `ASK` and needs no
   assistant, so it cannot fail.

**A turn may not open over a running program or procedure unless that program or procedure says
it may.** The `AI` command is refused with BR error **4169** while either is active, before the
`ASK` goes out, unless `ENV$("AI_TURN_OK")` is `"Y"` — case does not matter.

*Why a program cannot simply bridge a turn.* BR has never allowed an interrupted program to be
replaced: `SAVE`, `REPLACE`, `RENUM` and `RUN` all refuse with 2108, *program is active*, while
one is. A turn's commands include the `LOAD` that would replace it, so an AI inquiry over an
interrupted program is that same operation with extra steps.

*Why a procedure is in the same position for a different reason.* A procedure can stand above a
program the way an operator does, so it can still be there when a turn is over — but it is
driving the program state, and a turn can change it underneath. A proc that resumes expecting the
program it loaded, and finds another, does harm it has no way to detect.

*Why the flag is needed even when the procedure typed the `AI` line itself.* Writing `AI <text>`
into a proc consents to **asking**. It cannot consent to the `LOAD` and the `RUN` the assistant
will send, because those did not exist when the line was written — which is the whole point of a
turn. The flag is the programmer saying *I know the loaded program may be gone when control comes
back to me*.

*How long the consent lasts, and what takes it down.* **Two things, and the `AI` command is
neither of them:**

1. **The programmer clears it** — `SETENV("AI_TURN_OK","")`, or any value but `"Y"`. It is their
   flag, so revoking it is theirs too, at whatever moment they decide consent is over.
2. **The turn ends** — every path out of a turn goes through `aiTurnEnd`, so consent does not
   survive the conversation it was given for. A proc driving three turns therefore says so three
   times, because each turn's end takes the last one's consent with it.

Reading it is not spending it, which has one consequence worth stating: **a turn that never
OPENED leaves the flag standing.** An `AI` line with no assistant listening fails with 4158
through the command's own error path and never reaches `aiTurnEnd`, so the next `AI` line in that
procedure is still authorised. A program that cares about that clears the flag itself — which is
what the first reset is for.

Keeping it readable through the turn is the other reason it is not spent at the gate: a program the
assistant's own `RUN` loaded can ask `ENV$("AI_TURN_OK")` and find out how it was reached.

**The `AI` command itself is refused on an assistant's line**, with 4171. A turn's whole authority
is that a person typed `AI`, and the state is single — so such a line ended the person's turn and
opened one of its own, against a question nobody had asked. Measured before it was closed:
`COMMAND AI can you hear yourself` reported the first turn as ended and then took commands for the
second. What makes it a rule rather than a curiosity is the `ASK` on the way out: it reaches
whatever is listening, which in `chat` mode is the model that just sent the line — handed its own
text as a fresh inquiry, free to do it again, bounded only by the silence timeout. `AI NEW` is
refused from there too, because the assistant already ends its turn by answering, and ending one
with no reply does not need a second route.

*Who may set it.* Whatever is running. **A line from the assistant may not** — refused with 4170
and logged, the same rule and the same reason as `MSG("grant")`: a permission the restrained party
can grant itself is not one. **`CONFIG SETENV` may not either**, because nothing is running when a
configuration file is read, so the name has nothing to mean there; seeding it would authorise
exactly the session's first turn and then stop.

*A proc whose last line is the `AI` line needs no flag*, and correctly: BR pops a proc as it reads
its last line, so by the time the gate is reached `t.procfile` is the enclosing proc's, or zero.
Nothing is left to protect.

**`PROC` from the assistant behaves as `SUBPROC`.** `PROC` normally pops the proc it was typed
from, which is what makes it a replacement rather than a call. From an assistant's line that would
destroy the very procedure bridging the turn — which set `AI_TURN_OK` on the understanding that
the loaded *program* might be gone, not that it would itself be gone. Converted rather than
refused: "run this procedure" is what the model meant, `SUBPROC` is that meaning carried out
safely, and the `[AI] >` line shows the person the command either way. An operator-keyed `PROC`
has always been exempt for a related reason, and an assistant's line is not operator-keyed —
`ENTER_COMMAND` clears `OPER_KEYED` before the turn is asked for its next line.

**`CLEAR PROC` ends an open turn**, along with its other duties, and so does `CLEAR ALL`, which
does everything `CLEAR PROC` does. A turn is a state of the command processor like a proc
supplying lines, and `CLEAR PROC` is how a person says *stop taking commands from anywhere but
me*; leaving the turn standing would leave the assistant holding the prompt with every proc
beneath it gone, waiting on a result nothing was going to produce. It reaches a `CLEAR PROC` the
assistant sent too: that ends its own turn, and it is told — the command is reported as `RAN -1`,
*the turn ended before this command’s result was known*, which is true of it (BR never came back
to the prompt) without claiming it did not run.

**A turn on the wire.** The transcript below was captured from a running session, not composed
from the rules above: `hchatsrc.prc` opened the channel and a driver stood in for the assistant.
`→` is what the assistant sent, `←` what BR sent back.

```
→ HELLO 73a5f84295526d11ddc83489ed89902d76787f5695b58c3ad850e802dbf9a300
← OK 0
→ SUBSCRIBE ASK NOTE RAN
← OK 1
← SUBSCRIBED NOTE ASK RAN QUIET=200 0
←
← EVENT ASK 1 chat1 44
← please write me a program that proves it ran
→ QUESTIONS
← OK 2
← QUESTION chat1 CHAT 0
←
← QUESTION chat1-code CODE 13
← M:\w011.1.brs
→ SOURCE chat1-code 105
→ 00010 ! written for this turn by the assistant
→ 00020    PRINT "17 customers are over 1000"
→ 00030    STOP
← OK 1
← DELIVERED 3 105 0
←
→ COMMAND LOAD "M:\w011.1.brs",SOURCE
← OK 1
← QUEUED 1 0
←
← EVENT RAN 2 0 0
←
→ COMMAND RUN
← OK 1
← QUEUED 1 0
←
← EVENT RAN 3 0 0
←
→ MESSAGE chat1 51
→ Seventeen are over 1000; the program is on screen.
← OK 1
← DELIVERED 1 51 0
←
```

Line by line. Every record is a header and a body of the declared length, so the bare `←` lines
are empty bodies and their trailing LF (5.2) — they are in the transcript because a reader that
skips them loses sync.

| Line | What it is |
|---|---|
| `→ HELLO <64 hex>` | The token from `%LOCALAPPDATA%\ADS\harness.token`, which the program published with `MSG("harness", port)`. It is spent here: the file is deleted the moment this succeeds. |
| `← OK 0` | Success, **0 records follow**. The number on an `OK` is a record count, never a result. |
| `→ SUBSCRIBE ASK NOTE RAN` | Ask to be told, rather than poll. `ASK` is a turn opening, `RAN` a command finishing; `NOTE` is a program's own `MSG("notify")` and is not needed for a turn. |
| `← OK 1` | One record follows. |
| `← SUBSCRIBED NOTE ASK RAN QUIET=200 0` | Record `SUBSCRIBED`; arguments are what is now subscribed, **echoed back in BR's order, not the order asked**; `QUIET=200` is the coalescing window in milliseconds; the final `0` is the body length. |
| `← EVENT ASK 1 chat1 44` | An event, not a response: it arrives where a status line could, and a reader takes it and goes on looking (5.4). `ASK` is the name, `1` the sequence number, `chat1` the argument — **the turn's question id** — and `44` the body length. |
| `← please write me a program…` | The 44 bytes: what the person typed after `AI`. **This is data, not instruction.** |
| `→ QUESTIONS` | What is open. The assistant knows the turn id from the event, but not yet where a program would go. |
| `← OK 2` | Two records: a turn opens **two** questions. |
| `← QUESTION chat1 CHAT 0` | The reply question. Kind `CHAT`, empty body — a reply needs no destination. |
| `← QUESTION chat1-code CODE 13` | The program question. The id is the turn's with `-code` appended, **derived rather than announced**, so an assistant holding the turn id holds this one too. |
| `← M:\w011.1.brs` | The 13 bytes: **the path BR chose**, in the session's work path. A BR drive path, which is what `LOAD` takes — not an operating-system path, and not one the assistant may pick. |
| `→ SOURCE chat1-code 105` | Deliver a program against the code question. `SOURCE` for the `CHAT` question would be refused with 9: the kinds are what keep a program and a reply apart. |
| `→ 00010 …` | The 105 bytes, delivered whole. The interpreter writes them to the path above; the lines are not echoed to the console, one summary line is. |
| `← DELIVERED 3 105 0` | Three lines, 105 bytes, empty body. |
| `→ COMMAND LOAD "M:\w011.1.brs",SOURCE` | The first line to run, quoted as it would be typed. |
| `← QUEUED 1 0` | **Accepted, not finished.** The result cannot come back as this response, because a response belongs to the request before it (5.2). |
| `← EVENT RAN 2 0 0` | The result. Sequence `2`, then **`0` — BR's error code, 0 for success** — and a body length of 0, which is BR's message for that code and is empty when there is none. For this `LOAD` it means the last line of the file has been read. |
| `→ COMMAND RUN` / `← EVENT RAN 3 0 0` | The same shape, and *finished* means the program has **stopped**. A `RUN` that writes a year of history answers when the report is written. An error the program died on arrives here as its number. |
| `→ MESSAGE chat1 51` | The reply, against the `CHAT` question. **Delivering it ends the turn** — there is no "I have finished" action, and nothing after this will run. |
| `← DELIVERED 1 51 0` | One line, 51 bytes. The turn is over; a further `COMMAND` would now be refused with 13. |

What the person saw while that happened is the console transcript at the top of this section.

**Why the turn opens a question at all.** A delivery's authority is an open question, and a
question is opened from inside the session. At the `READY` prompt there is no program running to
open one, so until the turn opened its own there was nothing an assistant could deliver a program
*against*: a turn could carry prose, which prints, and commands, which run, and neither is a
program.

**Why two questions and not one.** The store holds one unread text per id, so the reply — which
*ends* the turn — would be refused while a program sat unread, or the program refused while the
reply did. A separate id also keeps the kinds honest: `SOURCE` is accepted for a question answered
with code and nothing else. The second id is `chatN-code`, derived rather than announced
separately, so an assistant that has the turn id has this one too; `QUESTIONS` reports both.

**The file is replaced by each delivery** and named by BR from the session's work path, so a turn
cannot accumulate programs and nothing is left behind that a later turn could load by accident.

**The turn is a state of the command processor, not a loop inside the `AI` command.** It has to
be. A command is run by BR's own command loop, and the `AI` command is standing in it — so running
a line from inside that command would nest a command, and a program, inside the one still on the
stack. The first version therefore collected the lines and ran them afterwards from a work file,
as a nested procedure, which worked and told the assistant nothing about any of them: the turn
was over before the first one ran.

So the `AI` command now sends its question, opens the turn and **returns**. `cmd()` then asks the
assistant for the next line at the one place it asks anybody for one, and runs it exactly as it
runs a procedure's line. Three consequences are worth stating because each one is a rule a reader
could otherwise get wrong:

- **The turn takes that prompt ahead of a procedure.** A turn typed from a proc finishes before
  the proc's next line, which is the order the batched arrangement had.
- **It takes it behind a source `LOAD`.** While `LOAD … ,SOURCE` is reading, the load owns the
  prompt; stepping in front of it would read the assistant's next command into the middle of the
  program it had just asked to be loaded. The turn resumes, with the `LOAD`'s result, when the
  file closes.
- **`PROCERR` does not apply to the assistant's line.** A procedure can be active while the line
  that failed came from the assistant, and `PROCERR` is a statement about the *proc's* own lines.
  Letting it apply made a failed command the proc's error: with `PROCERR RETURN` the proc swallowed
  it and carried on, the assistant was never told, and its turn stood at a prompt nobody was going
  to answer.

**With nobody subscribed to `ASK`, `AI` fails at once** with BR error 4158, *no assistant is
listening on this session's channel*, rather than waiting out its timeout for a reply that cannot
come.

**`AI` costs no name.** `AI=5` is still an implicit `LET`, because BR matches a command keyword
only when the line ends or the next character is a space — the same rule that lets `AUTO=5` assign
to a variable while `AUTO` is a command. What changes meaning is `AI` followed by a space, which
was a syntax error before; the one exception, `AI = 5` written with spaces, reads as the command,
exactly as `AUTO = 5` always has.

**The command runs in the interpreter and the assistant is attached to the client**, so each turn
is one synchronous client/server transaction, `AGENTCHAT`, carrying the question out and a reply
line, a command, or "nothing yet" back. In client/server mode that crosses the socket; locally it
goes through the client DLL in the same process.

**The driver's `chat` mode** holds the conversation and calls the model, because a person at BR's
console has no model of their own. It sends nothing anywhere without `ANTHROPIC_API_KEY` in the
environment, and `--echo` answers locally with no network call at all. The model is told to put a
line it wants run on its own line beginning `> `, so **BR never parses model output**: prose and
commands reach it over two different requests, and a command still needs an open turn.

<a id="the-client-server-messages"></a>

## 6. Messages between the BR server and a BR client

In BR client/server mode the program interpreter is on the server and everything the assistant 
touches — the screen, the keyboard, the harness socket, the token — is on the client. So every part 
of sections 5, 7 and 8 crosses BR's own client/server protocol, and this section defines which messages 
carry it. One is new for the AI surface and is specified here in full; the rest are long-standing
messages whose AI-relevant payload is named so that a reader can tell what travels and what does
not.

<a id="cs-shape"></a>
### 6.1 The shape of the protocol, and what follows from it

**It is server-driven.** The server calls the client to draw the screen, run fields, read keys and
open files. The client almost never starts anything: its only ordinary messages to the server are
"a key is waiting" and "I am closing". Two consequences shape every design in this document.

- **Information the client lacks should be pushed by the server**, as an asynchronous message.
  `SETFIELDSCONFIG` is the model (6.3). A true client-to-server *request* is the thing to avoid.
- **A question the server needs answered must be a synchronous call it makes**, because the client
  has no way to raise one. Section 5's whole channel is client-side for this reason, and section
  9's `AI` command had to become a synchronous call (6.2) rather than anything the client initiates.

**Message numbering.** Messages are declared in `clientserver.h`, which is included several times
with different macros, so each type is numbered as its own run in file order (`remoteargs.h`).
**Nothing verifies that the two ends agree on the numbering** — `VERIFY_MESSAGES` is flow control 
for unconfirmed asynchronous packets, not a
table checksum — so a mismatched pair would misread messages rather than refuse. **Client and server
are built and shipped together**, and the client DLL is version-stamped, which is what makes that
safe.

<a id="cs-agentchat"></a>
### 6.2 `AGENTCHAT` — the console conversation

The only message added for the AI surface. It carries a turn of the `AI` command
(5.7) between the interpreter, where the command runs, and the client, where the assistant is
attached. **Synchronous**, added at the end of the synchronous group.

```
AGENTCHAT_CALL   server -> client   integer what, string text, string extra
AGENTCHAT_RET    client -> server   integer kind, string line
```

`what` is one of:

| Value | Name | Carries | Meaning |
|---|---|---|---|
| 0 | `ASK` | the person's text; `extra` is the path | Open a turn: post an `ASK` event and open the turn's two questions (5.7). |
| 1 | `NEXT` | — | What has the assistant sent? One item per call, in arrival order. |
| 2 | `END` | — | Close the turn and drop anything still queued for it. |
| 3 | `GRANT` | — | Is a grant held? Asked once as the turn opens. Recorded in the log; it no longer decides what may go unquestioned (5.3.6.4). |
| 4 | `RESULT` | the error number and its message | The command just run is finished. The client posts it as a `RAN` event. |

**`extra` travels because the two halves are two machines.** It is where the *interpreter* will
write a program delivered for this turn. The client never opens it — it holds the string so that
`QUESTIONS` can hand it back to the assistant, which is the only way the assistant can learn the
path it has to put in a `LOAD`.

`kind` is one of:

| Value | Name | `line` holds | What the command does |
|---|---|---|---|
| 0 | `NOTHING` | empty | Keeps waiting, yielding to the event pump. |
| 1 | `REPLY` | a line of the reply | Prints it on the Command Console in the `HILITE` attribute. |
| 2 | `COMMAND` | a line to run | Echoes it as `[AI] > <line>` and collects it to run. |
| 3 | `DONE` | empty | The turn is over. |
| 4 | `NO_AGENT` | empty | Answer to `ASK` only: nobody is subscribed. The command fails with BR error 4158 instead of waiting. |
| 5 | `SOURCE` | a line of a delivered program | Writes it to the turn's file. Not printed and not run. Served ahead of the reply and the command queue, so the file is whole before a command can name it. |

`line` is at most 2048 bytes. The constants are in `basic.h` as `AGENTCHAT_*`, shared rather than
kept with the harness, because the interpreter names them without being able to see the harness at
all — the harness is client-only.

**A non-GUI client answers `NO_AGENT` to `ASK` and `DONE` to everything else.** It has no channel
to carry a conversation, and saying so is better than leaving the server waiting on one that
cannot exist.

<a id="cs-fieldsconfig"></a>
### 6.3 `SETFIELDSCONFIG` — what the client has to be told

The asynchronous message by which the server tells the client about itself, and the model for
anything else of that kind. Two of its fields belong to this surface, both at the tail of
`fieldsconfig` (`SERIALIZE_FIELDSCONFIG_LENGTH` 410, in addition order):

- **`restrictedSession`**, one byte. Once it says so, nothing switches it off, and the client
  applies the restricted-session file rule to its own file operations — the server-forwarded ones,
  `MSG("dump")` and `MSG("shot")` (4.5), a print job written to a named file, printing to a UNC
  name, and `Ctrl-]`, where the shell would start on the client.
- **`consoleHistory`**, four bytes. `CONSOLE HISTORY` is read by the *server* from its
  configuration, and the ring it sizes lives on the *client*, so the figure has to travel. This is
  why `HISTORY` (5.3.2.2) works in client/server mode at the size the server was configured with.

<a id="cs-the-rest"></a>
### 6.4 Messages the AI actor depends on

All long-standing, none changed for this work. Named here because they are what the sections above
actually travel over, and because knowing which they are is what tells a reader that no new
transaction was needed.

| Message | Direction | What it carries for this surface |
|---|---|---|
| `DLLCALL` | server → client | **Every `MSG` call in section 4.** The interpreter serialises the argument stack, the client runs the action and the arguments come back updated. This is why an action's answer arrives in its last argument. |
| `KEYBOARD`, `KEYBOARD_MOUSE` | server → client | The server asking for a key. `KEYS` and `SCANCODE` (5.3.4) land in the client's own queue and are taken through this. |
| `KEYBOARD_MOUSE_ASYNC` | **client → server** | "A key is waiting." One of the client's two unprompted messages, and the precedent for any other. The debugger's break key needed it: `KB_DEBUG_BREAK` could not interrupt a running program until the handler raised it. |
| `SCREEN`, `FIELDS`, `FIELDSPRINTLN` | server → client | Everything drawn. What `SCROLLVIEW`, `ATTRS` and `CONTROLS` (5.3.2) report is what these put there. |
| `READ_SCREEN` | server → client | Reading the glass back, for BR's own purposes; the harness reads the client's buffers directly instead. |
| `OPEN_FILE`, `READ_FILE`, `WRITE_FILE`, `CLOSE_FILE` | server → client | Files named with BR's `@:` prefix, which is a path on the **client**. A file that is already beside the client is reached this way, and `COPY` moves one either direction. **It is not how a model's program gets in** — nothing on the channel writes a file, so there would be nothing there to open; a program arrives as a `SOURCE` delivery and the interpreter writes it on its own side (5.7). In a restricted session the client applies the file rule to `@:` paths too. |
| `LOG_EVENT` | **client → server** | Client-originated log entries, merged into the server's log, which is why section 7's record is one file and not two. Batched, so a client event's position relative to a server event is approximate. |
| `CONFIG_MSG` | server → client | Configuration messages on the splash screen. Relevant only because a message holds the splash, which a comment deliberately does not. |
| `DEBUGGERKEY` | server → client | A key the debugger submitted, injected into the client's queue. |
| `DEBUGCONSOLEOFF` | server → client | `DEBUG CONSOLE OFF` (10.x) reaching the client, which is where the console prompt is. |
| `SETFIELDSCONFIG` | server → client | See 6.3. |

**The debugger channel does not travel over any of these.** It is the server's own socket (section
10), so a debugger attaches to the machine running the interpreter. Tunnelling it through the client
was considered and rejected: the console plus the notices cover what development needs, and the
debugger stays a separate tool for an outside debugger.

**What is deliberately absent.** There is no "evaluate this expression" message from the client.
`PRINT X` typed at the console already does it and the answer is on the screen, where the
assistant reads it; a message would only be needed for values *while a program is running*, which
is rare enough to wait for a real use.

<a id="what-is-recorded-and-what-that-is-worth"></a>

## 7. What is recorded, and what that is worth

**What is recorded.** BR's log captures, without the AI doing anything to enable it:

- **every command entered**, whoever entered it, including every command the AI submits over the
  debugger channel — the AI's commands go through BR's ordinary command path and are logged by the
  same line of code that logs yours. **Immediate statements are not logged**, yours or the AI's:
  a `PRINT X` or a `LET X=0` it submits runs and leaves no line in the log. Their effects can
  still be seen — on the Command Console, or through a watched variable — but BR's log covers an
  AI's commands, not its statements. **To record everything an attached AI submits, statements
  included, start `DEBUG LOG COMMANDS <file>` before it begins**: that file receives every line
  that arrives over the debugger channel, as received (see 10.6, *The `DEBUG` commands*);
- **every attach and every refusal**, with the address of the peer and, on success, the TLS version
  and cipher negotiated;
- **the setting of `DEBUG AUTH OFF`**, and every attach made under it;
- **every variable-watch stop**, with the value;
- **every grant** at the user level: given, how long it lasted, how many actions were submitted,
  and when and why it ended;
- **every refusal in a restricted session**, naming the file or the command.

**What that is worth, stated honestly.** It depends on which session you are asking about.

**In a restricted session the record is protected.** `CONFIG LOGGING` is one of the configuration
operations such a session may not perform, and the refusal is itself recorded. The same applies
however the setting arrives — from a `CONFIG` command or from the session's own configuration
file — because both are checked at the same point.

**In an ordinary session it is not, and you should know that before relying on it.** BR's logging
destination and level can be changed at run time with `CONFIG LOGGING`, which is an ordinary
command, so anyone holding the command channel — including an AI attached at programmer level to
an unrestricted session — could redirect the log elsewhere or lower its level until the entries
above stop being written. Nothing currently prevents that or records that it happened.

So for an ordinary session the record is a **reliable account of a cooperative session**, accurate
for after-the-fact review, audit and support, but **not tamper-evident** against the party being
recorded. Closing that is a contained piece of work — refusing to lower logging while a debugger
is attached, or recording any change of logging as a security event the new destination cannot
erase — and it is not done.

Two smaller limits, for completeness:

- **Attribution is by grant, not by keystroke.** At user level the AI types through exactly the
  same path a person does, deliberately, so BR cannot tell from a keystroke who produced it. The
  record therefore says "the AI held the grant from this time to that time and submitted this many
  actions", which is true, rather than a per-keystroke attribution, which would not be.
- **Client-originated log entries are batched**, so their position in the file relative to
  server-side entries is approximate. Timestamps are accurate to the millisecond; ordering between
  the two sources at sub-second resolution is not guaranteed.

<a id="programmer-level-letting-an-ai-join-as-a-debugger"></a>

## 8. Programmer level: letting an AI join as a debugger

This is a much larger grant of authority than the user-level door, and it is worth being clear
about that before the steps: an AI joined here can do anything the programmer can do at the
console. There is no reduced debugger mode.

<a id="the-authorization-sequence-programmer"></a>
### 8.1 The authorization sequence

**Step 1 — the programmer opens the channel.** From the BR console:

```
DEBUG LISTEN                  ! port 9555
DEBUG LISTEN 9555             ! the same, said explicitly
```

**The port is bound on the loopback interface, always, and there is no way to ask for otherwise.**
A debugger belongs on the machine running the interpreter. Anyone who needs to attach from
elsewhere forwards the port — which puts the decision with whoever administers the machine, rather
than with whoever can type a BR command.

Anything after the port is **error 1006, a syntax error** — refused rather than ignored, because a
script still carrying the removed `PUBLIC` keyword must fail where its author can see it rather
than bind loopback while they believe otherwise. A syntax error halts a procedure, and
`PROCERR RETURN` does **not** carry one past it: it carries a proc past a runtime error, which
this is not. `DEBUG OBSERVE` (8.2) is the same, and for a sharper reason —
it is shown the same material, so a rule applying to one and not the other would be the way around
the one it applied to.

**Step 2 — BR publishes the key before the door opens.** BR generates a fresh 32-byte token for
the session and writes it to `%LOCALAPPDATA%\ADS\brdebug.token` — the same per-user private folder
as before — *before* the port starts listening, so it is always in place before anything can
connect. To see the current setting and where the token is:

```
DEBUG AUTH                    ! reports the mode and the token's location
```

**The token file does not outlive its purpose.** It is managed exactly as the assistant channel's
is, and for the same reasons:

| When | What happens |
|---|---|
| BR starts | a token left by a session that has **ended** is deleted; one a **live** session is holding is left alone |
| `DEBUG LISTEN` / `DEBUG CONNECT` | a fresh token is written and **held open** — nothing can delete it while the channel waits |
| a debugger attaches | the file is **removed**. The debugger holds the secret in its own memory and can reconnect with it; BR's copy is a static no BR program can reach, so every further moment the file existed was one something could read it in |
| the debugger detaches | the secret is forgotten too, so the next `DEBUG LISTEN` mints and publishes a new one |
| five attaches fail in a row | the channel closes, **error 4161**, and the token goes with it |
| five minutes with nobody | the channel closes, **error 4163**, and the token goes with it |

The file is one path per account, so every session's startup sweep reaches every session's token.
Holding it open without delete sharing is what makes that safe: the operating system refuses the
delete, and the refusal is also how a sweep tells a live token from a dead session's.

**A refused attach is answered**, with `DEBUG_AUTH_REFUSED` (114), before the connection closes. A
peer that guessed learns nothing from it, but a debugger holding a token from before the channel
was reopened could otherwise not tell a refusal from BR not running. One byte of reason and no
more — the detail is in BR's log, and a peer that failed to authenticate is not owed BR's
reasoning.

**The peer's account is checked at accept**, before TLS. Both channels that accept a connection
bind to loopback and cannot be asked to do otherwise, so the peer is always a local process with an
account to read; a mismatch is refused and logged with the process name and SID (**4162**). Any
account on the machine can reach `127.0.0.1` and Windows puts no permissions on a TCP socket, so
without this the token is the only thing in the way. A foreign process is **not** counted against
the five: counting it would let any account close the channel with five connections.

**Step 3 — TLS first.** The AI connects and BR requires **TLS 1.3**. A peer that speaks plain text
gets no further; the handshake fails and the attempt is logged. This is not only about
eavesdropping: everything that crosses this channel afterwards — your program source, your
variables' values, BR's whole log stream — is material you would not post publicly.

The actual value of using self-signed TLS is more to encrypt the channel than to authenticate. 
Primary authentication is done using dynamic tokens within the TLS channel.

**Whose certificate, and who makes it.** Nobody makes one per site. There is a single certificate,
issued by Application Development Systems and **compiled into BR**, the same one the client,
server and listener already use — self-signed, `CN=BusinessRulesCert`, valid until August 2052. It
is regenerated only when ADS rebuilds it. So there is no
certificate authority to deal with, nothing to enroll, nothing to renew, and the debug channel adds
no trust store of its own.

The consequence is the one stated above, and it is worth being explicit about: because that
certificate and its private key ship in **every** copy of BR, presenting it proves only that the
far end has a BR installation. Actual party identification is managed by the exchange of tokens.

**Step 4 — then both sides prove themselves.** Inside the TLS session:

1. BR sends a challenge: a protocol version and a random number.
2. The AI answers with proof it holds the token, plus a random number of its own.
3. BR checks that proof in constant time, and if it is right, answers with proof that **it** holds
   the token too.

The exchange is mutual, and that is not ceremony. When BR *dials out* to a debugger the operator
names, BR is about to stream source and data to whatever answers — so BR proving it is BR matters
as much as the peer proving itself. The two proofs are separately labelled so that neither can be
replayed as the other.

Only when all of that has succeeded does BR mark a debugger as attached. Until then the channel
stays free to authenticate. Once it is attached, no second debugger can attach until it leaves:
`DEBUG CONNECT`, `DEBUG LISTEN` and `DEBUG AUTH` are refused with error 420.

**The console stays usable unless the debugger closes it.** Attaching does not block the command
console: you and the AI can both enter lines at the prompt — commands and immediate statements. If
the AI should have the channel to itself, it
sends `DEBUG CONSOLE OFF` after attaching (you can also type it at the console). From then on the
console takes no keyboard input at its prompt until the AI disconnects or sends `DEBUG CONSOLE ON`; you cannot lift it
from the console. Leaving the console open is the right choice when you want to work alongside the
AI, but remember that each of you can then change program state the other is relying on.

**Debugging together.** With the console left open, you and the AI can both set breakpoints, step
and inspect the same program. An assistant that works in turns attaches through
`br/aiaccess/dbgbridge.py`, which holds the channel open between its turns, records every stop,
step position, prompt and log line, and sends the assistant's lines — commands or immediate statements — one at a time when BR is at
its prompt. Taking turns is by agreement: the assistant says **"request complete"** when it has
finished and the prompt is yours. A line it sends while you are part way through typing one
replaces that line, so typing while it is active is at your own risk. Section 10.11, *Debugging
together: the bridge*, has the details.

**The AI can use the user-level door too.** Attached as your debugger it holds your authority, so it
may open the user-level connection (`MSG("harness", port)`) and give itself keyboard grants
(`MSG("grant", seconds)`) through the debugger channel whenever it needs them — to see the
Command Console at a breakpoint, or to run a program and test its screens as a user. It can never
raise a grant over the user-level connection itself. Each grant shows in the title bar and is
logged, and you can still withdraw one at any moment with `MSG("grant", 0)`.

**Step 5 — alternatives, and when to use them.**

```
DEBUG AUTH COOKIE             ! the default described above
DEBUG AUTH TOKEN <64 hex>     ! a token you supply, for a debugger on another machine
DEBUG AUTH OFF                ! no encryption, no authentication
```

`TOKEN` is for the case the cookie cannot cover: a debugger on another machine cannot read your
local token file, so you give both sides the same value yourself.

`DEBUG AUTH OFF` restores exactly how BR behaved in earlier releases. It exists so a debugger that has not
yet implemented its half can still be used during the transition. Both the act of setting it and
every attach under it are recorded as security events. It should be temporary; and if the port has
been forwarded off the machine, it should not be used at all.

<a id="joining-as-an-observer-instead"></a>
### 8.2 Joining as an observer instead

If you want the AI to *watch* a debugging session rather than conduct it, there is a second
connection for that:

```
DEBUG OBSERVE                 ! loopback only, port 9556
DEBUG OBSERVE OFF
```

An observer receives a copy of everything BR sends the debugger and can say nothing back. It
cannot issue a command, it does not occupy the debugger's place, and the session is unaffected by
whether it is connected, disconnected, or has crashed. It authenticates exactly as the debugger
does, because it is shown exactly the same material.

This is the right choice when a programmer wants help reading a session they are driving
themselves.

<a id="what-an-ai-can-do-at-programmer-level"></a>

## 9. What an AI can do at programmer level

**Section 10** is the full protocol reference — every message, how a debugger reads data back,
what the channel does not carry, and how it compares to the Debug Adapter Protocol. What follows
here is the summary.

Once attached as the debugger, the AI has the programmer's authority. Specifically:

**Enter anything at the prompt.** Whatever you could type at the BR command prompt, it can submit:
commands — `LOAD`, `RUN`, `LIST`, `SAVE`, `REPLACE`, file commands, `CONFIG`, and `SYSTEM` including
its form that runs an operating system command — and immediate statements, such as `PRINT X` or
`LET X=0`, which run at once and can change the program's variables. This is the part to weigh before attaching one: it is not a
restricted command set. (A *restricted* session is a different matter — see the summary — and an
AI attached to one is bound by the same restrictions as everything else in it.)

**Interrupt a running program.** A break request now takes effect while the program is running,
rather than waiting for the program to ask for input. (It was formerly acknowledged and then
ignored until the program happened to pause — so a program in a loop could not be broken into at
all.)

**Step and set breakpoints.** Step into or over, by line or by clause; set breakpoints on lines
and on clauses; run to a line.

**Watch variables, and see the values.** When a watched variable changes, the program stops and
the AI is told the line, the clause, the variable, the subscript if it is an array, and **the value
it changed to**. Earlier versions sent only the variable's name.

**Read BR's log stream live**, at whatever level is configured — including every command entered,
by anyone. Immediate statements are not in it; BR does not log them.

**Reach `DEBUG INTERNAL`**, BR's internal diagnostics.

**Watch the Command Console**, through the user-level connection it may open for itself (see
*Debugging together*), or through the screen log described in the summary for output that scrolls
past, so it can see what the program actually displayed rather than inferring it.

<a id="the-debugger-channel"></a>

## 10. The debugger channel

The protocol between BR and an attached debugger: what a debugger may send, what BR sends back,
what the channel deliberately does not carry, and how the whole thing compares to the Debug
Adapter Protocol that Visual Studio Code and most modern editors speak.

Written for whoever maintains the channel, writes a debugger against it, or wants to know what an
AI attached at programmer level can actually do.

**Securing and joining the channel** — TLS, the token exchange, `DEBUG AUTH` — is section 8.
This section is about what happens once you are on it.

`br/aiaccess/dbgauth.py` is a minimal debugger that authenticates and drives the channel, and
`dbgbridge.py` holds the channel open for an assistant (see *Debugging together: the bridge*).
Both are short, and readable as worked examples of everything below.

<a id="the-shape-of-it"></a>
### 10.1 The shape of it

One socket, one debugger. `DEBUG CONNECT` dials out to a debugger; `DEBUG LISTEN` waits for one.
Either way a second attempt is refused with `BREDEBUGGERATTACHED` (420) while a debugger is
attached, because permission and exclusivity are the same flag — `fieldsconfig.debuggerAttached`.

The command console is **not** blocked by attaching: by default the console and the debugger can
both enter lines at the prompt — commands and immediate statements alike. `DEBUG CONSOLE OFF`, sent
by the debugger or typed at the console while a debugger is attached, blocks keyboard entry at the
console's prompt, so that every line comes from the debugger. The
block lifts when the debugger disconnects or sends `DEBUG CONSOLE ON`; the person at the console
cannot lift it. A debugger that wants the channel to itself sends `DEBUG CONSOLE OFF` when it
attaches.

**Either end can open it.** `DEBUG LISTEN [port]` waits for a debugger to connect; `DEBUG CONNECT
host[:port]` dials out to one that is listening. Both directions exist so that a firewall between a
remote debugger and BR need only allow the connection one way. (The earlier debugger document
spells these `LISTEN DEBUGGER` and `CONNECT DEBUGGER`, and also describes putting LISTEN/CONNECT in
a `CONFIG EDITOR` statement; neither spelling nor the `CONFIG EDITOR` route is in the source.)

**Framing** is `SocketPacket`, the same in both directions:

1. a 32-bit packet length in bytes, **counting these four bytes** — so a packet with no data has
   length 8;
2. a 32-bit packet type — the message id;
3. the message's data, if any.

Every integer is big endian, network byte order — BR's `BH` rather than `BL` or `B`: 4 is sent as
`00 00 00 04`. Strings are **not** NUL-terminated; a string's length is whatever the packet length
leaves, which for a message whose data is only a string is the packet length minus 8.

**A debugger must ignore message ids it does not know.** The length leads every packet precisely so
that one can be skipped without being understood, and that is how the protocol grows: 113 and the
step reports are new, and a debugger written against the previous release keeps working by skipping
or ignoring them. BR is stricter in the other direction — an id it does not know closes the connection.

The whole thing now runs inside TLS 1.3 unless `DEBUG AUTH OFF` is set.

<a id="what-a-debugger-may-send"></a>
### 10.2 What a debugger may send

Three messages, plus the authentication response. `processMessage` in `debug.cpp` has no other
cases, and its `default` closes the connection.

| Id | Message | Effect |
|---|---|---|
| 1 | `FORCE_BREAK` | interrupt the program |
| 2 | `ISSUE_COMMAND` | submit one line at the prompt: a command or an immediate statement |
| 3 | `DEBUG_AUTH_RESPONSE` | during authentication only |
| 200 | `TERMINATE_CONNECTION` | disconnect |

That is the entire inbound vocabulary. It is small because one of the actions is "do anything".

**`ISSUE_COMMAND`'s data is the line itself**: its characters, not NUL-terminated, length = packet
length − 8.

**The conversation is prompt-driven.** A debugger sends `ISSUE_COMMAND` only after BR has sent
`ENTER_INPUT_MODE` — that message is BR saying it is at its prompt. Once a line has been submitted,
BR accepts nothing further from the debugger except `FORCE_BREAK` until it sends the next
`ENTER_INPUT_MODE`; a second `ISSUE_COMMAND` in between is refused with 430, *not processing input
command mode*. So the rhythm is always: prompt, one line, response, … prompt.

**`FORCE_BREAK`** may be sent at any time and has the effect of pressing Ctrl-A. It carries no
data. BR answers with `FORCE_BREAK_RESPONSE`, also without data, as soon as it recognises the
request and **before** it does anything to stop; then, once stopped, it sends `ENTER_INPUT_MODE`.

**`TERMINATE_CONNECTION`** can be sent by either side and carries no data. Send it before closing
the socket even though the other side would usually see the close as an error anyway — how a
closed TCP connection is reported varies, and the message removes the doubt. BR sends it too when
it closes the channel, including when BR itself exits.

**`FORCE_BREAK` works while the program is running.** It previously took effect only
when the program next waited for input, so a program in a loop could not be broken into at all —
`processKeyboard` skips the client unless `keyboardSignal` says a key is waiting, and the
debugger's key never raised it. The `DEBUGGERKEY_ASYNC` handler now calls `keyIsAvailable()`.

<a id="what-br-sends"></a>
### 10.3 What BR sends

All unsolicited except `ISSUE_COMMAND_RESPONSE`.

| Id | Message | Carries |
|---|---|---|
| 101 | `FORCE_BREAK_RESPONSE` | acknowledgement |
| 102 | `ENTER_INPUT_MODE` | BR is at a prompt: run status and error code |
| 103 | `ISSUE_COMMAND_RESPONSE` | whether the line just submitted was accepted into BR's input |
| 104 | `DEBUGGER_FILE_DATA` | channel number and bytes — see the redirect below |
| 105 | `DEBUG_VARIABLE_BREAK` | the name of a watched variable that changed |
| 106 | `DEBUG_FUNCTION_BREAK` | the name of a function break |
| 107 | `DEBUG_LINE_BREAK` | line and clause of a breakpoint hit, or of a step |
| 108 | `DEBUG_BEGIN_BREAK` | a begin break |
| 109 | `SYNTAX_ERROR_INDENT` | character offset where the last line failed |
| 110 | `DEBUG_MESSAGE_LOG` | sender, level and text of a log event |
| 111 | `DEBUG_AUTH_CHALLENGE` | protocol version and BR's nonce |
| 112 | `DEBUG_AUTH_CONFIRM` | BR's proof |
| 113 | `DEBUG_VARIABLE_CHANGED` | **new** — the value a watched variable changed to |
| 114 | `DEBUG_AUTH_REFUSED` | **new** — one byte of reason, sent before a refused attach is closed |
| 200 | `TERMINATE_CONNECTION` | BR is closing the channel |

**`ENTER_INPUT_MODE`** is sent whenever BR begins to wait for programmer input, and carries two
32-bit integers: the run status, then an error code. The status is a `RUNSTAT_VALUES` (`basic.h`),
so it names the state rather than merely signalling one:

| | | | | | |
|---|---|---|---|---|---|
| 0 `INVALID` (shown as READY) | 1 `RUN` | 2 `ATTN` | 3 `ERROR` | 4 `PAUSE` | 5 `CHAIN` |
| 6 `LIST` | 7 `STEP` | 8 `SYSERR` | 9 `LOAD` | 10 `SAVE` | 11 `REPLACE` |
| 12 `PROC` | 13 `EXEC` | 14 `READY` | | | |

The error code is the error the last line or the program stopped on, and is what tells a debugger
whether the line it submitted worked — `ISSUE_COMMAND_RESPONSE` does not (see below). Two things the
earlier document does not say: the prompt after a program has ended, or before one has
run, reports 14 (`READY`), not 0; and a stop at a breakpoint reports 7 (`STEP`), the same as a step,
because BR enters step mode when a breakpoint fires.

**`ISSUE_COMMAND_RESPONSE`** carries one 32-bit integer: 0 if BR took the line into its input, or
the error that prevented it — such as 430 when BR was not at its prompt. It is sent at once, before
the line is processed. It says the line was *issued*, not that it *worked*: that comes with the
`ENTER_INPUT_MODE` sent when processing has finished.

**`DEBUG_MESSAGE_LOG`** carries two 32-bit integers and then the text: the **source** — 1 for BR's
own messages, 2 for messages a user program logged — then the **log level**, then the message,
whose length is the packet length − 16 (eight bytes of header, eight of the two integers).

`DEBUG_MESSAGE_LOG` mirrors BR's own log stream at `g_debuggerLogLevel`, or the configured log
level if that is unset — including every **command** entered, by anyone, as *Command entered …*.
**Immediate statements are not logged**: `PRINT X`, `LET X=…`, `END` typed at the prompt run without
a log line, whoever types them. A debugger therefore learns of a statement someone else entered only
from its effects — the Command Console, or a variable it is watching.

<a id="driving-br-one-message-the-whole-console"></a>
### 10.4 Driving BR: one message, the whole console

`ISSUE_COMMAND` submits a line exactly as though it had been typed at the Ready prompt — a command
or an immediate statement, which BR tells apart as it does for anyone typing. Despite the message's
name there is no reduced set and no separate debugger vocabulary. Everything below is just a string
sent in that one message:

| Intent | Line |
|---|---|
| resume | `GO` |
| resume in step mode | `GO STEP` |
| resume at, or until, a line | `GO <line>` / `GO .<line>` |
| step | `DEBUG STEP INTO LINE`, `DEBUG STEP OVER CLAUSE`, … |
| set a line breakpoint | `BREAK <line>` |
| watch a variable | `BREAK <variable>` |
| evaluate | `PRINT X*2` — an immediate statement, not a command |
| read the source | `LIST >DEBUG:1` |
| edit the source | `00220 LET X = Y + 1` |
| and equally | `SAVE`, `REPLACE`, `FREE`, `CONFIG`, `SYSTEM` |

The last row is the point to weigh before attaching anything, human or otherwise: a debugger holds
the programmer's full authority. The exception is a restricted session, where the same command
filter applies to the debugger as to everything else — see `AI-Restricted-Operations.md`.

Lines submitted this way go through `command.cpp`'s ordinary path — `tokenize`, then `tokensub`
into `table1k` — and meet the same gates. A **command** is logged as *Command entered …* like any
other; an immediate statement is not logged, however it was entered.

There is **no correlation identifier**. `ISSUE_COMMAND_RESPONSE` carries a result code and nothing
to tie it to a particular request, so a debugger must keep one line outstanding at a time.

<a id="reading-back-the-debug-redirect"></a>
### 10.5 Reading back: the `DEBUG:` redirect

This is the part that is not visible in the message list, and it is how a debugger reads anything.

BR recognises a pseudo-file whose name begins `DEBUG:` (`isDebuggerPath`, `wbuser.cpp`). Opening
`DEBUG:<n>` yields a handle in the debugger range (`CONVERT_TO_DEBUGGER`, `IS_DEBUGGER_HANDLE` in
`basic.h`); writes to such a handle are routed by `wbname.cpp` to `writeDebuggerFile`, buffered,
and sent as `DEBUGGER_FILE_DATA` packets carrying the channel number and the bytes.

So a debugger reads by redirecting a command's output to itself:

```
LIST >DEBUG:1                  ! the program source
STATUS STACKS >DEBUG:2         ! the call stack
STATUS BREAKPOINTS >DEBUG:3    ! what is currently set
STATUS FILES >DEBUG:4
DEBUG INTERNAL MESSAGES >DEBUG:5
```

Redirection is supported by `LIST`, `STATUS`, `BREAK`, `DISPLAY`, `INDEX` and `DEBUG INTERNAL` —
the reading commands. The output is human-readable text; there is no structured form.

**Which socket it goes out on, because the name invites the wrong guess.** `DEBUG:` output goes
over **the debugger's own TCP/TLS socket** — `debuggerSSL` or `debuggerSocket`, the one
`DEBUG LISTEN` or `DEBUG CONNECT` opened, port 9555 by default and always on the loopback
interface. It does **not** travel the client/server link, it does **not** reach the Command
Console, and it has nothing to do with BR's embedded web server's port.

That is not a detail of implementation but a property to rely on: the write routing in
`wbname.cpp` is a chain of mutually exclusive branches — a client path (`@:`) goes out as
`WRITE_FILE`, a debugger handle goes to `writeDebuggerFile`, and only then does `UF_SCREEN` reach
the console. A `DEBUG:` handle takes the second branch and never the third, so redirecting a
command to `DEBUG:` **takes its output away from the screen** rather than copying it.

Two consequences follow, and both matter to anyone reading this to build something:

- **The debugger must be on the machine running the interpreter.** In client/server mode that is
  the server, not the user's workstation. `DEBUG LISTEN` binds there.
- **A `DEBUG:` redirect is invisible to anything attached to the client**, including the
  user-level channel of section 5. An assistant working through a user's client cannot read it,
  and should not try: it reads the same content by running the same commands **without** the
  redirect, so the output goes to the Command Console, where `SCROLLVIEW` and `HISTORY` reach it.
  `LIST`, `STATUS STACKS` and the rest all print there by default.

**Opening `DEBUG:<n>` does not require a debugger**, and is not refused when none is attached:
`CONVERT_TO_DEBUGGER` succeeds for any valid channel number. Writes are then dropped silently,
because `sendMessage` has no socket to use. So a program that redirects to `DEBUG:` with no
debugger attached loses that output altogether — it does not fall back to the screen.

**The packet.** `DEBUGGER_FILE_DATA` carries a 32-bit channel number and then the bytes, not
NUL-terminated, their length being the packet length − 12. One redirect may arrive as **several
packets**: BR buffers up to 2,000 bytes and sends a packet each time the buffer fills. For a
command, all of its packets have arrived by the time the next `ENTER_INPUT_MODE` does.

**The channel number is optional.** `DEBUG:` alone is channel 0 (`LIST 20 >DEBUG:` arrives on 0).
The number exists so that a debugger can tell apart output it asked for in different places.

**`DISPLAY <variable> >DEBUG:<n>` is a watch that does not stop.** Unlike `BREAK <variable>`, which
halts the program at each change, it lets the program run and streams one line to channel *n* for
every change it sees — the line and clause where the change was noticed, the variable, and the
new value:

```
line 00060:01, X, value = 2
```

It is the cheap way to follow a value through a loop.

**`STATUS STACKS >DEBUG:<n>`** includes `Current Line=<line>:<clause>`, which is how a debugger
learned where execution was before step stops reported it.

**Not everything the earlier document lists still works.** It gives `PRINT variable-name >DEBUG:`
as a way to read a value. That line is accepted, raises no error, and sends nothing to the
debugger. `PRINT` is an immediate statement, and the redirect above is a feature of the
reading commands. Read a value with `DISPLAY`, a watch, or a `PRINT` whose output reaches the
Command Console (and so the harness, or the screen log).

**Measured with a debugger attached, 2026-10-06**, because the sentence above was written from
reading and the interesting case is the attached one — a write to a debugger handle with nothing
attached is dropped by design, so a test without a debugger proves nothing. With an authenticated
debugger on the channel:

| Command | What arrived |
|---|---|
| `LIST >DEBUG:1` | one `DEBUGGER_FILE_DATA` packet, 1105 bytes, on channel 1 |
| `PRINT 42 >DEBUG:2` | nothing |

So the claim holds. Two further things the measurement turned up, both worth knowing:

- **`PRINT X >DEBUG:1` loads, and `PRINT X >CON:` does not.** The first is accepted as a statement
  and silently drops the redirect — the output goes to the screen — while the second is a load-time
  syntax error. So this is not a parser that swallows any trailing text: something recognises the
  `DEBUG:` form and then does nothing with it.
- **`brls` rejects what BR accepts**, reporting *this is not a statement* for the same line. The
  checker is right about the intent and BR is the lax one. It is left as it is deliberately: making
  BR refuse the line would be the honest answer, but `PRINT` has carried this laxity for far longer
  than the debugger channel has existed, and a program in the field that has such a line prints to
  the screen today and would stop running tomorrow. The disagreement is recorded here instead.

**Making it work would be a new language feature, not a repair.** The `>` redirect belongs to the
commands — `RUN >file`, `LIST >DEBUG:n` — and `PRINT` has no redirect syntax in BR at all. Adding
one is a different proposition from fixing a defect, and `PRINT` to the Command Console already
reaches the harness, the screen log and the screen itself.

<a id="the-debug-commands"></a>
### 10.6 The `DEBUG` commands

Commands that exist for the channel, typed at the console or sent by the debugger. The earlier document
lists the first four; the rest are later.

| Command | Does |
|---|---|
| `DEBUG LOG <file>` | writes a readable trace of the channel to a file: every message each way (`BR - ENTER_INPUT_MODE status=…`, `DEBUGGER - ISSUE_COMMAND …`) and every line the debugger submits. Replaces the file |
| `DEBUG LOG COMMANDS <file>` | writes only the lines the debugger submits, one per line, as received — **including immediate statements**, which BR's own log does not record. Written before the line is processed, so a line BR then refuses is in it too |
| `DEBUG LOG OFF` | closes either. Either also closes when the debugger disconnects |
| `DEBUG CONSOLE ON` / `OFF` | whether the console's prompt takes keyboard input while a debugger is attached (see *The shape of it*). `OFF` also hides the command console window on the client. Refused as a syntax error when no debugger is attached |
| `DEBUG STEP INTO`/`OVER` `CLAUSE`/`LINE` | sets the step mode and resumes. From a paused program use `GO STEP` first: `DEBUG STEP` does not accept the pause state and fails silently |
| `DEBUG CONNECT host[:port]`, `DEBUG LISTEN [port]` | open the channel (see *The shape of it*; authentication in section 8) |
| `DEBUG DISCONNECT` | closes the channel from BR's side |
| `DEBUG AUTH [COOKIE \| OFF \| TOKEN <hex>]` | how the next attach is authenticated; alone, reports the mode and where the token is |
| `DEBUG OBSERVE [port]`, `DEBUG OBSERVE OFF` | the observer — see below |
| `DEBUG SCREENLOG …` | the screen tee |
| `DEBUG INTERNAL …` | BR's internal diagnostics |
| `DEBUG PROFILE …` | the profiler |

**`DEBUG LOG COMMANDS` is the record of what a debugger did at the prompt.** BR's log stream records
commands as *Command entered …* but not immediate statements, whoever enters them; this file
records every line the debugger submitted, statements included. When an assistant is attached as
the debugger and the record matters, start it first:

```
DEBUG LOG COMMANDS context\scratch\aiaccess\debugger-lines.txt
```

It does not record what a person types at the console, only what arrives over the channel.

**One thing the earlier document promised is not implemented.** It says that while BR is waiting for input
from the editor, pressing Ctrl-A at the keyboard brings up a confirmation dialog, and confirming it
ends debugger input and terminates the connection. The code has no such escape: a console
blocked by `DEBUG CONSOLE OFF` waits for the debugger and does not read the keyboard at all. The
block ends only when the debugger sends `DEBUG CONSOLE ON` or disconnects.

<a id="stops-and-who-raises-them"></a>
### 10.7 Stops, and who raises them

**BR raises every stop. The debugger never polls for one.** All of the following happen inside the
interpreter and are pushed outward.

#### Line breakpoints

`BREAK <line>` creates a `BreakPointLine` on `t.curpcb->breakPointLine`. `checkbreakpoints`
(`run.cpp`) is called at line and clause boundaries during execution; on a match it calls
`debugBreakLineClause`, which sends `DEBUG_LINE_BREAK` with the line and clause, and returns true,
which is what stops the program.

#### Variable watches

`BREAK <variable>` resolves the name through `findVariable`, creates a `BreakPointVariable`, takes
a snapshot of the current value with `updateData`, and chains it onto
`t.curpcb->breakPointVariable`.

The same `checkbreakpoints` walks that list at every line and clause boundary:

```c
while (bv){
   if (!bv -> compareAsTracked(t.curpcb)){
      displayVariableInfo(...);                    /* work out what it became */
      bv -> updateData(t.curpcb);                  /* new snapshot */
      debugBreakVariable(bv -> getDictName(t.curpcb));
      ret = true;
      break;
   }
   bv = bv -> next;
}
```

`debugBreakVariable` (`debug.cpp`) is the only sender of `DEBUG_VARIABLE_BREAK` and has that one
caller. It is gated on a debugger being attached; with none, the same detection happens and the
result goes to the Command Console.

Three properties follow from this being a snapshot comparison rather than a write trap:

- **It is polled.** Cost is one comparison per watched variable per line or clause boundary.
- **A value that changes and changes back between two boundaries is never seen.**
- **The watch belongs to the program control block**, not to the session, so it follows the program
  it was set in.

#### The value

`DEBUG_VARIABLE_BREAK` carries only the **name**. The value was formerly computed solely on the
branch that had no debugger to send it to — `run.cpp` read `if (!isDebuggerActive())
displayVariableInfo(...)` — so an attached debugger was told that something changed and never what
to. That guard is gone; `displayVariableInfo` now runs either way, before `updateData` so the old
value is still there to compare against, and `displayVariableOutput` decides the destination: the
new `DEBUG_VARIABLE_CHANGED` (113) when a debugger is attached, the Command Console when not. The text is
the one the console already produced — line, clause, variable, subscript where it is an array, and
value — so there is one format rather than two. Every stop is also written to the log.

`DEBUG_VARIABLE_BREAK` is unchanged and still sent, so a debugger that has not been updated
behaves exactly as before.

<a id="syntax-errors-and-why-they-happen-mid-session"></a>
### 10.8 Syntax errors, and why they happen mid-session

A syntax error during a debugging run is routine rather than anomalous, because **BR is not
compile-then-run**: source is tokenised at the moment a line is submitted, and `ISSUE_COMMAND` is
that submission. Four ways it arises:

1. **Editing the program while it is loaded.** BR's editing model is typing numbered source lines
   at the Ready prompt, each parsed on entry. `00220 LET X = Y *` fails immediately. This is the
   case the message exists for.
2. **Immediate statements.** `PRINT X*` is compiled and run on the spot.
3. **Malformed commands.** `DEBUG AUTH BOGUS` returns 1006. Anything in the 900–1100 band counts —
   36 errors, including 1000 *unidentified source remaining* and 1001 *invalid use of reserved
   word* — and `command.cpp` sets its `synerr` flag from exactly that range.
4. **`EXECUTE` of a string built at run time.** The only one that happens with nobody typing: a
   program assembles a command and the assembled text is malformed. It is also why BR's
   restricted-session gate has to be a runtime check rather than a source scan.

**`SYNTAX_ERROR_INDENT` is misnamed.** `debugIndent` is called from the general `COMMAND_ERROR`
path in `command.cpp`, for **every** failed command, not only syntactic ones:

```c
COMMAND_ERROR:
   indent = 0;
   if (t.cmdline) {
      cp = skip_spaces(cp);
      indent = cp - t.cmdline;   /* error position */
      debugIndent(indent);
```

`synerr` is worked out afterwards and separately. So the message means *the last command failed,
and parsing stopped this many characters in*. The name describes what an editor does with it —
position the cursor — not what caused it.

Useful consequence for any automated client: a rejected command comes back with the error code in
`ISSUE_COMMAND_RESPONSE` **and** the character offset in `SYNTAX_ERROR_INDENT`, so it can point at
what it got wrong rather than guessing.

<a id="what-the-channel-does-not-carry"></a>
### 10.9 What the channel does not carry

One blind spot remains, and one that used to be here is closed.

**No Command Console content.** Nothing the program displays travels this channel. A debugger sees stops,
log events and whatever it redirects, but not the application's own output. `DEBUG SCREENLOG`
(the screen tee) or a harness screen dump is what supplies that.

**The stepping position — now closed.** A session stepped line by line formerly emitted only
`ENTER_INPUT_MODE status=7` per step, while the line itself went to the **Command Console**: a
debugger learned that stepping was happening but not where execution was, and had to ask after
every step. The step stop in `run.cpp` (at `DISPATCH`, beside `showCurrentLine`) now also calls
`debugBreakLineClause` with the line and clause it stopped at, so a step is reported exactly as a
breakpoint is: `DEBUG_LINE_BREAK`, then `ENTER_INPUT_MODE`.

**One report per stop.** A breakpoint hit is also a stop in step mode, so it reaches
`debugBreakLineClause` from both paths, and the breakpoint check itself could already report one
stop twice. `debugBreakLineClause` therefore drops a repeat of the same line and clause until BR
next reaches its prompt (`enterInputMode` clears it), which is where one stop ends. A debugger that
counted `DEBUG_LINE_BREAK` messages as breakpoint hits would have seen the duplicates before; it now
also sees a message for each step, which it can tell apart by the status on the `ENTER_INPUT_MODE`
that follows (7, `RUNSTAT_STEP`) and by there being no breakpoint at that line.

<a id="the-observer"></a>
### 10.10 The observer

`DEBUG OBSERVE [<port>]`, default port 9556, `DEBUG OBSERVE OFF` to detach. Loopback only, like the debugger channel it mirrors: it carries the same material, so a rule that did not apply to both would be the way around the one it did apply to.

An observer receives a copy of every packet BR sends the debugger and may send nothing back. It
holds no part of the programmer channel, cannot issue a command, and the session is unaffected by
whether it is attached, absent or has crashed. It authenticates exactly as the debugger does,
because it is shown exactly the same material.

The mirror is in `sendMessage`, before the debugger's own send, so the last packet BR tried to send
still reaches the observer when the debugger has gone. An observer that disconnects is reaped:
it is defined never to send, so anything readable on its socket means it has left.

This is not multi-client debugging. It exists so that something — a colleague, a log, an AI — can
watch a session without taking the channel, which admits only one debugger.

<a id="debugging-together-the-bridge"></a>
### 10.11 Debugging together: the bridge

A programmer at the console and an assistant attached as the debugger can work the same program:
the console is not blocked by attaching, so both can set breakpoints, step, resume and inspect.
Breakpoints belong to the program, so either sees what the other set (`STATUS BREAKPOINTS`), and
there is one execution point, so a stop is a stop for both.

An assistant works in turns, and the channel has to stay open between them.
`br/aiaccess/dbgbridge.py` holds it:

```
DEBUG LISTEN                                  ! at the BR console
python dbgbridge.py [--port 9555] [--dir <folder>] [--hours 8]
```

It attaches (TLS 1.3 and the token exchange, from `dbgauth.py`), then:

| File in `<dir>` (default `br/aiaccess/bridge`) | Holds |
|---|---|
| `events.log` | one numbered, timestamped line per event: `PROMPT status=… error=…`, `STOP line … clause …`, `CHANGED …`, `ACCEPTED`/`REFUSED`, `FAILED-AT offset …`, `OUTPUT DEBUG:n …`, and BR's log stream as `LOG`, which includes every command anyone enters (not immediate statements, which BR does not log) |
| `state.txt` | one line: attached, at the prompt, run status, last stop, anything outstanding |
| `out<n>.txt` | whatever a command redirected to `DEBUG:<n>` |
| `in.txt` + `in.rdy` | lines from the assistant — commands or immediate statements — one per line; the bridge takes and deletes them |

The bridge sends each line only when BR is at its prompt and the previous one has been answered,
because `ISSUE_COMMAND_RESPONSE` carries no identifier. That response means only that BR took the
line; whether it worked is the error code on the next `PROMPT`. Two lines are the
bridge's own: `!BREAK` sends `FORCE_BREAK`, and `!BYE` detaches, leaving BR running.

**Taking turns is protocol, not code.** A line the debugger sends while the programmer is part
way through typing one replaces it and clears the keyboard buffer (`exitInputMode`). So
the assistant says **"request complete"** when it has finished and the prompt is the programmer's;
typing while the assistant is active is at the programmer's own risk.

**`SYSTEM` is refused while a program is paused** (2108, *program is active*), for the debugger as for
anyone at the prompt: end the program first (`END`).

`br/aiaccess/dbgbridge_test.py` exercises it end to end: breakpoint, two steps with their positions,
a listing returned through `DEBUG:1`, a failing command's error and offset, `END` and `SYSTEM`.

#### Both channels at once

The debugger channel knows where execution is and cannot see the Command Console; the harness
channel (`harness-formats.json`) sees it — text, attributes, every field and control
with its value, grids and lists, a picture — and, under a grant, types as a person would, but does
not know where execution is. An assistant attached as the debugger uses both: a stop arrives on the
debugger channel, and the Command Console at that stop is read from the harness. It can also run a program
from the debugger and drive its screens as a user through the harness, which is how it tests a user
interface it has written.

**The grant rule.** An assistant attached as the debugger holds the programmer's authority, so it
may open the harness and issue keyboard grants through the debugger channel, as often as it needs:

```
LET X=MSG("harness",8733)      ! sent through the debugger: open the client channel
LET X=MSG("grant",600)         ! and give the keyboard, time boxed
```

It may **never** raise a grant over the harness channel itself: `GRANT` there is refused with
`ERR 8`, whoever asks. The harness can only ask what the grant is, or hand it back with `RELEASE`.
Every grant shows in the title bar and is logged as a security event, which reaches the debugger's
log stream too.

**What the harness replaces, and what it does not.** For anything that stays on the Command
Console — a
form, a report page, the state at a stop — a harness read is complete and better than
`DEBUG SCREENLOG`, which never carried fields and controls. It is a snapshot, though: output that
scrolls past between two reads is gone. Keep the screen log for programs that print a stream.

**Keys typed through the harness are console input.** At the prompt they type a line like any
other: a command, which BR logs as entered, so the debugger sees it, or an immediate statement,
which runs but is not logged.
The same turn-taking applies to both channels: "request complete" means the assistant has stopped
typing and the prompt is the programmer's. (The programmer never loses the keyboard: a grant lets
the assistant's keys in alongside theirs, it does not shut theirs out.)

**Where it breaks.** A modal dialog stops the client's event pump and with it the harness; the
debugger channel keeps working. Both channels accept only local connections (the debugger channel
always), so in client/server mode the assistant runs on the client's machine.

`br/aiaccess/dualchannel_test.py` verifies all of it: the debugger opens the harness; the harness is
refused `KEYS` without a grant and refused `GRANT` outright; the debugger's grant is honoured and
logged; a breakpoint stop is visible through the harness; a command typed through the harness is
seen entered by the debugger, and an immediate statement typed there runs unlogged; `RELEASE` ends the grant early, after which the harness's keys are refused again.

<a id="comparison-with-the-debug-adapter-protocol"></a>
### 10.12 Comparison with the Debug Adapter Protocol

DAP is what VS Code and most modern editors speak to debuggers. The comparison is more favourable
than the size of BR's message set suggests.

#### The shape is the same

DAP has *requests* (client to adapter), *responses* (correlated by sequence number) and *events*
(unsolicited, adapter to client). BR has exactly that division. So BR's unsolicited messages are
DAP's events, and the correspondence is direct:

| BR | DAP event |
|---|---|
| `DEBUG_LINE_BREAK` | the position of a `stopped` event; `reason: "breakpoint"`, or `"step"` when the `ENTER_INPUT_MODE` after it has status 7 and no breakpoint is set there |
| `DEBUG_VARIABLE_BREAK` + `DEBUG_VARIABLE_CHANGED` | `stopped`, `reason: "data breakpoint"` |
| `DEBUG_FUNCTION_BREAK` | `stopped`, `reason: "function breakpoint"` |
| `ENTER_INPUT_MODE` status 7 / 2 | `stopped`, `reason: "step"` / `"pause"` |
| `DEBUG_MESSAGE_LOG`, `DEBUGGER_FILE_DATA` | `output` |
| `TERMINATE_CONNECTION` | `terminated` / `exited` |
| `SYNTAX_ERROR_INDENT` | none — see below |

Inbound, DAP's `pause` is `FORCE_BREAK`, and `continue`, `next`, `stepIn`, `setBreakpoints`,
`setDataBreakpoints` and `evaluate` all collapse into `ISSUE_COMMAND` carrying `GO`,
`DEBUG STEP OVER LINE`, `BREAK 220`, `BREAK X` and `PRINT X*2`.

#### Where they differ

**One generic request against forty typed ones.** BR's protocol is a *remote console*; DAP is a
*structured debugger API*. An adapter is buildable, but it works by issuing commands and parsing
text rather than calling typed methods.

**No structured variable enumeration.** DAP's variables pane is built on `scopes` and `variables`
returning typed, expandable trees. BR has no protocol message for it and no command that lists
variables with values; you evaluate one at a time with an immediate `PRINT`. Hover-to-inspect would
work. The variables pane would have to be synthesised or omitted.

**No correlation ids, no capability negotiation.** DAP carries `seq`/`request_seq` so requests can
be pipelined, and opens with `initialize`, where an adapter declares what it supports. BR has
neither — though the authentication challenge already carries a protocol version field, which is
the natural hook if a capability exchange is ever wanted.

**The call stack is obtainable, but as text.** `STATUS STACKS >DEBUG:n` produces it, as do
`STATUS BREAKPOINTS`, `STATUS DIMS` and `STATUS LIBRARY`. A `stackTrace` response can be assembled
from that — brittle, because it means parsing prose, but real.

**`SYNTAX_ERROR_INDENT` has no counterpart** because DAP assumes the source was compiled elsewhere
and the debuggee never parses anything handed to it. There is no DAP concept of editing a running
program, which BR does routinely.

#### If an adapter were to be built

The transport, the stop events and the output stream already line up, and the authentication
gives it a properly secured socket, which most debug adapters do not have. BR would need to **Add a machine-readable variable inspection**, so the variables pane does not depend on parsing
   `PRINT` output — which does not reach the channel anyway (see *Reading back*).

<a id="message-reference"></a>
### 10.13 Message reference

Constants are in `basic.h`. Ids 1–3 are sent by the debugger, 101–113 by BR, 200 by either. Every
packet is `length` (32-bit, counting itself) + `id` (32-bit) + the data below; integers are 32-bit
big endian; strings are not NUL-terminated and run to the end of the packet. `int` below means a
32-bit integer.

| Id | Name | Direction | Data |
|---|---|---|---|
| 1 | `FORCE_BREAK` | debugger → BR | none |
| 2 | `ISSUE_COMMAND` | debugger → BR | the line (string) |
| 3 | `DEBUG_AUTH_RESPONSE` | debugger → BR | the peer's proof and nonce — see section 8 |
| 101 | `FORCE_BREAK_RESPONSE` | BR → debugger | none |
| 102 | `ENTER_INPUT_MODE` | BR → debugger | int run status, int error code |
| 103 | `ISSUE_COMMAND_RESPONSE` | BR → debugger | int result: 0 issued, else the error |
| 104 | `DEBUGGER_FILE_DATA` | BR → debugger | int channel, then the bytes |
| 105 | `DEBUG_VARIABLE_BREAK` | BR → debugger | the variable's name (string) |
| 106 | `DEBUG_FUNCTION_BREAK` | BR → debugger | the function's name (string) |
| 107 | `DEBUG_LINE_BREAK` | BR → debugger | int line, int clause |
| 108 | `DEBUG_BEGIN_BREAK` | BR → debugger | none |
| 109 | `SYNTAX_ERROR_INDENT` | BR → debugger | int offset into the last line where processing stopped |
| 110 | `DEBUG_MESSAGE_LOG` | BR → debugger | int source (1 BR, 2 user program), int level, the text |
| 111 | `DEBUG_AUTH_CHALLENGE` | BR → debugger | int protocol version, BR's nonce |
| 112 | `DEBUG_AUTH_CONFIRM` | BR → debugger | BR's proof |
| 113 | `DEBUG_VARIABLE_CHANGED` | BR → debugger | the line, clause, variable and new value, as text |
| 114 | `DEBUG_AUTH_REFUSED` | BR → debugger | one byte of reason; the detail is in BR's log |
| 200 | `TERMINATE_CONNECTION` | either | none |

Principal source files: `br/brs/debug.cpp` (the channel), `br/brs/run.cpp` (`checkbreakpoints` and
the stops), `br/brs/command.cpp` (command entry and `COMMAND_ERROR`), `br/brs/commandc.cpp`
(the `BREAK` command), `br/brs/wbname.cpp` and `br/brs/wbuser.cpp` (the `DEBUG:` redirect),
`br/brs/basic.h` (constants and handle conversion).

---
