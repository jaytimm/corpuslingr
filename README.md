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

These functions .... There are other packages/means to scrape the web. The two included here are designed for quick/easy search of headline news. And creation of tif corpus-object. making subsequent annotation straightforward. 'Scrape news -&gt; annotate -&gt; search' in three or four steps.

Following grammatical constructions ~ day-to-day changes, eg. Search defaults to NULL, which smounts to national headlines.

### clr\_web\_gnews()

``` r
dailyMeta <- corpuslingr::clr_web_gnews (search="New Mexico",n=30)

head(dailyMeta['titles'])
##                                                                              titles
## 2 Indian Slavery Once Thrived in New Mexico. Latinos Are Finding Family Ties to It.
## 3                        Publicly-Funded New Mexico Spaceport Seeks Confidentiality
## 4                      University of New Mexico Ranked 7th for Application Increase
## 5                       Lawsuit Targets New Mexico's Two-Tier Identification System
## 6                             New Mexico lawmaker seeks funding for school security
## 7                         New Mexico Art Exhibit Highlights Presidents' Word Choice
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
## 1:     16      11007     2526      641
```

``` r
head(corpuslingr::clr_desc_corpus(lingr_corpus)$text)
##    doc_id textLength textType textSent
## 1:  text1        958      346       56
## 2: text10        759      327       41
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
## 2: text10      come up   VB RP     come up 
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
## 2:    COME UP     2    2
## 3: PARTNER UP     2    1
## 4:     SET UP     2    2
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
## 1: text10        strong and broad
## 2: text10     different and local
## 3: text11       public and tribal
## 4: text11 irreversible and costly
## 5: text11     efficient and safer
## 6: text11  transparent and honest
##                                                                                               kwic
## 1: Florida and Virginia had very <mark> strong and broad </mark> protections for companies that go
## 2:           decides on a . Sometimes <mark> different and local </mark> laws pose a for companies
## 3:    emissions being wasted on our <mark> public and tribal </mark> lands yearly . These measures
## 4:    full of this without creating <mark> irreversible and costly </mark> issues . The New Mexico
## 5:          Mining and to develop more <mark> efficient and safer </mark> methods of mineral . The
## 6:    operating in a responsible , <mark> transparent and honest </mark> . Every across New Mexico
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
## 4:        COMPANY  NOUN      2
## 5:             GO  VERB      2
## 6:         OPTION  NOUN      2
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
##    doc_id                                                      keyphrases
## 1:  text1          West Texas | western New Mexico | Buffs | Evans | WNm 
## 2: text10              company | Hicks | open rule | DiBello | operation 
## 3: text11           lands | measure | New Mexicans | resource | Martinez 
## 4: text12 Colorado State | Rams | point | Jackson | Wyoming on Wednesday 
## 5: text13            slave | Americas | descendant | Hispanic | Trujillo 
## 6: text14   inmate | Valencia | document | corrections Department | July
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
