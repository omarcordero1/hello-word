###An�lisis Netflix##

###Cragar ambiente

# PAQUETES
library(dplyr)
library(tidyr)
library(lubridate)
library(zoo)
library(ggplot2)

###Cragar datos

minetflix  <- read.csv("C:/Users/omar.cordero/OneDrive - Mediotiempo/2020/Junio/25062020/NetflixViewingHistory.csv")
minetflix$Date <- dmy(minetflix$Date)

##�Qu� tanto veo Maratones?

minetflix_serie <- minetflix %>%
  separate(col = Title, into = c("title", "temporada", "titulo_episodio"), sep = ': ')

minetflix_serie <- minetflix_serie[!is.na(minetflix_serie$temporada),]
minetflix_serie <- minetflix_serie[!is.na(minetflix_serie$titulo_episodio),]

maratones_minetflix <- minetflix_serie %>%
  count(title, Date)

maratones_minetflix <- maratones_minetflix[maratones_minetflix$n >= 6,]
maratones_minetflix
maratones_minetflix <- maratones_minetflix[order(maratones_minetflix$Date),]
maratones_minetflix

##Top de series m�s vistas
maratones_minetflix_todas <- maratones_minetflix %>% 
  group_by(title) %>% 
  summarise(n = sum(n)) %>%
  arrange(desc(n))

##Gr�fica
maratones_minetflix_top <- maratones_minetflix_todas %>% 
  top_n(10) %>%
  ggplot(aes(x = reorder(title, n), y = n)) +
  geom_col(fill = "#0097d6") +
  coord_flip() +
  ggtitle("Top 10 de series m�s vistas en marat�n en mi Netflix", "4 o m�s episodios por d�a") +
  labs(x = "Serie en Netflix", y = "Episodios vistos en total") +
  theme_minimal()

##�Cu�nto Netflix consumes al d�a en series?

# EPISODIOS POR D�A
netflix_episodios_dia <- minetflix %>%
  count(Date) %>%
  arrange(desc(n))
# VISUALIZACI�N DE EPISODIOS POR D�A
netflix_episodios_dia_plot <- ggplot(aes(x = Date, y = n, color = n), data = netflix_episodios_dia) +
  geom_col(color = c("#f16727")) +
  theme_minimal() +
  ggtitle("Episodios vistos en mi Netflix por d�a", "Historial de 2016 a 2020") +
  labs(x = "Fecha", y = "Episodios vistos") 
netflix_episodios_dia_plot


###Calendario de episodios

# CALENDARIO CON N�MERO DE EPIODIOS VISTOS POR D�A EN HEATMAP
netflix_episodios_dia <- netflix_episodios_dia[order(netflix_episodios_dia$Date),]
netflix_episodios_dia$diasemana <- wday(netflix_episodios_dia$Date)
netflix_episodios_dia$diasemanaF <- weekdays(netflix_episodios_dia$Date, abbreviate = T)
netflix_episodios_dia$mesF <- months(netflix_episodios_dia$Date, abbreviate = T)
netflix_episodios_dia$diasemanaF <-factor(netflix_episodios_dia$diasemana, levels = rev(1:7), labels = rev(c("Lun","Mar","Mier","Jue","Vier","S�b","Dom")),ordered = TRUE) 
netflix_episodios_dia$mesF <- factor(month(netflix_episodios_dia$Date),levels = as.character(1:12), labels = c("Enero","Febrero","Marzo","Abril","Mayo","Junio","Julio","Agosto","Septiembre","Octubre","Noviembre","Diciembre"),ordered = TRUE)
netflix_episodios_dia$a�omes <- factor(as.yearmon(netflix_episodios_dia$Date)) 
netflix_episodios_dia$semana <- as.numeric(format(netflix_episodios_dia$Date,"%W"))
netflix_episodios_dia$semanames <- ceiling(day(netflix_episodios_dia$Date) / 7)
netflix_episodios_dia_calendario <- ggplot(netflix_episodios_dia, aes(semanames, diasemanaF, fill = netflix_episodios_dia$n)) + 
  geom_tile(colour = "white") + 
  facet_grid(year(netflix_episodios_dia$Date) ~ mesF) + 
  scale_fill_gradient(low = "#FFD000", high = "#FF1919") + 
  ggtitle("Episodios vistos por d�a en mi Netflix", "Heatmap por d�a de la semana, mes y a�o") +
  labs(x = "N�mero de semana", y = "D�a de la semana") +
  labs(fill = "No.Episodios")
netflix_episodios_dia_calendario
maratones_minetflix_top


###D�a de la semana

# FRECUENCIA DE ACTIVIDAD EN MI NETFLIX POR D�A
vista_dia <- netflix_episodios_dia %>%
  count(diasemanaF)
vista_dia
vista_dia_plot <- vista_dia %>% 
  ggplot(aes(diasemanaF, n)) +
  geom_col(fill = "#5b59d6") +
  coord_polar()  +
  theme_minimal() +
  theme(axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text.y = element_blank(),
        axis.text.x = element_text(face = "bold"),
        plot.title = element_text(size = 16, face = "bold")) +
  ggtitle("Frecuencia de episodios vistos", "Actividad por d�a de la semana en mi Netflix")
vista_dia_plot

##Meses de mayor actividad

vista_mes <- netflix_episodios_dia %>%
  count(mesF)
vista_mes
vista_mes_plot <- vista_mes %>% 
  ggplot(aes(mesF, n)) +
  geom_col(fill = "#808000") +
  coord_polar()  +
  theme_minimal() +
  theme(axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text.y = element_blank(),
        axis.text.x = element_text(face = "bold"),
        plot.title = element_text(size = 18, face = "bold")) +
  ggtitle("Frecuencia de episodios vistos", "Actividad por mes en mi Netflix") 
vista_mes_plot


###Periodicidad

# FRECUENCIA DE ACTIVIDAD EN MI NETFLIX POR A�O
vista_a�os <- netflix_episodios_dia %>%
  count(a�omes)
vista_a�os
vista_a�os_plot <- vista_a�os %>% 
  ggplot(aes(a�omes, n)) +
  geom_col(fill = "#1a954d") +
  coord_polar()  +
  theme_minimal() +
  theme(axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text.y = element_blank(),
        axis.text.x = element_text(face = "bold"),
        plot.title = element_text(size = 18, face = "bold")) +
  ggtitle("Frecuencia de episodios vistos", "Actividad por mes del a�o en mi Netflix")
vista_a�os_plot
