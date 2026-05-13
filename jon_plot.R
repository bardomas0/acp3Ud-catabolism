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


data_jon <- readxl::read_excel(
  path = master_path,
  sheet = "NaCl stats",
  range = "B18:Q21"
  ) |>
  transpose(keep.names = "Mėginys") |>
  rename("Koncentracija" = V1,
    "Slope 1" = V2,
    "Slope 2" = V3
    ) |>
  slice(-1)

data_jon <- data_jon |> arrange(Mėginys)

data_jon["Mėginys"][1:5,] <- "Control"
data_jon["Mėginys"][6:10,] <- "R1"
data_jon["Mėginys"][11:15,] <- "R2"

data_jon$Koncentracija <- as.double(data_jon$Koncentracija)

data_jon <- data_jon |> filter(
  Mėginys != "Control"
)

data_jon_long <-
  data_jon |>
  pivot_longer(
    cols = 3:4,
    names_to = "Slope group",
    values_to = "V0"
    ) |> drop_na(V0)

data_jon_long$V0 <- as.double(data_jon_long$V0)
#data_jon_long$`Slope average` <- as.double(data_jon_long$`Slope average`)
#data_jon_long$`Slope SD` <- as.double(data_jon_long$`Slope SD`)

data_graphing <-
  data_jon_long |>
  group_by(Mėginys, Koncentracija) |>
  mutate(
    mean = mean(V0),
    lwr.sd = mean(V0) - sd(V0)/2,
    upr.sd = mean(V0) + sd(V0)/2
  ) |> distinct(mean, lwr.sd, upr.sd)

plot_old <-
  data_jon_long |>
  ggplot(aes(
    x = Koncentracija,
    y = V0,
    color = Mėginys,
    group = Mėginys
  ))

plot <-
  data_graphing |>
  ggplot(aes(
    x = Koncentracija,
    y = mean,
    color = Mėginys,
    group = Mėginys,
  )) +
  labs(
    title = "Fermento aktyvumas NaCl",
    x = "Koncentracija, M",
    y = "Santykinis aktyvumas, %",
    color = "Fermentas"
    )

plot_points <-
  plot +
  geom_point(alpha = 1)

plot_line <-
  plot_points +
  geom_line()

#plot_line

plot_error <-
  plot_line +
  geom_errorbar(aes(
    ymin = lwr.sd,
    ymax = upr.sd,
  ), width = 0.05, position = position_dodge2(preserve = "total")
  )

plot_error


ggsave("jon_facet.png", plot = plot_error, width = 17, height = 9, units = "cm")
