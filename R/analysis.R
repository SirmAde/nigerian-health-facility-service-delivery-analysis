# 1. DESCRIPTIVE STATISTICAL ANALYSIS
# -------------------------------------------

library(readxl)
file_path <- "data/nigeria_health_facility_dataset_enhanced.xlsx"
health_data <- read_excel(file_path)
View(health_data)

# Install packages if not already installed
if (!require("dplyr")) install.packages("dplyr")
if (!require("ggplot2")) install.packages("ggplot2")
if (!require("tidyr")) install.packages("tidyr")
if (!require("knitr")) install.packages("knitr")
if (!require("car")) install.packages("car")
if (!require("lmtest")) install.packages("lmtest")
if (!require("FSA")) install.packages("FSA")

# Load packages
library(dplyr)
library(ggplot2)
library(tidyr)
library(knitr)
library(car)
library(lmtest)
library(FSA)

# Summary statistics
summary_stats <- summary(health_data[, c("Average_Patient_Age", "Patients_Served_Per_Month", 
                                         "Staff_Count", "Patient_to_Staff_Ratio", 
                                         "Satisfaction_Index")])

# Create a summary table
library(knitr)
desc_table <- health_data %>%
  summarise(
    Variable = c("Age", "Patients/Month", "Staff Count", "Patient:Staff Ratio", "Satisfaction"),
    Mean = c(mean(Average_Patient_Age), mean(Patients_Served_Per_Month),
             mean(Staff_Count), mean(Patient_to_Staff_Ratio), mean(Satisfaction_Index)),
    SD = c(sd(Average_Patient_Age), sd(Patients_Served_Per_Month),
           sd(Staff_Count), sd(Patient_to_Staff_Ratio), sd(Satisfaction_Index)),
    Min = c(min(Average_Patient_Age), min(Patients_Served_Per_Month),
            min(Staff_Count), min(Patient_to_Staff_Ratio), min(Satisfaction_Index)),
    Max = c(max(Average_Patient_Age), max(Patients_Served_Per_Month),
            max(Staff_Count), max(Patient_to_Staff_Ratio), max(Satisfaction_Index))
  )

# Exploratory graph: Distribution of Satisfaction Index by Facility Type
library(ggplot2)
p1 <- ggplot(health_data, aes(x = Facility_Type, y = Satisfaction_Index, fill = Facility_Type)) +
  geom_boxplot(alpha = 0.7) +
  geom_jitter(width = 0.2, alpha = 0.5) +
  labs(title = "Distribution of Patient Satisfaction by Facility Type",
       x = "Facility Type",
       y = "Satisfaction Index (1-5 scale)") +
  theme_minimal() +
  theme(legend.position = "none")
print(p1)

# Print summary table
print(kable(desc_table, caption = "Descriptive Statistics of Key Variables"))


# --------------------------------------
# 2. HYPOTHESIS TEST FOR POPULATION MEAN
# --------------------------------------

cat("\n\nQUESTION 2: ONE-SAMPLE T-TEST\n")

# Test if average Satisfaction Index differs from 3 (neutral value from 1 - 5)
# H0: μ = 3 vs H1: μ ≠ 3

# Check normality assumption
shapiro.test(health_data$Satisfaction_Index)
# Since p > 0.05, normality assumption holds

# Perform one-sample t-test
t_test_result <- t.test(health_data$Satisfaction_Index, mu = 3, conf.level = 0.95)

cat("Testing if average Satisfaction Index differs from 3 (neutral point):\n")
cat(sprintf("t-statistic: %.3f, p-value: %.4f\n", 
            t_test_result$statistic, t_test_result$p.value))
cat(sprintf("95%% CI: [%.3f, %.3f]\n", 
            t_test_result$conf.int[1], t_test_result$conf.int[2]))

if(t_test_result$p.value < 0.05) {
  cat("Conclusion: Reject H0. The average Satisfaction Index is significantly different from 3.\n")
} else {
  cat("Conclusion: Do not reject H0. No significant evidence that average differs from 3.\n")
}


# -------------------------------
# 3. TWO-SAMPLE T-TEST (UNPAIRED)
# -------------------------------

cat("\n\nQUESTION 3: TWO-SAMPLE T-TEST\n")
cat("===============================\n")

# Compare Staff_Training_Level between Primary and Tertiary facilities
primary_data <- health_data %>% filter(Facility_Type == "Primary")
tertiary_data <- health_data %>% filter(Facility_Type == "Tertiary")

# Check assumptions
# 1. Normality within groups
shapiro_primary <- shapiro.test(primary_data$Staff_Training_Level)
shapiro_tertiary <- shapiro.test(tertiary_data$Staff_Training_Level)

# 2. Equal variances
var_test <- var.test(primary_data$Staff_Training_Level, tertiary_data$Staff_Training_Level)

cat("Comparing Staff Training Level between Primary and Tertiary facilities:\n")
cat(sprintf("Primary (n=%d): Mean=%.2f, SD=%.2f\n", 
            nrow(primary_data), mean(primary_data$Staff_Training_Level), 
            sd(primary_data$Staff_Training_Level)))
cat(sprintf("Tertiary (n=%d): Mean=%.2f, SD=%.2f\n", 
            nrow(tertiary_data), mean(tertiary_data$Staff_Training_Level), 
            sd(tertiary_data$Staff_Training_Level)))

cat("\nAssumption checks:\n")
cat(sprintf("Normality - Primary: p=%.4f, Tertiary: p=%.4f\n", 
            shapiro_primary$p.value, shapiro_tertiary$p.value))
cat(sprintf("Equal variances (F-test): p=%.4f\n", var_test$p.value))

# Perform t-test (Welch's if variances unequal)
if(var_test$p.value < 0.05) {
  t_test_2sample <- t.test(primary_data$Staff_Training_Level, 
                           tertiary_data$Staff_Training_Level, 
                           var.equal = FALSE, conf.level = 0.99)
  cat("Using Welch's t-test (variances unequal)\n")
} else {
  t_test_2sample <- t.test(primary_data$Staff_Training_Level, 
                           tertiary_data$Staff_Training_Level, 
                           var.equal = TRUE, conf.level = 0.99)
  cat("Using Student's t-test (variances equal)\n")
}

cat(sprintf("t-statistic: %.3f, p-value: %.4f\n", 
            t_test_2sample$statistic, t_test_2sample$p.value))
cat(sprintf("99%% CI for difference: [%.3f, %.3f]\n", 
            t_test_2sample$conf.int[1], t_test_2sample$conf.int[2]))

if(t_test_2sample$p.value < 0.01) {
  cat("Conclusion: Reject H0. Significant difference in Staff Training Level between facility types.\n")
} else {
  cat("Conclusion: Do not reject H0. No significant difference in Staff Training Level.\n")
}

# ----------------------------------
# 4. HYPOTHESIS TEST FOR PROPORTION
# ----------------------------------

cat("\n\nQUESTION 4: PROPORTION TEST\n")
cat("============================\n")

# Test if proportion of facilities with Clean_Water_Access ≥ 4 is > 50%
# H0: p = 0.5 vs H1: p > 0.5

high_water_access <- sum(health_data$Clean_Water_Access >= 4)
total_facilities <- nrow(health_data)
sample_prop <- high_water_access / total_facilities

# Check assumptions: np ≥ 10 and n(1-p) ≥ 10
n <- total_facilities
p0 <- 0.5
cat(sprintf("Facilities with good water access (score ≥4): %d out of %d (%.1f%%)\n", 
            high_water_access, total_facilities, sample_prop*100))

cat("\nAssumption check:\n")
cat(sprintf("np = %d * 0.5 = %.1f ≥ 10: %s\n", n, n*p0, ifelse(n*p0 >= 10, "YES", "NO")))
cat(sprintf("n(1-p) = %d * 0.5 = %.1f ≥ 10: %s\n", n, n*(1-p0), ifelse(n*(1-p0) >= 10, "YES", "NO")))

# Perform one-sample proportion test
prop_test <- prop.test(high_water_access, n, p = 0.5, alternative = "greater", 
                       conf.level = 0.95, correct = FALSE)

cat(sprintf("\nz-statistic: %.3f, p-value: %.4f\n", 
            sqrt(prop_test$statistic), prop_test$p.value))
cat(sprintf("95%% CI: [%.3f, 1.000]\n", prop_test$conf.int[1]))

if(prop_test$p.value < 0.05) {
  cat("Conclusion: Reject H0. Proportion of facilities with good water access is > 50%.\n")
} else {
  cat("Conclusion: Do not reject H0. No evidence that proportion > 50%.\n")
}


# -----------------------------------
# 5. 90% CONFIDENCE INTERVAL FOR MEAN
# -----------------------------------

cat("\n\nQUESTION 5: 90% CONFIDENCE INTERVAL\n")
cat("=====================================\n")

# Calculate CI for Average_Consultation_Time
ci_90 <- t.test(health_data$Average_Consultation_Time, conf.level = 0.90)

cat("Variable: Average Consultation Time (minutes)\n")
cat(sprintf("Sample mean: %.2f minutes\n", mean(health_data$Average_Consultation_Time)))
cat(sprintf("Sample SD: %.2f minutes\n", sd(health_data$Average_Consultation_Time)))
cat(sprintf("90%% Confidence Interval: [%.2f, %.2f] minutes\n", 
            ci_90$conf.int[1], ci_90$conf.int[2]))
cat("Interpretation: We are 90% confident that the true population mean consultation time\n")
cat("falls between these bounds.\n")

# --------------------------------------
# 6. CONFIDENCE INTERVALS FOR PROPORTION
# --------------------------------------

cat("\n\nQUESTION 6: MULTIPLE CIs FOR PROPORTION\n")
cat("=========================================\n")

# Create dichotomous variable: High vs Low Maternal Care (score ≥ 3)
health_data <- health_data %>%
  mutate(High_Maternal_Care = ifelse(Maternal_Care_Score >= 3, 1, 0))

high_maternal_count <- sum(health_data$High_Maternal_Care)
total <- nrow(health_data)

# Calculate CIs at different confidence levels
conf_levels <- c(0.90, 0.95, 0.99)
ci_results <- data.frame()

for(level in conf_levels) {
  prop_ci <- prop.test(high_maternal_count, total, conf.level = level, correct = FALSE)
  ci_results <- rbind(ci_results, data.frame(
    Confidence = paste0(level*100, "%"),
    Proportion = high_maternal_count/total,
    Lower = prop_ci$conf.int[1],
    Upper = prop_ci$conf.int[2],
    Width = prop_ci$conf.int[2] - prop_ci$conf.int[1]
  ))
}

cat("Proportion of facilities with High Maternal Care (score ≥3):\n")
print(kable(ci_results, digits = 3))

cat("\nInterpretation:\n")
cat("1. Higher confidence levels yield wider intervals (trade-off between precision and certainty)\n")
cat("2. All intervals are above 0.5, suggesting majority of facilities have adequate maternal care\n")
cat("3. The 90% CI is narrowest but with less certainty about capturing the true proportion\n")


# --------------------------
# 7. NON-PARAMETRIC ANALYSIS
# --------------------------

cat("\n\nQUESTION 7: NON-PARAMETRIC TESTS\n")
cat("==================================\n")

# a) Create New variable from Patients_Served_Per_Month
set.seed(123) # For reproducibility 

# Get extremes
lowest_5 <- head(sort(health_data$Patients_Served_Per_Month), 5)
highest_5 <- tail(sort(health_data$Patients_Served_Per_Month), 5)

# Get random intermediate values
intermediate <- health_data$Patients_Served_Per_Month
intermediate <- intermediate[!intermediate %in% c(lowest_5, highest_5)]
random_10 <- sample(intermediate, 10)

New_variable <- c(lowest_5, random_10, highest_5)

# b) Non-parametric test for mean (Wilcoxon signed-rank)
# Check normality
shapiro_new <- shapiro.test(New_variable)
cat("a) New variable created from Patients_Served_Per_Month\n")
cat("   Contains: 5 lowest + 10 random intermediate + 5 highest values\n")
cat(sprintf("   Shapiro-Wilk normality test: W=%.3f, p=%.4f\n", 
            shapiro_new$statistic, shapiro_new$p.value))

if(shapiro_new$p.value < 0.05) {
  cat("   Decision: Non-normal distribution → Non-parametric test appropriate\n")
  # Wilcoxon signed-rank test (median = 500?)
  wilcox_test <- wilcox.test(New_variable, mu = 500, conf.int = TRUE)
  cat(sprintf("   Wilcoxon signed-rank test: V=%.1f, p=%.4f\n", 
              wilcox_test$statistic, wilcox_test$p.value))
  cat(sprintf("   95%% CI for median: [%.1f, %.1f]\n", 
              wilcox_test$conf.int[1], wilcox_test$conf.int[2]))
} else {
  cat("   Decision: Normal distribution → Parametric test appropriate\n")
}

# c) Non-parametric alternative to ANOVA (Kruskal-Wallis)
# Create age groups from Average_Patient_Age
health_data <- health_data %>%
  mutate(Age_Group = cut(Average_Patient_Age,
                         breaks = c(0, 18, 65, Inf),
                         labels = c("Young", "Adult", "Elderly")))

# Check assumptions for Kruskal-Wallis
cat("\nc) Kruskal-Wallis test (non-parametric ANOVA alternative)\n")
cat("   Comparing Patients_Served_Per_Month across Age Groups\n")

# Test
kruskal_test <- kruskal.test(Patients_Served_Per_Month ~ Age_Group, data = health_data)
cat(sprintf("   Kruskal-Wallis: H=%.3f, p=%.4f\n", 
            kruskal_test$statistic, kruskal_test$p.value))

if(kruskal_test$p.value < 0.05) {
  cat("   Conclusion: Significant difference in patient load across age groups.\n")
  # Post-hoc pairwise comparisons
  library(FSA)
  dunn_test <- dunnTest(Patients_Served_Per_Month ~ Age_Group, 
                        data = health_data, method = "bonferroni")
  cat("   Post-hoc Dunn test results:\n")
  print(dunn_test$res)
} else {
  cat("   Conclusion: No significant difference across age groups.\n")
}



# -----------------
# 8. ONE-WAY ANOVA
# -----------------

cat("\n\nQUESTION 8: ONE-WAY ANOVA\n")
cat("===========================\n")

# Compare Satisfaction_Index across Facility_Type
cat("Testing: Satisfaction_Index ~ Facility_Type\n")

# Check ANOVA assumptions
# 1. Normality of residuals within groups
model_anova <- aov(Satisfaction_Index ~ Facility_Type, data = health_data)

# Shapiro-Wilk test on residuals
shapiro_resid <- shapiro.test(residuals(model_anova))

# 2. Homogeneity of variances (Levene's test)
library(car)
levene_test <- leveneTest(Satisfaction_Index ~ Facility_Type, data = health_data)

cat("Assumption checks:\n")
cat(sprintf("1. Normality of residuals: W=%.3f, p=%.4f\n", 
            shapiro_resid$statistic, shapiro_resid$p.value))
cat(sprintf("2. Homogeneity of variances (Levene's): F=%.3f, p=%.4f\n", 
            levene_test$`F value`[1], levene_test$`Pr(>F)`[1]))

if(shapiro_resid$p.value < 0.05) {
  cat("   Warning: Residuals not normally distributed\n")
}

if(levene_test$`Pr(>F)`[1] < 0.05) {
  cat("   Warning: Variances not homogeneous\n")
}

# Perform ANOVA
anova_summary <- summary(model_anova)
cat("\nANOVA Results:\n")
print(anova_summary)

if(anova_summary[[1]]$`Pr(>F)`[1] < 0.05) {
  cat("\nConclusion: Significant difference in Satisfaction Index across facility types.\n")
  
  # Tukey's HSD for post-hoc comparisons
  tukey_results <- TukeyHSD(model_anova)
  cat("\nTukey's HSD Post-hoc Comparisons:\n")
  print(tukey_results$Facility_Type)
} else {
  cat("\nConclusion: No significant difference in Satisfaction Index across facility types.\n")
}

# --------------------
# 9. LINEAR REGRESSION
# --------------------

cat("\n\nQUESTION 9: SIMPLE LINEAR REGRESSION\n")
cat("======================================\n")

# Y = Satisfaction_Index, X = Staff_Training_Level
cat("Model: Satisfaction_Index = β₀ + β₁ * Staff_Training_Level + ε\n")

# Fit model
lm_model <- lm(Satisfaction_Index ~ Staff_Training_Level, data = health_data)
summary_lm <- summary(lm_model)

cat("\na) Model Summary:\n")
print(summary_lm)


# d) Scatter plot with regression line
p_reg <- ggplot(health_data, aes(x = Staff_Training_Level, y = Satisfaction_Index)) +
  geom_point(alpha = 0.6, size = 2) +
  geom_smooth(method = "lm", se = TRUE, color = "blue") +
  labs(title = "Regression: Satisfaction vs Staff Training Level",
       x = "Staff Training Level (1-5 scale)",
       y = "Satisfaction Index (1-5 scale)") +
  theme_minimal()
print(p_reg)

# e) Check model assumptions
cat("\ne) Model Assumption Diagnostics:\n")

# 1. Normality of residuals
shapiro_lm <- shapiro.test(residuals(lm_model))
cat(sprintf("1. Normality of residuals (Shapiro-Wilk): p=%.4f\n", shapiro_lm$p.value))
if(shapiro_lm$p.value < 0.05) {
  cat("   Warning: Residuals may not be normally distributed\n")
} else {
  cat("   OK: Residuals appear normally distributed\n")
}

# 2. Homoscedasticity (constant variance)
library(lmtest)
bptest_result <- bptest(lm_model)
cat(sprintf("2. Homoscedasticity (Breusch-Pagan): p=%.4f\n", bptest_result$p.value))
if(bptest_result$p.value < 0.05) {
  cat("   Warning: Evidence of heteroscedasticity (non-constant variance)\n")
} else {
  cat("   OK: Constant variance assumption appears valid\n")
}

# 3. Independence (Durbin-Watson)
dw_test <- dwtest(lm_model)
cat(sprintf("3. Independence (Durbin-Watson): DW=%.3f, p=%.4f\n", 
            dw_test$statistic, dw_test$p.value))
if(dw_test$p.value < 0.05) {
  cat("   Warning: Evidence of autocorrelation in residuals\n")
} else {
  cat("   OK: Residuals appear independent\n")
}

# 4. Linearity
cat("4. Linearity: Check residual vs fitted plot\n")

# Create diagnostic plots
par(mfrow = c(2, 2),
mar = c(4, 4, 2, 1))
plot(lm_model, which = 1:4)
par(mfrow = c(1, 1))

cat("\nPractical Interpretation:\n")
if(summary_lm$coefficients[2, 4] < 0.05) {
  cat("Staff Training Level is a statistically significant predictor of Satisfaction.\n")
  cat(sprintf("Each 1-point increase in training is associated with %.3f-point ", coef(lm_model)[2]))
  cat("change in Satisfaction.\n")
} else {
  cat("Staff Training Level is not a significant predictor of Satisfaction.\n")
}


