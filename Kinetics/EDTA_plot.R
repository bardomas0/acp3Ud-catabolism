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


data_edta <- readxl::read_excel(
  path = master_path,
  sheet = "EDTA stats",
  range = "B18:T22"
  ) |>
  transpose(keep.names = "Mėginys") |>
  rename("Laikas" = V1,
    "EDTA" = V2,
    "Slope 1" = V3,
    "Slope 2" = V4
    ) |>
  slice(-1)

data_edta <- data_edta |> arrange(Mėginys)

data_edta["Mėginys"][1:6,] <- "Control"
data_edta["Mėginys"][7:12,] <- "R1"
data_edta["Mėginys"][13:18,] <- "R2"

data_edta$Laikas <- as.integer(data_edta$Laikas)

data_edta <- data_edta |> filter(
  Mėginys != "Control"
)

data_edta_long <-
  data_edta |>
  pivot_longer(
    cols = 4:5,
    names_to = "Slope group",
    values_to = "V0"
    ) |> drop_na(V0)

data_edta_long$V0 <- as.double(data_edta_long$V0)
#data_edta_long$`Slope average` <- as.double(data_edta_long$`Slope average`)
#data_edta_long$`Slope SD` <- as.double(data_edta_long$`Slope SD`)

data_graphing <-
  data_edta_long |>
  group_by(Mėginys, Laikas, EDTA) |>
  mutate(
    mean = mean(V0),
    lwr.sd = mean(V0) - sd(V0)/2,
    upr.sd = mean(V0) + sd(V0)/2
  ) |> distinct(mean, lwr.sd, upr.sd)

plot_old <-
  data_edta_long |>
  ggplot(aes(
    x = Laikas,
    y = V0,
    color = Mėginys,
    group = Mėginys
  ))
  #scale_x_log10(guide = "axis_logticks")

plot <-
  data_graphing |>
  ggplot(aes(
    x = Laikas,
    y = mean,
    color = Mėginys,
    group = Mėginys
  )) +
  #scale_x_log10(guide = "axis_logticks") +
  labs(
    title = "Fermento aktyvumas po inkubacijos EDTA",
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

#plot_line + facet_wrap(~EDTA)

plot_error <-
  plot_line +
  geom_errorbar(aes(
    ymin = lwr.sd,
    ymax = upr.sd,
  ), width = 2, position = position_dodge2(preserve = "total")
  )

plot_facet <- plot_error + facet_wrap(~EDTA)

plot_facet

ggsave("EDTA_facet.png", plot = plot_facet, width = 12, height = 9, units = "cm")
