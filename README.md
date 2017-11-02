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
## 3                  New York Times
## 4                             CNN
## 5                          SFGate
## 6                  New York Times
##                                                            titles
## 1                                 This RSS feed URL is deprecated
## 2            Republican Plan Delivers Permanent Corporate Tax Cut
## 3 Trump Abandons Idea of Sending Terrorism Suspect to GuantÃ¡namo
## 4                    Former DNC chair torches Clinton in new book
## 5            The Latest: 3 victims of Walmart shooting identified
## 6               Trump Announces Jerome Powell as New Fed Chairman
```

``` r
txts <- dailyMeta$links  %>% 
  GetWebTexts()

substr(txts[1:5],1, 100)
## [1] "NYTimes.com no longer supports Internet Explorer 9 or earlier. Please upgrade your browser. LEARN MO"
## [2] "NYTimes.com no longer supports Internet Explorer 9 or earlier. Please upgrade your browser. LEARN MO"
## [3] "By Dan Merica and Maegan Vazquez, CNN Updated 3:26 PM ET, Thu November 2, 2017 Chat with us in Faceb"
## [4] "Updated 12:17 pm, Thursday, November 2, 2017 Now Playing: A man nonchalantly walked into a Walmart a"
## [5] "NYTimes.com no longer supports Internet Explorer 9 or earlier. Please upgrade your browser. LEARN MO"
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
## 2      2  1296     602      61
## 3      3  1296     487      45
## 4      4  1879     433      85
## 5      5  1545     666      69
## 6      6   614     336      23
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
  mutate(cont=gsub("<mark>|</mark>","||",cont))%>%
  kable("markdown") %>%
  kable_styling()
```

<table>
<colgroup>
<col width="5%" />
<col width="94%" />
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
<td align="left">businesses blasted the bill as || ineffective and harmful || to Americans Advertisement Representative Peter</td>
</tr>
<tr class="even">
<td align="right">1</td>
<td align="left">host of changes on the || corporate and individual || side , including repealing tax</td>
</tr>
<tr class="odd">
<td align="right">1</td>
<td align="left">. The cut would be || immediate and permanent || . It also eliminates the</td>
</tr>
<tr class="even">
<td align="right">2</td>
<td align="left">February called the comments &quot; || disturbing and disappointing || , &quot; but decided since</td>
</tr>
<tr class="odd">
<td align="right">5</td>
<td align="left">its stimulus campaign at a || slow and steady || pace . Over the last</td>
</tr>
<tr class="even">
<td align="right">7</td>
<td align="left">prevention measure . &quot; Use || interior and exterior || lighting at all times ,</td>
</tr>
<tr class="odd">
<td align="right">7</td>
<td align="left">well - lit streets with || competent and trustworthy || government , &quot; and that</td>
</tr>
<tr class="even">
<td align="right">8</td>
<td align="left">turn away ; along the || quiet and private || Lazy Lane , big estates</td>
</tr>
<tr class="odd">
<td align="right">8</td>
<td align="left">and they 'll forget the || hidden and beautiful || unintended consequence of that victory</td>
</tr>
<tr class="even">
<td align="right">8</td>
<td align="left">victory : All over the || flawed and beautiful || city of Houston , for</td>
</tr>
<tr class="odd">
<td align="right">9</td>
<td align="left">, is known for being || shy and idiosyncratic || . A model - train</td>
</tr>
<tr class="even">
<td align="right">10</td>
<td align="left">is not obviously accessible . || Japanese and French || scientists made the announcement after</td>
</tr>
<tr class="odd">
<td align="right">10</td>
<td align="left">cavity is perhaps 30 m || long and several || metres in height All three</td>
</tr>
</tbody>
</table>

render("C:\\Users\\jason\\Google Drive\\GitHub\\packages\\corpuslingr\\README.rmd")
