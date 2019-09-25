pH Female Broodstock Histology Analysis
================
Shelly Trigg
9/24/2019

Load libraries

``` r
library(readxl)
library(ggplot2)
```

Read in data

``` r
female_data <- read_xlsx("HistologyScores.xlsx", sheet = 1)
```

Plot percent follicle area for each treatment group

``` r
ggplot(data = female_data, aes(x = pH,y = perc_follicle_area, group = as.factor(pH), fill = pH)) + geom_violin(trim = FALSE) + geom_boxplot(width = 0.2) + geom_jitter(shape =16, position= position_jitter(0.1)) + ylab("follicle area (%)") + theme_bw()
```

![](pHFemaleBroodstockHistoAnalysis_files/figure-markdown_github/follicle%20area%20plot-1.png)

Run wilcox test to see if follicle area is significantly different

``` r
pH6.8 <- subset(female_data, pH == "6.8", perc_follicle_area, drop = TRUE)
pHamb <- subset(female_data, pH == "amb", perc_follicle_area, drop = TRUE)
wt <- wilcox.test(pH6.8, pHamb)
print(wt$p.value)
```

    ## [1] 0.3884116

Plot percent follicle area for each tank

``` r
ggplot(data = female_data, aes(x = tank,y = perc_follicle_area, group = as.factor(tank), fill = pH)) + geom_violin(trim = FALSE) + geom_boxplot(width = 0.2) + geom_jitter(shape =16, position= position_jitter(0.1)) + ylab("follicle area (%)") + theme_bw()
```

![](pHFemaleBroodstockHistoAnalysis_files/figure-markdown_github/follicle%20area%20plot%20by%20tank-1.png)

anova to see if there is a tank or a pH effect

``` r
model <- aov(perc_follicle_area ~ pH * tank, data = female_data)
summary(model)
```

    ##             Df Sum Sq Mean Sq F value Pr(>F)
    ## pH           1  323.9   323.9   1.983  0.187
    ## tank         1   11.9    11.9   0.073  0.792
    ## pH:tank      1   19.2    19.2   0.118  0.738
    ## Residuals   11 1796.4   163.3

Plot percent egg area for each treatment group

``` r
ggplot(data = female_data, aes(x = pH,y = perc_egg_area, group = as.factor(pH), fill = pH)) + geom_violin(trim = FALSE) + geom_boxplot(width = 0.2) + geom_jitter(shape =16, position= position_jitter(0.1)) + ylab("egg area (%)") + theme_bw()
```

![](pHFemaleBroodstockHistoAnalysis_files/figure-markdown_github/egg%20area%20plot-1.png)

Run wilcox test to see if egg area is significantly different

``` r
pH6.8 <- subset(female_data, pH == "6.8", perc_egg_area, drop = TRUE)
pHamb <- subset(female_data, pH == "amb", perc_egg_area, drop = TRUE)
wt <- wilcox.test(pH6.8, pHamb)
print(wt$p.value)
```

    ## [1] 0.1446553

Plot percent egg area for each tank

``` r
ggplot(data = female_data, aes(x = tank,y = perc_egg_area, group = as.factor(tank), fill = pH)) + geom_violin(trim = FALSE) + geom_boxplot(width = 0.2) + geom_jitter(shape =16, position= position_jitter(0.1)) + ylab("egg area (%)") + theme_bw()
```

![](pHFemaleBroodstockHistoAnalysis_files/figure-markdown_github/egg%20area%20plot%20by%20tank-1.png)

anova to see if there is a tank or a pH effect

``` r
model <- aov(perc_egg_area ~ pH * tank, data = female_data)
summary(model)
```

    ##             Df Sum Sq Mean Sq F value Pr(>F)
    ## pH           1  19.75  19.746   2.942  0.114
    ## tank         1   3.85   3.851   0.574  0.465
    ## pH:tank      1   0.36   0.357   0.053  0.822
    ## Residuals   11  73.83   6.712

Plot egg:follicle ratio for each treatment group

``` r
ggplot(data = female_data, aes(x = pH,y = follicle_egg_ratio, group = as.factor(pH), fill = pH)) + geom_violin(trim = FALSE) + geom_boxplot(width = 0.2) + geom_jitter(shape =16, position= position_jitter(0.1)) + ylab("egg:follicle ratio") + theme_bw()
```

![](pHFemaleBroodstockHistoAnalysis_files/figure-markdown_github/egg-follicle%20ratio%20plot-1.png)

Run wilcox test to see if egg:follicle ratio is significantly different

``` r
pH6.8 <- subset(female_data, pH == "6.8", follicle_egg_ratio, drop = TRUE)
pHamb <- subset(female_data, pH == "amb", follicle_egg_ratio, drop = TRUE)
wt <- wilcox.test(pH6.8, pHamb)
print(wt$p.value)
```

    ## [1] 0.9546454

Plot egg:follicle ratio for each tank

``` r
ggplot(data = female_data, aes(x = tank,y = follicle_egg_ratio, group = as.factor(tank), fill = pH)) + geom_violin(trim = FALSE) + geom_boxplot(width = 0.2) + geom_jitter(shape =16, position= position_jitter(0.1)) + ylab("egg:follicle ratio") + theme_bw()
```

![](pHFemaleBroodstockHistoAnalysis_files/figure-markdown_github/egg:follicle%20ratio%20plot%20by%20tank-1.png)

anova to see if there is a tank or a pH effect

``` r
model <- aov(follicle_egg_ratio ~ pH * tank, data = female_data)
summary(model)
```

    ##             Df  Sum Sq  Mean Sq F value Pr(>F)
    ## pH           1 0.00005 0.000050   0.012  0.915
    ## tank         1 0.00478 0.004784   1.139  0.309
    ## pH:tank      1 0.00010 0.000102   0.024  0.879
    ## Residuals   11 0.04619 0.004199
