# Statistical Analysis of Service Delivery in Nigerian Health Facilities

## Overview

This project applies descriptive and inferential statistical methods to examine service delivery across **100 health facilities in Nigeria**.

The analysis explores facility characteristics, operational capacity, quality-of-care indicators, resource access, and patient satisfaction. Statistical tests are used to investigate differences between facility groups, evaluate resource-access indicators, and assess whether operational factors such as staff training are associated with patient satisfaction.

The analysis was conducted in **R** using packages including `dplyr`, `ggplot2`, `car`, `lmtest`, `FSA`, `readxl`, and `knitr`.

---

## Research Objective

The primary objective of this study is to statistically examine patterns in health-facility service delivery and identify factors associated with patient satisfaction.

The analysis addresses several questions:

1. How do service-delivery characteristics vary across Nigerian health facilities?
2. Does average patient satisfaction differ from the neutral midpoint of the satisfaction scale?
3. Does staff training differ between Primary and Tertiary facilities?
4. What proportion of facilities have high access to clean water?
5. What is the estimated average consultation time?
6. What proportion of facilities meet the defined maternal-care threshold?
7. How is patient volume distributed across different patient-age groups?
8. Does patient satisfaction differ by facility type?
9. Is staff training associated with patient satisfaction?

---

## Dataset

The dataset contains information from:

**100 health facilities across Nigerian states**

The facilities are distributed across three facility tiers:

| Facility Type | Number of Facilities |
|---|---:|
| Primary | 38 |
| Secondary | 29 |
| Tertiary | 33 |
| **Total** | **100** |

The dataset contains **14 variables** covering demographic, operational, staffing, healthcare quality, resource-access, and patient-satisfaction indicators.

### Main Variables

| Variable | Description |
|---|---|
| State | Nigerian state where the facility is located |
| Facility Type | Primary, Secondary, or Tertiary |
| Average Patient Age | Average age of patients served |
| Patients Served Per Month | Monthly patient volume |
| Staff Count | Number of staff at the facility |
| Patient-to-Staff Ratio | Ratio of patients served to available staff |
| Average Consultation Time | Average consultation duration |
| Staff Training Level | Measure of staff training |
| Vaccine Availability | Availability of vaccines |
| Clean Water Access | Facility clean-water access score |
| Maternal Care Score | Maternal-care quality/access score |
| Satisfaction Index | Patient satisfaction score on a 1–5 scale |

---

## Descriptive Statistics

The main continuous variables were summarised using means, standard deviations, minimums, and maximums.

| Variable | Mean | SD | Range |
|---|---:|---:|---:|
| Average Patient Age (years) | 44.6 | 26.1 | 2–88 |
| Patients Served / Month | 534.4 | 279.8 | 79–993 |
| Patient-to-Staff Ratio | 20.3 | 28.4 | 1.0–155.8 |
| Satisfaction Index | 2.88 | 0.92 | 1.0–5.0 |
| Consultation Time (minutes) | 26.4 | 11.6 | 5.6–45.0 |

The wide range in the patient-to-staff ratio indicates substantial variation in staffing pressure across facilities. The maximum observed ratio was approximately **155.8 patients per staff member**.

---

# Methodology

The analysis was conducted in several stages.

## 1. Data Preparation

The health-facility dataset was imported into R using the `readxl` package.

Data manipulation and transformation were performed using `dplyr` and `tidyr`.

## 2. Descriptive Analysis

Descriptive statistics were calculated for key continuous variables, including:

- Patient age
- Monthly patient volume
- Staff count
- Patient-to-staff ratio
- Patient satisfaction
- Consultation time

Visual exploration was performed using `ggplot2`.

## 3. Assumption Checking

Where applicable, statistical assumptions were assessed before conducting parametric tests.

The analysis included:

- Shapiro-Wilk tests for normality
- Variance testing
- Levene's test for homogeneity of variance
- Residual diagnostics for regression

Where appropriate, non-parametric methods were used.

## 4. Inferential Analysis

The following statistical methods were applied:

- One-sample t-test
- Independent-samples t-test
- One-sample proportion test
- Confidence intervals
- Wilcoxon signed-rank test
- Kruskal-Wallis test
- One-way ANOVA
- Simple linear regression
- Regression diagnostics

The general significance level was:

**α = 0.05**

A stricter significance level of:

**α = 0.01**

was used for the Primary versus Tertiary staff-training comparison.

---

# Results

## 1. Patient Satisfaction

The mean Satisfaction Index was:

**Mean = 2.88**

on a 1–5 scale.

A one-sample t-test was used to determine whether the population mean differed from the neutral midpoint of 3.0.

### Hypotheses

**H₀:** μ = 3.0

**H₁:** μ ≠ 3.0

### Result

- t(99) = **−1.30**
- p = **0.195**
- 95% CI = **[2.70, 3.06]**

The result does not provide sufficient statistical evidence that the mean satisfaction level differs from the neutral midpoint of 3.0.

Although the sample mean was slightly below 3.0, the difference was not statistically significant.

---

## 2. Staff Training: Primary vs Tertiary Facilities

Staff training levels were compared between Primary and Tertiary facilities using an independent-samples t-test.

The analysis found:

- t(69) = **−0.49**
- p = **0.624**
- 99% CI for the mean difference = **[−1.02, 0.70]**

At the specified α = 0.01 significance level, there was no statistically significant evidence of a difference in staff-training levels between Primary and Tertiary facilities.

---

## 3. Clean Water Access

Clean-water access was evaluated by identifying facilities with a clean-water access score of **4 or higher**.

The observed proportion was:

**62 out of 100 facilities = 62%**

The proportion test in the R analysis evaluated whether this proportion was greater than 50%.

### Result

- Observed proportion = **0.62**
- z = **1.75** approximately
- p = **0.040**

At α = 0.05, the result provides evidence that the proportion of facilities meeting the defined clean-water access threshold is greater than 50%.

> **Note:** The current R code tests the proportion against a 50% benchmark (`p = 0.5`). If the intended research benchmark is 70%, the code should be updated before claiming that the 62% level is statistically below 70%.

---

## 4. Maternal Care

Facilities were classified according to whether their Maternal Care Score was at least 3.

The estimated proportion meeting this threshold was:

**65%**

Confidence intervals were calculated at three confidence levels:

| Confidence Level | Confidence Interval |
|---|---|
| 90% | [0.572, 0.728] |
| 95% | [0.557, 0.743] |
| 99% | [0.527, 0.773] |

As expected, increasing the confidence level produces a wider interval.

All three intervals remain above 50%, indicating that the estimated proportion of facilities meeting the defined maternal-care threshold is above one-half of the sample.

---

## 5. Average Consultation Time

The mean consultation time was:

**26.44 minutes**

The 90% confidence interval was:

**[24.52, 28.36] minutes**

This provides an estimate of the average consultation time represented by the sampled facilities.

---

## 6. Non-Parametric Analysis

A 20-facility subset of monthly patient volume was constructed using:

- 5 lowest observations
- 10 randomly selected intermediate observations
- 5 highest observations

A fixed random seed (`123`) was used to make the random selection reproducible.

The Shapiro-Wilk test indicated that the constructed sample was not normally distributed, so a Wilcoxon signed-rank test was used to compare the median against 500 patients per month.

### Result

- Wilcoxon V = **37**
- p = **0.004**
- 95% CI for the median = **[136, 457]**

The result provides statistical evidence that the median patient volume in this constructed sample differs from 500 patients per month.

---

## 7. Kruskal-Wallis Analysis

A Kruskal-Wallis test was used as a non-parametric alternative to one-way ANOVA.

In the R code, monthly patient volume was compared across three age groups created from average patient age:

- Young
- Adult
- Elderly

### Result

- H(2) = **0.65**
- p = **0.724**

The result does not provide evidence of a statistically significant difference in monthly patient volume across the defined age groups.

---

## 8. Patient Satisfaction by Facility Type

A one-way ANOVA was used to compare Satisfaction Index across:

- Primary
- Secondary
- Tertiary facilities

### Result

- F(2, 97) = **1.09**
- p = **0.342**
- η² = **0.022**

The result does not provide evidence of a statistically significant difference in patient satisfaction across facility types.

The effect size indicates that facility type accounts for approximately **2.2% of the observed variance** in satisfaction.

---

## 9. Staff Training and Patient Satisfaction

A simple linear regression was used to examine whether Staff Training Level predicts Satisfaction Index.

The estimated regression equation was:

**Satisfaction = 2.613 + 0.096 × Staff Training Level**

The model produced:

**R² = 0.026**

Staff training therefore explained approximately **2.6% of the variation** in satisfaction in the sample.

The regression slope was not statistically significant at the 5% level.

This suggests that staff training, considered as a single predictor, does not adequately explain variation in patient satisfaction within this dataset.

---

# Key Findings

The analysis produced several important findings:

### Patient Satisfaction
Average satisfaction was **2.88/5**, but was not statistically different from the neutral midpoint of 3.0.

### Facility Type
Patient satisfaction did not differ significantly across Primary, Secondary, and Tertiary facilities.

### Staff Training
No statistically significant difference in staff-training level was identified between Primary and Tertiary facilities.

### Clean Water Access
62% of facilities met the defined clean-water access threshold of 4 or higher.

The current analysis tests this against a **50% benchmark**.

### Maternal Care
Approximately 65% of facilities met the defined maternal-care threshold of 3 or higher.

### Staffing Pressure
The patient-to-staff ratio showed substantial variation, ranging from approximately **1:1 to 155.8:1**, indicating considerable differences in staffing pressure across facilities.

### Training and Satisfaction
Staff training explained only approximately **2.6%** of the variation in patient satisfaction and was not a statistically significant standalone predictor.

---

# Visualisation

The project includes graphical analysis of the health-facility data using `ggplot2`.

The visualisations include analysis of:

- Patient satisfaction by facility type
- Staff training and patient satisfaction
- Regression relationships
- Distributional patterns

Figures generated from the analysis are available in:

```text
results/figures/
