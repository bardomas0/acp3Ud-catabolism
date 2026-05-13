library(tidyverse)
library(data.table)
library(dplyr)
library(ggpubr)
library(plotly)
library(ggplot2)

library(readxl)

library(scales)

library(stringr)

library(ci)

set.seed(123)

master_path = "C:/Users/bardo/Files/Uni/Praktika/microplate reader/Master RihA.xlsx"


data_termo <- readxl::read_excel(
  path = master_path,
  sheet = "Termostabilumas stats",
  range = "B18:BZ22"
  ) |>
  transpose(keep.names = "Mėginys") |>
  rename("Laikas" = V1,
    "Temperatūra" = V2,
    "Slope 1" = V3,
    "Slope 2" = V4
    ) |>
  slice(-1)

data_termo <- data_termo |> arrange(Mėginys)

data_termo["Mėginys"][1:2,] <- "Control"
data_termo["Mėginys"][3:39,] <- "R1"
data_termo["Mėginys"][40:76,] <- "R2"

#data_termo$Temperatūra <- as.integer(data_termo$Temperatūra)
data_termo$Laikas <- as.double(data_termo$Laikas)

data_termo <- data_termo |> filter(
  Mėginys != "Control",
  Temperatūra != "25 °C"
  )

data_termo_long <-
  data_termo |>
  pivot_longer(
    cols = 4:5,
    names_to = "Slope group",
    values_to = "V0"
    ) |> drop_na(V0)

data_termo_long$V0 <- as.double(data_termo_long$V0)
#data_termo_long$`Slope average` <- as.double(data_termo_long$`Slope average`)

data_graphing <-
  data_termo_long |>
  group_by(Mėginys, Laikas, Temperatūra) |>
  mutate(
    mean = mean(V0),
    lwr.sd = mean(V0) - sd(V0)/2,
    upr.sd = mean(V0) + sd(V0)/2
  ) |> distinct(mean, lwr.sd, upr.sd)


# data_ci nėra naudojamas niekur

data_ci <-
  data_termo_long |>
  group_by(Mėginys, Laikas, Temperatūra) |>
  mutate(
    sd = sd(V0)
  ) |>
  ci_mean_t(V0, conf.level = 0.95)

# Nunulina PI jeigu jis mažesnis už 0

data_ci <-
  data_ci |>
  mutate(
    lwr.ci = if_else(lwr.ci < 0, lwr.ci == 0, lwr.ci)
  )

plot_old <-
  data_termo_long |>
  ggplot(aes(
    x = Laikas,
    y = V0,
    color = Mėginys,
    group = Mėginys
  )) +
  scale_x_log10(guide = "axis_logticks")

plot <-
  data_graphing |>
  ggplot(aes(
    x = Laikas,
    y = mean,
    color = Mėginys,
    group = Mėginys
  )) +
  scale_x_log10(guide = "axis_logticks") +
  labs(
    title = "Fermento termostabilumas",
    x = "Laikas, h",
    y = "Santykinis aktyvumas, %",
    color = "Fermentas"
    )

plot_points <-
  plot +
  geom_point(alpha = 1)

plot_line <-
  plot_points +
  geom_line()

#plot_line + facet_wrap(~Temperatūra)

plot_error <-
  plot_line +
  geom_errorbar(aes(
    ymin = lwr.sd,
    ymax = upr.sd,
  ), width = 0.1, position = position_dodge2(0.1))

plot_facet <- plot_error + facet_wrap(~Temperatūra)

plot_facet

ggsave("termo_facet.png", plot = plot_facet, width = 17, height = 9, units = "cm", scale = 1.5)
