Impostazione e script helper per usare openvasreporting nel creare report di OpenVAS.

---

# Installazione
Scarico gli strumenti

```
git clone git@github.com:mbonfiglio-mmul/OpenVAS.Reports.git
cd OpenVAS.Reports
git submodule init
git submodule update
```

Creo ambiente virtuale python3

```
virtualenv3 virtualenv/
```

Attivo ambiente virtuale

```
source virtualenv/bin/activate
```

Aggiorno PIP (si sa mai... :-)

```
pip install -U pip
```

Installo openvasreport nell'ambiente virtuale (attenzione allo slash finale, è importante)

```
pip install -r openvasreporting/
```

E' compresa un'utili perl per la manipolazione degli XML; usa XML::LibXML, che deve essere quindi
presente nel sistema.

---

# Uso
I report che vogliamo usare saranno depositati in XML.
In caso di mancanza di hostname rilevati (per reverese DNS errato, per esempio),
lo script `utils/search_and_add_hostname.plx` può essere usato per inserirli.
A fronte di un file CSV

```
IP_1,"nome host1"
IP_2,"nome host2"
[...]
```

Lo script
- carica IP e relativi hostname in memoria
- agli hostname prepone un asterisco, per distinguere quelli inseriti da quelli rilevati
- legge dallo standard input il file XML originale di OpenVAS (e lo carica in memoria)
- cerca i campi hostname vuoti
- cerca l'IP tra quelli caricati in memoria
- riempie il campo
- se mancante, aggiunge il dettaglio dell'hostname a quelli legati all'host
- scrive il risultato nello standar output (pretty-printed)

Quindi, preparato il file di IP e Host (`XML/hosts.list.csv`), per ogni XML prodotto da 
OpenVAS (`~/Downloads/report-7ca3c334-f40c-431c-9fa6-e44f4083bd66.xml`) è possibile produrne uno 
con l'aggiunta degli hostname (`XML/Day.xml`) sfruttando le redirezioni con il seguente comando :

```
utils/search_and_add_hostname.plx XML/hosts.list.csv <~/Download/report-7ca3c334-f40c-431c-9fa6-e44f4083bd66.xml >XML/Day.xml
```

I messaggi di controllo sono inviati all standard error:

```
Reading "XML/hosts.list.csv"...
Found 67 hosts.
Reading stdin into memory...
Read 7922 lines.
Done. Have a good day!
```
Una volta preparati tutti gli XML nella cartella, basta lanciare lo script `make_report.sh`
per generare un report di ogni tipo disponibile (csv, xlsx, docx) dagli XML.

In alternativa, piazzarsi nella cartella `opevasreporting` e invocare il modulo
python direttamente

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

