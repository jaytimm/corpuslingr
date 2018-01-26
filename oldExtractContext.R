extractContext <- function(x,search,LW,RW) {
  locations <- gregexpr(pattern= search, paste(x$tup, collapse=" "), ignore.case=TRUE)
  starts <- unlist(as.vector(locations[[1]]))
  stops <- starts + attr(locations[[1]],"match.length") -1

  if (-1 %in% starts){} else {

  L1 <- match(starts,x$tupBeg)  #Get search  boundaries.
  R1 <- match(stops,x$tupEnd)
  L2 <- ifelse((L1-LW) < 1, 1,L1-LW)
  R2 <- ifelse((R1+RW) > nrow(x), nrow(x),R1+RW)

  lapply(1:length(R2), function(y)
    cbind(
          x[L2[y]:R2[y],1:ncol(x)],
          place= as.character(c(rep("pre",L1[y]-L2[y]),
                   rep("targ",R1[y]-L1[y]+1),
                   rep("post",R2[y]-R1[y]))))
    )}}