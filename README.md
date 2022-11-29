# 🎃 Gráficos de Horror 🎃

## Librerias
* [**tidyverse:**](https://www.tidyverse.org/) Es una colección de paquetes de R-Ladies diseñados para Ciencia de Datos.
  
* [**ggimage y ggtext:**](https://exts.ggplot2.tidyverse.org/) Son extensiones de ggplot2 que permiten mejorar el texto en los gráficos y permite introducir imágenes en el mismo.
  
* **[sysfonts](https://cran.r-project.org/web/packages/sysfonts/sysfonts.pdf) y [showtext](https://journal.r-project.org/archive/2015-1/qiu.pdf):** Permite cargar fuentes diferentes desde [Google](https://fonts.google.com/) y ajustar la [tipografía](https://cran.rstudio.com/web/packages/showtext/vignettes/introduction.html).

### Instalar:

<pre><code># list of packages used in this workshop

packages<- c("tidyverse","ggimage","sysfonts","showtext")

# if package not already installed, install package

installed_packages <- packages %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  install.packages(packages[!installed_packages])
} </pre></code>

### Importar:

<pre><code>#includes dplyr + ggplot

library(tidyverse)

#ggplot extension packages

library(ggimage)

#to add google font libraries

library(sysfonts)

#showtext convierte el texto en una imágen rasterizada (a base de pixeles) que luego se añade al gràfico

library(showtext)
</pre></code>

### Cargar fuentes

<pre><code> 
#Cargar fuentes

sysfonts::font_add_google("Acme","Acme")
sysfonts::font_add_google("Creepster","Creepster")

#Graficar las fuentes

showtext::showtext_auto() 
</pre></code>

### Algunos problemas en la instalación
Es posible que sea necesario instalar lo siguiente previo a tidyverse,ggimage y ggtext:
<pre><code>sudo apt-get install libcurl4-openssl-dev
sudo apt-get install libmagick++-dev </code></pre>

## 📑 Datos

Los datos fueron tomados de [TMDB](https://www.themoviedb.org/) (The movie Data Base) usando el [API](https://developers.themoviedb.org/3/getting-started/introduction) por [Tanya Shapiro](https://www.tanyashapiro.com/).

### Cargar los datos

Una vez se tengan los datos en un archivo *. podemos cargarlos en nuestro script:

<pre><code>
#Descargar los datos del repositorio

raw <- readr::read_csv("https://raw.githubusercontent.com/tashapiro/horror-movies/main/data/horror_movies.csv")

#Vista previa de los datos

head(raw,5)
</pre></code>

### Diccionario de los datos

Son 32540 datos cada uno con 23 variables que los caracterizan. En la siguente tabla se muestran las variables, el tipo, una pequeña descripciòn y un ejemplo.

| **Variable**          | **Tipo** | **Definición**             | **Eejemplo**                    |
|:---------------|:--------------:|:------------------|:---------------------|
| **id**                |   int    | ID ùnico de la película    | 9378                            |
| **original_title**    |   char   | Título original            | Thir13en Ghosts                 |
| **title**             |   char   | Tìtulo                     | Thir13en Ghosts                 |
| **original_language** |   char   | Lenguaje                   | en                              |
| **overview**          |   char   | Descripción                | Arthur and his two children...  |
| **tagline**           |   char   | tagline                    | Misery loves company            |
| **release_date**      |   date   | Año de estreno             | 2001-10-26                      |
| **poster_path**       |   char   | Url de la imagen           | /6yrrddjIjx0ElCRZp5pTZeqrj3k.jpg|
| **popularity**        |   num    | Popularidad                | 52.197                          |
| **vote_count**        |   int    | Votos totales              | 1695                            |
| **vote_average**      |   num    | Promedio de votos          | 6.2                             |
| **budget**            |   int    | Presupuesto                | 4200000                         |
| **revenue**           |   int    | Ingresos                   | 68467960                        |
| **runtime**           |   int    | Duraciòn de la película    | 91                              |
| **status**            |   char   | movie status               | Released                        |
| **genre_names**       |   char   | Listado de géneros         | Horror, Thriller                |
| **collection**        |   num    | ID de la colecciòn         | NA                              |
| **collection_name**   |   char   | Nombre de la colecciòn     | NA                              |
| **release_year**      |   int    | Año de lanzamiento         | 2001                            |
| **release_month**     |   int    | Mes de lanzamiento         | 10                              |

### Preprocesamiento

Se usará **[dplyr](https://www.rstudio.com/wp-content/uploads/2015/02/data-wrangling-cheatsheet.pdf)** para modificar algunas columnas y emparejar algunas otras. Los pasos a seguir son:

-   Escribir las cantidades de *budget* y *revenue* en millones
-   Convertir *release_date* de caracter a fecha
-   Crear *release_year* y *release_month*
-   Añadir a *poster_path* la imagen en cartelera de la pelicula, tomada de themoviedb  creando un *poster_url*

<pre><code>
# url de las imagenes 
# Conecciòn a la url del poster de la pelìcula

base_url<-'https://www.themoviedb.org/t/p/w1280'
df <- raw|>
  mutate(budget = budget/1000000,
         revenue = revenue/1000000,
         #convertir datos de caracter a fecha
         release_date = as.Date(release_date),
         release_year = as.numeric(format(release_date, '%Y')), #Dividir la fecha de lanzamiento en mes y año
         release_month = as.numeric(format(release_date, '%m')),
         poster_url = paste0(base_url,poster_path)) #Concatenar base_url con la direcciòn del poster y obtener la url final
         
#Ver parte de los datos
head(df,5)
</pre></code>

## 📈 Primera gráfica: Scatter

Primero seleccionaré algunas de mis peliculas favoritas:

<pre><code>
#lista de peliculas tomadas desde su colección de peliculas

fav<- c("Saw collection","The grudge collection","Insiduous collection","28 Days/weeks later collection",
        "The conjuring collection","Annabelle collection")
        
#Creación del dataframe

df_fav<-df|>
  filter(collection_name %in% fav & budget>0 & revenue>0)|> #filtran las peliculas con respecto a la lista fav
  mutate(collection_name = gsub(" Collection","",collection_name))|> #Se quita "Collection" de collection_name
  select(title, collection_name, budget, revenue, popularity) #Seleccionar algunas columnas
  
#Vista de algunos datos

head(df_slashers,5)
</pre></code>

Una **Scatter plot** es una gráfica que presenta la relaciòn entre dos variables en un conjunto de datos. Muestra los datos en un plano o sistema cartesiano. 

<pre><code>
#Crear la gráfica
plot_scatter<-ggplot(df_fav, mapping=aes(y=revenue, x=budget))+
  geom_point(mapping=aes(size=popularity, color=collection_name), alpha=0.6)+
  scale_color_manual(values = c("#DB2B39","#29335C","#F3A712",'#3ED58E','#a64d79','#674ea7'))+
  guides(
    color = guide_legend(override.aes = list(size=4)),
    size = guide_legend(override.aes=list(shape=21,color="black",fill="white"))
  )+
  labs(title="Peliculas Favoritas: Ingresos vs. Presupuesto", 
       subtitle = "Comparando las películas en su popularidad en la franquicia",
       y="Ingresos (millones USD)",
       x="Presupuesto (millones USD)",
       caption = "Datos tomados de The Movie Database",
       size = "Popularidad (votos-miles)", 
       color = "Franquicia")+
  theme_minimal()
#Ver la gráfica
plot_scatter
#Guardar la gráfica
ggsave(filename="plot_scatter.png", plot=plot_scatter, width =7 , height=5, units="in", bg="white")
</pre></code>

## 📈 Segunda Gráfica: Gràfica de líneas

Con esta gráfica se quiere saber cuántas películas fueron estrenadas por mes y año. Para ello se organizan los datos con **dplyr** usando **group_by** en *release_month* y *release_year* desde 1993 al 2021

<pre><code>
df_monthly<-df|>
  group_by(release_year, release_month)|>  #Agregar datos por año y mes
  summarise(count=n())|> #conteo de las películas
  filter(release_year>=1993 & release_year<=2021)#Filtrar los datos desde 1993 a 2021
  
#Ver parte de los datos
head(df_monthly,5)
</pre></code>


A plots example of a horror database using ggplot2. The espanish version of the R-Ladies Paris workshop  https://github.com/tashapiro/horror-movies
