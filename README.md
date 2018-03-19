``` r
library(tidyverse)
library(cleanNLP)
library(corpuslingr) #devtools::install_github("jaytimm/corpuslingr")
library(quicknews)#devtools::install_github("jaytimm/quicknews")
```

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

This function prepares the annotated corpus for complex, tuple-based search. Tuples are created, taking the form `<token~lemma~pos>`; tuple onsets/offsets are also set. Annotation output is homogenized, including column names, making text processing easier 'downstream.' Naming conventions established in the `spacyr` package are adopted here.

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
summary <- corpuslingr::clr_desc_corpus(lingr_corpus,doc="doc_id", sent="sentence_id", tok="token",upos='pos', genre="search")
```

Corpus summary:

``` r
summary$corpus
##    n_docs textLength textType textSent
## 1:     64      61804     9684     2837
```

By genre:

``` r
summary$genre
##           search n_docs textLength textType textSent
## 1:  topic_nation     17      13158     3246      630
## 2:   topic_world     16      15563     3952      663
## 3:  topic_sports     19      23854     4271     1162
## 4: topic_science     12       9229     2438      449
```

By text:

``` r
head(summary$text)
##    doc_id textLength textType textSent
## 1:      1        182      121        8
## 2:      2        613      290       25
## 3:      3        173      109        7
## 4:      4       1170      543       46
## 5:      5        715      329       32
## 6:      6        219      139        7
```

Search & aggregation functions
------------------------------

### Basic search syntax

The search syntax utilized here is modeled after the syntax implemented in the BYU suite of corpora. A full list of part-of-speech syntax can be viewed [here](https://github.com/jaytimm/corpuslingr/blob/master/data-raw/clr_ref_pos_syntax.csv).

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
search1 <- "VERB (*)? up"

lingr_corpus %>%
  corpuslingr::clr_search_gramx(search=search1)%>%
  head ()
##    doc_id         token        tag        lemma
## 1:      2  is forced up VBZ VBN RP  be force up
## 2:      7       Sign up      VB RP      sign up
## 3:      9  need help up  VBP VB RP need help up
## 4:      9     jumped up     VBN RP      jump up
## 5:     13     picked up     VBD RP      pick up
## 6:     14 looking it up VBG PRP RP   look it up
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
##                    token txtf docf
## 1: PRESIDENTIAL ELECTION    3    2
## 2:     PRESIDENTIAL SEAT    2    1
## 3:     PRESIDENTIAL TERM    2    2
## 4:       INITIAL MELTING    1    1
## 5:        INITIAL PUBLIC    1    1
## 6:      POTENTIAL BUYERS    1    1
```

### clr\_search\_context()

A function that returns search terms with user-specified left and right contexts (`LW` and `RW`). Output includes a list of two dataframes: a `BOW` (bag-of-words) dataframe object and a `KWIC` (keyword in context) dataframe object.

``` r
search3 <- 'NPHR (do)? (NEG)? (THINK| BELIEVE )'

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
| 13      | Mr. Trump wrote . " <mark> I do n't believe </mark> he made memos except to                   |
| 13      | lied as well . So <mark> I do n't think </mark> this is the end of                            |
| 15      | secret , family members and <mark> authorities believe </mark> . The girl had exchanged       |
| 15      | " They were yelling about <mark> they think </mark> that Amy and Kevin are                    |
| 15      | But during that time , <mark> investigators believe </mark> , Amy and Esterly were            |
| 15      | Yu told CNN . " <mark> I think </mark> it was both of their                                   |
| 22      | Malpass said . " So <mark> I think </mark> we have a context where                            |
| 25      | people ? " Leo said <mark> he thought </mark> he 'd clarified the issue                       |
| 25      | an anecdote ) : " <mark> You do n't believe </mark> you made a show of                        |
| 27      | called Trump a moron , <mark> I think </mark> that was from the heart                         |
| 32      | touring polling places . " <mark> I think </mark> there 's a lot more                         |
| 37      | it can have , because <mark> I think </mark> it 's what this university                       |
| 38      | that , as well . <mark> I think </mark> most of all it feels                                  |
| 38      | there . " Harvick made <mark> the mistake thinking </mark> about potential points for winning |
| 38      | " Larson said . " <mark> I thought </mark> he would be mad at                                 |

### clr\_context\_bow()

`agg_var` and `content_only` Access `BOW` object:

``` r
search3 <- "White House"

corpuslingr::clr_search_context(search=search3,corp=lingr_corpus,LW=10, RW = 10)%>%
  corpuslingr::clr_context_bow(content_only=TRUE,agg_var=c('searchLemma','lemma'))%>%
  head()
##    searchLemma  lemma cofreq
## 1: WHITE HOUSE    SAY     10
## 2: WHITE HOUSE  TRUMP      5
## 3: WHITE HOUSE OPIOID      4
## 4: WHITE HOUSE BANNON      3
## 5: WHITE HOUSE    MR.      3
## 6: WHITE HOUSE REDUCE      3
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

| doc\_id | keyphrases                                                                  |
|:--------|:----------------------------------------------------------------------------|
| 1       | boy | office | Colorado Springs | El Paso County | undisclosed location     |
| 10      | attack | Phelan | Thomas Phelan | heroism | World Trade Center on September |
| 11      | Cambridge Analytica | Facebook | Mr. Wylie | company | data                 |
| 12      | Mr. Cruz | deputy Peterson | sheriff | deputy | Sept.                       |
| 13      | Mr. Mueller | Mr. Trump | Mr. McCabe | Comey | director                     |
| 14      | White | video | Rothschilds | D-Ward | resilient city                       |
