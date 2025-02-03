# Titanic Survival Prediction with Random Forest

This project leverages a Random Forest model to predict survival outcomes on the Titanic dataset. The goal of the project is to create a robust predictive model while utilizing effective data preprocessing and visualization techniques.


The Titanic dataset is one of the most well-known datasets in data science and machine learning. It provides information on passengers aboard the Titanic, including personal details (e.g., age, gender, and class) and their survival status. This project aims to:

- Preprocess the data using the recipes package from the tidymodels framework.
- Build a Random Forest classification model using ranger to predict survival outcomes.
- Evaluate the model's performance with metrics like accuracy and confusion matrices

### 1. Data Preprocessing
Used the recipes package for preprocessing.
Preprocessing steps included:
Handling missing values using k-Nearest Neighbors imputation (step_impute_knn()).
Normalizing numeric features like Fare (step_normalize()).
Converting categorical variables (e.g., Cabin_assi, Sex) into factors for compatibility with the model.

### 2. Modeling
Built a Random Forest model using the ranger engine.
The model predicts the Survived status of passengers based on features such as:
Passenger class (Pclass)
Fare (Fare)
Embarked location (Embarked)
Gender (Sex)
Cabin assignment (Cabin_assi)

### 3. Evaluation
The model's predictions were evaluated using:
Confusion matrices (conf_mat) to analyze prediction accuracy.
Metrics such as accuracy, precision, and recall.
Visualizations were created to interpret the results effectively.
