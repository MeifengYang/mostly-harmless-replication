# R code for Figure 4-1-1         #
# Required packages               #
# - dplyr: easy data manipulation #
# - lubridate: data management    #
# - ggplot2: making pretty graphs #
# - gridExtra: combine graphs     #
library(dplyr)
library(ggplot2)
library(gridExtra)

# Download data and unzip the data
# download.file('http://economics.mit.edu/files/397', 'asciiqob.zip')
# unzip('asciiqob.zip')

# Read the data into a dataframe
pums = read.table('asciiqob.txt',
                  header           = FALSE,
                  stringsAsFactors = FALSE)
names(pums) <- c('lwklywge', 'educ', 'yob', 'qob', 'pob')

# Collapse for means
pums.qob.means      <- pums %>% group_by(yob, qob) %>% summarise_each(funs(mean))

# Add dates
pums.qob.means$yqob <- ymd(paste0("19",
                                  pums.qob.means$yob,
                                  pums.qob.means$qob * 3),
                           truncated = 2)

# Plot data
g.pums <- ggplot(pums.qob.means, aes(x = yqob))

# Function for plotting data
plot.qob <- function(ggplot.obj, ggtitle, ylab) {
  gg.colours <- c("firebrick", rep("black", 3), "white")
  ggplot.obj + geom_line(aes(y = educ))                                 +
               geom_point(aes(y = educ, colour = factor(qob)),
                              size = 4)                                 +
               geom_text(aes(y = educ, label = qob, colour = "white"),
                         size  = 2,
                         hjust = 0.5, vjust = 0.5,
                         show_guide = FALSE)                            +
               scale_colour_manual(values = gg.colours, guide = FALSE)  +
               ggtitle(ggtitle)                                         +
               xlab("Year of birth")                                    +
               ylab(ylab)                                               +
               theme_set(theme_gray(base_size = 10))
}

p.educ     <- plot.qob(g.pums,
                       "A. Average education by quarter of birth (first stage)",
                       "Years of education")
p.lwklywge <- plot.qob(g.pums,
                       "B. Average weekly wage by quarter of birth (reduced form)",
                       "Log weekly earnings")

p.ivgraph  <- arrangeGrob(p.educ, p.lwklywge)

ggsave(p.ivgraph, file = "Figure 4-1-1-R.png", height = 12, width = 8, dpi = 300)

# End of script
