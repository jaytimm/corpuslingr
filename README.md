corpuslingr:
============

Some r functions for (1) quick web scraping and (2) corpus seach of complex grammatical constructions in context.

The two sets of functions can be used in conjunction, or independently. In theory, one could build a corpus of the days news (as a dataframe in text interchange format), annotate the corpus using r-pacakges `cleanNLP`, `spacyr`, or `udap`, and subsequently search the corpus for complex grammtical constructions utilizing search functionality akin to that made available in the [BYU suite of corpora]().

The package facilitates regex/CQL-based search across form, lemma, and detailed part-of-speech tags. Multi-term search is also supported. Summary functions allow users to aggregate search results by text & token frequency, view search results in context (kwic), and create word embeddings/co-occurrence vectors for each search term.

The collection of functions presented here is ideal for usage-based linguists and digital humanists interested in fine-grained search of moderately-sized corpora.

``` r
library(tidyverse)
library(cleanNLP)
library(corpuslingr) #devtools::install_github("jaytimm/corpuslingr")
```

Web scraping functions
----------------------

The two web-based functions presented here more or less work in tandem.

### clr\_web\_gnews()

The first, `clr_web_gnews`, simply pulls metadata based on user-specified search paramaters from the GoogleNews RSS feed.

``` r
dailyMeta <- corpuslingr::clr_web_gnews (search="New Mexico",n=30)

head(dailyMeta['titles'])
##                                                                              titles
## 2              Publicly-Funded New Mexico Spaceport Seeks Confidentiality | New ...
## 3 Indian Slavery Once Thrived in New Mexico. Latinos Are Finding Family Ties to It.
## 4                      University of New Mexico Ranked 7th for Application Increase
## 5                       Lawsuit Targets New Mexico's Two-Tier Identification System
## 6                   New Mexico lawmaker seeks funding for school security | The ...
## 7                         New Mexico Art Exhibit Highlights Presidents' Word Choice
```

### clr\_web\_scrape()

The second function, `clr_web_scrape`, scrapes text from a vector of web addresses. This can be supplied by the output from `clr_web_gnews`, or any dataframe with links to websites. The function returns a [TIF](https://github.com/ropensci/tif#text-interchange-formats)-compliant dataframe, with each scraped text represented as a single row. Metadata from output of `clr_web_gnews` is also included.

Both functions depend on functionality made available in the `boilerpipeR`, `XML`, and `RCurl` packages.

``` r
nm_news <- dailyMeta %>% 
  corpuslingr::clr_web_scrape(link_var='links')
```

Corpus preparation & annotation
-------------------------------

### clr\_prep\_corpus

This function performs two tasks. It elminates unnecessary whitespace from the text column of a corpus dataframe object. Additionally, it attempts to trick annotators into treating hyphenated words as a single token. With the exception of Stanford's CoreNLP (via `cleanNLP`), annotators tend to treat hyphenated words as multiple word tokens. For linguists interested in word formation processes, eg, this is disappointing. There is likley a less hacky way to do this.

``` r
nm_news <- nm_news %>% mutate(text = corpuslingr::clr_prep_corpus (text, hyphenate = TRUE))
```

### Annotate via cleanNLP and udpipe

For demo purposes, we use `udpipe` (via `cleanNLP`) to annotate the corpus dataframe object. The `cleanNLP` package is fantastic -- the author has aggregated three different annotators (spacy, CoreNLP, and `udpipe`) into one convenient pacakge. There are pros/cons with each annotator; we won't get into these here.

A benefit of `udpipe` is that it is dependency-free, making it super useful for classroom and demo purposes.

``` r
cleanNLP::cnlp_init_udpipe(model_name="english",feature_flag = FALSE, parser = "none") 
ann_corpus <- cleanNLP::cnlp_annotate(nm_news$text, as_strings = TRUE) 
```

### clr\_set\_corpus()

This function gets the corpus ready for complex, tuple-based search. Tuples are created, taking the form `<token,lemma,pos>`; tuple onsets/offsets are also set. Annotation output is homogenized, including column names, making things easier 'downstream.' Naming conventions established in the `spacyr` package are adopted here.

Lastly, the function splits the corpus into a list of dataframes by document. This is ultimately a search convenience.

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

A simple function for describing corpus. As can be noted, not all of the user-specified (n=30) links were successfully scraped. Not all websites care to be scraped.

``` r
corpuslingr::clr_desc_corpus(lingr_corpus)$corpus
##    n_docs textLength textType textSent
## 1:     16      10842     2549      667
```

Text-based descritpives:

``` r
head(corpuslingr::clr_desc_corpus(lingr_corpus)$text)
##    doc_id textLength textType textSent
## 1:  text1        289      177       14
## 2: text10        963      404       61
## 3: text11        540      268       32
## 4: text12        338      188       18
## 5: text13        643      334       29
## 6: text14        985      448       48
```

Search & aggregation functions
------------------------------

After setting the tuples, text can now be rebuilt

``` r
paste(lingr_corpus[[5]]$tup[1:5], sep=" ",collapse=" ")
## [1] "<Opt,opt,VB> <out,out,RP> <or,or,CC> <contact,contact,VB> <us,we,PRP>"
```

### An in-house corpus querying language (CQL)

A fairly crude corpus querying language Should be 'copy and paste' at his point. See 'Corpus design' post. Tuples and complex corpus search.?

### clr\_search\_gramx()

``` r
search1 <- "<_Vx> <up!>"

lingr_corpus %>%
  corpuslingr::clr_search_gramx(search=search1)%>%
  head ()
##    doc_id         token     tag       lemma
## 1: text10      stay up   VB IN     stay up 
## 2: text10    teamed up  VBN RP     team up 
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
## 2:    SHOW UP     3    1
## 3: PARTNER UP     2    1
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
## 1: text10        third and fourth
## 2: text11       public and tribal
## 3: text11 irreversible and costly
## 4: text11     efficient and safer
## 5: text11  transparent and honest
## 6: text11     fair and reasonable
##                                                                                            kwic
## 1:          1:00.30 ) finished second , <mark> third and fourth </mark> , respectively , at the
## 2: emissions being wasted on our <mark> public and tribal </mark> lands yearly . These measures
## 3: full of this without creating <mark> irreversible and costly </mark> issues . The New Mexico
## 4:       Mining and to develop more <mark> efficient and safer </mark> methods of mineral . The
## 5: operating in a responsible , <mark> transparent and honest </mark> . Every across New Mexico
## 6:                  we leave as their . <mark> Fair and reasonable </mark> rules are in 's best
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
## 4:             GO  VERB      2
## 5:           KNOW  VERB      2
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
##    doc_id
## 1:  text1
## 2: text10
## 3: text11
## 4: text12
## 5: text13
## 6: text14
##                                                                keyphrases
## 1: Morale | Services | meals on wheels | senior | senior service for ten 
## 2:                       event | Aggy | Lobos | McGowan | individual win 
## 3:                       lands | measure | dollar | State | New Mexicans 
## 4:         point | Colorado State | minute | Rams | Wyoming on Wednesday 
## 5:                 slave | origin | Trujillo | Hispanic | indian captive 
## 6:          Valencia | inmate | document | corrections Department | July
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
