corpuslingr:
------------

Corpus work flow.

``` r
library(tidyverse)
devtools::install_github("jaytimm/corpuslingr")
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

head(dailyMeta)
##            source
## 1 Washington Post
## 2 Washington Post
## 3        Politico
## 4            ESPN
## 5          SFGate
## 6 Washington Post
##                                                                                                           titles
## 1                             The Finance 202: Playbook to kill tax overhaul already written before bill's debut
## 2               Investigators probe New York attack suspect's communications while Trump calls for death penalty
## 3                                          Trump USDA pick, linked to Russia probe, withdraws from consideration
## 4                      Thanks for the memories! Game 7 was no classic, but this was still one great World Series
## 5                                                    The Latest: Tip leads police to suspect in Walmart shooting
## 6 Ex-DNC chair goes at the Clintons, alleging Hillary's campaign hijacked DNC during primary with Bernie Sanders
##                                                                                                                                                                                         links
## 1 https://www.washingtonpost.com/news/powerpost/paloma/the-finance-202/2017/11/02/the-finance-202-playbook-to-kill-tax-overhaul-already-written-before-bill-s-debut/59fa220a30fb0468e7654023/
## 2                              https://www.washingtonpost.com/news/post-nation/wp/2017/11/02/investigators-probe-new-york-attack-suspects-communications-while-trump-calls-for-death-penalty/
## 3                                                                       https://www.politico.com/story/2017/11/02/trump-campaign-aide-clovis-withdraws-from-consideration-for-usda-job-244458
## 4                                                                                                http://www.espn.com/mlb/story/_/id/21259131/game-7-was-no-classic-was-one-great-world-series
## 5                                                                                            http://www.sfgate.com/news/crime/article/The-Latest-Police-name-suspect-in-Colorado-12325944.php
## 6                     https://www.washingtonpost.com/news/the-fix/wp/2017/11/02/ex-dnc-chair-goes-at-the-clintons-alleging-hillarys-campaign-hijacked-dnc-during-primary-with-bernie-sanders/
##                        pubdates
## 1 Thu, 02 Nov 2017 15:11:02 GMT
## 2 Thu, 02 Nov 2017 14:18:59 GMT
## 3 Thu, 02 Nov 2017 16:18:45 GMT
## 4 Thu, 02 Nov 2017 12:56:40 GMT
## 5 Thu, 02 Nov 2017 16:09:09 GMT
## 6 Thu, 02 Nov 2017 15:51:42 GMT
```

``` r
txts <- dailyMeta$links  %>% 
  GetWebTexts()

substr(txts[1:5],1, 100)
## [1] "Analysis Analysis Interpretation of the news based on evidence, including data, as well as anticipat"
## [2] "The inside track on Washington politics. Be the first to know about new stories from PowerPost. Sign"
## [3] "Trump USDA pick, linked to Russia probe, withdraws from consideration Clovis had been under criticis"
## [4] "3hESPN.com 2dMarly Rivera Thanks for the memories! Game 7 was no classic, but this was still one gre"
## [5] "The Latest: Tip leads police to suspect in Walmart shooting Updated 9:32 am, Thursday, November 2, 2"
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
##   doc_id sentence_id token_id          token          lemma   pos tag
## 1      1           1        1       Analysis       Analysis PROPN NNP
## 2      1           1        2       Analysis       Analysis PROPN NNP
## 3      1           1        3 Interpretation Interpretation PROPN NNP
## 4      1           1        4             of             of   ADP  IN
## 5      1           1        5            the            the   DET  DT
## 6      1           1        6           news           news  NOUN  NN
##   entity                                 tup tupBeg tupEnd
## 1  ORG_B             <Analysis,Analysis,NNP>      1     24
## 2  ORG_I             <Analysis,Analysis,NNP>     25     48
## 3  ORG_I <Interpretation,Interpretation,NNP>     49     84
## 4                                 <of,of,IN>     85     95
## 5                               <the,the,DT>     96    108
## 6                             <news,news,NN>    109    123
```

``` r
mm <- GetDocDesc(annotations)
```

Search function and aggregate functions.
----------------------------------------

``` r
x <- spacyr::entity_extract(annotations[[1]])

gg <- lapply(annotations,function(x) {spacyr::entity_extract(x)}) %>%
  bind_rows()
```

GetSearchFreqs()
================

GetKWIC()
=========

GetBOW()
========

Allows for multiple search terms...

As a single pipe.

``` r
library(knitr)
dailyMeta$links  %>% 
  corpuslingr::GetWebTexts()  %>%
  lapply(spacyr::spacy_parse,tag=TRUE)%>%
  corpuslingr::PrepAnnotation()%>%
  corpuslingr::GetContexts(search="<_NXP> <_Vx>",corp=., LW=5, RW = 5)%>%
  corpuslingr::GetKWIC()%>%
  data.frame()%>%
  select(cont)%>%
  slice(1:5)%>%
  kable("html") 
```

<table>
<thead>
<tr>
<th style="text-align:left;">
cont
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
Analysis Analysis Interpretation of &lt;mark&gt; the news based &lt;/mark&gt; on evidence , including data
</td>
</tr>
<tr>
<td style="text-align:left;">
'll receive free e - &lt;mark&gt; mail news updates &lt;/mark&gt; each time a new story
</td>
</tr>
<tr>
<td style="text-align:left;">
mail news updates each time &lt;mark&gt; a new story is &lt;/mark&gt; published . You 're all
</td>
</tr>
<tr>
<td style="text-align:left;">
You 're all set ! &lt;mark&gt; THE TICKER Want &lt;/mark&gt; to keep smart and easy
</td>
</tr>
<tr>
<td style="text-align:left;">
debate in Washington ? &lt;mark&gt; We have &lt;/mark&gt; you covered here . Today
</td>
</tr>
</tbody>
</table>
``` r
spacy_finalize()
```
