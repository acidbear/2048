library(tidyverse)
library(ggpubr)
library(dplyr)

clean <- bot_data %>% 
          mutate(isLastTurn = case_when(lead(`Bot id`) == `Bot id` ~ FALSE,
                           TRUE ~ TRUE)) %>% 
            mutate(weightClass = substr(`Bot id`,1,1)) %>% 
             mutate( prefStrength = case_when(`up weight`== 25 | `down weight` == 25
                                         | `left weight` == 25 | `right weight` == 25 ~ "Strong",
                                         `up weight`== 5 | `down weight` == 5
                                       | `left weight` == 5 | `right weight` == 5 ~ "Weak",
                                         TRUE ~ "Control")) %>% 
           mutate(direction = case_when(`up weight` > `down weight` & `left weight` == 1 ~ "U",
                              `down weight` > `up weight` & `right weight` == 1 ~ "D",
                              `left weight` > `right weight` & `up weight` == 1 ~ "L",
                              `right weight` > `left weight` & `down weight` == 1 ~ "R",
                               TRUE ~ NA))

score_summary <- clean %>% 
            filter(isLastTurn) %>% 
             group_by(weightClass) %>% 
              summarize(avg_score = mean(`Current score`),
                        median_score = median(`Current score`),
                        sd_score = sd(`Current score`))

attributes(clean)
attributes(score_summary)
glimpse(clean)

final_scores <- clean %>% 
    filter(isLastTurn) %>% 
     rename(finalScore = `Current score`)


ggplot(final_scores,aes(x=`Turn no.`, 
                   y= `Current score`,
                   color=prefStrength)) + 
          geom_point() +
          geom_smooth(method='lm',
                      se = FALSE)
           labs(x = "Turn Number",
                y="Final Score",
                title="Turn number vs final score",
                color= "Weight settings")

ggplot(final_scores,aes(x=prefStrength,y=`Current score`)) +
  geom_boxplot()

View(filter(final_scores, `Current score` > 3500))

best_score <- top_n(final_scores,1,finalScore)
top_score <- best_score$`Bot id`

best_perf <- allCols %>% 
  filter(,`Bot id` == top_score) %>% 
  mutate(score_gained_on_move = `Current score` - lag(`Current score`))

res <- cor.test(final_scores$finalScore, final_scores$`Turn no.`, 
                method = "pearson")
res

comb_sing <- clean %>% 
  mutate(case_when(`up weight` != `down weight` & `left weight` != `right weight` ~ "COMBO",
                   `up weight` == `down weight` & `left weight` == `right weight` ~ "CONTROL",
                   TRUE ~ "SINGLE"))

counts = c(50,100,150,200,250,300,350,400,450)

r <- nrow(filter(clean,`Turn no.` == 300))


inter <- clean %>% 
  group_by(`Turn no.`) %>% 
  summarize(count = n()) %>% ungroup() %>% 
  filter(`Turn no.` %in% counts)

df <- data.frame("Turn no." = counts,check.names = FALSE) %>% 
  left_join(inter) %>% replace(is.na(.),0)

glimpse(df)
?mean
mean(final_scores$`Turn no.`)

