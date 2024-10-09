# Plugin resize-images

È stato utilizzato il plugin resize-images per uniformare la grandezza degli assets da
usare nella documentazione, il plugin fa scale down di immagini grandi affinché entrambe
le dimensioni rientrino nei limiti configurati all'interno della sezione `plugins` del
file `mkdocs.yml`. Non consente di ingrandire immagini e preserva le proporzioni.

Per fare uso di questa funzionalità salvare la propria immagine in questa cartella, il
plugin si occuperà di copiare la versione ridotta all'interno della cartella assets.
