
# lista de paquetes
packages<- c("tidyverse","ggimage","sysfonts","showtext")

# Instalación rápida de los paquetes
installed_packages <- packages %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  install.packages(packages[!installed_packages])
}

#Llamar librerias

library(tidyverse) #incluye dplyr + ggplot
library(ggimage) #extensiones de ggplot
#Para añadir las librerias de Googlefonts
library(sysfonts) 
library(showtextdb) #Es necesaria para usar showtext
library(showtext)
library(dplyr)

################################################################################

#Cargar fuentes

sysfonts::font_add_google("Acme","Acme")
sysfonts::font_add_google("Creepster","Creepster")

#Graficar las fuentes

showtext::showtext_auto()

################################################################################

#Descargar los datos del repositorio de GitHub

raw <- readr::read_csv("https://raw.githubusercontent.com/AlejandraTM/R-LadiesMorelia-Plots/main/Datos/horror_movies.csv")
#Ver parte de los datos
head(raw,5)

################################################################################

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

################################################################################

#Plot1

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

################################################################################

## Plot 2

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

################################################################################

## Plot 3. varias gráfica de líneas en una misma imagen

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

################################################################################

## Plot4. Diagrama de barras

#Se organizaran los datos de forma descendenter de acuerdo a los ingresos.  

#Peliculas por ingresos
df_top_movies<-df|>
  arrange(-revenue)|>  #organizar los datos de forma descendente
  select(title, release_year, revenue, budget, poster_url)|> #Tomar las columnas específicas
  #Quedarse las primeras 10 columnas
  head(10)
#ver los datos
head(df_top_movies,10)

#Paleta de colores
pal_bar<-'#A70000'

#Gráfica
plot_bar<-ggplot(data=df_top_movies, mapping=aes(y=reorder(title,revenue), x=revenue))+
  #Barra horizontal con ganancia y presupuesto
  geom_col(fill=pal_bar, width=0.35)+
  geom_col(mapping=aes(x=budget), fill='#600000', width=0.15)+
  #Textos con ganancias
  geom_text(mapping=aes(x=revenue+18, label=round(revenue,0)), 
            color="white", size=3.5)+
  #Texto con nombre de la película y año de estreno
  geom_text(mapping=aes(x=0, y=title, label=paste0(title, " (",release_year,")")), 
            color="white", vjust=-1, hjust=0,size=4)+
  #Imagen del poster de la película
  geom_image(mapping=aes(x=-50, image=poster_url))+
  #Anotación
  annotate(geom="text", color="white", x=250, y=9.5, label="Presupuesto de la película", size=3)+
  geom_curve(mapping=aes(x=250, xend=205, y=9.35, yend=9), 
             color="white", curvature=-0.2, size=0.2, alpha=0.6,
             arrow = arrow(length = unit(0.07, "inch")))+
  #Ajustes del eje horizontal
  scale_x_continuous(expand=c(0,0), 
                     limits=c(-70,800),
                     breaks = c(0, 100,200, 300, 400, 500, 600, 700))+
  #Título y etiquetas
  labs(x="Ganancia (milliones USD)", y="",
       title="Películas de terror que arrasaron en taquilla",
       subtitle="Top 10 de películas basado en las ganancias.",
       caption = "Datos tomados de The Movie Database.")+
  #Tema 
  theme(
    #Fondo
    plot.background =element_rect(fill=pal_bg, color=pal_bg),
    panel.background =element_rect(fill=pal_bg, color=pal_bg),
    #Textos-Fuentes
    text = element_text(color=pal_text, family="Acme"),
    axis.text = element_text(color=pal_text),
    axis.title.x = element_text(margin=margin(t=10)),
    axis.text.y = element_blank(),
    plot.subtitle = element_text(color=pal_subtext, size=12),
    plot.caption = element_text(color=pal_subtext, size=12),
    plot.title=element_text(family="Acme", size=30, color=pal_text),
    #Lineas y cuadrícula
    axis.ticks = element_blank(),
    panel.grid = element_blank(),
    panel.grid.major.x= element_line(color=pal_grid, size=0.2),
    #Margenes
    plot.margin = margin(t=20, b=20, l=20, r=20)
  )
plot_bar

#Guardar imagen
save(filename="plot_bar.png", plot=plot_bar,width=8,height=8, units="in")
