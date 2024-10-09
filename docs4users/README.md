# MkDocs

[MkDocs](https://www.mkdocs.org/) è un sistema che permette di generare pagine **HTML**
statiche a partire da file [MarkDown](https://www.markdownguide.org/) e il file di
configurazione `mkdocs.yml`, consentendo alla documentazione di essere accessibile
tramite la piattaforma di distribuzione ReadTheDocs.

## Prerequisiti

È necessario avere **python** installato, si consiglia anche l'installazione di un
sistema di virtualizzazione dell'ambiente python
([pipenv](https://pypi.org/project/pipenv/) o similare).

## Primi passi

MkDocs è un pacchetto python, installare i prerequisiti tramite:

    pipenv install -r requirements.txt

o se non si usa un ambiente virtuale:

    pip install -r requirements.txt

Per iniziare modificare il file `mkdocs.yml` secondo le proprie necessità, specialmente
le variabili site_name, repo_url, repo_name e la configurazione del page tree tramite la
variabile nav. Per maggiori informazioni sul file di configurazione si rimanda a [questa
sezione della guida ufficiale](https://www.mkdocs.org/user-guide/configuration/).

## Struttura

La Directory del progetto si dirama come segue:

    ├── _data
    │   └── vars.yml
    ├── docs
    │   ├── assets
    │   │   ├── favicon.ico
    │   │   └── logo-garr.png
    │   ├── assets-resize
    │   │   └── README.md
    │   ├── *.md
    ├── mkdocs.yml
    ├── README.md
    └── requirements.txt

- `_data/`

    Directory dove inserire file yaml che verranno elaborati dal plugin extradata come
    variabili da poter usare nei file MarkDown interni alla documentazione (similare al
    template Ansible)

- `docs/`

    Directory dove inserire i propri file MarkDown che verranno renderizzati in pagine
    **HTML** statiche

- `docs/assets/`

    Directory dove inserire le eventuali immagini utilizzate nella propria
    documentazione

- `docs/assets-resize/`

    Directory dove inserire le immagini da ridimensionare attraverso il plugin
    resize-images (maggiori informazioni nel README interno a questa cartella)

- `site/`

    Directory che contiene la build della documentazione (inserita in .gitignore)

- `mkdocs.yml`

    file di configurazione del progetto

- `requirements.txt`

    Pacchetti necessari all'utilizzo di mkdocs

## Build

MkDocs consente di visualizzare la documentazione tramite l'utilizzo di un server di
sviluppo locale:

- Avviare l'ambiente virtuale tramite `pipenv shell`
- Portarsi al livello di un file mkdocs.yml
- Eseguire `mkdocs serve` per avviare il server locale
- Collegarsi tramite <http://localhost:8000> per visualizzare la documentazione locale
  aggiornata in tempo reale

Per buildare la documentazione eseguire `mkdocs build`. I file renderizzati saranno
disponibili nella cartella site.

La documentazione dovrà poi essere renderizzata e servita da Read The Docs, [qui la
guida](https://hands-on-git-e-gitlab.docs.dir.garr.it/en/latest/read_the_docs.html)
per automatizzare il processo.

Il file `.readthedocs.yaml` presente nella root del progetto istruisce ReadTheDocs su
come eseguire la build.

## Plugins

MkDocs offre la possibilità di usare
[plugins](https://www.mkdocs.org/dev-guide/plugins/) per modificare o aggiungere
funzionalità, i plugins sono pacchetti python installabili tramite **pip** e per
convenzione seguono la nomenclatura `mkdocs-nome-del-plugin`. Per attivare un plugin
installato inserire sotto la variabile `plugins` del file `mkdocs.yml` una riga
contenente il nome del plugin. Per alcuni plugins è possibile specificare configurazioni
aggiuntive, seguire la documentazione del plugin in questione per maggiori informazioni.

Se si usano plugins non presenti nel template aggiungerli al file `requirements.txt`.

[Catalogo dei plugin](https://github.com/mkdocs/catalog?tab=readme-ov-file)

## MarkDown

MkDocs utilizza la sintassi [MarkDown](https://www.markdownguide.org/) base, rifarsi a
[questa sezione della guida
ufficiale](https://www.mkdocs.org/user-guide/writing-your-docs/) per le peculiarità di
questa implementazione.

### Estensioni VSCode per MarkDown

- <https://marketplace.visualstudio.com/items?itemName=yzhang.markdown-all-in-one>
- <https://marketplace.visualstudio.com/items?itemName=DavidAnson.vscode-markdownlint>

Per il linting è presente un file di configurazione nella root del progetto
`.markdownlint.json`
