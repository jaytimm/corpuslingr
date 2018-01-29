corpuslingr:
------------

Some r functions for (1) quick web scraping and (2) corpus seach of complex grammatical constructions.

High Level utility. Hypothetical workflows. Independently or in conjunction. Academic linguists and digital humanists.

``` r
library(tidyverse)
library(cleanNLP)
library(corpuslingr) #devtools::install_github("jaytimm/corpuslingr")
```

Web scraping functions
----------------------

These functions .... There are other packages/means to scrape the web. The two included here are designed for quick/easy search of headline news. And creation of tif corpus-object. making subsequent annotation straightforward. 'Scrape news -&gt; annotate -&gt; search' in three or four steps.

Following grammatical constructions ~ day-to-day changes, eg. Search defaults to NULL, which smounts to national headlines.

### clr\_web\_gnews()

``` r
dailyMeta <- corpuslingr::clr_web_gnews (search="New Mexico",n=30)

head(dailyMeta['titles'])
##                                                                              titles
## 2 Indian Slavery Once Thrived in New Mexico. Latinos Are Finding Family Ties to It.
## 3                        Publicly-Funded New Mexico Spaceport Seeks Confidentiality
## 4                             New Mexico lawmaker seeks funding for school security
## 5                         New Mexico Art Exhibit Highlights Presidents' Word Choice
## 6             New Mexico holds hundreds of people in prison past their release date
## 7                                  Colorado State comes up short against New Mexico
```

### clr\_web\_scrape()

This function ... takes the output of corp\_web\_gnews() (or any table with links to websites) ... and returns a 'tif as corpus df' Text interchange formats. Builds on top of boilerpipeR, XML, RCurl packages.

``` r
nm_news <- dailyMeta %>% 
  corpuslingr::clr_web_scrape(link_var='links')
```

Corpus preparation
------------------

### clr\_prep\_corpus

Also, PrepText(). Although, I think it may not work on TIF. Hyphenated words and any excessive spacing in texts. Upstream solution.

``` r
nm_news <- nm_news %>% mutate(text = corpuslingr::clr_prep_corpus (text, hyphenate = TRUE))
```

Using the ... `cleanNLP` package.

``` r
cleanNLP::cnlp_init_udpipe(model_name="english",feature_flag = FALSE, parser = "none") 
ann_corpus <- cleanNLP::cnlp_annotate(nm_news$text, as_strings = TRUE) 
```

### clr\_set\_corpus()

This function performs some cleaning ... It will ... any/all annotation types in theory. Output, however, homogenizes column names to make things easier downstream. Naming conventions established in the `spacyr` package are adopted here. The function performs two or three general tasks. Eliminates spaces. Annotation form varies depending on the annotator, as different folks have different

Adds tuples and their chraracter onsets/offsets. A fairly crude corpus querying language

Lastly, the function splits corpus into a list of dataframes by doc\_id. This facilitates ... any easy solution to ...

``` r
lingr_corpus <- ann_corpus$token %>%
  clr_set_corpus(doc_var='id', 
                  token_var='word', 
                  lemma_var='lemma', 
                  tag_var='pos', 
                  pos_var='upos',
                  sentence_var='sid',
                  NER_as_tag = FALSE)
```

### clr\_desc\_corpus()

``` r
corpuslingr::clr_desc_corpus(lingr_corpus)$corpus
##    n_docs textLength textType textSent
## 1:     21      11773     2759      684
```

``` r
head(corpuslingr::clr_desc_corpus(lingr_corpus)$text)
##    doc_id textLength textType textSent
## 1:  text1        958      346       56
## 2: text10        137       88       10
## 3: text11        470      197       21
## 4: text12        419      216       17
## 5: text13        963      404       61
## 6: text14        791      356       39
```

Search & aggregation functions
------------------------------

We also need to discuss special search terms, eg, `keyPhrase` and `nounPhrase`.

### An in-house corpus querying language (CQL)

Should be 'copy and paste' at his point. See 'Corpus design' post. Tuples and complex corpus search.?

### clr\_search\_gramx()

``` r
search1 <- "<_Vx> <up!>"

lingr_corpus %>%
  corpuslingr::clr_search_gramx(search=search1)%>%
  head ()
##    doc_id       token     tag    lemma
## 1:  text1    sets up  VBZ RP   set up 
## 2: text11    step up   VB IN  step up 
## 3: text13    stay up   VB IN  stay up 
## 4: text13  teamed up  VBN RP  team up 
## 5: text14 setting up  VBG RP   set up 
## 6: text16   comes up  VBZ RP  come up
```

### clr\_search\_context()

This function allows ... output includes a list of data.frames. `BOW` and `KWIC`

``` r
search2 <- '<all!> <> <of!>'
found_egs <- corpuslingr::clr_search_context(search=search2,corp=lingr_corpus,LW=5, RW = 5)
```

``` r
clr_nounphrase
## [1] "(?:(?:<_DT> )?(?:<_Jx> )*)?(?:((<_Nx> )+|<_PRP> ))"
```

### clr\_get\_freqs()

``` r
lingr_corpus %>%
  corpuslingr::clr_search_gramx(search=search1)%>%
  corpuslingr::clr_get_freq(agg_var = 'lemma')%>%
  head()
##          lemma txtf docf
## 1:    GROW UP     4    2
## 2: PARTNER UP     2    1
## 3:     SET UP     2    2
## 4:    STEP UP     2    2
## 5:      BE UP     1    1
## 6: CLAMBER UP     1    1
```

### clr\_context\_kwic()

``` r
search4 <- "<_Jx> <and!> <_Jx>"

corpuslingr::clr_search_context(search=search4,corp=lingr_corpus,LW=5, RW = 5)%>%
  corpuslingr::clr_context_kwic()%>%
  head()
##    doc_id                   lemma
## 1: text13        third and fourth
## 2: text14        warmer and drier
## 3: text14        early and active
## 4: text15       public and tribal
## 5: text15 irreversible and costly
## 6: text15     efficient and safer
##                                                                                            kwic
## 1:          1:00.30 ) finished second , <mark> third and fourth </mark> , respectively , at the
## 2:        through early , so continued <mark> warmer and drier </mark> than normal , " Fontenot
## 3:          We are preparing for an <mark> early and active </mark> and bringing some and crews
## 4: emissions being wasted on our <mark> public and tribal </mark> lands yearly . These measures
## 5: full of this without creating <mark> irreversible and costly </mark> issues . The New Mexico
## 6:       Mining and to develop more <mark> efficient and safer </mark> methods of mineral . The
```

### clr\_context\_bow()

Vector space model, or word embedding

``` r
corpuslingr::clr_search_context(search=search4,corp=lingr_corpus,LW=5, RW = 5)%>%
  corpuslingr::clr_context_bow()%>%
  head()
##             lemma   pos cofreq
## 1:         MEXICO PROPN      3
## 2:            NEW PROPN      3
## 3: COMMUNITY-BASE  VERB      2
## 4:         OPTION  NOUN      2
## 5:           RATE  NOUN      2
## 6:          WOMAN  NOUN      2
```

### clr\_search\_keyphrases()

most of this is described more thoroughly in this [post](https://www.jtimm.net/blog/keyphrase-extraction-from-a-corpus-of-texts/).

The function leverages `clr_search_gramx()` .... uses tf-idf weights to extract keyphrases from each text comprising corpus. The user can specify ...

``` r
clr_keyphrase
## [1] "(<_JJ> )*(<_N[A-Z]{1,10}> )+((<_IN> )(<_JJ> )*(<_N[A-Z]{1,10}> )+)?"
```

``` r
lingr_corpus %>%
  corpuslingr::clr_search_keyphrases(n=5, key_var ='lemma', flatten=TRUE,jitter=TRUE)%>%
  head()
##    doc_id
## 1:  text1
## 2: text10
## 3: text11
## 4: text12
## 5: text13
## 6: text14
##                                                                                    keyphrases
## 1:                                     West Texas | western New Mexico | Evans | Buffs | WNm 
## 2: Mortensen | Bloomfield | Steven Mortensen | prosecutor | San Juan Regional Medical Center 
## 3:   New Mexico House | democratic lawmaker | dollar to New Mexico | NBC | Russell Contreras 
## 4:                                           Rams | Colorado State | Lobos | point | rebound 
## 5:                               Aggy | event | Lobos | NEW MEXICO Saturday | individual win 
## 6:                                                    La | condition | Thursday | fire | run
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
corpuslingr::corpuslingr::clr_web_gnews(search="New Mexico",n=30) %>%
  corpuslingr::clr_web_scrape(link_var='links') %>%
  cleanNLP::cnlp_annotate(as_strings = TRUE) %>%
  corpuslingr::clr_set_corpus(doc_var='id', 
                  token_var='word', 
                  lemma_var='lemma', 
                  tag_var='pos', 
                  pos_var='upos',
                  sentence_var='sid',
                  NER_as_tag = FALSE) %>%
  corpuslingr::clr_search_context(search=search2,LW=5, RW = 5)%>%
  corpuslingr::clr_context_kwic()
```
