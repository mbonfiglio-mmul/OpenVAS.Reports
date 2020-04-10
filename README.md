Settings and scripts helper to user (a fork of) openvasreporting fo generating OpenVAS reports.

---

# Prerequisites

Needed on system:
- git
- python3

Optional, but raccomended:
- python3 virtualenv

Needed only for perl utility:
- perl
- libXML module


# Installation

```
$ git clone git@github.com:mmul-it/openvas.git
$ cd openvas/reports
$ git submodule init
$ git submodule update
```

If installed, initialize virtualenv...

```
$ virtualenv3 virtualenv/
```

... and activate it

```
$ source virtualenv/bin/activate
```

Update PIP (just to be sure)

```
$ pip install -U pip
```

Install opevasreporting from local dir with all dependencies
(the final `/` is meaningful)

```
pip install -r openvasreporting/
```

---

# Use
The report must be pulled from OpenVAS/GreenBone in xml.
They can be put in `input_xml` to be analyzed.

If hostnames are missing (no reverse DNS, for example), and you want
to add them, the perl utility script is there for you.
Prepare a CSV with IP and relative hostname:

```
IP_1,"hostname_1"
IP_2,"hostname_2"
[...]
```

The script will:
- load IP and hostname in memory;
- put a `* ` before the hostname (so you'll know wich hostname were found and which weren't)
- read from stdinput the OpenVAS XML, validate and keep in memory
- look for empty hostname fields
- search the IP for hostname; if found, fill the field
- if missing, adds this host detail
- write to stadndard output (pretty-printed)

Example:
With IP-hostname file `hosts.list.csv`, fill empty hosntame fields of 
OpenVAS `report-7ca3c334-f40c-431c-9fa6-e44f4083bd66.xml` and save the
result in `XML/report.xml` (with redirections):

```
utils/search_and_add_hostname.plx hosts.list.csv <report-7ca3c334-f40c-431c-9fa6-e44f4083bd66.xml >XML/report.xml
```

Control message are wrote to standard error

```
Reading "hosts.list.csv"...
Found 67 hosts.
Reading stdin into memory...
Read 7922 lines.
Done. Have a good day!
```

To generate the reports from XML files, just launch `reports.sh` script.
This will generate a **single report** of each format `openvasreporting` can (csv, xlsx, docx)
from **all** the xml in `input_xml`.

If you need more control, launch the tool itself: from his directory `opevasreporting`
with python

```
> python -m openvasreporting --help
usage: openvasreporting [-h] -i [INPUT_FILES [INPUT_FILES ...]] [-o OUTPUT_FILE] [-l MIN_LVL] [-f FILETYPE] [-t TEMPLATE]

OpenVAS report converter

optional arguments:
  -h, --help            show this help message and exit
  -i [INPUT_FILES [INPUT_FILES ...]], --input [INPUT_FILES [INPUT_FILES ...]]
                        OpenVAS XML reports
  -o OUTPUT_FILE, --output OUTPUT_FILE
                        Output file, no extension
  -l MIN_LVL, --level MIN_LVL
                        Minimal level (c, h, m, l, n)
  -f FILETYPE, --format FILETYPE
                        Output format (xlsx)
  -t TEMPLATE, --template TEMPLATE
                        Template file for docx export
```
