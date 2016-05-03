library(stringr)
args = commandArgs(trailingOnly=T)
years = as.numeric(args[1])
print(paste(years,' years'))
mutations = ceiling(years*18959*0.0013)  #Hoenen et al.
print(paste(mutations, ' mutations'))
ez = str_split(readLines('ez.txt'),pattern='')
bases = ez[[1]]

vcf = data.frame(CHROM=character(),POS=numeric(),ID=character(),REF=character(),
ALT=character(),QUAL=numeric(),FILTER=character(),INFO=character(),stringsAsFactors=F)

mutate = function(n){
for (i in 1:n){
	pos = sample(1:length(bases),1)
	nt = bases[pos]
	type = runif(1,0,1)
	trans = runif(1,0,1)
	if (type <= .34){
		if (nt == 'A'){
			if (trans <= .5){
				bases[pos] <<- 'C'
			} 
			else {
				bases[pos] <<- 'T'
					} 
		} else if (nt == 'T'){
			if (trans <= .5){
                   bases[pos] <<- 'G'
            } else {
                   bases[pos] <<- 'A'
                            }
		} else if (nt == 'G'){
            if (trans <= .5){
                    bases[pos] <<- 'C'
             } else {
                    bases[pos] <<- 'T'
                     }
		} else {
            if (trans <= .5){
                     bases[pos] <<- 'A'
            } else {
                     bases[pos] <<- 'G'
                   	}
                    		} 
						
	} 
	else {
		if (nt == 'A'){
               bases[pos] <<- 'G'
		} else if (nt == 'T'){
			bases[pos] <<- 'C'
		} else if (nt == 'G'){
			bases[pos] <<- 'A'
		} else {
			bases[pos] <<- 'T'
				}
		}
			
	vcf[nrow(vcf)+1,] <<- c('KJ660346',pos,'.',nt,bases[pos],100,'PASS','')	
	}

}	

mutate(mutations)
write.table(vcf,'ez.vcf',col.names=T,quote=F,row.names=F,sep='\t')
