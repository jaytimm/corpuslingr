corpuslingr:
------------

Some r functions for (1) quick web scraping and (2) corpus seach of complex grammatical constructions.

High Level utility. Hypothetical workflows. Independently or in conjunction. Academic linguists and digital humanists.

``` r
library(tidyverse)
library(cleanNLP)
library(stringi)
library(corpuslingr) #devtools::install_github("jaytimm/corpuslingr")
```

Web scraping functions
----------------------

These functions .... There are other packages/means to scrape the web. The two included here are designed for quick/easy search of headline news. And creation of tif corpus-object. making subsequent annotation straightforward. 'Scrape news -&gt; annotate -&gt; search' in three or four steps.

Following grammatical constructions ~ day-to-day changes, eg.

### GetGoogleNewsMeta()

``` r
dailyMeta <- corpuslingr::GetGoogleNewsMeta (search="New Mexico",n=30)

head(dailyMeta['titles'])
##                                                                  titles
## 2 New Mexico holds hundreds of people in prison past their release date
## 3                      Colorado State comes up short against New Mexico
## 4   Stuck at the bottom: Why New Mexico fails to thrive | Education ...
## 5                   Breaking down lawmakers' bills on kids and families
## 6   New Mexico Senior care services no longer on the chopping block ...
## 7                Turnovers too costly as Rams fall at New Mexico, 80-65
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

### PrepCorpus()

Also, PrepText(). Although, I think it may not work on TIF. Hyphenated words and any excessive spacing in texts. Upstream solution.

Using the ... `cleanNLP` package.

``` r
cleanNLP::cnlp_init_udpipe(model_name="english",feature_flag = FALSE, parser = "none") 
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
## 1:     21      14016     3079      824
```

``` r
head(corpuslingr::GetDocDesc(lingr_corpus)$text)
##    doc_id textLength textType textSent
## 1:  text1        958      348       55
## 2: text10        543      256       35
## 3: text11        182      106       11
## 4: text12        474      200       21
## 5: text13        529      247       36
## 6: text14        422      210       18
```

Search & aggregation functions
------------------------------

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
## 2: text10    shake up   VB RP   shake up 
## 3: text12     step up   VB IN    step up 
## 4: text13 climbing up  VBG RP  climbe up 
## 5: text13     woke up  VBD RP    wake up 
## 6: text15     stay up   VB IN    stay up
```

### GetContexts()

This function allows ... output includes a list of data.frames. `BOW` and `KWIC`

``` r
search2 <- '<all!> <> <of!>'
corpuslingr::GetContexts(search=search2,corp=lingr_corpus,LW=5, RW = 5)%>%
  corpuslingr::GetKWIC()
##    doc_id       lemma
## 1: text15 all four of
## 2: text20   all or of
## 3: text21 all sort of
## 4:  text7   all or of
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
## 2:    SHOW UP     3    1
## 3:    MAKE UP     2    2
## 4: PARTNER UP     2    1
## 5:     SET UP     2    2
## 6:      BE UP     1    1
```

### GetKWIC()

``` r
search4 <- "<_Jx> <and!> <_Jx>"

corpuslingr::GetContexts(search=search4,corp=lingr_corpus,LW=5, RW = 5)%>%
  corpuslingr::GetKWIC()%>%
  head()
##    doc_id              lemma
## 1: text15   third and fourth
## 2: text16   warmer and drier
## 3: text16   early and active
## 4: text20 expensive and long
## 5: text20  overall and fewer
## 6: text21  more and populous
##                                                                                     kwic
## 1:   1:00.30 ) finished second , <mark> third and fourth </mark> , respectively , at the
## 2: through early , so continued <mark> warmer and drier </mark> than normal , " Fontenot
## 3:   We are preparing for an <mark> early and active </mark> and bringing some and crews
## 4:                   " in- . " An <mark> expensive and long </mark> - , it routinely has
## 5:         a in women 's rates <mark> overall and fewer </mark> - based options for them
## 6: young brains draining away to <mark> more and populous </mark> markets . But there 's
```

### GetBOW()

Vector space model, or word embedding

### GetKeyphrases()

most of this is described more thoroughly in this [post]().

The function leverages `SimpleSearch()` .... uses tf-idf weights to extract keyphrases from each text comprising corpus. The user can specify ...

``` r
keyPhrase
## [1] "(<_JJ> )*(<_N[A-Z]{1,10}> )+((<_IN> )(<_JJ> )*(<_N[A-Z]{1,10}> )+)?"
```

``` r
lingr_corpus %>%
  GetKeyPhrases(n=5, key_var ='lemma', flatten=TRUE,jitter=TRUE)%>%
  head()
##    doc_id
## 1:  text1
## 2: text10
## 3: text11
## 4: text12
## 5: text13
## 6: text14
##                                                                                      keyphrases
## 1:                                       West Texas | Evans | western New Mexico | Buffs | WNm 
## 2:                                     Dunn | Libertarians | Libertarian | party | Republicans 
## 3:                                     Medicaid | glitch | Families Department | Youth | child 
## 4: democratic lawmaker | New Mexico House | dollar to New Mexico | Maestas | Russell Contreras 
## 5:                     West Valley High School | McKenzie Jamieson | Yakima | light | dinosaur 
## 6:                                             Rams | Lobos | Colorado State | point | rebound
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
search6 <- "<_xNP> (<wish&> |<hope&> |<believe&> )"
```
