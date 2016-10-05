# Here's a (simulated) experiment, with a single subject and 500 categorization trials.
all.data <- read.csv('experiment-data.csv')
source('memory-limited-exemplar-model.R')
rm(sample.data.set)
rm(sample.training.data)

# Use optim() to fit the model to this data.
# Note: In optim() you can tell it to display updates as it goes with:
# optim( ... , control=list(trace=4))

exemplar.optimize<-function(parameters){
  sensitivity<-parameters[1]
  decay.rate<-parameters[2]
  if((decay.rate>1) || (decay.rate<0)){
    return(NA)
  }else if(sensitivity<=0){
    return(NA)
  }else{
    return(exemplar.memory.log.likelihood(all.data, sensitivity, decay.rate))
  }
}

exemplar.optimize.optim<- optim(c(2, 0.5), exemplar.optimize, method="Nelder-Mead", control=list(trace=4))
exemplar.optimize.optim$par
exemplar.optimize.optim$value

# Now try fitting a restricted version of the model, where we assume there is no decay.
# Fix the decay.rate parameter to 1, and use optim to fit the sensitivity parameter.
# Note that you will need to use method="Brent" in optim() instead of Nelder-Mead. 
# The brent method also requires an upper and lower boundary:
# optim( ..., upper=100, lower=0, method="Brent")
exemplar.optimize.restricted<-function(parameters){
  sensitivity<-parameters[1]
  if(sensitivity<=0){
    return(NA)
  }else{
    return(exemplar.memory.log.likelihood(all.data, sensitivity, 1))
  }
}

exemplar.optimize.restricted.optim<-optim(c(0.01), exemplar.optimize.restricted, upper=100, lower=0, method="Brent")
exemplar.optimize.restricted.optim$par
exemplar.optimize.restricted.optim$value

# What's the log likelihood of both models? (see the $value in the result of optiom(),
# remember this is the negative log likeihood, so multiply by -1.

#Nelder-Mead
#sensitivity 5.1529831
#decay rate  0.62727227

#Brent
#sensitivity 3.862599

# What's the AIC and BIC for both models? Which model should we prefer?

#AIC.nelder = 2k-2*ln(L) = 2*(2)-2*188 = -372
#BIC.nelder = k*ln(N)-2*ln(L) -> (2)*ln(500)-2*188 = 2*6.21-376 = -363.57

#AIC.brent = 2k-2*ln(L) = 2*(1)-2*248.5161 = -495.04
#BIC.brent = k*ln(N)-2*ln(L) = (1)*ln(500)-2*248.5161 = -490.83

#### BONUS...
# If you complete this part I'll refund you a late day. You do not need to do this.

# Use parametric bootstrapping to estimate the uncertainty on the decay.rate parameter.
# Unfortunately the model takes too long to fit to generate a large bootstrapped sample in
# a reasonable time, so use a small sample size of 10-100 depending on how long you are
# willing to let your computer crunch the numbers.

# Steps for parametric bootstrapping:
# Use the best fitting parameters above to generate a new data set (in this case, that means
# a new set of values in the correct column for all.data).
# Fit the model to this new data, record the MLE for decay.rate.
# Repeat many times to get a distribution of decay.rate values.
# Usually you would then summarize with a 95% CI, but for our purposes you can just plot a
# histogram of the distribution.

