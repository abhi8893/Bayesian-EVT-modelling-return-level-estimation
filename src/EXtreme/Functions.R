bayesevd<-function(df,plotname){
	mat<-diag(c(10000,10000,100))
	pn<-prior.norm(mean=c(0,0,0),cov=mat)
	n<-100000	; p0<-c(5,20,0.1)	; s<-c(.1,.1,.1)
	burnin<-50000
	# find optimal initial values using SANN
	maxpst<-mposterior(p0,prior=pn,lh='gev',data=df,method='SANN')
	# find optimal initial values for s
	psd<-ar.choice(init=maxpst$par,prior=pn,lh='gev',data=df,psd=s,tol=rep(0.02,3))
	ptpmc<-posterior(n,maxpst$par,prior=pn,lh='gev',data=df,psd=psd$psd,burn=burnin)

	# Plot and diagnostics
	ptp.mcmc<-mcmc(ptpmc,start=burnin,end=n) # burn-in of 10000
	#print(geweke.diag(ptp.mcmc,0.1,0.5)) # should be more than 2 or less than -2
	#geweke.plot(ptp.mcmc,0.1,0.5)
	#print(raftery.diag(ptp.mcmc))
	return(ptpmc)
}

coles<-function(mu,sig,xi,p){
	# From Coles, p.56, equation (3.10)
	yp<- -log(1-p)
	if(xi == 0)
	{mu - (sig * log(yp))} else{
		z<-mu - ((sig/xi)*(1-yp^(-xi)))
	}
}

returnlev<-function(ptp.mcmc,year){
	yr<-year # e.g. 100-year return level
	p<-1/yr # probability

	# Quantiles
	ci<-0.95
	mat.mu<-quantile(ptp.mcmc[,1], probs = c((1 - ci)/2, 0.5,(1 + ci)/2))
	mat.sig<-quantile(ptp.mcmc[,2], probs = c((1 - ci)/2, 0.5,(1 + ci)/2))
	mat.xi <-quantile(ptp.mcmc[,3], probs = c((1 - ci)/2, 0.5,(1 + ci)/2))

	# Quantiles of z
	z.all<-mapply(coles,ptp.mcmc[,1],ptp.mcmc[,2],ptp.mcmc[,3],p)
	mat.z.all<-quantile(z.all,probs = c((1 - ci)/2, 0.5,(1 + ci)/2))

	# List of values to be returned
	newList<-list("mat.mu"=mat.mu,
				"mat.sig"=mat.sig,
				"mat.xi"=mat.xi,"mat.z.all"=mat.z.all)
	return(newList)
}

Date<-function(Start_date,End_date,freq){
	# Start_date: '1901-01-01'
	# End_date:   '2001-12-31'
	# freq:		  '1 day'
	Data<-matrix(as.numeric(unlist(strsplit(as.character(seq(as.Date(Start_date),as.Date(End_date),by=freq)),'-'))),ncol=3,byrow=T)
	return(Data)
}

Select_period<-function(df,threshold,freq,period){
	winter<-c(12,1,2) 	; summer<-c(3,4,5)
	monsoon<-c(6:9)		; post<-c(10:11)

	{if(freq=='month')
		{result<-df[which(df[,2]==period & df[,4]>=threshold),]
		result_agg<-aggregate(result[,4],by=list(result[,1]),FUN='max')}
	}

	{if(freq=='season')
		{if(period=='winter') period2<-winter
		if(period=='summer') period2<-summer
		if(period=='monsoon') period2<-monsoon
		if(period=='post') period2<-post
		result<-NULL
		for(i in period2){
			res<-df[which(df[,2]==i & df[,4]>=threshold),]
			result<-rbind(result,res)
		}
		pos<-order(result[,1])
		result2<-result[pos,]
		result_agg<-aggregate(result2[,4],by=list(result2[,1]),FUN='max')}
	}
	return(result_agg)
} # End Function

extremes_makeplot<-function(df,threshold,freq,period,units,place,directory){
	df2<-Select_period(df,threshold,freq,period)
	resbayes<-bayesevd(df2[,2],"X_month")
	resbayes.rl.10<-returnlev(resbayes,10) 		# 10 years
	resbayes.rl.25<-returnlev(resbayes,25) 		# 25 years
	resbayes.rl.50<-returnlev(resbayes,50) 		# 50 years
	resbayes.rl.100<-returnlev(resbayes,100) 	# 100 years
	resbayes.rl<-fevd(df2[,2],units=units)

	result<-matrix(0,ncol=4,nrow=4) ; result[,1]<-c(10,25,50,100)
	result[1,-1]<-c(resbayes.rl.10$mat.z.all) ; result[2,-1]<-c(resbayes.rl.25$mat.z.all)
	result[3,-1]<-c(resbayes.rl.50$mat.z.all) ; result[4,-1]<-c(resbayes.rl.100$mat.z.all)

	colnames(result)<-c('Return Period','Lower Limit','Return Level','Upper Limit')
	write.table(result,file=paste0(directory,place,'.txt'),sep=';',row.names=F,quote=F)
	tiff(paste0(directory,place,'.tiff'),height=3500,width=6000,res=600,compression='lzw',family='serif')
	plot.fevd(resbayes.rl,rperiods=c(2,25,50,100),type="rl",col = 1:4,main=place)
	dev.off()
} #End Function
