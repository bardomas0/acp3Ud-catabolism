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


data_pH <- readxl::read_excel(
  path = master_path,
  sheet = "pH stats",
  range = "B18:AF23"
  ) |>
  transpose(keep.names = "Mėginys") |>
  rename("pH" = V1,
    "Buferis" = V2,
    "Slope 1" = V3,
    "Slope 2" = V4,
    "Slope 3" = V5,
    ) |>
  slice(-1)


#data_pH[1] <- gsub('[:digit:]$', '', data_pH[1])
#substr(each(data_pH["Mėginys"]), 1, 2)
# These two fucking suck, I'm gonna do it the simple way

data_pH["Mėginys"][1:10,] <- "Control"
data_pH["Mėginys"][11:20,] <- "R1"
data_pH["Mėginys"][21:30,] <- "R2"

data_pH$pH <- as.integer(data_pH$pH)

data_pH <- data_pH |> filter(
  Mėginys != "Control")

data_pH_long <-
  data_pH |>
  pivot_longer(
    cols = 4:6,
    names_to = "Slope group",
    values_to = "V0"
    ) |> drop_na(V0)

data_pH_long$V0 <- as.double(data_pH_long$V0)
#data_pH_long$`Slope average` <- as.double(data_pH_long$`Slope average`)
#data_pH_long$`Slope SD` <- as.double(data_pH_long$`Slope SD`)

data_graphing <-
  data_pH_long |>
  group_by(Mėginys, pH, Buferis) |>
  mutate(
    mean = mean(V0),
    lwr.sd = mean(V0) - sd(V0)/2,
    upr.sd = mean(V0) + sd(V0)/2
  ) |> distinct(mean, lwr.sd, upr.sd) |> ungroup()


# kad būtų įmanoma normaliai nupiešti grafiką be sujungimų tarp buferių

data_graphing <- data_graphing |>
  add_row(Mėginys = "R1", pH = 5, Buferis = "Citratinis", .after = 2)
data_graphing <- data_graphing |>
  add_row(Mėginys = "R1", pH = 7, Buferis = "MES", .after = 6)
data_graphing <- data_graphing |>
  add_row(Mėginys = "R1", pH = 9, Buferis = "TRIS", .after = 10)

data_graphing <- data_graphing |>
  add_row(Mėginys = "R2", pH = 5, Buferis = "Citratinis", .after = 15)
data_graphing <- data_graphing |>
  add_row(Mėginys = "R2", pH = 7, Buferis = "MES", .after = 19)
data_graphing <- data_graphing |>
  add_row(Mėginys = "R2", pH = 9, Buferis = "TRIS", .after = 23)

plot_old <-
  data_pH_long |>
  ggplot(aes(
    x = pH,
    y = V0,
    color = Buferis,
    group = pH
  ))

plot <-
  data_graphing |>
  ggplot(aes(
    x = pH,
    y = mean,
    color = Buferis,
    group = Mėginys
  )) +
  scale_x_log10(guide = "axis_logticks") +
  labs(
    title = "Fermento aktyvumas skirtinguose pH",
    x = "pH",
    y = "Santykinis aktyvumas, %",
    color = "Buferis"
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
  ), width = 0.02, position = position_dodge2(preserve = "total")
  )

plot_facet <- plot_error + facet_wrap(~Mėginys)

plot_facet

ggsave("pH_facet.png", plot = plot_facet, width = 17, height = 9, units = "cm")
