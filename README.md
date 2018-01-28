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

Following grammatical constructions ~ day-to-day changes, eg. Search defaults to NULL, which smounts to national headlines.

### GetGoogleNewsMeta()

``` r
dailyMeta <- corpuslingr::GetGoogleNewsMeta (search="New Mexico",n=30)

head(dailyMeta['titles'])
##                                                                              titles
## 2             New Mexico holds hundreds of people in prison past their release date
## 3 Indian Slavery Once Thrived in New Mexico. Latinos Are Finding Family Ties to It.
## 4                                  Colorado State comes up short against New Mexico
## 5               Stuck at the bottom: Why New Mexico fails to thrive | Education ...
## 6               New Mexico Senior care services no longer on the chopping block ...
## 7                               Breaking down lawmakers' bills on kids and families
```

### GetWebTexts()

This function ... takes the output of GetGoogleNews() (or any table with links to websites) ... and returns a 'tif as corpus df' Text interchange formats.

``` r
nm_news <- dailyMeta %>% 
  corpuslingr::GetWebTexts(link_var='links')
```

Corpus preparation
------------------

### PrepCorpus()

Also, PrepText(). Although, I think it may not work on TIF. Hyphenated words and any excessive spacing in texts. Upstream solution.

``` r
nm_news <- nm_news %>% mutate(text = PrepCorpus(text, hyphenate = TRUE))
```

Using the ... `cleanNLP` package.

``` r
cleanNLP::cnlp_init_udpipe(model_name="english",feature_flag = FALSE, parser = "none") 
ann_corpus <- cleanNLP::cnlp_annotate(nm_news$text, as_strings = TRUE) 
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
## 1:     20      12720     2962      749
```

``` r
head(corpuslingr::GetDocDesc(lingr_corpus)$text)
##    doc_id textLength textType textSent
## 1:  text1        958      346       56
## 2: text10        470      197       21
## 3: text11        526      244       36
## 4: text12        417      215       18
## 5: text13        963      404       61
## 6: text14        791      356       39
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
## 2: text10     step up   VB IN    step up 
## 3: text11 climbing up  VBG RP  climbe up 
## 4: text11     woke up  VBD RP    wake up 
## 5: text13     stay up   VB IN    stay up 
## 6: text13   teamed up  VBN RP    team up
```

### GetContexts()

This function allows ... output includes a list of data.frames. `BOW` and `KWIC`

``` r
search2 <- '<all!> <> <of!>'
corpuslingr::GetContexts(search=search2,corp=lingr_corpus,LW=5, RW = 5)%>%
  corpuslingr::GetKWIC()
##    doc_id       lemma
## 1: text13 all four of
## 2: text19   all or of
## 3: text20 all sort of
## 4:  text6   all or of
##                                                                                              kwic
## 1:                                s came out on in <mark> all four of </mark> her events on the ,
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
## 2:    MAKE UP     2    2
## 3: PARTNER UP     2    1
## 4:     SET UP     2    2
## 5:      BE UP     1    1
## 6: CLAMBER UP     1    1
```

### GetKWIC()

``` r
search4 <- "<_Jx> <and!> <_Jx>"

corpuslingr::GetContexts(search=search4,corp=lingr_corpus,LW=5, RW = 5)%>%
  corpuslingr::GetKWIC()%>%
  head()
##    doc_id                   lemma
## 1: text13        third and fourth
## 2: text14        warmer and drier
## 3: text14        early and active
## 4: text18       mexican and other
## 5: text18 fascinating and disturb
## 6: text19       overall and fewer
##                                                                                        kwic
## 1:      1:00.30 ) finished second , <mark> third and fourth </mark> , respectively , at the
## 2:    through early , so continued <mark> warmer and drier </mark> than normal , " Fontenot
## 3:      We are preparing for an <mark> early and active </mark> and bringing some and crews
## 4:       , as well as from <mark> Mexican and other </mark> Latin American immigrants . But
## 5:   , but it 's both <mark> fascinating and disturbing </mark> to see how various cultures
## 6: a in women 's rates <mark> overall and fewer </mark> community-based options for them as
```

### GetBOW()

Vector space model, or word embedding

### GetKeyphrases()

most of this is described more thoroughly in this [post](https://www.jtimm.net/blog/keyphrase-extraction-from-a-corpus-of-texts/).

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
##                                                                                        keyphrases
## 1:                                         West Texas | Buffs | western New Mexico | Evans | WNm 
## 2: democratic lawmaker | dollar to New Mexico | New Mexico House | Russell Contreras | incentive 
## 3:                       light | dinosaur | Yakima | West Valley High School | McKenzie Jamieson 
## 4:                                               Rams | Lobos | Colorado State | point | rebound 
## 5:                                                 event | Aggy | Lobos | individual win | State 
## 6:                                               Thursday | La | condition | Fontenot | Pajarito
```

?Reference corpus.
~Perhaps using SOTU.

Multi-term search
-----------------

``` r
#multi-search <- c("")
search6 <- "<_xNP> (<wish&> |<hope&> |<believe&> )"
```

Corpus workflow with corpuslingr, cleanNLP, & tidy
--------------------------------------------------

``` r
corpuslingr::GetGoogleNewsMeta (search="New Mexico",n=30) %>%
  corpuslingr::GetWebTexts(link_var='links') %>%
  mutate(txt=stringi::stri_enc_toutf8(txt))%>%
  cleanNLP::cnlp_annotate(as_strings = TRUE) %>%
  corpuslingr::SetSearchCorpus(doc_var='id', 
                  token_var='word', 
                  lemma_var='lemma', 
                  tag_var='pos', 
                  pos_var='upos',
                  sentence_var='sid',
                  NER_as_tag = FALSE) %>%
  corpuslingr::GetContexts(search=search2,LW=5, RW = 5)%>%
  corpuslingr::GetKWIC()
```
