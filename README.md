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
## 2                             CNN
## 3                 Washington Post
## 4                 Washington Post
## 5                  New York Times
## 6                 Washington Post
##                                                                                                           titles
## 1                                                                                This RSS feed URL is deprecated
## 2                                                                 GOP leaders unveil key details in new tax plan
## 3 Ex-DNC chair goes at the Clintons, alleging Hillary's campaign hijacked DNC during primary with Bernie Sanders
## 4               Investigators probe New York attack suspect's communications while Trump calls for death penalty
## 5                                                      When Astros Needed to Improvise, Charlie Morton Was Ready
## 6           Sam Clovis withdraws his nomination for USDA's top scientist post after being linked to Russia probe
```

``` r
txts <- dailyMeta$links  %>% 
  GetWebTexts()

substr(txts[1:5],1, 100)
## [1] "Updated 12:20 PM ET, Thu November 2, 2017 Chat with us in Facebook Messenger. Find out what's happen"
## [2] "Analysis Analysis Interpretation of the news based on evidence, including data, as well as anticipat"
## [3] "The inside track on Washington politics. Be the first to know about new stories from PowerPost. Sign"
## [4] "Follow Stories Sam Clovis withdraws his nomination for USDA's top scientist post after being linked "
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
##   doc_id sentence_id token_id   token  lemma   pos tag entity
## 1      1           1        1 Updated update  VERB VBN       
## 2      1           1        2   12:20  12:20   NUM  CD TIME_B
## 3      1           1        3      PM     pm  NOUN  NN TIME_I
## 4      1           1        4      ET     ET PROPN NNP TIME_I
## 5      1           1        5       ,      , PUNCT   ,       
## 6      1           1        6     Thu    Thu PROPN NNP       
##                    tup tupBeg tupEnd
## 1 <Updated,update,VBN>      1     21
## 2     <12:20,12:20,CD>     22     38
## 3           <PM,pm,NN>     39     49
## 4          <ET,ET,NNP>     50     61
## 5              <,,,,,>     62     69
## 6        <Thu,Thu,NNP>     70     83
```

``` r
head(GetDocDesc(annotations))
## # A tibble: 6 x 4
##   doc_id  docN docType docSent
##    <int> <int>   <int>   <int>
## 1      1  1220     526      50
## 2      2  1015     455      43
## 3      3  1972     806      83
## 4      4   965     474      38
## 5      5  2570     418     100
## 6      6  1293     466      56
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
  kable("markdown") 
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
<td align="left">happening in the world as <mark> it unfolds </mark> . JUST WATCHED Story highlights</td>
</tr>
<tr class="even">
<td align="left">as it unfolds . JUST <mark> WATCHED Story highlights </mark> A new Republican tax plan</td>
</tr>
<tr class="odd">
<td align="left">. JUST WATCHED Story highlights <mark> A new Republican tax plan lowers </mark> the individual brackets from seven</td>
</tr>
<tr class="even">
<td align="left">brackets from seven to four <mark> GOP Congress members hope </mark> party leaders have learned from</td>
</tr>
<tr class="odd">
<td align="left">four GOP Congress members hope <mark> party leaders have </mark> learned from health care 's</td>
</tr>
<tr class="even">
<td align="left">'s failure ( CNN ) <mark> House Republicans unveiled </mark> key details and the text</td>
</tr>
<tr class="odd">
<td align="left">tax legislation Thursday , with <mark> House Speaker Paul Ryan pitching </mark> the plan as much -</td>
</tr>
<tr class="even">
<td align="left">for the middle class . <mark> The Wisconsin Republican described </mark> the proposal to the public</td>
</tr>
<tr class="odd">
<td align="left">proposal to the public as <mark> a break aimed </mark> at helping most Americans .</td>
</tr>
<tr class="even">
<td align="left">class tax cut , &quot; <mark> Ryan said </mark> in an interview with CNN</td>
</tr>
</tbody>
</table>

render("C:\\Users\\jason\\Google Drive\\GitHub\\packages\\corpuslingr\\README.rmd")
