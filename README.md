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
## 4                             CNN
## 5                 Washington Post
## 6                          SFGate
##                                                                                                 titles
## 1                                                                      This RSS feed URL is deprecated
## 2                                                 Republican Plan Delivers Permanent Corporate Tax Cut
## 3                             Terror suspect wanted to attack people on Brooklyn Bridge, documents say
## 4                                                         Former DNC chair torches Clinton in new book
## 5 Sam Clovis withdraws his nomination for USDA's top scientist post after being linked to Russia probe
## 6                                                 The Latest: 3 victims of Walmart shooting identified
```

``` r
txts <- dailyMeta$links  %>% 
  GetWebTexts()

substr(txts[1:5],1, 100)
## [1] "NYTimes.com no longer supports Internet Explorer 9 or earlier. Please upgrade your browser. LEARN MO"
## [2] "Updated 12:49 PM ET, Thu November 2, 2017 Chat with us in Facebook Messenger. Find out what's happen"
## [3] "By Dan Merica and Maegan Vazquez, CNN Updated 3:26 PM ET, Thu November 2, 2017 Chat with us in Faceb"
## [4] "Follow Stories Sam Clovis withdraws his nomination for USDA's top scientist post after being linked "
## [5] "Updated 12:17 pm, Thursday, November 2, 2017 Now Playing: A man nonchalantly walked into a Walmart a"
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
## 3      3  1296     487      45
## 4      4  1036     482      41
## 5      5  1879     433      85
## 6      6  1373     575      61
```

Search function and aggregate functions.
----------------------------------------

GetSearchFreqs() GetKWIC() GetBOW()

Allows for multiple search terms...

As a single pipe.

``` r
library(knitr)
library(kableExtra)
library(DT)

annotations%>%
  corpuslingr::GetContexts(search="<_Jx> <and!> <_Jx>",corp=., LW=5, RW = 5)%>%
  corpuslingr::GetKWIC()%>%
  data.frame()%>%
  select(doc_id,cont)%>%
  kable("markdown") %>%
  kable_styling()
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
<td align="left">businesses blasted the bill as <mark> ineffective and harmful </mark> to Americans Advertisement Representative Peter</td>
</tr>
<tr class="even">
<td align="right">1</td>
<td align="left">host of changes on the <mark> corporate and individual </mark> side , including repealing tax</td>
</tr>
<tr class="odd">
<td align="right">1</td>
<td align="left">. The cut would be <mark> immediate and permanent </mark> . It also eliminates the</td>
</tr>
<tr class="even">
<td align="right">4</td>
<td align="left">&quot; I will remain a <mark> devoted and loyal </mark> supporter and will continue to</td>
</tr>
<tr class="odd">
<td align="right">6</td>
<td align="left">final out . It 's <mark> unfair and borderline </mark> irresponsible the way we insist</td>
</tr>
<tr class="even">
<td align="right">6</td>
<td align="left">feeling that he pitched well <mark> enough and long </mark> enough to ignite an offseason</td>
</tr>
<tr class="odd">
<td align="right">7</td>
<td align="left">'ll be toting a hefty <mark> economic and national </mark> security agenda . But he</td>
</tr>
<tr class="even">
<td align="right">8</td>
<td align="left">its stimulus campaign at a <mark> slow and steady </mark> pace . Over the last</td>
</tr>
<tr class="odd">
<td align="right">10</td>
<td align="left">pain and divisiveness undermining the <mark> open and productive </mark> discourse that I had hoped</td>
</tr>
<tr class="even">
<td align="right">10</td>
<td align="left">within the confines of a <mark> clear and concise </mark> set of laws that they</td>
</tr>
<tr class="odd">
<td align="right">10</td>
<td align="left">pain and divisiveness undermining the <mark> open and productive </mark> discourse that I had hoped</td>
</tr>
</tbody>
</table>

render("C:\\Users\\jason\\Google Drive\\GitHub\\packages\\corpuslingr\\README.rmd")
