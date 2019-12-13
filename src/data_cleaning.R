library(mice)
# library(lattice)
library(parallel)
library(qtl2)
library(tidyverse)

getdata<-function(url){
  return(read_cross2(url))
  # print("hello")
}
#keepidx<-which(rowSums(is.na(bxd$pheno))<1000798)

keep_row_idx<-function(pheno, droprate){
  rs = rowSums(is.na(pheno)) 
  keepidx <- which(rs/ncol(pheno) <= droprate)
  return(keepidx)
}

keep_col_idx<-function(pheno, droprate){

  cs = colSums(is.na(pheno))
  keepidx <- which(cs/nrow(pheno) <= droprate)
  return(keepidx)
}

calc_gprob_update_gmap<-function(gmap_file, cross, ncore=1, error_prob=0.002, step=0, pseudomarker=FALSE){

  #insert pseudomarker
  map = cross$gmap
  if(pseudomarker){
    map <- insert_pseudomarkers(map, step=step)
    #write.csv(map, file=gmap_file, row.names = FALSE)
  }
  
  pr <- calc_genoprob(cross, map, error_prob=error_prob, cores=ncore)
  return(pr)
}

# intersect(phenotype, genotype, 
            # selected_pheno = "ProbeSet", 
            # selected_geno = one_of("Locus","Chr","cM","Mb"), 
            # match_name="BXD")
# intersect <- function(pheno, geno, selected_pheno, selected_geno, match_name){
#   sub_pheno = cbind(select(pheno, selected_pheno), select(pheno, match_name))
#   sub_pheno_names = names(sub_pheno)

#   sub_geno = cbind(select(geno, selected_geno), select(geno, match_name))
#   sub_geno_names = names(sub_geno)

#   transed_sub_pheno_df = as_tibble(t(sub_pheno))
#   transed_sub_geno_df = as_tibble(t(sub_geno))

#   transed_sub_pheno_df$id <- sub_pheno_names
#   transed_sub_geno_df$id <- sub_geno_names

#   join_by_this = "id"
#   joined_data = right_join(transed_sub_pheno_df, transed_sub_geno_df, join_by_this)
#   # joined_data[1, 1:ncol(transed_sub_pheno_df)] <- 

# }

#get whole genotype prob file
getGenopr<-function(x){
  temp<<-NULL
  m=length(attributes(x)$names)
  cnames<-attributes(x)$names
  for (i in 1:m) {
    d<-eval(parse(text=paste(c('dim(x$\'', cnames[i] ,'\')'),collapse='')))
    nam<-eval(parse(text=paste(c('dimnames(x$\'',cnames[i],'\')[[2]]'),collapse = '')))
    cnam<-rep(nam,d[3])
    p_chr<-paste(c('array(x$\'',cnames[i],'\',dim=c(d[1],d[2]*d[3]))'),collapse='')
    prob<-eval(parse(text = p_chr))
    temp<-cbind(temp,prob)
  }
  return(temp)
}

# url : data url
# indi_droprate: droprate in percentage, ie: 10 percent
# trait_droprate : droprate in percentage, ie: 10 percent
# ncores: default detectCores()
clean_and_write<-function(url, geno_output_file="geno_prob.csv", pheno_output_file="pheno.csv", new_gmap_file="gmap.csv", 
                          indi_droprate=0.0, trait_droprate=0.0, nseed=100, ncores=1, error_prob=0.002, stepsize=1){  
  url = "/Users/xiaoqihu/Documents/hg/genome-scan-data-cleaning/data/UTHSC_SPL_RMA_1210.zip"
  geno_output_file="geno_prob.csv"
  pheno_output_file="pheno.csv"
  indi_droprate = 0.0
  trait_droprate = 0.0
  trait_droprate=0.0
  nseed=100
  ncores=1
  error_prob=0.002
  stepsize=1
  
  bxd = getdata(url)
  print("got data from url")

  # intersect 
  

  
  # process pheno
  col_idx = keep_col_idx(bxd$pheno, trait_droprate)
  trait<-bxd$pheno[,col_idx]
  row_idx = keep_row_idx(trait, indi_droprate)
  trait<-trait[row_idx,]

  print("processing pheno done")
  
  #imputation
  # temp_imp = mice(trait,m=1, method = "norm", seed = nseed)
  #print("mice done")
  #imp = complete(temp_imp)
  #print("complete imputation done")
  
  # calculate genotype probablity
  pr = calc_gprob_update_gmap(new_gmap_file, bxd, ncores, error_prob, step)
  prob1 = getGenopr(pr)
  print("calculating geno prob done")
  
  write.csv(trait, file = pheno_output_file, row.names = FALSE)
  write.csv(prob1[row_idx,], file = geno_output_file, row.names = FALSE)
  print("writing out pheno and geno done")

}


url = "/Users/xiaoqihu/Documents/hg/genome-scan-data-cleaning/data/UTHSC_SPL_RMA_1210.zip"
#clean_and_write(url)

#clean_and_write("/Users/xiaoqihu/Documents/hg/genome-scan-data-cleaning/data/BXD/BXD.zip", "geno_prob.csv", "imputed_pheno.csv", "gmap.csv", 10,10, 1,detectCores(), 0.002, 1)

#bxd = getdata("/Users/xiaoqihu/Documents/hg/genome-scan-data-cleaning/data/BXD/BXD.zip")

