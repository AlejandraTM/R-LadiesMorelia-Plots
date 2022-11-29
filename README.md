# 🎃 Gráficos de Horror 🎃

## Librerias
* [**tidyverse:**](https://www.tidyverse.org/) Es una colección de paquetes de R-Ladies diseñados para Ciencia de Datos.
  
* [**ggimage y ggtext:**](https://exts.ggplot2.tidyverse.org/) Son extensiones de ggplot2 que permiten mejorar el texto en los gráficos y permite introducir imágenes en el mismo.
  
* **[sysfonts](https://cran.r-project.org/web/packages/sysfonts/sysfonts.pdf) y [showtext](https://journal.r-project.org/archive/2015-1/qiu.pdf):** Permite cargar fuentes diferentes desde [Google](https://fonts.google.com/) y ajustar la [tipografía](https://cran.rstudio.com/web/packages/showtext/vignettes/introduction.html).

### Instalar:

<pre><code>
# lista de paquetes
packages<- c("tidyverse","ggimage","sysfonts","showtext")

# Instalación rápida de los paquetes
installed_packages <- packages %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  install.packages(packages[!installed_packages])
}
</pre></code>

### Importar:

<pre><code>
library(tidyverse) #includes dplyr + ggplot
library(ggimage) #ggplot extension packages
library(sysfonts) #to add google font libraries
library(showtextdb) #Es necesaria para usar showtext
library(showtext) #showtext convierte el texto en una imágen rasterizada (a base de pixeles) que luego se añade al gràfico
library(dplyr)
</pre></code>

### Cargar fuentes

<pre><code> 
#Cargar fuentes

sysfonts::font_add_google("Acme","Acme")
sysfonts::font_add_google("Creepster","Creepster")

#Mostrar las fuentes

showtext::showtext_auto() 
</pre></code>

### Algunos problemas en la instalación
Es posible que sea necesario instalar lo siguiente previo a tidyverse,ggimage y ggtext:
<pre><code>sudo apt-get install libcurl4-openssl-dev
sudo apt-get install libmagick++-dev </code></pre>

## 📑 Datos

Los datos fueron tomados de [TMDB](https://www.themoviedb.org/) (The movie Data Base) usando el [API](https://developers.themoviedb.org/3/getting-started/introduction) por [Tanya Shapiro](https://www.tanyashapiro.com/).

### Cargar los datos

Una vez se tengan los datos en un archivo *.csv * podemos cargarlos en nuestro script:

<pre><code>
#Descargar los datos del repositorio de GitHub
raw <- readr::read_csv("https://raw.githubusercontent.com/AlejandraTM/R-LadiesMorelia-Plots/main/Datos/horror_movies.csv")

#Ver parte de los datos
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
# Creación del dataframe
base_url<-'https://www.themoviedb.org/t/p/w1280'
df <- raw|>
  mutate(budget = budget/1000000,
         revenue = revenue/1000000,
         #convertir datos de caracter a fecha
         release_date = as.Date(release_date),
         #Dividir la fecha de lanzamiento en mes y año
         release_year = as.numeric(format(release_date, '%Y')),
         release_month = as.numeric(format(release_date, '%m')),
         #Concatenar base_url con la direcciòn del poster y obtener la url final
         poster_url = paste0(base_url,poster_path))

#Ver parte de los datos
head(df,5)
</pre></code>

## 📈 Primera gráfica: Scatter

![Plot_scatter](https://github.com/AlejandraTM/R-LadiesMorelia-Plots/blob/main/Graficos/plot_scatter.png?raw=true)

Primero seleccionaré algunas de mis peliculas favoritas:

<pre><code>
#lista de peliculas tomadas desde su colección de peliculas
fav<- c("Saw Collection","The grudge Collection","Insidious Collection","28 Days/Weeks Later Collection",
        "The Conjuring Collection","Annabelle Collection")
        
#Creación del dataframe
df_fav<-df|>
  #filtran las peliculas con respecto a la lista fav
  filter(collection_name %in% fav & budget>0 & revenue>0)|>
  #Se quita "Collection" de collection_name
  mutate(collection_name = gsub(" Collection","",collection_name))|>
  #subet columns with select
  select(title, collection_name, budget, revenue, popularity)
  
#Vista de algunos datos
head(df_fav,5)
</pre></code>

Una **Scatter plot** es una gráfica que presenta la relaciòn entre dos variables en un conjunto de datos. Muestra los datos en un plano o sistema cartesiano. 

<pre><code>
#Crear la gráfica (Scatter)
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

## 📈 Segunda Gráfica: Gráfica de líneas

<div>
<p style = 'text-align:center;'>
<img src="https://github.com/AlejandraTM/R-LadiesMorelia-Plots/blob/main/Graficos/plot_line.png?raw=true" width="600px">
<img src="https://github.com/AlejandraTM/R-LadiesMorelia-Plots/blob/main/Graficos/plot_facet.png?raw=true" alt="JuveYell" width="600px">
</p>
</div>

Con esta gráfica se quiere saber cuántas películas fueron estrenadas por mes y año. Para ello se organizan los datos con **dplyr** usando **group_by** en *release_month* y *release_year* desde 1993 al 2021. Con ellos se generará un segundo conjunto de datos filtrando solo las películas estrenadas en 1993.

<pre><code>
#Datos
df_monthly<-df|>
  group_by(release_year, release_month)|>  #Agregar datos por año y mes
  summarise(count=n())|> #conteo de las películas
  filter(release_year>=1993 & release_year<=2021)#Filtrar los datos desde 1993 a 2021
  
#Ver parte de los datos
head(df_monthly,5)

#Datos para el año 1993
df_monthly_1993<- df_monthly|>filter(release_year==1993)#Número de películas en 1993 por mes

#Ver parte de los datos
head(df_monthly_1993,5)
</pre></code>

En esta gráfica se usarán las letras cargadas al inicio. Recordemos que es necesario haber llamado las librerias *sysfonts*, *showtextdb* y *showtext*.

<pre></code>
#Paleta de colores
pal_text <-"white"
pal_subtext <-"#DFDFDF"
pal_grid <-"grey30"
pal_bg<-'#191919'

#Gráfica 
plot_line<-ggplot(data = df_monthly_1993, 
                  mapping=aes(x=release_month, y=count))+
  geom_line(color="green")+
  annotate(geom="label", 
           label="Peliculas a un epsilon de Halloween",
           x=10, y=50, color=pal_text, fill=pal_bg, size=3)+#Anotaciones y ubicación
  scale_x_continuous(breaks=1:12, labels=month.abb[1:12])+ #Escala del eje x
  scale_y_continuous(limits=c(0,100))+ #Escala del eje y
  labs(x="",
       y="Número de películas", x="Mes",
       title = "Películas de muedo estrenadas en 1993",
       caption = "Datos tomados de The Movie Database")+
  theme(
    #Ajustes del fondo + cuadrícula
    plot.background = element_rect(fill=pal_bg, color=pal_bg),#Color de fondo exterior a la gráfica y bordes de la imagen
    panel.background = element_rect(fill=pal_bg),#Color del interior de la gráfica o fondo de la cuadrícula
    panel.grid.minor = element_blank(),#Remover la cuadrícula menor
    panel.grid = element_line(color=pal_grid, size=0.2),#color de la cuadrícula
    #Color del texto
    text = element_text(color=pal_text),#Color del título de la gráfica y  los ejes
    axis.text = element_text(color=pal_text),#Color de la leyenda de los ejes
    axis.title.y = element_text(size=10, margin=margin(r=10)),#Tamaño del título del eje y
    axis.title.x = element_text(size=10, margin=margin(r=30)),#Tamaño del título del eje x
    plot.title = element_text(family="Creepster", size=20, hjust=0.5),#Título de la gráfica con el texto importado de Google
    #plot.subtitle = element_text(hjust=0.5),
    #Marjenes de la gráfica
    plot.margin = margin(l=20, r=20, b=20, t=20))
plot_line

#Guardar la imagen
ggsave(filename="plot_line.png", plot=plot_line, width=7, height=5, units="in")
</pre></code>

También es posible hacer un gráfico comparativo de diagramas de líneas usando [**facet_wrap**](https://ggplot2.tidyverse.org/reference/facet_wrap.html). Para nuestro caso, se compara el número de estrenos, por mes y año, de películas de terror desde 2004 a 2021. Primero, se filtraron los datos de 2004 a 2021, de la misma forma como se hizó para el gráfico anterior, y con dicha información se hizo la comparación.

<pre><code>
#Datos
df_monthly2<-df|>
  group_by(release_year, release_month)|>  #Agregar datos por año y mes
  summarise(count=n())|> #conteo de las películas
  filter(release_year>=2004 & release_year<=2021)#Filtrar los datos desde 1993 a 2021
#Ver parte de los datos
head(df_monthly,5)

#gráfico
plot_facet<-ggplot(data = df_monthly2, mapping=aes(x=release_month, y=count, group=1))+
  geom_line(color="green")+
  facet_wrap(~release_year)+ #Generar las multiples subgráficas usando como pivote el año de estreno
  scale_x_continuous(breaks=1:12, labels=month.abb[1:12])+
  labs(x="",
       y="Estrenos", 
       title = "Estrenos de peliculas de terror",
       caption = "Datos tomados de The Movie Database",
       subtitle = "Total de estrenos por mes y año.")+
  theme(
    #Fondo y cuadrícula
    plot.background = element_rect(fill=pal_bg, color=pal_bg),
    panel.background = element_rect(fill=pal_bg),
    strip.background = element_rect(fill="#521EA4"),
    panel.grid.minor = element_blank(),
    panel.grid = element_line(color=pal_grid, size=0.2),
    #Texto
    text = element_text(color=pal_text),
    axis.text = element_text(color=pal_text),
    axis.title.y = element_text(size=11, margin=margin(r=8)),
    axis.text.x=element_text(angle=90, size=5),
    plot.title = element_text(family="Creepster", size=20, hjust=0.5),
    plot.subtitle = element_text(hjust=0.5, size=10),
    strip.text=element_text(color=pal_text),
    #Margenes
    plot.margin = margin(l=20, r=20, b=20, t=20))
plot_facet

#Salvar imagen
ggsave(filename="plot_facet.png", plot=plot_facet, width =7 , height=5, units="in")
</pre></code>

## 📈 Tercera Gráfica: Diagrama de barras

En esta última gráfica se organizaran los datos de forma descendente con respecto a los ingresos. Se usará la librería *dplyr* con la función **arrange()**. Luego, se tomarán solo las columnas necesarias para el gráfico usando **select()**. La gráfica final tendrá como barras principales las ganancias de cada película, como barra secundarias el presupuesto de las mismas y en su eje verticas estarà el poster de cada estreno acompañado del nombre y año de extreno de las películas sobre la barra principal. Todo lo anterior se obtiene al usar las funciones **geo_col()**, **geo_text()**, **geo_image()** y **geo_curve()** de la librería *ggimage*.









A plots example of a horror database using ggplot2. The espanish version of the R-Ladies Paris workshop  https://github.com/tashapiro/horror-movies
