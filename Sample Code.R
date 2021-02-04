ecoregion_sst_month <- ecoregion_sst %>% 
  group_by(ecoregion, year, month) %>% 
  summarize(mean = mean(mean_sst, na.rm = TRUE))

head(ecoregion_sst_month)


regionList <- levels(as.factor(ecoregion_sst_month$ecoregion))
sst_lm_preds <- data.frame("ecoregion" = factor(),
                           "time" = numeric(),
                           "sst" = numeric(),
                           "preds" = numeric(),
                           "overall_mean" = numeric())

sst_gam_preds <- data.frame("ecoregion" = factor(),
                           "time" = numeric(),
                           "sst" = numeric(),
                           "preds" = numeric(),
                           "overall_mean" = numeric())


for (region in regionList) {

  df <- subset(ecoregion_sst_month, ecoregion == region) # subset for desired region
  
  ## LM of ecoregion SST
  eco_lm <- lm(mean ~ year, data = df)
  lm_preds <- data.frame(ecoregion = df$ecoregion,
                         time = df$year,
                         sst = df$mean,
                         preds = predict(eco_lm, newdata = df),
                         overall_mean = mean(df$mean, na.rm = TRUE))
  sst_lm_preds <- rbind(sst_lm_preds, lm_preds)


  ## GAM of ecoregion SST
  eco_gam <- gam(mean ~ s(year), data = df, method = "REML")
  gam_preds <- data.frame(ecoregion = df$ecoregion,
                         time = df$year,
                         sst = df$mean,
                         preds = predict(eco_gam, newdata = df),
                         overall_mean = eco_gam[["coefficients"]][["(Intercept)"]])
  sst_gam_preds <- rbind(sst_gam_preds, gam_preds)  

}




plot <- ggplot() +
  theme_cowplot() +
  geom_hline(data = sst_gam_preds, aes(yintercept = overall_mean), linetype = "dashed",alpha = 0.3) +
  #geom_hline(data = sst_lm_preds, aes(yintercept = overall_mean), linetype = "dashed", colour = "purple", alpha = 0.3) +  
  geom_line(data = sst_gam_preds, aes(x = time, y = preds), colour = "green") +
  geom_line(data = sst_lm_preds, aes(x = time, y = preds), colour = "purple") +
  facet_wrap(~ecoregion, ncol = 2)

ggplotly(plot)
ggplotly(plot2)

## construct df for the GAM smoothing of mean SST
sst_gam_df <- gather(had_full, reef, sst, `1`:`5607`)
sst_gam_df$date <- gsub("\\X", "", sst_gam_df$date) # convert year to numeric and remove 'X'
sst_gam_df <- sst_gam_df %>% separate(date, c("year", "month","day"), convert = TRUE) # create year, month, and day column columns
sst_gam_df$date <- as.Date(with(sst_gam_df, paste(year, month, day, sep="-")), "%Y-%m-%d")
sst_gam_df <- subset(sst_gam_df, year != "2020")


sst_lm2 <- lm(mean_sst ~ year, data = sst_gam_df3)
summary(sst_lm2)
lm_pred2 <- data.frame(time = sst_gam_df3$year,
                       sst = sst_gam_df3$mean_sst,
                       preds = predict(sst_lm2, newdata = sst_gam_df3))


### modelling with month:
sst_gam_df2 <- sst_gam_df %>% 
  group_by(date, month) %>% 
  summarize(mean_sst = mean(sst, na.rm = TRUE))

sst_gam_df2$date2 <- as.integer(sst_gam_df2$date) # creates an integer form of date for the GAM model

## fit a GAM for SST data for all reefs:
library(mgcv)
sst_gam <- gam(mean_sst ~ s(month, bs = 'cc', k = 12) + s(date2), data = sst_gam_df2, method = "REML")
plot(sst_gam)

par(mfrow = c(2,2))
gam.check(sst_gam)

gam_pred <- data.frame(time = sst_gam_df2$date2,
                       sst = sst_gam_df2$mean_sst,
                       preds = predict(sst_gam, newdata = sst_gam_df2))

ggplot(gam_pred, aes(x = time)) +
  geom_point(aes(y = sst), size = 1, alpha = 0.5) + 
  geom_line(aes(y = preds), colour = "red")



### modelling withOUT month:
sst_gam_df3 <- sst_gam_df %>% 
  group_by(year) %>% 
  summarize(mean_sst = mean(sst, na.rm = TRUE))


## fit a GAM for SST data for all reefs:
sst_gam2 <- gam(mean_sst ~ s(year), data = sst_gam_df3, method = "REML")
plot(sst_gam2)

par(mfrow = c(2,2))
gam.check(sst_gam2)

gam_pred2 <- data.frame(time = sst_gam_df3$year,
                        sst = sst_gam_df3$mean_sst,
                        preds = predict(sst_gam2, newdata = sst_gam_df3))

ggplot(gam_pred2, aes(x = time)) +
  theme_cowplot() +
  geom_hline(aes(yintercept = sst_gam[["coefficients"]][["(Intercept)"]]), linetype = "dashed") +
  geom_point(aes(y = sst), size = 1, alpha = 0.5) + 
  geom_smooth(data = gam_pred2, method = "gam", aes(x = time, y = sst), colour = "green", se = FALSE, formula = y ~ s(x, bs = "cs")) +
  #geom_smooth(data = sst_gam_df, method = "lm", aes(x = year, y = sst), colour = "purple", se = FALSE) +  
  geom_line(data = lm_pred2, aes(x = time, y = preds), colour = "purple") +
  geom_line(aes(y = preds), colour = "red")

summary(sst_gam2)

head(sst_gam_df)
str(sst_gam_df2)


rate_30 <- subset(sst_gam_df3, year >= 1990)
rate_30 <- subset(rate_30, year < 2020)

plot(rate_30)

lm(mean_sst ~ year, data = rate_30)





path_gam_df <- sst_gam_df

path_lm_df <- path_gam_df %>% 
  group_by(year) %>% 
  summarize(mean_sst = mean(sst, na.rm = TRUE))

path_sst_lm2 <- lm(mean_sst ~ year, data = path_lm_df)
path_sst_lm2
path_lm_pred <- data.frame(time = path_lm_df$year,
                           sst = path_lm_df$mean_sst,
                           preds = predict(sst_lm2, newdata = path_lm_df))


Prate_30 <- subset(path_lm_df, year >= 1990)
plot(Prate_30)

Prate_30 <- subset(path_lm_df, year >= 1990)
plot(Prate_30)

lm(mean_sst ~ year, data = Prate_30)
lm(mean_sst ~ year, data = rate_30)



rate_30 <- subset(sst_gam_df3, year >= 1990)
rate_30 <- subset(rate_30, year < 2020)

plot(sst_gam_df3)

lm(mean_sst ~ year, data = sst_gam_df3)
