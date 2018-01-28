-   [corpuslingr:](#corpuslingr)
-   [Web scraping functions](#web-scraping-functions)
    -   [GetGoogleNewsMeta()](#getgooglenewsmeta)
    -   [GetWebTexts()](#getwebtexts)
-   [Corpus preparation](#corpus-preparation)
    -   [SetSearchCorpus()](#setsearchcorpus)
    -   [GetDocDesc()](#getdocdesc)
-   [Search function and aggregate functions.](#search-function-and-aggregate-functions.)
    -   [An in-house corpus querying language (CQL)](#an-in-house-corpus-querying-language-cql)
    -   [SimpleSearch()](#simplesearch)
    -   [GetContexts()](#getcontexts)
    -   [GetSearchFreqs()](#getsearchfreqs)
    -   [GetKWIC()](#getkwic)
    -   [GetBOW()](#getbow)
    -   [GetKeyphrases()](#getkeyphrases)
-   [Multi-term search](#multi-term-search)
-   [Corpus workflow](#corpus-workflow)

corpuslingr:
------------

Some r functions for (1) quick web scraping and (2) corpus seach of complex grammatical constructions.

High Level utility. Hypothetical workflows. Independently or in conjunction. Academic linguists and digital humanists.

``` r
library(tidyverse)
library(cleanNLP)
library(stringi)
library(corpuslingr) #devtools::install_github("jaytimm/corpuslingr")
library(corpusdatr) #devtools::install_github("jaytimm/corpusdatr")
```

Web scraping functions
----------------------

These functions .... There are other packages/means to scrape the web. The two included here are designed for quick/easy search of headline news. And creation of tif corpus-object. making subsequent annotation straightforward. 'Scrape news -&gt; annotate -&gt; search' in three or four steps.

Following grammatical constructions ~ day-to-day changes, eg.

### GetGoogleNewsMeta()

``` r
dailyMeta <- corpuslingr::GetGoogleNewsMeta (search="New Mexico",n=30)

head(dailyMeta['titles'])
##                                                                    titles
## 2   New Mexico holds hundreds of people in prison past their release date
## 3                        Colorado State comes up short against New Mexico
## 4     Stuck at the bottom: Why New Mexico fails to thrive | Education ...
## 5                     Breaking down lawmakers' bills on kids and families
## 6         New Mexico Senior care services no longer on the chopping block
## 7 New Mexico invests in young entrepreneurs to kickstart its sluggish ...
```

### GetWebTexts()

This function ... takes the output of GetGoogleNews() (or any table with links to websites) ... and returns a 'tif as corpus df' Text interchange formats.

``` r
nm_news <- dailyMeta %>% 
  corpuslingr::GetWebTexts(link_var='links') %>%
  mutate(txt=stringi::stri_enc_toutf8(txt))
```

Corpus preparation
------------------

Also, PrepText(). Although, I think it may not work on TIF. Hyphenated words and any excessive spacing in texts. Upstream solution.

Using the ... `cleanNLP` package.

``` r
cleanNLP::cnlp_init_udpipe(model_name="english",feature_flag = FALSE, parser = "none") 
## Loading required namespace: udpipe
#cnlp_init_corenlp(language="en",anno_level = 1L)
ann_corpus <- cleanNLP::cnlp_annotate(nm_news$txt, as_strings = TRUE) 
```

### SetSearchCorpus()

This function performs some cleaning ... It will ... any/all annotation types in theory. Output, however, homogenizes column names to make things easier downstream. Naming conventions established in the `spacyr` package are adopted here. The function performs two or three general tasks. Eliminates spaces. Annotation form varies depending on the annotator, as different folks have different

Adds tuples and their chraracter onsets/offsets. A fairly crude corpus querying language

Lastly, the function splits corpus into a list of dataframes by doc\_id. This facilitates ... any easy solution to ...

``` r
lingr_corpus <- ann_corpus$token %>%
  SetSearchCorpus(doc_var='id', 
                  token_var='word', 
                  lemma_var='lemma', 
                  tag_var='pos', 
                  pos_var='upos',
                  sentence_var='sid',
                  NER_as_tag = FALSE)
```

### GetDocDesc()

``` r
corpuslingr::GetDocDesc(lingr_corpus)$corpus
##    n_docs textLength textType textSent
## 1:     21      13649     3041      807
```

``` r
head(corpuslingr::GetDocDesc(lingr_corpus)$text)
##    doc_id textLength textType textSent
## 1:  text1        958      348       55
## 2: text10         92       76        6
## 3: text11       1039      427       70
## 4: text12        543      256       35
## 5: text13        182      106       11
## 6: text14        474      200       21
```

Search function and aggregate functions.
----------------------------------------

We also need to discuss special search terms, eg, `keyPhrase` and `nounPhrase`.

### An in-house corpus querying language (CQL)

Should be 'copy and paste' at his point. See 'Corpus design' post. Tuples and complex corpus search.?

### SimpleSearch()

``` r
search1 <- "<_Vx> <up!>"

lingr_corpus %>%
  corpuslingr::SimpleSearch(search=search1)%>%
  head ()
##    doc_id        token     tag      lemma
## 1:  text1     sets up  VBZ RP     set up 
## 2: text11     grow up   VB RP    grow up 
## 3: text11  growing up  VBG RP    grow up 
## 4: text12    shake up   VB RP   shake up 
## 5: text14     step up   VB IN    step up 
## 6: text15 climbing up  VBG RP  climbe up
```

### GetContexts()

``` r
search4 <- '<all!> <> <of!>'
corpuslingr::GetContexts(search=search4,corp=lingr_corpus,LW=5, RW = 5)%>%
  corpuslingr::GetKWIC()
##    doc_id       lemma
## 1: text16 all four of
## 2: text20   all or of
## 3: text21 all sort of
## 4:  text8   all or of
##                                                                                              kwic
## 1:                            Burns came out on in <mark> all four of </mark> her events on the ,
## 2: corrections officials holding inmates for <mark> all or of </mark> their terms - often because
## 3:            The draws Native vendors and <mark> all sorts of </mark> visitors from far and wide
## 4: corrections officials holding inmates for <mark> all or of </mark> their terms - often because
```

``` r
nounPhrase
## [1] "(?:(?:<_DT> )?(?:<_Jx> )*)?(?:((<_Nx> )+|<_PRP> ))"
```

### GetSearchFreqs()

``` r
lingr_corpus %>%
  corpuslingr::SimpleSearch(search=search1)%>%
  corpuslingr::GetSearchFreqs(aggBy = 'lemma')%>%
  head()
##          lemma txtf docf
## 1:    GROW UP     4    2
## 2:      BE UP     3    2
## 3:    SHOW UP     3    1
## 4: PARTNER UP     2    1
## 5:     SET UP     2    2
## 6:   BRING UP     1    1
```

### GetKWIC()

``` r
search2 <- "<_Jx> <and!> <_Jx>"

corpuslingr::GetContexts(search=search2,corp=lingr_corpus,LW=5, RW = 5)%>%
  corpuslingr::GetKWIC()
##     doc_id                lemma
##  1: text11  economic and social
##  2: text11   economic and early
##  3: text16     third and fourth
##  4: text17     warmer and drier
##  5: text17     early and active
##  6: text20   expensive and long
##  7: text20    overall and fewer
##  8: text21    more and populous
##  9: text21   varied and diverse
## 10: text21         far and wide
## 11: text21    bigger and bigger
## 12:  text4   economic and early
## 13:  text4   early and economic
## 14:  text4      small and large
## 15:  text6 honest and effective
## 16:  text8   expensive and long
## 17:  text8    overall and fewer
##                                                                                                    kwic
##  1:                            and , and of the <mark> economic and social </mark> well - of families .
##  2:                    , nonpartisan Coming Monday : <mark> Economic and early </mark> go in ; shows of
##  3:                 1:00.30 ) finished second , <mark> third and fourth </mark> , respectively , at the
##  4:               through early , so continued <mark> warmer and drier </mark> than normal , " Fontenot
##  5:                 We are preparing for an <mark> early and active </mark> and bringing some and crews
##  6:                                 " in- . " An <mark> expensive and long </mark> - , it routinely has
##  7:                       a in women 's rates <mark> overall and fewer </mark> - based options for them
##  8:               young brains draining away to <mark> more and populous </mark> markets . But there 's
##  9:              these human collisions with a <mark> varied and diverse </mark> of people that can add
## 10:                             all sorts of visitors from <mark> far and wide </mark> . The big is the
## 11:                          to , you know , <mark> bigger and bigger </mark> places ? Alonso Estrada :
## 12:                       around the and the that <mark> economic and early </mark> go in . And nowhere
## 13:                           zeroed in on the between <mark> early and economic </mark> well - . His ,
## 14:             a statewide that represents 250 <mark> small and large </mark> businesses . " . Showing
## 15: empower New Mexicans to demand <mark> honest and effective </mark> public . Politically , advocates
## 16:                                 " in- . " An <mark> expensive and long </mark> - , it routinely has
## 17:                       a in women 's rates <mark> overall and fewer </mark> - based options for them
```

### GetBOW()

Vector space model, or word embedding

### GetKeyphrases()

The package has one 'specialty' function... most of this is described more thoroughly in this [post]().

``` r
keyPhrase
## [1] "(<_JJ> )*(<_N[A-Z]{1,10}> )+((<_IN> )(<_JJ> )*(<_N[A-Z]{1,10}> )+)?"
```

``` r
lingr_corpus %>%
  #SimpleSearch() %>% add doc_var ~makes it more generic. key_var
  GetKeyPhrases(n=5, key_var ='lemma', flatten=TRUE,jitter=TRUE)%>%
  head()
##    doc_id
## 1:  text1
## 2: text10
## 3: text11
## 4: text12
## 5: text13
## 6: text14
##                                                                         keyphrases
## 1:                          West Texas | Buffs | Evans | western New Mexico | WNm 
## 2:     police | passenger | Bloomfield | NW New Mexico David Lynch January | belt 
## 3:                         child | Minnesota | ranking | teens | Casey Foundation 
## 4:                       Dunn | Libertarian | Libertarians | Republicans | Senate 
## 5:                        Youth | Medicaid | glitch | Families Department | child 
## 6: dollar to New Mexico | New Mexico House | democratic lawmaker | AP Photo | NBC
```

?Reference corpus.
~Perhaps using SOTU.

Multi-term search
-----------------

``` r
#multi-search <- c("")
```

Corpus workflow
---------------

``` r
search4 <- "<_xNP> (<wish&> |<hope&> |<believe&> )"
```
