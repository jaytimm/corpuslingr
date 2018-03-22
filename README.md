corpuslingr
===========

The main function of this library is to enable complex search of an annotated corpus akin to search functionality made available via `RegexpParser` in Python's Natural Language Toolkit (NLTK). While regex-based, search syntax has been simplified, and modeled after the more intuitive syntax used in the online BYU suite of corpora.

Summary functions allow users to aggregate search results by text & token frequency, view search results in context (kwic), and create word embeddings/co-occurrence vectors for each search term. Functions allow users to specify how search results are aggregated. Search and aggregation functions can be easily applied to multiple (ie, any number of) search queries.

The package additionally automates the extraction of key phrases from a corpus of texts.

The collection of functions presented here is ideal for usage-based linguists and digital humanists interested in fine-grained search of moderately-sized corpora.

``` r
library(tidyverse)
library(cleanNLP)
library(corpuslingr) #devtools::install_github("jaytimm/corpuslingr")
library(quicknews)#devtools::install_github("jaytimm/quicknews")
```

Here, we walk through a simple workflow from corpus creation using `quicknews`, corpus annotation using the `cleanNLP` package, and annotated corpus search using `corpuslingr`.

Corpus preparation & annotation
-------------------------------

To demo the search functionality of `corpuslingr`, we first build a small corpus of current news articles using my `quicknews` package. We apply the `gnews_get_meta`/`gnews_scrape_web` functions across multiple Google News sections to build out the corpus some, and to add a genre-like dimension to the corpus.

``` r
topics <- c('nation','world', 'sports','science')

corpus <- lapply(topics, function (x) {
    quicknews::qnews_get_meta (language="en", country="us", type="topic", search=x)%>%
    quicknews::qnews_scrape_web (link_var='link')})%>%
  bind_rows() %>%
  mutate(doc_id = as.character(row_number())) #Add doc_id
```

### clr\_prep\_corpus

This function performs two tasks. It elminates unnecessary whitespace from the text column of a corpus dataframe object. Additionally, it attempts to trick annotators into treating hyphenated words as a single token. With the exception of Stanford's CoreNLP (via `cleanNLP`), annotators tend to treat hyphenated words as multiple word tokens. For linguists interested in word formation processes, eg, this is disappointing. There is likley a less hacky way to do this.

``` r
corpus <- clr_prep_corpus (corpus, hyphenate = TRUE)
```

### Annotate via cleanNLP and udpipe

For demo purposes, we use `udpipe` (via `cleanNLP`) to annotate the corpus dataframe object.

``` r
cleanNLP::cnlp_init_udpipe(model_name="english",feature_flag = FALSE, parser = "none") 
ann_corpus <- cleanNLP::cnlp_annotate(corpus$text, as_strings = TRUE, doc_ids = corpus$doc_id) 
```

### clr\_set\_corpus()

This function prepares the annotated corpus for complex, tuple-based search. Tuples are created, taking the form `<token~lemma~pos>`; tuple onsets/offsets are also set.

Annotation output is homogenized, including column names. Naming conventions established in the `spacyr` package are adopted here.

Lastly, the function splits the corpus into a list of dataframes by document. This is ultimately a search convenience.

``` r
lingr_corpus <- ann_corpus$token %>%
  clr_set_corpus(doc_var='id', 
                  token_var='word', 
                  lemma_var='lemma', 
                  tag_var='pos', 
                  pos_var='upos',
                  sentence_var='sid',
                  meta = corpus[,c('doc_id','source','search')])
```

### clr\_desc\_corpus()

A simple function for describing an annotated corpus, providing some basic aggregate statisitcs at the corpus, genre, and text levels.

``` r
summary <- corpuslingr::clr_desc_corpus(lingr_corpus,doc="doc_id", 
                        sent="sentence_id", tok="token",upos='pos', genre="search")
```

Corpus summary:

``` r
summary$corpus
##    n_docs textLength textType textSent
## 1:     64      47490     8330     2096
```

By genre:

``` r
summary$genre
##           search n_docs textLength textType textSent
## 1:  topic_nation     16      14423     3427      674
## 2:   topic_world     15       9369     2757      385
## 3:  topic_sports     17      13096     2968      653
## 4: topic_science     16      10602     2893      488
```

By text:

``` r
head(summary$text)
##    doc_id textLength textType textSent
## 1:      1        780      336       48
## 2:      2        622      247       31
## 3:      3        723      282       30
## 4:      4        579      274       28
## 5:      5        710      278       25
## 6:      6       1270      522       53
```

Search & aggregation functions
------------------------------

### Basic search syntax

The search syntax utilized here is modeled after the syntax implemented in the [BYU suite of corpora](https://corpus.byu.edu/). A full list of part-of-speech syntax can be viewed [here](https://github.com/jaytimm/corpuslingr/blob/master/data-raw/clr_ref_pos_syntax.csv).

``` r
library(knitr)
corpuslingr::clr_ref_search_egs %>% kable(escape=TRUE,caption = "Search syntax examples")
```

| type                                               | search\_syntax                                | example                                     |
|:---------------------------------------------------|:----------------------------------------------|:--------------------------------------------|
| Simple form search                                 | lime                                          | lime                                        |
| Simple lemma search                                | DRINK                                         | drinks, drank, drinking                     |
| Lemma with POS search                              | BARK~VERB                                     | barked, barking                             |
| Simple phrasal search                              | in the long run                               | in the long run                             |
| Phrasal search - POS/form                          | ADJ and ADJ                                   | happy and healthy, political and economical |
| Phrasal search inc noun phrase                     | VERB NPHR into VBG                            | trick someone into believing                |
| Phrasal search inc noun phrase                     | VERB PRP$ way PREP NPHR                       | make its way through the Senate             |
| Suffix search                                      | \*tion                                        | defenestration, nation, retaliation         |
| Infix search                                       | *break*                                       | breakable, heartbreaking                    |
| Optional search w/ parens and ?                    | MD (NEG)? HAVE been                           | should have been, might not have been       |
| Multiple term search w parens and |                | PRON (HOPE| WISH| DESIRE)                     | He hoped, they wish                         |
| Wildcard                                           | \*                                            | ANYTHING                                    |
| Indeterminate length search w brackets and min/max | NPHR BE \*{1,4} ADJ                           | He was very, very happy; I'm not sure       |
| Noun phrase search - POS w regex                   | (?:(?:DET )?(?:ADJ )\*)?(?:((NOUNX )+|PRON )) | Bill Clinton, he, the red kite              |
| Key phrase search - POS w regex                    | (ADJ )*(NOUNX )+((PREP )(ADJ )*(NOUNX )+)?    | flowers in bloom, very purple couch         |

### clr\_search\_gramx()

Search for all instantiaions of a particular lexical pattern/grammatical construction devoid of context. This function enables fairly quick search.

``` r
search1 <- "VERB (PRON)? PREP| RP"

lingr_corpus %>%
  corpuslingr::clr_search_gramx(search=search1)%>%
  slice(1:10)
## # A tibble: 10 x 4
##    doc_id token           tag    lemma       
##    <chr>  <chr>           <chr>  <chr>       
##  1 1      network as      VBP IN network as  
##  2 1      gathered in     VBD IN gather in   
##  3 1      boasted about   VBD IN boast about 
##  4 1      bragged about   VBD IN brag about  
##  5 1      sent by         VBN IN send by     
##  6 1      leaked to       VBD IN leake to    
##  7 1      said that       VBD IN say that    
##  8 1      explaining that VBG IN explain that
##  9 1      hit like        VBZ IN hit like    
## 10 1      spoke on        VBD IN speak on
```

### clr\_get\_freqs()

A simple function for calculating text and token frequencies of search term(s). The `agg_var` parameter allows the user to specify how frequency counts are aggregated.

Note that generic noun phrases can be include as a search term (regex below), and can be specified in the query using `NPHR`.

``` r
clr_ref_nounphrase
## [1] "(?:(?:DET )?(?:ADJ )*)?(?:((NOUNX )+|PRON ))"
```

``` r
search2 <- "*tial NOUNX"

lingr_corpus %>%
  corpuslingr::clr_search_gramx(search=search2)%>%
  corpuslingr::clr_get_freq(agg_var = 'token', toupper=TRUE)%>%
  head()
##                      token txtf docf
## 1:   PRESIDENTIAL ELECTION    2    2
## 2: CONFIDENTIAL STRATEGIES    1    1
## 3:    INITIAL NEGOTIATIONS    1    1
## 4:        INITIAL REACTION    1    1
## 5:          POTENTIAL LEAD    1    1
## 6:  PRESIDENTIAL CANDIDATE    1    1
```

### clr\_search\_context()

A function that returns search terms with user-specified left and right contexts (`LW` and `RW`). Output includes a list of two dataframes: a `BOW` (bag-of-words) dataframe object and a `KWIC` (keyword in context) dataframe object.

``` r
search3 <- 'NPHR (DO)? (NEG)? (THINK| BELIEVE )'

found_egs <- corpuslingr::clr_search_context(search=search3,corp=lingr_corpus,LW=5, RW = 5)
```

### clr\_context\_kwic()

Access `KWIC` object:

``` r
found_egs %>%
  corpuslingr::clr_context_kwic()%>% #Add genre.
  select(doc_id,kwic)%>%
  slice(1:15)%>%
  kable(escape=FALSE)
```

| doc\_id | kwic                                                                                          |
|:--------|:----------------------------------------------------------------------------------------------|
| 1       | the network , explaining that <mark> he believed </mark> Fox News had become a                |
| 1       | branches of government and said <mark> he believed </mark> Fox News was knowingly causing     |
| 1       | the fire , tweeting that <mark> she thought </mark> Smith 's comments were "                  |
| 13      | reading the main story " <mark> You do n't believe </mark> that surrogates from the Trump     |
| 13      | Sessions replied . " And <mark> I do n't believe </mark> it happened . " That                 |
| 15      | before fatally shooting Clark . <mark> The gun officers thought </mark> Clark had in his hand |
| 15      | Police Department said the man <mark> they believed </mark> was breaking windows was the      |
| 15      | produced by the Bee . <mark> She believes </mark> another suspect was smashing windows        |
| 15      | they are resisting or if <mark> police think </mark> a weapon is present ,                    |
| 18      | " certainly right . " <mark> I think </mark> the comparison with 1936 is                      |
| 19      | . " Contrary to what <mark> some people thought </mark> , Cassidy pointed out ,               |
| 2       | still opposed to it . <mark> I think </mark> President Trump was right when                   |
| 2       | still opposed to it . <mark> I think </mark> President Trump was right when                   |
| 27      | . Mr. Olmert contended that <mark> Mr. Barak believed </mark> Mr. Olmert would soon have      |
| 31      | 's top diplomat . " <mark> I think </mark> the comparison to 1936 is                          |

### clr\_context\_bow()

A function for accessing `BOW` object. The parameters `agg_var` and `content_only` can be used to ....

``` r
search3 <- "White House"

corpuslingr::clr_search_context(search=search3,corp=lingr_corpus,LW=10, RW = 10)%>%
  corpuslingr::clr_context_bow(content_only=TRUE,agg_var=c('searchLemma','lemma'))%>%
  head()
##    searchLemma    lemma cofreq
## 1: WHITE HOUSE   ARABIA      2
## 2: WHITE HOUSE      BIN      2
## 3: WHITE HOUSE    CROWN      2
## 4: WHITE HOUSE    MARCH      2
## 5: WHITE HOUSE MOHAMMED      2
## 6: WHITE HOUSE   PRINCE      2
```

### clr\_search\_keyphrases()

Function for extracting key phrases from each text comprising a corpus based on tf-idf weights. The methods and logic underlying this function are described in more detail [here](https://www.jtimm.net/blog/keyphrase-extraction-from-a-corpus-of-texts/).

The regex for key phrase search:

``` r
clr_ref_keyphrase
## [1] "(ADJ )*(NOUNX )+((PREP )(ADJ )*(NOUNX )+)?"
```

The user can specify the number of keyphrases to extract, how to aggregate key phrases, how to output key phrases, and whether or not to use jitter to break ties among top n key phrases.

``` r
lingr_corpus %>%
  corpuslingr::clr_search_keyphrases(n=5, key_var ='lemma', flatten=TRUE,jitter=TRUE)%>%
  head()%>%
  kable()
```

| doc\_id | keyphrases                                                              |
|:--------|:------------------------------------------------------------------------|
| 1       | network | Peters | note | CNN | matter                                  |
| 10      | suspect | pound of cocaine | airline worker | Border Protection | pound |
| 11      | teacher | percent | school | school shootings | percent of teacher      |
| 12      | Mr. Conditt | Austin | bomb | neighbor | sense                          |
| 13      | Mr. Sessions | Mr. Trump | Mr. Mueller | news report | Russians         |
| 14      | great-grandmother | senior staff editor | Times | readers | feather     |
