# BR application data model (file schemas)

Data dictionary for **3** BR data files, parsed from `filelay`. Dual purpose:
an LLM uses this to know what files/fields exist and how they are keyed when writing BR
code; an LSP uses field names + FORM types to validate/complete `OPEN`/`READ…USING` and
to build correct key expressions.

Per file: the data path, record length, key indexes (with their key-file name and composing fields — the
order you concatenate values to build a `KEY=` lookup), and every field with its FORM type.

> Each file section carries an `<a id="…">` anchor (its file name). For cheap per-file
> retrieval, `data-model-index.json` maps every file to its 1-based inclusive line range —
> load just that slice instead of the whole document. Regenerate the index with
> `tools/gen_datamodel_index.exe` after (re)generating or hand-editing this file.

| File | Recl | Fields | Keys |
|---|---|---|---|
| [`comments`](#comments) | ? | 4 | 0 |
| [`customer`](#customer) | 280 | 40 | 1 |
| [`logfile`](#logfile) | ? | 6 | 1 |

<a id="comments"></a>
## comments

- **Data file:** `data\comments.ind` (field prefix `C_`) · **recl** ?

| Field | Type | Pos | Description |
|---|---|---|---|
| `NAME$` | V 40 | — | Name |
| `COMMENT$` | V 255 | — | User Name |
| `DATE` | BH 3 | — | Date |
| `TIME$` | V 8 | — | Time |

<a id="customer"></a>
## customer

- **Data file:** `data\customer` (field prefix `RCU_`) · **recl** 280
- **Keys:**
  - `key` (`data\customer.key`) = `CUSTOMER` + `RCD_TYPE` + `DESTINATION`

| Field | Type | Pos | Description |
|---|---|---|---|
| `CUSTOMER$` | C 8 | 1-8 | Customer Number |
| `RCD_TYPE$` | C 2 | 9-10 | Record Type (BT or ST) |
| `DESTINATION$` | C 9 | 11-19 | Destination Code |
| `CUST_NAME$` | C 30 | 20-49 | Customer Name |
| `CUST_ADDRESS_1$` | C 30 | 50-79 | Customer Address 1 |
| `CUST_ADDRESS_2$` | C 30 | 80-109 | Customer Address 2 |
| `CUST_CITY$` | C 18 | 110-127 | Customer City |
| `CUST_STATE$` | C 3 | 128-130 | Customer State |
| `CUST_ZIP$` | C 9 | 131-139 | Customer Postal Code |
| `CUST_PHONE$` | C 10 | 140-149 | Customer Phone |
| `COMMUN$` | C 4 | 150-153 | Communication Code |
| `TERR$` | C 3 | 154-156 | Territory |
| `CONTACT$` | C 20 | 157-176 | Contact |
| `TERMS$` | C 2 | 177-178 | Terms |
| `TAX_STATUS$` | C 1 | 179-179 | Tax Status |
| `SEND$` | C 1 | 180-180 | Send Statement |
| `LATE_CHARGE$` | C 1 | 181-181 | Late Charge |
| `CARRIER$` | C 4 | 182-185 | Carrier |
| `UNUSED$` | C 5 | 186-190 | Unused |
| `TRANS_TIME$` | C 6 | 191-196 | Transportation Time |
| `PPD/COL$` | C 1 | 197-197 | Prepaid/Collect |
| `CLASS_CODE` | BH 1 | 198-198 | Class Code |
| `PRICE_CODE` | BH 1 | 199-199 | Price Code |
| `SALESMAN` | BH 2 | 200-201 | Salesman Number |
| `COMPANY` | BH 1 | 202-202 | Company Number |
| `TAX_JURIS` | BH 2 | 203-204 | Tax Jurisdiction |
| `CURRENCY` | BH 1 | 205-205 | Currency Number |
| `CREDIT_LIMIT` | BH 4 | 206-209 | Credit Limit |
| `DISCOUNT` | BH 2.2 | 210-211 | Trade Discount |
| `INVOICE_DATE` | BH 3 | 212-214 | Date of Last Invoice |
| `ORDER_DATE` | BH 3 | 215-217 | Date of Last Order |
| `PAYMENT_DATE` | BH 3 | 218-220 | Date of Last Payment |
| `LAST_TRANSMIT` | BH 3 | 221-223 | Date of Last Transmission |
| `BALANCE` | PD 6.2 | 224-229 | Current A/R Balance |
| `OPEN_ORDERS` | PD 6.2 | 230-235 | Current Open Orders |
| `SALES_MTD` | PD 6.2 | 236-241 | Sales Dollars MTD |
| `SALES_YTD` | PD 6.2 | 242-247 | Sales Dollars YTD |
| `PROFIT_YTD` | PD 6.2 | 248-253 | Profit Ytd |
| `ORD_MTD` | BH 3 | 254-256 | Number of Shipments MTD |
| `ORD_YTD` | BH 3 | 257-259 | Number of Shipments YTD |

<a id="logfile"></a>
## logfile

- **Data file:** `data\logfile.ind` (field prefix `LOG_`) · **recl** ?
- **Keys:**
  - `idx` (`data\logfile.idx`) = `DATE` + `TIME`

| Field | Type | Pos | Description |
|---|---|---|---|
| `PROGRAM$` | V 40 | — | Program |
| `USERNAME$` | V 65 | — | User Name |
| `SESSION$` | V 6 | — | Wsid and Session |
| `DATE` | BH 3 | — | Date |
| `TIME$` | V 8 | — | Time |
| `MESSAGE$` | V 255 | — | Log Message |
