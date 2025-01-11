library(tidyverse)
library(tidymodels)
library(usemodels)
library(vip)
library(ggstatsplot)

################################################################################
# Inspect Data

test <- read.csv('titanic_test.csv')
train <- read.csv('titanic_train.csv')


glimpse(train)
train$Pclass <- as.factor(train$Pclass) # feature engineering
train$Survived <- as.factor(train$Survived) # feature engineering
skimr::skim(train) # looking at missing + more

test$Pclass <- as.factor(test$Pclass) # feature engineering

# str_sub(Cabin, 1, 1) dplyr
# str_extract(Cabin, "^.") regex

################################################################################
# Explore Data for basic understanding

train %>%
  ggplot(aes(x = Sex, fill = Sex)) +
  geom_bar(position = "dodge") +
  facet_wrap(~ Survived, labeller = as_labeller(c('0' = 'Did Not Survive', '1' = 'Survived'))) +
  labs(x = NULL, y = "Number of People") +
  theme(
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

train %>% ggplot(aes(x = Pclass, fill = Pclass)) +
  geom_bar(position = 'dodge') + 
  facet_grid(~Survived, labeller = as_labeller(c('0' = 'Did Not Survive', '1' = 'Survived'))) 

### The '3' Passenger class had the largest fatality. One can assume these were the cheaper cabins further down into the ship.
### OR, did they have the most people? Both...

train %>% group_by(Pclass) %>% summarise(avg_price = mean(Fare))
train %>% group_by(Pclass) %>% count()

################################################################################
# Building Model

set.seed(123)
titanic_split <- initial_split(train, strata = Survived)
titanic_train <- training(titanic_split)
titanic_test <- testing(titanic_split)

### Resample (ensures quality, helps tune)
titanic_folds <- bootstraps(titanic_train, strata = Survived)
titanic_folds

### Model Scaffolding

use_ranger(Survived ~., data = titanic_train) # From this we get below


ranger_recipe <- 
  recipe(formula = Survived ~ ., data = titanic_train) %>% 
  step_impute_knn(Cabin)

ranger_spec <- 
  rand_forest(mtry = tune(), min_n = tune(), trees = 1000) %>% 
  set_mode("classification") %>% 
  set_engine("ranger") 

ranger_workflow <- 
  workflow() %>% 
  add_recipe(ranger_recipe) %>% 
  add_model(ranger_spec) 

set.seed(84361)
doParallel::registerDoParallel()
ranger_tune <-
  tune_grid(ranger_workflow, 
            resamples = titanic_folds, 
            grid = 11)

################################################################################
# Results

show_best(ranger_tune, metric = 'roc_auc')

autoplot(ranger_tune)


################################################################################
# Finalizing

final_rf <- ranger_workflow %>% 
  finalize_workflow(select_best(ranger_tune))

final_rf

### fitting to split
titanic_fit <- last_fit(final_rf, titanic_split) 
titanic_fit

################################################################################
# Metrics

collect_metrics(titanic_fit)

################################################################################
# Collecting Predictions

preds <- collect_predictions(titanic_fit)

preds %>% conf_mat(truth = Survived, estimate = .pred_class)

################################################################################
# Unseen Data

predict(titanic_fit$.workflow[[1]], test)

################################################################################
# VIP

imp_spec <- ranger_spec %>% 
  finalize_model(select_best(ranger_tune)) %>% 
  set_engine('ranger', importance = 'permutation')

workflow() %>% 
  add_recipe(ranger_recipe) %>% 
  add_model(imp_spec) %>% 
  fit(train) %>% 
  pull_workflow_fit() %>% 
  vip(aesthetics = list(alpha = .8, fill = 'dodgerblue'))


################################################################################
# Correlation






