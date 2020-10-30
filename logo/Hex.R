library(ggraph)
library(tidygraph)
library(hexSticker)

dat <-
  tibble::tribble(
  ~from, ~to,
  "SEM", "???",
  "SEM", "S1",
  "SEM", "S2",
  "SEM", "...",
  "SEM", "S40",
  "Psych", "SEM",
  "Psych", "???"
) %>% 
  as_tbl_graph() %E>%
    mutate(dir = c("<", "<", "<", "<", "<", "<", "<>")) %N>% 
  arrange(name) %>% 
  mutate(type = c(rep("Obs",6), "Lat"))

dat %>% 
  as.data.frame()

arrow_cap     <- circle(4, 'mm')
label.padding <- unit(0.3,"lines")

sem_p <- ggraph(dat, layout = "manual",
                x = c(1, 2.5, 2.5, 1, 1, 1, 2)/40,
                y = -c(2.75, 3.5, 1.5, 1.75, 2.25, 3.25, 2.5)/80) +
  # edges
  geom_node_label(aes(filter = type=="Obs",
                      label  = name),
                  label.r       = unit(0, "lines"),
                  label.padding = label.padding) +
  geom_node_label(aes(filter = type!="Obs",
                      label  = name),
                  label.r       = unit(0.4, "lines"),
                  label.padding = label.padding) +
  # edges
  geom_edge_link(aes(filter = dir == "<"),
                 arrow     = arrow(20, unit(.1, "cm"), type = "closed"),
                 start_cap = arrow_cap,
                 end_cap   = arrow_cap) +
  geom_edge_arc(aes(filter = dir == "<>"),
                arrow     = arrow(20, unit(.1, "cm"), type = "closed", ends = "both"),
                start_cap = arrow_cap,
                end_cap   = arrow_cap) +
  # theme_bw() 
  theme_transparent() +
  coord_cartesian(xlim = c(0.02, 0.07),
                  ylim = -c(0.015, 0.047)) +
  NULL


sticker(sem_p, package="SEM - Practical Applications in R",
        filename = "Hex.png",
        s_x = 0.9, s_y = 0.8, s_width = 1.6, s_height = 1.2,
        p_color = "white", p_size = 8,
        h_color = "grey", h_fill = "orange",
        spotlight = TRUE, l_y = 1.2)
