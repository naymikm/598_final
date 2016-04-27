library(stringr)
args = commandArgs(trailingOnly=T)
years = as.numeric(args[1])
print(years)
mutations = ceiling(years*18959*0.0013)  #Hoenen et al.
print(mutations)
ez = str_split(readLines('ez.txt'),pattern='')
bases = ez[[1]]

mutate = function(n){
for (i in 1:n){
	pos = sample(1:length(bases),1)
	nt = bases[pos]
	type = runif(1,0,1)
	trans = runif(1,0,1)
	if (type <= 0.33){
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
			
#print(nt)
#print(bases[pos])
#print(pos)		
	}

}	

reads = split(bases,ceiling(seq_along(bases)/1000))
invisible(lapply(reads,cat,'\n',file='mutant_reads.fa',append=T))