corpuslingr:
------------

Corpus work flow.

``` r
library(tidyverse)
#devtools::install_github("jaytimm/corpuslingr")
library(corpuslingr)
```

``` r
library(spacyr)
spacy_initialize()
## NULL
#spacy_initialize(python_executable = "C:\\Users\\jason\\AppData\\Local\\Programs\\Python\\Python36\\python.exe")
```

Web-based functions -- super simple
-----------------------------------

``` r
#dailyMeta <- corpuslingr::GetGoogleNewsMeta (search="New Mexico", n=5)
dailyMeta <- corpuslingr::GetGoogleNewsMeta (n=15)

head(dailyMeta[1:2])
##                            source
## 1 This RSS feed URL is deprecated
## 2                  New York Times
## 3                             CNN
## 4                 Washington Post
## 5                 Washington Post
## 6                          SFGate
##                                                                                                           titles
## 1                                                                                This RSS feed URL is deprecated
## 2                                                           Republican Plan Delivers Permanent Corporate Tax Cut
## 3                                       Terror suspect wanted to attack people on Brooklyn Bridge, documents say
## 4     Post-ABC poll: Most Americans approve of Trump-Russia probe, and nearly half think Trump committed a crime
## 5 Ex-DNC chair goes at the Clintons, alleging Hillary's campaign hijacked DNC during primary with Bernie Sanders
## 6                                                     The Latest: Neighbors: Walmart suspect unfriendly, hostile
```

``` r
txts <- dailyMeta$links  %>% 
  GetWebTexts()

substr(txts[1:5],1, 100)
## [1] "NYTimes.com no longer supports Internet Explorer 9 or earlier. Please upgrade your browser. LEARN MO"
## [2] "Updated 12:49 PM ET, Thu November 2, 2017 Chat with us in Facebook Messenger. Find out what's happen"
## [3] "The inside track on Washington politics. Be the first to know about new stories from PowerPost. Sign"
## [4] "Analysis Analysis Interpretation of the news based on evidence, including data, as well as anticipat"
## [5] "Now Playing: A man nonchalantly walked into a Walmart about 10 miles north of Denver and immediately"
```

Can be used to in a pipe laong with a corpus annotator, in this case `spacyr`...`GetWebTexts` a generic webscraping function

``` r
annotations <- txts  %>%
  lapply(spacyr::spacy_parse,tag=TRUE)%>%
  corpuslingr::PrepAnnotation()
```

Output consists of a list of dataframes. Distinct from `spacyr` output.

``` r
head(annotations[[1]])
##   doc_id sentence_id token_id       token       lemma   pos tag entity
## 1      1           1        1 NYTimes.com nytimes.com     X ADD       
## 2      1           1        2          no          no   DET  DT       
## 3      1           1        3      longer      longer   ADV RBR       
## 4      1           1        4    supports     support  VERB VBZ       
## 5      1           1        5    Internet    Internet PROPN NNP       
## 6      1           1        6    Explorer    Explorer PROPN NNP       
##                             tup tupBeg tupEnd
## 1 <NYTimes.com,nytimes.com,ADD>      1     30
## 2                    <no,no,DT>     31     41
## 3           <longer,longer,RBR>     42     61
## 4        <supports,support,VBZ>     62     84
## 5       <Internet,Internet,NNP>     85    108
## 6       <Explorer,Explorer,NNP>    109    132
```

``` r
head(GetDocDesc(annotations))
## # A tibble: 6 x 4
##   doc_id  docN docType docSent
##    <int> <int>   <int>   <int>
## 1      1  1932     740      84
## 2      2  1329     562      60
## 3      3  1116     475      46
## 4      4  1045     463      44
## 5      5  2569     418     100
## 6      6  2154     854      93
```

Search function and aggregate functions.
----------------------------------------

``` r
x <- spacyr::entity_extract(annotations[[1]])

gg <- lapply(annotations,function(x) {spacyr::entity_extract(x)}) %>%
  bind_rows()
```

GetSearchFreqs() GetKWIC() GetBOW()

Allows for multiple search terms...

As a single pipe.

``` r
library(knitr)
annotations%>%
  corpuslingr::GetContexts(search="<_NXP> <_Vx>",corp=., LW=5, RW = 5)%>%
  corpuslingr::GetKWIC()%>%
  data.frame()%>%
  select(cont)%>%
  slice(1:10)%>%
  kable("markdown",escape=FALSE) 
```

<table>
<colgroup>
<col width="100%" />
</colgroup>
<thead>
<tr class="header">
<th align="left">cont</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left">tax plan today . Mr. <mark> Brady said </mark> the bill is estimated to</td>
</tr>
<tr class="even">
<td align="left">today . Mr. Brady said <mark> the bill is </mark> estimated to cost $ 1.51</td>
</tr>
<tr class="odd">
<td align="left">New York Times WASHINGTON - <mark> Republican lawmakers unveiled </mark> a sweeping rewrite of the</td>
</tr>
<tr class="even">
<td align="left">groups , special interests and <mark> Democrats began </mark> tearing into the text ahead</td>
</tr>
<tr class="odd">
<td align="left">a Republican sprint to get <mark> the legislation passed </mark> and to President Trump 's</td>
</tr>
<tr class="even">
<td align="left">'s desk by Christmas . <mark> Lawmakers appeared </mark> unfazed by the blowback and</td>
</tr>
<tr class="odd">
<td align="left">&quot; With this plan , <mark> we are </mark> making pro growth reforms ,</td>
</tr>
<tr class="even">
<td align="left">Ryan of Wisconsin . But <mark> the bill includes </mark> several land mines that could</td>
</tr>
<tr class="odd">
<td align="left">states like New York and <mark> New Jersey said </mark> the bill will need to</td>
</tr>
<tr class="even">
<td align="left">gain their support , while <mark> powerful trade groups representing </mark> the real estate industry and</td>
</tr>
</tbody>
</table>

render("C:\\Users\\jason\\Google Drive\\GitHub\\packages\\corpuslingr\\README.rmd")
