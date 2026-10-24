#!/usr/bin/env python3
"""Phase 0: classify every .md file in context/br_tree into the new taxonomy.
Emits MANIFEST.csv (old_path,new_path,title,category,subcategory,kind,status,confidence)
plus a summary and a low-confidence review list. Moves nothing."""
import os, csv, re, sys
from pathlib import Path

ROOT = Path(sys.executable if getattr(sys, "frozen", False) else __file__).resolve().parent.parent   # context/br_tree
SRC_DIRS = ["advanced-features","commands","context","data_operations","error-handling",
            "examples","file-operations","flow_and_branching","libraries-procedures",
            "printing-reporting","screen-operations","screenio-library","statements"]

# ---- destination path constants -------------------------------------------------
CONF_DIR="00-configuration"; CONF_DIRECTIVES=f"{CONF_DIR}/config-directives"
CONF_CS=f"{CONF_DIR}/client-server"; CONF_PLAT=f"{CONF_DIR}/platform"
CONF_ENV=f"{CONF_DIR}/environment"; CONF_INSTALL=f"{CONF_DIR}/installation-tooling"
CONF_SERIAL=f"{CONF_DIR}/serial-comm"
LANG="10-language"; L_SYNTAX=f"{LANG}/syntax"
L_UDF=f"{LANG}/flow-control/functions-udf"; L_FLOW=f"{LANG}/flow-control/other-flow"
L_DECL=f"{LANG}/data-manipulation/declaration"; L_ASSIGN=f"{LANG}/data-manipulation/assignment"
L_SYSFN=f"{LANG}/data-manipulation/system-functions"; L_COND=f"{LANG}/data-manipulation/conditionals"
L_EXPR=f"{LANG}/data-manipulation/expressions"; L_TYPES=f"{LANG}/data-manipulation/data-types"
SCR="20-io-screen"; S_IO=f"{SCR}/input-output"; S_FLD=f"{SCR}/fields-attributes"
S_CTL=f"{SCR}/controls"; S_WIN=f"{SCR}/windows-cursor"
FIL="30-io-file"; F_STMT=f"{FIL}/statements"; F_FORM=f"{FIL}/form-spec"
F_KEYS=f"{FIL}/keys-indexes"; F_MODEL=f"{FIL}/file-model"
PRT="40-io-printing"; P_STMT=f"{PRT}/statements"; P_PCL=f"{PRT}/pcl-pdf"; P_SORT=f"{PRT}/sort"
LIB="50-libraries"; LIB_FAC=f"{LIB}/library-facility"; LIB_FN=f"{LIB}/fnsnap"; LIB_SIO=f"{LIB}/screenio"
CMD="70-commands"; C_PROG=f"{CMD}/program-management"; C_FILE=f"{CMD}/file-directory"
C_INFO=f"{CMD}/information"; C_EDIT=f"{CMD}/editing"
REF="90-reference"; R_ERR=f"{REF}/error-codes"; R_KEYS=f"{REF}/keyboard-shortcuts"
R_LIM=f"{REF}/limits-constants"; R_STUB=f"{REF}/glossary-stubs"
EXAMPLES="99-examples"

def kind_for(dest):
    if dest==R_ERR: return "error-code"
    if dest.startswith(CMD): return "command"
    if dest.startswith(CONF_DIR): return "config-directive"
    if dest==R_KEYS: return "shortcut"
    if dest==R_LIM: return "constant"
    if dest==R_STUB: return "concept"
    if dest==EXAMPLES: return "tutorial"
    if dest in (L_SYSFN,LIB_FN): return "function"
    if dest in (L_TYPES,): return "datatype"
    return "statement"

# ---- explicit per-basename overrides (basename without .md) --------------------
OVR = {}
def add(dest, *names):
    for n in names: OVR[n]=dest

# data_operations
add(L_DECL,"Arrays","DIM","MAT","Mat_Grouping","Option_(Statement)","Option_Base_0")
add(L_ASSIGN,"Append","Assignment_Operations","Assignment_Statements","CSV2MAT","Clipboard",
    "Concatenation","DATA","Delete_(substring)","INSERT","Insert_(substring)","LET","Left",
    "Lower","Modify","Prepend","Restore_Data","STR2MAT","Internal_Data_Table_Statements")
add(L_EXPR,"Binary_operations","Complex_Logical_Operations","Numeric_expression","OR","AND",
    "Operation_Precedence","Clause","Expressions")
add(L_TYPES,"Fixed_Point_Number","Floating_Point_Numbers","Hexadecimal","Null","Numeric",
    "Numeric_constant")
# flow_and_branching
add(L_FLOW,"Branching_Statements","Control_statements","DO","DO_LOOP","END","EXIT_DO",
    "Ending_Programs_Statements","Exit_After","FOR","FOR_NEXT","GOTO","LOOP","Line-ref",
    "Loop_Performance","Loop_Statements","Nested_Control_Structures","Next_(Statement)",
    "ON_GOTO","On","PAUSE")
add(L_COND,"IF","ELSE","END_IF")
add(L_SYNTAX,"Line_Label","Line_Label_(program)","Comment","Line_Continuation",
    "Miscellaneous_Statements","Multiple_statements","Line_Number","Program","Labels")
add(R_STUB,"None")
# statements/Functions overview
add(L_UDF,"Functions","DEF","END_DEF","FNEND","Comparison_of_User-Defined_Function_Features",
    "Local_variable","Line_Label_(procedure)","Paragraph_labels")
# libraries-procedures
add(LIB_FAC,"Library_(statement)","Library_Facility","Library_function","Library_Functions",
    "Release_(library)")
add(LIB_SIO,"ScreenIO","ScreenIO_Library","Lexi","PhpIO")
add(C_PROG,"CHAIN","CLEAR","PROC","Procedure_Commands","Procedure_files",
    "Program_Management_Commands")
add(C_FILE,"CHDIR")
add(C_INFO,"ECHO")
add(S_CTL,"Alert")
add(CONF_INSTALL,"Color.exe","MyEdit_(BR_Edition)","Notepad++")
add(EXAMPLES,"Libraries_Tutorial")
# commands dir — functions
for n in ["ABS","ATN","CEIL","CFORM$","CHR$","CNT","CNVRT$","CODE","CURTAB","DATE$","DATE",
    "DATE_(Internal_Function)","DAYS","DIDX","AIDX","ENV$","ERR","EXISTS","EXP","FILENUM",
    "FILE_(internal_function)","FP","FREESP","HELP$","HEX$","INF","INT","IP","KPS","KSTAT$",
    "LEN","LINE","LINES","LINESPP","LOG","LOGIN_NAME$","LPAD$","LTRM$","LWRC$","MAX$","MAX",
    "MIN$","MIN","MOD","MSG$","NEXT_(Internal_Function)","NXTCOL","NXTFLD","NXTROW","ORD",
    "PI","PIC$","POS"]:
    add(L_SYSFN,n)
# commands dir — commands
add(C_PROG,"GO","Go_End","LIST","LOAD","MERGE","EXECUTE")
add(C_FILE,"Dir_option","Drop_options","Free_option","Directory_Management_Commands")
add(C_INFO,"Command_Console","Command_line","DEBUG_STR","Date_(Command)","Display_(Command)",
    "Information_Commands","Increment","BELL","MSG","PRINTER_LIST","PROCIN","PROGRAM$")
add(C_EDIT,"Editing_Commands")
# commands dir — shortcuts
for n in ["Ctrl+","Ctrl+A","Ctrl+Right_Bracket","Ctrl+Shift+Tab","Ctrl+Tab","Ctrl+Y","Ctrl-A","Help_Key"]:
    add(R_KEYS,n)
add(R_LIM,"3.14159265358979")
add(S_WIN,"CMDKEY","Col","ECOL","Control_Keys_and_Predefined_Functions","Control_keys")
add(C_PROG,"Break_(Command)")
add(F_MODEL,"ABSOLUTE","LINKED","SEQUENTIAL","Key_file",".BR",".BAK",".$$$")
# context dir
add(CONF_ENV,"Environmental_variables")
add(CONF_DIRECTIVES,"BASE","Copies=","Collate_Native","Corners","INVP","Icon")
add(CONF_CS,"BRSERVER.DAT")
# screenio-library handled above

# ---- keyword rules per source dir ---------------------------------------------
def is_tutorial(n):
    return bool(re.search(r'(Tutorial|Fast_Track|Chapter_|Challenge_|Prerequisites|Mat_for_Beginners|Config_for_Beginners)', n))
def is_disambig(n):
    return "(disambiguation)" in n.lower() or "(Disambiguation)" in n
def is_singlechar(n):
    return len(n)<=2 and not n.isdigit() or n in ("9","GL","DB","BH","BL","GF","PD","RD","DT")
def is_versionnum(n):
    return bool(re.fullmatch(r'\d+(\.\d+)?[a-zA-Z]*', n)) or bool(re.fullmatch(r'[\d,]+', n)) \
        or bool(re.match(r'\d+\.\d+[A-Za-z]', n)) or "E+3" in n or n.replace(",","").isdigit()

def rule_screen(n):
    if is_tutorial(n): return EXAMPLES,"med"
    if is_disambig(n): return R_STUB,"high"
    if re.fullmatch(r'\d+(\.\d+)?[a-z]*', n) or re.fullmatch(r'\d+', n): return R_LIM,"med"
    if re.search(r'(CONFIG_GUI|_\(Config\)|OPTION_\(Config\))',n): return CONF_DIRECTIVES,"high"
    if re.search(r'(INPUT|RINPUT|_FIELDS|_SELECT|Print_Fields|ENTER_CRLF)',n): return S_IO,"high"
    if re.search(r'(Button|Check_Box|Checkbox|Radio|Grid|Date_Picker|Display_Menu|Textbox|List)',n): return S_CTL,"high"
    if re.search(r'(FMT|PIC|COLOR|FONT|3D_FIELDS|Attribute|Format_Spec|Border|Monochrome|CAPTION|CELL|DATE\(|FILTER|Fields|HTML_Color|DISPLAYED_ORDER|AUTO|^ALL$|FREE$|CHG)',n): return S_FLD,"med"
    if re.search(r'(WINDOW|window|CUR|Keyboard|Control_key|GUIMODE|NOMAXIMIZE|Help|HELP|Screen_Open|Screen_Operations)',n): return S_WIN,"med"
    if len(n)<=2: return R_STUB,"low"
    return S_FLD,"low"

def rule_file(n):
    if is_tutorial(n): return EXAMPLES,"med"
    if is_disambig(n): return R_STUB,"high"
    if n in ("DATABITS",): return CONF_SERIAL,"high"
    if re.fullmatch(r'\d+\.\d+[a-zA-Z]*', n): return R_LIM,"med"
    if re.search(r'(FORM|FORMAT|form_spec|Form_spec|Numeric_form|Internal_form|Floating_point_form)',n): return F_FORM,"high"
    if re.search(r'(KEY|INDEX|Index|DUPREC|Dup|Badkeys|LISTDUPKEYS|Reindex|REORG|Anchor|KEYED|KEYONLY)',n): return F_KEYS,"high"
    if re.search(r'(Lock|LOCKED|PROTECT|Share|Reserved|EXTERNAL|External|Internal|internal|Computer_file|File_number|EOL|Differences)',n): return F_MODEL,"med"
    if re.search(r'(OPEN|CLOSE|READ|REWRITE|WRITE|Delete|Read|REC=|POS=|REORG|Communication|Processing_Statement|Management_Commands|File_Browser|Header|LREC|Name|Pos_Parameter|Positional|Input_Parameter|FILE\$|FILENAMES|OS_FILENAME|Drop|Copy|Free)',n): return F_STMT,"med"
    if len(n)<=2: return R_STUB,"low"
    if re.search(r'FnSnap',n): return LIB_FN,"high"
    return F_STMT,"low"

def rule_print(n):
    if is_tutorial(n): return EXAMPLES,"med"
    if re.fullmatch(r'\d+(\.\d+)?', n): return R_LIM,"med"
    if re.search(r'(SPOOL|PRINTER\.SYS|BRSpool|PDF_READER|MAX_SORT_MEMORY|PRINTER\.md|Multi-spooled|Direct_Printing|Connecting)',n): return CONF_DIR+"/config-directives","high"
    if re.search(r'(SORT|Nosort|AIDX|DIDX)',n): return P_SORT,"high"
    if re.search(r'(PCL|PDF|PJL|PNG|Barcode|Picture|PIC$|Export)',n): return P_PCL,"med"
    if re.search(r'(PRINT|PAGEOFLOW|Newpage|Border|Form_feed|Line_Feed|CR$|COPY|COLLATE|Reset|Initialization|Facility|Displaying)',n): return P_STMT,"med"
    return P_STMT,"low"

def rule_adv(n):   # advanced-features: mostly configuration
    if is_tutorial(n): return EXAMPLES,"med"
    if is_versionnum(n) or re.fullmatch(r'[\d,]+',n) or "Quintillion" in n or "E+3" in n: return R_LIM,"med"
    if re.search(r'(BRServer|BRClient|Client_Server|Reconnect|Keepalive|HTTP=CLIENT|wbserver|BRLISTENER|wbserver)',n): return CONF_CS,"high"
    if re.search(r'(Linux|MAC|SCO|Windows|browser|Br_in_a_browser|BR32|wb32|Executable_version|Backward_Comp)',n): return CONF_PLAT,"med"
    if re.search(r'(\.exe|\.dll|\.DLL|Setup|INNO|NSIS|Dotnetfx|ODBC|REGCLEAN|Regclean|Installing|PDFLIB|Pdflib|Pemnet|PEM_File|Brconvert|BRODBC|Profiler|CURL|Printlocks|CheckSerial)',n): return CONF_INSTALL,"med"
    if re.search(r'(BAUD|PARITY|DATABITS|Com$|Com\.)',n): return CONF_SERIAL,"high"
    if re.search(r'(env|ENV|DRIVE|ONQ|ONQPATH|Client_Current_Dir|Registry|Host|Public|Private|@Login|LOGIN)',n): return CONF_ENV,"med"
    if re.search(r'(Decrypt\$|Encrypt\$|Encryption)',n): return L_SYSFN,"high"
    if re.search(r'(Expressions)',n): return L_EXPR,"high"
    if re.search(r'(DT|DIMONLY)',n): return L_DECL,"med"
    if re.search(r'(Webinar|Conference|Advanced_Computer|Main_Page|Business_Rules!|Round_Table|Common_Categories|BR_Reference|Group)',n): return R_STUB,"med"
    if re.search(r'(Config|CONFIG|OPTION|BRConfig|CHAINDFLT|COLLATE|BASEYEAR|MAXRECALL|LOGGING|INDENT|INIT|EDIT|EDITOR|KEYBOARD|CONSOLE|FORCE_VISIBILITY|FieldBreak|Filter_Delimiters|Include|Decimal|Font|Execute_|Insert_|Break_|Picture_|Object|READY_mode|DATABASE|APPLICATION_NAME|Double_Click|External_Editor|Built-In_Text|Executive_Commands|Mixed|Json|PHP|Dll|RD$|Labels)',n): return CONF_DIRECTIVES,"low"
    return CONF_DIRECTIVES,"low"

RULES={"screen-operations":rule_screen,"file-operations":rule_file,
       "printing-reporting":rule_print,"advanced-features":rule_adv}

def read_title(p):
    try:
        for line in p.read_text(encoding="utf-8",errors="replace").splitlines()[:6]:
            m=re.match(r'title:\s*(.+)',line.strip())
            if m: return m.group(1).strip()
    except Exception: pass
    return p.stem

def classify(src_dir,name):
    base=name[:-3]
    if src_dir=="error-handling": return R_ERR,"high"
    if src_dir=="examples": return EXAMPLES,"high"
    if src_dir=="screenio-library": return LIB_SIO,"high"
    if base in OVR: return OVR[base],"high"
    if base.startswith("FnSnap"): return LIB_FN,"high"
    if src_dir in RULES: return RULES[src_dir](base)
    # remaining small dirs already covered by OVR; default by dir
    defaults={"data_operations":L_ASSIGN,"flow_and_branching":L_FLOW,"statements":L_SYNTAX,
              "libraries-procedures":LIB_FAC,"commands":C_INFO,"context":CONF_DIRECTIVES}
    return defaults.get(src_dir,R_STUB),"low"

rows=[]
for d in SRC_DIRS:
    dp=ROOT/d
    if not dp.is_dir(): continue
    for f in sorted(dp.glob("*.md")):
        dest,conf=classify(d,f.name)
        status="duplicate" if (f.name.startswith("FnSnap_") and not f.name.startswith("FnSnap__")) else "ok"
        rows.append({"old_path":f"{d}/{f.name}","new_path":f"{dest}/{f.name}",
                     "title":read_title(f),"category":dest.split('/')[0],
                     "subcategory":dest,"kind":kind_for(dest),"status":status,"confidence":conf})

out=ROOT/"_migrate"/"MANIFEST.csv"
with out.open("w",newline="",encoding="utf-8") as fh:
    w=csv.DictWriter(fh,fieldnames=["old_path","new_path","title","category","subcategory","kind","status","confidence"])
    w.writeheader(); w.writerows(rows)

# summary
from collections import Counter
cat=Counter(r["category"] for r in rows)
print(f"TOTAL {len(rows)} files")
for k in sorted(cat): print(f"  {k:20} {cat[k]}")
low=[r for r in rows if r["confidence"]=="low"]
print(f"\nLOW-CONFIDENCE: {len(low)}")
for r in low: print(f"  {r['old_path']:55} -> {r['subcategory']}")
