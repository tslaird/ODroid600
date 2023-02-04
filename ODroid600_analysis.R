
#specify working directory
chwd("/home/tslaird/leveau_lab/ODroid600")

#import data
calib<-read.csv("ODroid600_Calibration.csv")
#check proper row numbers
numrows<-sapply("ODroid600_Calibration.csv",countLines)
ifelse(nrow(calib)==(numrows-1),"proper line numbers", "error importing file" )

#add OD data for col A,B,C,D
calib$A_OD<-log10(calib$A[1]/calib$A)
calib$B_OD<-log10(calib$B[1]/calib$B)
calib$C_OD<-log10(calib$C[1]/calib$C)
calib$D_OD<-log10(calib$D[1]/calib$D)

rsquared_mat<-apply(calib[,c(4,9:12)],2, function(x) apply(calib[,c(4,9:12)],2, function(y) cor(x,y)^2   ) )

#plotting
library(reshape2)
library(ggplot2)
library(gridExtra)
calib_long<-melt(calib)
ggplot(calib_long) + geom_point(aes(x=value,y=value,color=Tube_id))


all_comp<-list(
  list(calib$A_OD,calib$B_OD,"OD_A","OD_B"),
  list(calib$B_OD,calib$C_OD,"OD_B","OD_C"),
  list(calib$C_OD,calib$D_OD,"OD_C","OD_D"),
  list(calib$A_OD,calib$C_OD,"OD_A","OD_C"),
  list(calib$A_OD,calib$D_OD,"OD_A","OD_D"),
  list(calib$A_OD,calib$D_OD,"OD_B","OD_D"),
  list(calib$A_OD,calib$Genesys50,"OD_A","OD_Genesys50"),
  list(calib$B_OD,calib$Genesys50,"OD_B","OD_Genesys50"),
  list(calib$C_OD,calib$Genesys50,"OD_C","OD_Genesys50"),
  list(calib$D_OD,calib$Genesys50,"OD_D","OD_Genesys50")
)


output_plots<-list()
for(i in 1:length(all_comp)){
info<-all_comp[[i]]
input1<-info[[1]]
input2<-info[[2]]
name1= info[[3]]
name2= info[[4]]
#print(c(name1,name2))
lin_mod<-lm(input2~input1)
eq<-paste("y =",round(coef(lin_mod)[[1]],2),"+", round(coef(lin_mod)[[2]],3),"x")
r2<-paste("R^2 = ",round(cor(input1,input2)^2,3))
df<-cbind.data.frame(input1,input2)
colnames(df)<-c(name1,name2)
p<-ggplot(data = df)+
  geom_point(aes_string(x = name1,y = name2), color = "dodgerblue3", size=3)+
  geom_smooth(aes_string(x = name1,y = name2), method=lm, color= 'dodgerblue', se=FALSE)+
  annotate("text",x=0,y=0.8,label=eq,hjust = 0, vjust=0)+
  annotate("text",x=0,y=0.6,label=r2,hjust = 0, vjust=0)+
  theme_bw()+
  theme(text=element_text(size=12))
print(p)
output_plots[[i]]<-p
}

master_plot<-do.call("grid.arrange", c(output_plots, ncol=2))
ggsave("OD_comparisons.pdf",master_plot, width=7, height=10)
