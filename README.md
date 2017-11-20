corpuslingr:
------------

Some r functions for quick web scraping and corpus seach of complex grammtical constructions. Works in conjunction with `spacyr` package.

``` r
library(tidyverse)
devtools::install_github("jaytimm/corpuslingr")
#devtools::install_github("jaytimm/corpusdatr")
library(corpuslingr)
library(corpusdatr)
library(knitr)
```

Web scraping functions
----------------------

### `GetGoogleNewsMeta()`

``` r
#dailyMeta <- corpuslingr::GetGoogleNewsMeta (search="New Mexico", n=5)
dailyMeta <- corpuslingr::GetGoogleNewsMeta (n=15)

head(dailyMeta['titles'])
##                                                                                                titles
## 1                   The Justice Department is suing AT&T to block its $85 billion bid for Time Warner
## 2                             North Korea's on-again-off-again status as a state sponsor of terrorism
## 3                      Charlie Rose Suspended By CBS, PBS and Bloomberg Amid Sexual Misconduct Claims
## 4      Slain border agent may have been beaten to death by rocks in 'grisly scene,' union leader says
## 5 'We will continue to report this uncowed by his threats': Alabama Media Group responds to Roy Moore
## 6                 Sarah Huckabee Sanders to April Ryan: 'I'm starting to regret calling on you first'
```

We need to sort out meta with sites that are actually scraped. Also, re-try "article" verion of boilerpipeR.

### `GetWebTexts()`

``` r
txts <- dailyMeta$links  %>% 
  GetWebTexts()

substr(txts[1:5],1, 50)
## [1] "The Justice Department is suing AT&T to block its "
## [2] "Analysis Interpretation of the news based on evide"
## [3] "2:57 PM PST 11/20/2017 by Jeremy Barr Charlie Rose"
## [4] "Slain border agent may have been beaten to death b"
## [5] "Hamburger icon Close icon 'We will continue to rep"
```

Corpus preparation
------------------

### `PrepAnnotation()`

``` r
annotations <- txts  %>%
  lapply(spacyr::spacy_parse,tag=TRUE)%>%
  corpuslingr::PrepAnnotation()
```

Output consists of a list of dataframes. Distinct from `spacyr` output.

``` r
gnews <- corpusdatr::gnews11_20_17
```

### `GetDocDesc()`

``` r
head(GetDocDesc(gnews))
## # A tibble: 6 x 4
##   doc_id  docN docType docSent
##    <int> <int>   <int>   <int>
## 1      1   785     369      33
## 2      2  1321     496      71
## 3      3  1216     538      47
## 4      4  1075     435      54
## 5      5  1320     617      72
## 6      6   817     386      34
```

Search function and aggregate functions.
----------------------------------------

### `GetContexts()`

``` r
search1 <- "<_Vx> <_IN>"

found <- corpuslingr::GetContexts(search=search1,corp=gnews,LW=5, RW = 5)
```

### `GetSearchFreqs()`

``` r
corpuslingr::GetSearchFreqs(found)[[1]]
## # A tibble: 608 x 3
## # Groups:   targ [608]
##               targ termDocFreq termTextFreq
##              <chr>       <int>        <int>
##  1    ACCORDING TO          13           30
##  2         SAID IN          10           17
##  3       SAID THAT           4            8
##  4           IS IN           5            6
##  5 RECOMMENDED FOR           3            6
##  6      ADDED THAT           4            5
##  7  CONTRIBUTED TO           5            5
##  8      RELATED TO           2            5
##  9    WORKING WITH           5            5
## 10    HAPPENING IN           4            4
## # ... with 598 more rows
```

### `GetKWIC()`

``` r
search2 <- "<_Jx> <and!> <_Jx>"

corpuslingr::GetContexts(search=search2,corp=gnews,LW=5, RW = 5)%>%
  corpuslingr::GetKWIC()%>%
  data.frame()%>%
  select(doc_id,cont)%>%
  mutate(cont=gsub("<mark>|</mark>","||",cont))%>%
  knitr::kable("markdown")
```

<table>
<colgroup>
<col width="6%" />
<col width="93%" />
</colgroup>
<thead>
<tr class="header">
<th align="right">doc_id</th>
<th align="left">cont</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="right">1</td>
<td align="left">whom he cast as a || maniacal and deranged || man . &quot; The regime</td>
</tr>
<tr class="even">
<td align="right">2</td>
<td align="left">Menz said she had a || brief and cordial || exchange with the senator .</td>
</tr>
<tr class="odd">
<td align="right">2</td>
<td align="left">said she has equally supported || Republican and Democratic || candidates while he said he</td>
</tr>
<tr class="even">
<td align="right">4</td>
<td align="left">do remember she was very || rattled and upset || and ashamed of what she</td>
</tr>
<tr class="odd">
<td align="right">8</td>
<td align="left">24 hours . CNN 's || military and diplomatic || analyst John Kirby reported in</td>
</tr>
<tr class="even">
<td align="right">10</td>
<td align="left">an investigation , according to || legal and national || security experts at the website</td>
</tr>
<tr class="odd">
<td align="right">11</td>
<td align="left">, 2001 . Plenty of || former and current || players , including former Patriots</td>
</tr>
<tr class="even">
<td align="right">18</td>
<td align="left">use personal funds to help || current and former || White House staff with their</td>
</tr>
<tr class="odd">
<td align="right">18</td>
<td align="left">legal bills that would meet || regulatory and ethical || standards , White House lawyer</td>
</tr>
<tr class="even">
<td align="right">25</td>
<td align="left">indeed partly covert with many || Muslim and Arab || countries , and usually (</td>
</tr>
</tbody>
</table>

### `GetBOW()`

Vector space model, or word embedding

``` r
search3 <- "<Trump!>"

corpuslingr::GetContexts(search=search3,corp=gnews,LW=15, RW = 15)%>%
  corpuslingr::GetBOW(contentOnly=TRUE)%>%
  data.frame()%>%
  slice(1:10)%>%
  ggplot(aes(x=reorder(lemma,n), y=n)) + 
    geom_bar(stat="identity", width=.5, fill="tomato3") +  
    coord_flip()+
    theme_bw()
```

![](README-unnamed-chunk-11-1.png)

``` r

##How would we get Noun Phrases from a BOW?
```

Multi-term search
-----------------

``` r
#multi-search <- c("")
```

Corpus workflow
---------------

``` r
search4 <- "<_xNP> (<wish&> |<hope&> |<believe&> )"

dailyMeta$links  %>% 
  corpuslingr::GetWebTexts()%>%
  lapply(spacyr::spacy_parse,tag=TRUE)%>%
  corpuslingr::PrepAnnotation()%>%
  corpuslingr::GetContexts(search=search4,corp=.,LW=10, RW = 10)%>%
  corpuslingr::GetSearchFreqs(found)[[1]]
```
