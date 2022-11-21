# 🎃 Gráficos de Horror 🎃

## Librerias
[**tidyverse:**](https://www.tidyverse.org/) Es una colección de paquetes de R-Ladies diseñados para Ciencia de Datos.
[**ggimage y ggtext**](https://exts.ggplot2.tidyverse.org/) Son extensiones de ggplot2 que permiten mejorar el texto en los gràficos y permite introducir imágenes en el mismo.
[**sysfonts y showtext**] Permite cargar fuentes diferentes desde [Google](https://fonts.google.com/) y ajustar la [tipografía](https://cran.rstudio.com/web/packages/showtext/vignettes/introduction.html).

Para su instalación:

<pre><code> #list of packages used in this workshop
packages<- c("tidyverse","ggimage","sysfonts","showtext")
# if package not already installed, install package
installed_packages <- packages %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  install.packages(packages[!installed_packages])
} </pre></code>

### ⏸️ Algunos problemas en la instalación
Es posible que sea necesario instalar lo siguientes previo a tidyverse,ggimage y ggtext:
<pre><code>sudo apt-get install libcurl4-openssl-dev
sudo apt-get install libmagick++-dev </code></pre>





A plots example of a horror database using ggplot2. The espanish version of the R-Ladies Paris workshop  https://github.com/tashapiro/horror-movies
