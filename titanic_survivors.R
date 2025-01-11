library(tidyverse)
library(tidymodels)


# Inspect Data
str(train)

# Explore Data for basic understanding
test <- read.csv('titanic_test.csv')
train <- read.csv('titanic_train.csv')

train %>%
  ggplot(aes(x = Sex, fill = Sex)) +
  geom_bar(position = "dodge") +
  facet_wrap(~ Survived, labeller = as_labeller(c('0' = 'Did Not Survive', '1' = 'Survived'))) +
  labs(x = NULL, y = "Number of People") +
  theme(
    strip.text = element_text(size = 12, face = "bold"),
    axis.text.x = element_blank(),
    axis.ticks.x = element_blank(),
    legend.position = "right"
  )

### Many more men perished than women.

(x <- train %>% summarise(pct_prish = sum(train$Survived == '0')/ nrow(train),
                    pct_women_prish = sum(train$Sex == 'female')/ nrow(train),
                    pct_men_prish = sum(train$Sex == 'male')/ nrow(train)) %>%
  pivot_longer(cols = everything(), names_to = "Label", values_to = "Percentage") %>%
  mutate(Percentage = round(Percentage, 2)))

### out of the 62% that perished, 65% were men.

## Now lets see what the difference is when it comes to classes












