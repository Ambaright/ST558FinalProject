# Load the libraries
library(plumber)
library(tidyverse)
library(tidymodels)

#* @apiTitle Diabetes Prediction API
#* @apiDescription This is an API that obtains predictions from a Random Forest model with an mtry = 3 parameter, as determined by the modeling investigation completed in the modeling file. This API has three endpoints: a pred endpoint, an info endpoint, and a confusion endpoint. The pred endpoint allows the user to predict the probability of having diabetes based on any selected level of categorical predictor variables or any BMI value. The info endpoint will give my name and the link to the EDA and Modeling websites. And the confusion endpoint will produce a plot of the confusion matrix for my model fit. That is, it is comparing the predictions from the model to the actual values from the data set.

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

rf_full_model <- rand_forest(mtry = 3) |>
  set_engine("ranger") |>
  set_mode("classification")

rf_full_wkf <- workflow() |>
  add_model(rf_full_model) |>
  add_recipe(rf_recipe)

final_model <- fit(rf_full_wkf, data = full_data)

# We are asked to have default values for any predictors used in our 'best' model, such that if the
# predictor is numeric use the mean of the variable, and if categorical use the most prevalent class.

default_values <- full_data |>
  summarise(
    HighBP = levels(HighBP)[which.max(table(HighBP))],
    HighChol = levels(HighChol)[which.max(table(HighChol))],
    HeartDiseaseorAttack = levels(HeartDiseaseorAttack)[which.max(table(HeartDiseaseorAttack))],
    PhysActivity = levels(PhysActivity)[which.max(table(PhysActivity))],
    BMI = mean(BMI)
  )

# Set up Pred endpoint
#* Predict Diabetes
#* @param HighBP High blood pressure, No/Yes, default: No
#* @param HighChol High cholesterol, No/Yes, default: No
#* @param HeartDiseaseorAttack History of coronary heart disease or myocardial infection, No/Yes, default: No
#* @param PhysActivity Physical activity in the past 30 days, not including job, No/Yes, default: Yes
#* @param BMI Body mass index, default: 28.4
#* @get /pred
function(HighBP = default_values$HighBP,
         HighChol = default_values$HighChol,
         HeartDiseaseorAttack = default_values$HeartDiseaseorAttack,
         PhysActivity = default_values$PhysActivity,
         BMI = default_values$BMI) {
  
  input_data <- tibble(
    HighBP = as.factor(HighBP),
    HighChol = as.factor(HighChol),
    HeartDiseaseorAttack = as.factor(HeartDiseaseorAttack),
    PhysActivity = as.factor(PhysActivity),
    BMI = as.numeric(BMI)
  )
  
  predict(final_model, new_data = input_data, type = "prob") |>
    pull(.pred_Yes) |>
    round(4)
  
}

# Example calls for /pred endpoint:
# http://127.0.0.1:6586/pred
# http://127.0.0.1:6586/pred?HighBP=Yes&HighChol=No&HeartDiseaseorAttack=No&PhysActivity=No&BMI=28
# http://127.0.0.1:6586/pred?BMI=35&HighBP=Yes&HighChol=Yes

# Info endpoint
#* Info about the API
#* @get /info
function() {
  list(
    name = "Amanda Baright",
    github_page = "https://ambaright.github.io/ST558FinalProject/"
  )
}


