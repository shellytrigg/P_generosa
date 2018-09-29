# range of t-test cohen D effect sizes
d <- seq(0.2,0.5,0.1)
nd <- length(d)
 
# power values
p <- seq(.4,.9,.1)
np <- length(p)
   
# obtain sample sizes
samsize <- array(numeric(nd*np), dim=c(nd,np))
for (i in 1:np){
  for (j in 1:nd){
    result <- pwr.t.test(n = NULL, d = d[j],sig.level = 0.05 , power = p[i],alternative = "two.sided") 
    samsize[j,i] <- ceiling(result$n)
    }
}
     
xrange <- range(d)
yrange <- round(range(samsize))
colors <- rainbow(length(p))
plot(xrange, yrange, type="n", xlab="T Test Effect Size (d)", ylab="Sample Size (n)" )

for (i in 1:np){
  lines(d, samsize[,i], type="l", lwd=2, col=colors[i])
  }
# add annotation (grid lines, title, legend)
abline(v=0, h=seq(0,yrange[2],50), lty=2, col="grey89")
abline(h=0, v=seq(xrange[1],xrange[2],.02), lty=2, col="grey89")
title("Sample Size Estimation for T test Studies\nSig=0.05 (Two-tailed)")
legend("topright", title="Power", as.character(p), fill=colors)

pwr.t.test(n = NULL, d = 0.5 ,sig.level = 0.05 , power = 0.75,alternative = "two.sided") 
#Two-sample t test power calculation 
#n = 56.49861
#d = 0.5
#sig.level = 0.05
#power = 0.75
#alternative = two.sided
#NOTE: n is number in *each* group



##if we expect a big difference (i.e. d = 0.8):
> pwr.t.test(n = NULL, d = 0.8 ,sig.level = 0.05 , power = 0.75,alternative = "two.sided")
#Two-sample t test power calculation 
#n = 22.68883
#d = 0.8
#sig.level = 0.05
#power = 0.75
#alternative = two.sided
#NOTE: n is number in *each* group


#########################
#ANOVA 
##########################
# range of cohen effect sizes for AOV
f <- seq(0.15,0.4,0.05)
nf <- length(f)

# power values
p <- seq(.4,.9,.1)
np <- length(p)

# obtain sample sizes
samsize <- array(numeric(nf*np), dim=c(nf,np))
for (i in 1:np){
  for (j in 1:nf){
    result <- pwr.anova.test(k = 3, n = NULL, f = f[j],sig.level = 0.05 , power = p[i]) 
    samsize[j,i] <- ceiling(result$n)
  }
}

xrange <- range(f)
yrange <- round(range(samsize))
colors <- rainbow(length(p))
plot(xrange, yrange, type="n", xlab="AOV Effect Size (f)", ylab="Sample Size (n)" )

for (i in 1:np){
  lines(f, samsize[,i], type="l", lwd=2, col=colors[i])
}
# add annotation (grid lines, title, legend)
abline(v=0, h=seq(0,yrange[2],50), lty=2, col="grey89")
abline(h=0, v=seq(xrange[1],xrange[2],.02), lty=2, col="grey89")
title("Sample Size Estimation for 3 group AOV Studies\nSig=0.05")
legend("topright", title="Power", as.character(p), fill=colors)

pwr.anova.test(k = 2, n = NULL, f = 0.25,sig.level = 0.05 , power = 0.75)
#Balanced one-way analysis of variance power calculation 
#k = 2
#n = 56.49861
#f = 0.25
#sig.level = 0.05
#power = 0.75

pwr.anova.test(k = 3, n = NULL, f = 0.25,sig.level = 0.05 , power = 0.75)
#Balanced one-way analysis of variance power calculation 
#k = 3
#n = 46.83008
#f = 0.25
#sig.level = 0.05
#power = 0.75

NOTE: n is number in each group

##################################################
#######plotting with sample size as the colored lines
# range of Ttest Cohen D effect sizes
d <- seq(0.2,0.8,0.1)
nd <- length(d)


ss <- seq(20,100,10)
nss <- length(ss)

# obtain sample sizes
power <- array(numeric(nd*nss), dim=c(nd,nss))
for (i in 1:nss){
  for (j in 1:nd){
    result <- pwr.t.test(n = ss[i], d = d[j],sig.level = 0.05 , power = NULL) 
    power[j,i] <- result$power
  }
}

xrange <- range(d)
yrange <- round(range(power))
colors <- rainbow(length(ss))
plot(xrange, yrange, type="n", xlab="T Test Effect Size (d)", ylab="Power" )

for (i in 1:nss){
  lines(d, power[,i], type="l", lwd=2, col=colors[i])
}
# add annotation (grid lines, title, legend)
abline(v=0, h=seq(0,yrange[2],50), lty=2, col="grey89")
abline(h=0, v=seq(xrange[1],xrange[2],.02), lty=2, col="grey89")
title("Sample Size Estimation for 2 group Ttest Studies\nSig=0.05 (two-sided)")
legend("bottomright", title="SampleSize", as.character(ss), fill=colors)

###################################################
#######plotting with sample size as the colored lines
# range of AOV Cohen D effect sizes
f <- seq(0.25,0.4,0.05)
nf <- length(f)


ss <- seq(20,100,10)
nss <- length(ss)

# obtain sample sizes
power <- array(numeric(nf*nss), dim=c(nf,nss))
for (i in 1:nss){
  for (j in 1:nf){
    result <- pwr.anova.test(k = 3, n = ss[i], f = f[j],sig.level = 0.05 , power = NULL) 
    power[j,i] <- result$power
  }
}

xrange <- range(f)
yrange <- round(range(power))
colors <- rainbow(length(ss))
plot(xrange, yrange, type="n", xlab="AOV Effect Size (f)", ylab="Power" )

for (i in 1:nss){
  lines(f, power[,i], type="l", lwd=2, col=colors[i])
}
# add annotation (grid lines, title, legend)
abline(v=0, h=seq(0,yrange[2],50), lty=2, col="grey89")
abline(h=0, v=seq(xrange[1],xrange[2],.02), lty=2, col="grey89")
title("Sample Size Estimation for 3 group AOV Studies\nSig=0.05")
legend("bottomright", title="SampleSize", as.character(ss), fill=colors)
