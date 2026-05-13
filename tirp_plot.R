library(tidyverse)
library(data.table)
library(dplyr)
library(ggpubr)
library(plotly)
library(ggplot2)

library(readxl)

library(stringr)

set.seed(123)

master_path = "C:/Users/bardo/Files/Uni/Praktika/microplate reader/Master RihA.xlsx"


data_tirp <- readxl::read_excel(
  path = master_path,
  sheet = "Tirpikliai stats",
  range = "B18:AF22"
  ) |>
  transpose(keep.names = "Mėginys") |>
  rename("Koncentracija" = V1,
    "Tirpiklis" = V2,
    "Slope 1" = V3,
    "Slope 2" = V4
    ) |>
  slice(-1)

data_tirp <- data_tirp |> arrange(Mėginys)

data_tirp["Mėginys"][1:10,] <- "Control"
data_tirp["Mėginys"][11:20,] <- "R1"
data_tirp["Mėginys"][21:30,] <- "R2"

data_tirp$Koncentracija <- as.integer(data_tirp$Koncentracija)

data_tirp <- data_tirp |> filter(
  Mėginys != "Control")

data_tirp_long <-
  data_tirp |>
  pivot_longer(
    cols = 4:5,
    names_to = "Slope group",
    values_to = "V0"
    ) |> drop_na(V0)

data_tirp_long$V0 <- as.double(data_tirp_long$V0)
#data_tirp_long$`Slope average` <- as.double(data_tirp_long$`Slope average`)
#data_tirp_long$`Slope SD` <- as.double(data_tirp_long$`Slope SD`)

data_graphing <-
  data_tirp_long |>
  group_by(Mėginys, Koncentracija, Tirpiklis) |>
  mutate(
    mean = mean(V0),
    lwr.sd = mean(V0) - sd(V0)/2,
    upr.sd = mean(V0) + sd(V0)/2
  ) |> distinct(mean, lwr.sd, upr.sd)

plot_old <-
  data_tirp_long |>
  ggplot(aes(
    x = Koncentracija,
    y = V0,
    color = Tirpiklis,
    group = Tirpiklis
  ))

plot <-
  data_graphing |>
  ggplot(aes(
    x = Koncentracija,
    y = mean,
    color = Mėginys,
    group = Mėginys
  )) +
  labs(
    title = "Fermento aktyvumas organiniuose tirpikliuose",
    x = "Koncentracija, %",
    y = "Santykinis aktyvumas, %",
    color = "Fermentas"
    )

plot_points <-
  plot +
  geom_point(alpha = 1)

plot_line <-
  plot_points +
  geom_line()

#plot_line + facet_wrap(~Mėginys)

plot_error <-
  plot_line +
  geom_errorbar(aes(
    ymin = lwr.sd,
    ymax = upr.sd,
  ), width = 2#, position = position_dodge2(preserve = "total")
  )

plot_facet <- plot_error + facet_wrap(~Tirpiklis)

plot_facet

ggsave("tirp_facet.png", plot = plot_facet, width = 17, height = 9, units = "cm")
