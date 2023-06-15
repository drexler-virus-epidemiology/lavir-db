createMiniCards <- function(df) {
  df <- df[!duplicated(df), ]
  return (
    lapply(1:nrow(df), function(i) {
      card (
        height="100%",
        width="100vh",
        card_header (
          class = "bg-dark",
          paste0("PMID: ", df[i, "pmid"])
        ),
        card_body (
          markdown(paste0("**Title:** ", df[i, "title"])),
          markdown(paste0("**Author:** ", df[i, "author"])),
          markdown(paste0("**Last Author:** ", df[i, "last_author"])),
          markdown(paste0("**Host Name:** ", df[i, "host_name"])),
          markdown(paste0("**Publication Date:** ", strsplit(df[i, "publication_date"], " ")[[1]][1])),
          markdown(paste0("**Publication DOI:** [", df[i, "doi"],"](https://www.doi.org/", df[i, "doi"],")"))
        )
      )
    })
  )
}