corpuslingr:
============

Some r functions for (1) quick web scraping and (2) corpus seach of complex grammatical constructions in context.

The two sets of functions can be used in conjunction, or independently. In theory, one could build a corpus of the days news (as a dataframe in text interchange format), annotate the corpus using `cleanNLP`, `spacyr`, or `udap`, and subsequently search the corpus for complex grammtical constructions utilizing search functionality akin to that made available in the [BYU suite of corpora]().

The package facilitates regex/CQL-based search across form, lemma, and detailed part-of-speech tags. Multi-term search is also supported. Summary functions allow users to aggregate search results by text & token frequency, view search results in context (kwic), and create word embeddings/co-occurrence vectors for each search term.

The collection of functions presented here is ideal for usage-based linguists and digital humanists interested in fine-grained search of moderately-sized (personal) corpora.

``` r
library(tidyverse)
library(cleanNLP)
library(corpuslingr) #devtools::install_github("jaytimm/corpuslingr")
```

Web scraping functions
----------------------

### clr\_web\_gnews()

The two functions presented here more or less work in tandem. The first, `clr_web_gnews`, simply pulls metadata based on user-specified search paramaters from the GoogleNews RSS feed.

``` r
dailyMeta <- corpuslingr::clr_web_gnews (search="New Mexico",n=30)

head(dailyMeta['titles'])
##                                                                              titles
## 2 Indian Slavery Once Thrived in New Mexico. Latinos Are Finding Family Ties to It.
## 3                        Publicly-Funded New Mexico Spaceport Seeks Confidentiality
## 4                      University of New Mexico Ranked 7th for Application Increase
## 5                       Lawsuit Targets New Mexico's Two-Tier Identification System
## 6                             New Mexico lawmaker seeks funding for school security
## 7             New Mexico holds hundreds of people in prison past their release date
```

### clr\_web\_scrape()

The second function, `clr_web_scrape`, scrapes text from a vector of web addresses. This can be supplied by the output from `clr_web_gnews`, or any dataframe with links to websites.

The function returns a [TIF]()-compliant dataframe, with each scraped text represented as a single row. Metadata from output of `clr_web_gnews` is also included.

Both functions depend on functionality made available in the `boilerpipeR`, `XML`, and `RCurl` packages.

``` r
nm_news <- dailyMeta %>% 
  corpuslingr::clr_web_scrape(link_var='links')
```

Corpus preparation
------------------

### clr\_prep\_corpus

This function performs two tasks. It elminates unnecessary whitespace from the text column of the corpus dataframe object. Additionally, it attempts to trick annotators into treating hyphenated words as a single token. With the exception of Stanford's CoreNLP (via `cleanNLP`), annotators tend to treat hyphenated words as multiple word tokens. For folks interested in word formation processes, eg, this is disappointing. There is likley a less hacky way to do this.

``` r
nm_news <- nm_news %>% mutate(text = corpuslingr::clr_prep_corpus (text, hyphenate = TRUE))
```

For demo purposes, we use `udpipe` (via `cleanNLP`) to annotate the corpus dataframe object. The `cleanNLP` package is fantastic -- the author has aggregated three different annotators (spacy, CoreNLP, and `udpipe`) into one convenient pacakge. There are pros/cons with each annotator; we won't get into these here.

A benefit of `udpipe` is that it is dependency-free, making it super useful for classroom and demo purposes.

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
## 1:     16      10373     2465      605
```

``` r
head(corpuslingr::clr_desc_corpus(lingr_corpus)$text)
##    doc_id textLength textType textSent
## 1:  text1        958      346       56
## 2: text10        791      356       39
## 3: text11        540      268       32
## 4: text12        338      188       18
## 5: text13        643      334       29
## 6: text14        985      448       48
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
##    doc_id         token     tag       lemma
## 1:  text1      sets up  VBZ RP      set up 
## 2: text10   setting up  VBG RP      set up 
## 3: text12     comes up  VBZ RP     come up 
## 4: text15        is up  VBZ JJ       be up 
## 5: text15   partner up   VB RP  partner up 
## 6: text15 partnered up  VBD RP  partner up
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
## 1: text10        warmer and drier
## 2: text10        early and active
## 3: text11       public and tribal
## 4: text11 irreversible and costly
## 5: text11     efficient and safer
## 6: text11  transparent and honest
##                                                                                            kwic
## 1:        through early , so continued <mark> warmer and drier </mark> than normal , " Fontenot
## 2:          We are preparing for an <mark> early and active </mark> and bringing some and crews
## 3: emissions being wasted on our <mark> public and tribal </mark> lands yearly . These measures
## 4: full of this without creating <mark> irreversible and costly </mark> issues . The New Mexico
## 5:       Mining and to develop more <mark> efficient and safer </mark> methods of mineral . The
## 6: operating in a responsible , <mark> transparent and honest </mark> . Every across New Mexico
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
##    doc_id                                                    keyphrases
## 1:  text1        West Texas | Buffs | western New Mexico | Evans | WNm 
## 2: text10              La | condition | Thursday | Fontenot | Pajarito 
## 3: text11           lands | New Mexicans | dollar | measure | resource 
## 4: text12              Colorado State | Rams | point | Jackson | Paige 
## 5: text13          slave | Americas | Hispanic | descendant | Trujillo 
## 6: text14 inmate | Valencia | document | corrections Department | July
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
corpuslingr::clr_web_gnews(search="New Mexico",n=30) %>%
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
