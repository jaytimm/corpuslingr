corpuslingr:
============

Some r functions for (1) quick web scraping and (2) corpus seach of complex grammatical constructions in context.

The two sets of functions can be used in conjunction, or independently. In theory, one could build a corpus of the days news (as a dataframe in text interchange format), annotate the corpus using r-pacakges `cleanNLP`, `spacyr`, or `udap`, and subsequently search the corpus for complex grammatical constructions utilizing search functionality akin to that made available in the [BYU suite of corpora]().

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
```

Metadata include:

    ## [1] "source"   "titles"   "links"    "pubdates" "date"

First six article titles:

``` r
head(dailyMeta['titles'])
##                                                                              titles
## 2                        Legal Challenge Targets New Mexico Driver's License System
## 3              Publicly-Funded New Mexico Spaceport Seeks Confidentiality | New ...
## 4 Indian Slavery Once Thrived in New Mexico. Latinos Are Finding Family Ties to It.
## 5                      University of New Mexico Ranked 7th for Application Increase
## 6                   New Mexico lawmaker seeks funding for school security | The ...
## 7             New Mexico holds hundreds of people in prison past their release date
```

### clr\_web\_scrape()

The second web-based function, `clr_web_scrape`, scrapes text from the web addresses included in the output from `clr_web_gnews` (or any vector that contains web addresses). The function returns a [TIF](https://github.com/ropensci/tif#text-interchange-formats)-compliant dataframe, with each scraped text represented as a single row. Metadata from output of `clr_web_gnews` are also included.

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

This function prepares the annotated corpus for complex, tuple-based search. Tuples are created, taking the form `<token,lemma,pos>`; tuple onsets/offsets are also set. Annotation output is homogenized, including column names, making text processing easier 'downstream.' Naming conventions established in the `spacyr` package are adopted here.

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

A simple function for describing the corpus. As can be noted, not all of the user-specified (n=30) links were successfully scraped. Not all websites care to be scraped.

``` r
corpuslingr::clr_desc_corpus(lingr_corpus)$corpus
##    n_docs textLength textType textSent
## 1:     17      11840     2754      722
```

Text-based descritpives:

``` r
head(corpuslingr::clr_desc_corpus(lingr_corpus)$text)
##    doc_id textLength textType textSent
## 1:  text1        289      177       14
## 2: text10        470      197       21
## 3: text11        963      404       61
## 4: text12        540      268       32
## 5: text13        338      188       18
## 6: text14       1516      633       76
```

Search & aggregation functions
------------------------------

### A corpus querying language (CQL)

A fairly crude corpus querying language is utilized/included in the package.

The CQL presented here consists of four basic elements. Individual search components are enclosed with `<>`, lemma search is specified using `&`, token search is specified using `!`, and part-of-speech search is specified using `_`. Additionally, parts-of-speech can be made generic/universal with the suffix `x`. So, a search for all nouns forms (NN, NNS, NNP, NNPS) would be specified by `_Nx`. All other regular expressions work in conjunction with these search expressions.

### clr\_search\_gramx()

Search for all instantiaions of a particular lexical pattern/grammatical construction devoid of context. This function enables fairly quick search.

``` r
search1 <- "<_Vx> <up!>"

lingr_corpus %>%
  corpuslingr::clr_search_gramx(search=search1)%>%
  head ()
##    doc_id      token     tag    lemma
## 1: text10   step up   VB IN  step up 
## 2: text11   stay up   VB IN  stay up 
## 3: text11 teamed up  VBN RP  team up 
## 4: text13  comes up  VBZ RP  come up 
## 5: text14   Sign up   VB RP  sign up 
## 6: text16     is up  VBZ JJ    be up
```

### clr\_get\_freqs()

A simple function for calculating text and token frequencies of search term(s). The `agg_var` parameter allows the user to specify how frequency counts are aggregated.

Note: Generic nounphrases can be include as a search term. The regex for a generic nounphrase is below, and can be specified using `_NXP`.

``` r
clr_nounphrase
## [1] "(?:(?:<_DT> )?(?:<_Jx> )*)?(?:((<_Nx> )+|<_PRP> ))"
```

``` r
search2 <- "<_NXP> <_Vx> <to!> <_Vx>"

lingr_corpus %>%
  corpuslingr::clr_search_gramx(search=search2)%>%
  corpuslingr::clr_get_freq(agg_var = 'token')%>%
  head()
##                                                    token txtf docf
## 1:               DEMOCRATIC LAWMAKERS WANT TO ELIMINATE     3    1
## 2:                             THEY PREPARE TO RE-ENTER     2    2
## 3: ADVERTISEMENT NMFFL JOSEPH PRESTWICH VENTURES TO SAY     1    1
## 4:                                     I WANT TO ASSURE     1    1
## 5:                     INDIAN CAPTIVES SOUGHT TO ESCAPE     1    1
## 6:                                   IT COMES TO RETURN     1    1
```

### clr\_search\_context()

A function that returns search terms with user-specified left and right contexts (`LW` and `RW`). Output is an intermediary list of dataframes, including `BOW` and `KWIC` dataframe objects.

``` r
search3 <- '<_Jx> <and!> <_Jx>'

found_egs <- corpuslingr::clr_search_context(search=search3,corp=lingr_corpus,LW=5, RW = 5)
```

### clr\_context\_kwic()

Access `KWIC` dataframe:

``` r
found_egs %>%
  corpuslingr::clr_context_kwic()%>%
  head()
##    doc_id                   lemma
## 1: text11        third and fourth
## 2: text12       public and tribal
## 3: text12 irreversible and costly
## 4: text12     efficient and safer
## 5: text12  transparent and honest
## 6: text12     fair and reasonable
##                                                                                            kwic
## 1:          1:00.30 ) finished second , <mark> third and fourth </mark> , respectively , at the
## 2: emissions being wasted on our <mark> public and tribal </mark> lands yearly . These measures
## 3: full of this without creating <mark> irreversible and costly </mark> issues . The New Mexico
## 4:       Mining and to develop more <mark> efficient and safer </mark> methods of mineral . The
## 5: operating in a responsible , <mark> transparent and honest </mark> . Every across New Mexico
## 6:                  we leave as their . <mark> Fair and reasonable </mark> rules are in 's best
```

### clr\_context\_bow()

Access 'BOW\` dataframe object:

``` r
search3 <- c('<Santa&> <Fe&>','<Albuquerque&>')

corpuslingr::clr_search_context(search=search3,corp=lingr_corpus,LW=10, RW = 10)%>%
  corpuslingr::clr_context_bow(content_only=TRUE,agg_var=c('searchLemma','lemma'))%>%
  head()
##    searchLemma       lemma cofreq
## 1: ALBUQUERQUE         NEW     17
## 2: ALBUQUERQUE      MEXICO     13
## 3: ALBUQUERQUE        N.M.     11
## 4: ALBUQUERQUE        2018      8
## 5: ALBUQUERQUE ALBUQUERQUE      6
## 6: ALBUQUERQUE        MORE      5
```

### clr\_search\_keyphrases()

Function for extracting keyphrases for each text in a corpus based on tf-idf weights. The methods and logic underlying this function are described more thoroughly in [here](https://www.jtimm.net/blog/keyphrase-extraction-from-a-corpus-of-texts/).

The regex for keyphrase search:

``` r
clr_keyphrase
## [1] "(<_JJ> )*(<_N[A-Z]{1,10}> )+((<_IN> )(<_JJ> )*(<_N[A-Z]{1,10}> )+)?"
```

The use can specify the number of keyphrases to extract,

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
##                                                                                       keyphrases
## 1:                                    Morale | meals on wheels | Services | senior | allegation 
## 2: New Mexico House | democratic lawmaker | dollar to New Mexico | official | Russell Contreras 
## 3:                                  event | Aggy | Lobos | individual win | NEW MEXICO Saturday 
## 4:                                                  lands | dollar | measure | Martinez | State 
## 5:                                             point | Colorado State | Rams | minute | Jackson 
## 6:                                           slave | Trujillo | descendant | Hispanic | Malcolm
```

Multi-term search
-----------------

``` r
#multi-search <- c("")
search6 <- "<_xNP> (<wish&> |<hope&> |<believe&> )"
```

Corpus workflow with corpuslingr, cleanNLP, & magrittr
------------------------------------------------------

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
