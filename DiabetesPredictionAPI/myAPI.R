# Load the libraries
library(plumber)
library(tidyverse)
library(tidymodels)

#* @apiTitle Diabetes Prediction API
#* @apiDescription This is an API that obtains predictions from a Random Forest model with an mtry = 3 parameter, as determined by the modeling investigation completed in the modeling file. This API has three endpoints: a pred endpoint, an info endpoint, and a confusion endpoint.

# Read in the data

full_data <- read_csv("diabetes_binary_health_indicators_BRFSS2015.csv")

head(full_data)

full_data <- full_data |>
  mutate(
    HighBP = factor(HighBP, levels = c(0,1), labels = c("No", "Yes")),
    HighChol = factor(HighChol, levels = c(0,1), labels = c("No", "Yes")),
    HeartDiseaseorAttack = factor(HeartDiseaseorAttack, levels = c(0,1), labels = c("No", "Yes")),
    PhysActivity = factor(PhysActivity, levels = c(0,1), labels = c("No", "Yes")),
    Diabetes_binary = factor(Diabetes_binary, levels = c(0,1), labels = c("No", "Yes"))
  ) |>
  select(Diabetes_binary, HighBP, HighChol, HeartDiseaseorAttack, PhysActivity, BMI)

head(full_data)

# Define and fit the best model to the entire data set.

rf_recipe <- recipe(Diabetes_binary ~ ., data = full_data)


