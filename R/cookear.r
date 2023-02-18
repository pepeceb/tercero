cookear<-function(x.y){

  mod <- lm(PESO~ESTRATO_RIM, data=datos2 )
  cooksd <- cooks.distance(mod)

  cooksd2<-as.data.frame(cooksd)
  cooksd2$ObsNumber <- 1:length(cooksd)
  datos2$ObsNumber      <- 1:length(cooksd)
  sp2<-full_join(datos2, cooksd2)%>%distinct()%>%arrange(ESTRATO_RIM, PUERTO, COD_ID)

  #hacer la media de cooksd para cada metier
  dMean <- sp2 %>%
    group_by(ESTRATO_RIM, ESP_MUE) %>%
    summarise(MN = mean(cooksd))

  sp3<-left_join(sp2, dMean)%>%distinct()
  table(sp3$ESP_MUE)
  sp4<-sp3%>%group_by(
   ESP_MUE,ESTRATO_RIM)%>%
    summarise(MN_Mean=mean(MN, na.rm=TRUE))%>%distinct()%>%as.data.frame()
  ggplot(data =sp3,
         mapping = aes(y = cooksd, x=PESO, col=factor(PUERTO)))  +
    geom_point(data =distinct(sp3),aes(size=PESO))  +

    geom_hline(data = sp4, aes(yintercept = 4*sp4$MN_Mean),size=1.5, colour="red")  +
    guides(colour = guide_legend(override.aes = list(size=5,linetype=4))) +
    scale_size(range=c(2,5))  +
    facet_wrap(ESP_MUE~ESTRATO_RIM, scales="free")   +
               geom_label_repel(show.legend=FALSE,data=subset(sp3,cooksd>4*MN),aes(fontface="bold",
                 PESO,cooksd, label = paste( FECHA_MUE, "", "\n",
                round(PESO,2), "", "KG")),label.size = 1,segment.color="darkblue",
                arrow=arrow(length= unit(0.03,"npc"), type="closed",ends="first"),
                fill = "white" ,
                size=3.5, vjust=1, hjust=0.1)    +
    guides(colour = guide_legend(override.aes = list(size=4,linetype=4))) # +
    #theme(legend.position = "none")
}