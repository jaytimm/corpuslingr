corpuslingr: some corpus linguistics in r
-----------------------------------------

A library of functions that streamlines two sets of common text-corpus tasks:

-   annotated corpus search of grammatical constructions and complex lexical patterns in context, and
-   detailed summary and aggregation of corpus search results.

### search

Grammatical constructions and complex lexical patterns are formalized here (in terms of an annotated corpus) as patterns comprised of:

-   different types of elements (eg, form, lemma, or part-of-speech),
-   contiguous and/or non-contiguous elements,
-   positionally fixed and/or free (ie, optional) elements, or
-   any combination thereof.

Under the hood, `corpuslingr` search is regex-based & (informally) tuple-based --- akin to the `RegexpParser` function in Python's Natural Language Toolkit (NLTK). Regex character matching is streamlined with a simple "corpus querying language" modeled after the more intuitive and transparent syntax used in the online BYU suite of English corpora. This allows for convenient specification of search patterns comprised of form, lemma, & pos, with all of the functionality of regex metacharacters and repetition quantifiers.

At present, part-of-speech search is based on **English-specific** part-of-speech tags. In theory, search functionality could be made more language-generic by utilizing universal part-of-speech tags when building tuples. However, language-specific search will utlimately be more powerful/insightful.

### summary

Summary functions allow users to:

-   aggregate search results by text & token frequency,
-   view search results in context (kwic),
-   create word embeddings/co-occurrence vectors for each search term, and
-   specify how search results are aggregated.

Importantly, both search and aggregation functions can be easily applied to multiple (ie, any number of) search queries.

### utility

While still in development, the package should be useful to linguists and digital humanists interested in having [BYU corpora](https://corpus.byu.edu/)-like search & summary functionality when working with (moderately-sized) personal corpora, as well as researchers interested in performing finer-grained, more qualitative analyses of language use and variation in context.

A simple shiny demo of search & summary functionaity is available [here](https://jasontimm.shinyapps.io/corpusQuery/)

------------------------------------------------------------------------

Here, we walk through a simple workflow from corpus creation using `quicknews`, corpus annotation using the `cleanNLP` package, and annotated corpus search & summary using `corpuslingr`.

``` r
library(tidyverse)
library(cleanNLP)
library(corpuslingr) #devtools::install_github("jaytimm/corpuslingr")
library(quicknews) #devtools::install_github("jaytimm/quicknews")
library(DT)
```

------------------------------------------------------------------------

Corpus preparation & annotation
-------------------------------

To demo the search functionality of `corpuslingr`, we first build a small corpus of current news articles using my `quicknews` package. We apply the `gnews_get_meta`/`gnews_scrape_web` functions across multiple Google News sections to build out the corpus some, and to add a genre-like dimension to the corpus.

``` r
topics <- c('nation','world', 'sports', 'science')

corpus <- lapply(topics, function (x) {
    quicknews::qnews_get_meta (language="en", country="us", type="topic", search=x)})%>%
  bind_rows() %>%
  quicknews::qnews_scrape_web ()
```

------------------------------------------------------------------------

### clr\_prep\_corpus

This function performs two tasks. It eliminates unnecessary whitespace from the text column of a corpus data frame object. Additionally, it attempts to trick annotators into treating hyphenated words as a single token. With the exception of Stanford's CoreNLP (via `cleanNLP`), annotators tend to treat hyphenated words as multiple word tokens. For linguists interested in word formation processes, eg, this is disappointing. There is likely a less hacky way to do this.

``` r
corpus <- clr_prep_corpus (corpus, hyphenate = TRUE)
```

------------------------------------------------------------------------

### Annotate via cleanNLP and udpipe

For demo purposes, we use `udpipe` (via `cleanNLP`) to annotate the corpus data frame object.

``` r
cleanNLP::cnlp_init_udpipe(model_name="english",feature_flag = FALSE, parser = "none") 
ann_corpus <- cleanNLP::cnlp_annotate(corpus$text, as_strings = TRUE, doc_ids = corpus$doc_id) 
```

------------------------------------------------------------------------

### clr\_set\_corpus()

This function prepares the annotated corpus for complex search (as defined above) by building `<token~lemma~pos>` tuples and setting tuple onsets/offsets. Additionally, column names are homogenized using the naming conventions established in the `spacyr` package. Lastly, the function splits the corpus into a list of data frames by document. This is ultimately a search convenience.

Including text metadata in the `meta` parameter enables access to text characteristics when aggregating search results.

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

Some example tuple-ized text:

``` r
paste(lingr_corpus$corpus[[1]]$tup[200:204], collapse= " ")
## [1] "<that~that~IN> <he~he~PRP> <'s~be~VBZ> <above~above~IN> <the~the~DT>"
```

------------------------------------------------------------------------

### clr\_desc\_corpus()

A simple function for describing an annotated corpus, providing some basic aggregate statistics at the corpus, genre, and text levels.

``` r
summary <- corpuslingr::clr_desc_corpus(lingr_corpus,doc="doc_id", 
                        sent="sentence_id", tok="token",upos='pos', genre="search")
```

-   **Corpus summary:**

``` r
summary$corpus
##    n_docs textLength textType textSent
## 1:     56      41282     7702     1849
```

-   **By genre:**

``` r
summary$genre
##           search n_docs textLength textType textSent
## 1:   topic_world     17      13666     3456      597
## 2:  topic_nation     10       5232     1639      241
## 3:  topic_sports     16      11891     3034      611
## 4: topic_science     13      10493     2840      530
```

-   **By text:**

``` r
head(summary$text)
##    doc_id textLength textType textSent
## 1:      1       1151      426       66
## 2:      2        232      116        9
## 3:      3        518      235       21
## 4:      4       1262      502       75
## 5:      5        577      294       22
## 6:      6        397      218       17
```

------------------------------------------------------------------------

Search & aggregation functions
------------------------------

### Basic search syntax

The search syntax utilized here is modeled after the syntax implemented in the [BYU suite of corpora](https://corpus.byu.edu/). A full list of part-of-speech syntax can be viewed [here](https://github.com/jaytimm/corpuslingr/blob/master/data-raw/clr_ref_pos_syntax.csv).

``` r
library(knitr)
corpuslingr::clr_ref_search_egs %>% kable(escape=FALSE, format = "html")
```

<table>
<thead>
<tr>
<th style="text-align:left;">
type
</th>
<th style="text-align:left;">
search\_syntax
</th>
<th style="text-align:left;">
example
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
Simple form search
</td>
<td style="text-align:left;">
lime
</td>
<td style="text-align:left;">
lime
</td>
</tr>
<tr>
<td style="text-align:left;">
Simple lemma search
</td>
<td style="text-align:left;">
DRINK
</td>
<td style="text-align:left;">
drinks, drank, drinking
</td>
</tr>
<tr>
<td style="text-align:left;">
Lemma with POS search
</td>
<td style="text-align:left;">
BARK~VERB
</td>
<td style="text-align:left;">
barked, barking
</td>
</tr>
<tr>
<td style="text-align:left;">
Simple phrasal search
</td>
<td style="text-align:left;">
in the long run
</td>
<td style="text-align:left;">
in the long run
</td>
</tr>
<tr>
<td style="text-align:left;">
Phrasal search - POS/form
</td>
<td style="text-align:left;">
ADJ and ADJ
</td>
<td style="text-align:left;">
happy and healthy, political and economical
</td>
</tr>
<tr>
<td style="text-align:left;">
Phrasal search inc noun phrase
</td>
<td style="text-align:left;">
VERB NPHR into VBG
</td>
<td style="text-align:left;">
trick someone into believing
</td>
</tr>
<tr>
<td style="text-align:left;">
Phrasal search inc noun phrase
</td>
<td style="text-align:left;">
VERB PRP$ way PREP NPHR
</td>
<td style="text-align:left;">
make its way through the Senate
</td>
</tr>
<tr>
<td style="text-align:left;">
Suffix search
</td>
<td style="text-align:left;">
\*tion
</td>
<td style="text-align:left;">
defenestration, nation, retaliation
</td>
</tr>
<tr>
<td style="text-align:left;">
Infix search
</td>
<td style="text-align:left;">
\*break\*
</td>
<td style="text-align:left;">
breakable, heartbreaking
</td>
</tr>
<tr>
<td style="text-align:left;">
Optional search w/ parens and ?
</td>
<td style="text-align:left;">
MD (NEG)? HAVE been
</td>
<td style="text-align:left;">
should have been, might not have been
</td>
</tr>
<tr>
<td style="text-align:left;">
Multiple term search w parens and |
</td>
<td style="text-align:left;">
PRON (HOPE| WISH| DESIRE)
</td>
<td style="text-align:left;">
He hoped, they wish
</td>
</tr>
<tr>
<td style="text-align:left;">
Multiple term search w parens and |
</td>
<td style="text-align:left;">
House (Republicans| Democrats)
</td>
<td style="text-align:left;">
House Republicans, House Democrats
</td>
</tr>
<tr>
<td style="text-align:left;">
Indeterminate wildcard search w brackets and min/max
</td>
<td style="text-align:left;">
NPHR BE \*{1,4} ADJ
</td>
<td style="text-align:left;">
He was very, very happy; I'm not sure
</td>
</tr>
<tr>
<td style="text-align:left;">
Multiple optional search
</td>
<td style="text-align:left;">
(President)? (Bill)? Clinton
</td>
<td style="text-align:left;">
Clinton, President Clinton, Bill Clinton
</td>
</tr>
</tbody>
</table>

------------------------------------------------------------------------

### clr\_search\_gramx()

Search for all instantiations of a particular lexical pattern/grammatical construction devoid of context. This function enables fairly quick search.

``` r
search1 <- "ADJ and (ADV)? ADJ"

lingr_corpus %>%
  corpuslingr::clr_search_gramx(search=search1)%>%
  select(doc_id, search, token, tag)%>% 
  slice(1:15)
## # A tibble: 15 x 4
##    doc_id search        token                      tag       
##    <chr>  <chr>         <chr>                      <chr>     
##  1 5      topic_nation  higher and higher          JJR CC JJR
##  2 15     topic_sports  humbling and emotional     JJ CC JJ  
##  3 17     topic_nation  geese and other            JJ CC JJ  
##  4 19     topic_sports  locked and loaded          JJ CC JJ  
##  5 21     topic_science unexpected and unwelcome   JJ CC JJ  
##  6 21     topic_science Cultural and political     JJ CC JJ  
##  7 27     topic_world   known-probiotic and immune JJ CC JJ  
##  8 27     topic_world   homey and smoky            JJ CC JJ  
##  9 28     topic_sports  physical and mental        JJ CC JJ  
## 10 30     topic_sports  academic and compliance    JJ CC JJ  
## 11 35     topic_science horizontal and vertical    JJ CC JJ  
## 12 40     topic_science irritable and impulsive    JJ CC JJ  
## 13 40     topic_science observable and repeatable  JJ CC JJ  
## 14 40     topic_science emotional and physical     JJ CC JJ  
## 15 50     topic_science clearer and clearer        JJR CC JJR
```

------------------------------------------------------------------------

### clr\_get\_freq()

A simple function for calculating text and token frequencies of search term(s). The `agg_var` parameter allows the user to specify how frequency counts are aggregated.

``` r
search2 <- "VERB into"

lingr_corpus %>%
  corpuslingr::clr_search_gramx(search=search2)%>%
  corpuslingr::clr_get_freq(agg_var = c('lemma'), toupper=TRUE)%>%
  head()
##          lemma txtf docf
## 1:     GO INTO    3    2
## 2:   COME INTO    2    2
## 3:  CRASH INTO    2    1
## 4:   TUNE INTO    2    1
## 5: ASCEND INTO    1    1
## 6:     BE INTO    1    1
```

Setting `include_meta = TRUE` facilitates aggregation by variable(s) included in metadata:

``` r
search3 <- "SHOT~NOUN| BALL~NOUN| PLAY~VERB"

lingr_corpus %>%
  corpuslingr::clr_search_gramx(search=search3)%>%
  corpuslingr::clr_get_freq(agg_var = c('search','token','tag'), toupper=TRUE)%>%
  slice(1:15)
## # A tibble: 13 x 5
##    search       token   tag    txtf  docf
##    <chr>        <chr>   <chr> <int> <int>
##  1 topic_sports BALL    NN        6     3
##  2 topic_sports PLAY    VB        6     6
##  3 topic_sports PLAYING VBG       4     3
##  4 topic_sports SHOT    NN        4     2
##  5 topic_sports PLAYED  VBN       2     2
##  6 topic_world  PLAY    VB        2     2
##  7 topic_world  PLAYED  VBD       2     1
##  8 topic_nation PLAY    VB        1     1
##  9 topic_nation PLAYING VBG       1     1
## 10 topic_sports BALLS   NNS       1     1
## 11 topic_sports PLAYED  VBD       1     1
## 12 topic_world  BALL    NN        1     1
## 13 topic_world  PLAYING VBG       1     1
```

------------------------------------------------------------------------

### clr\_search\_context()

A function that returns search terms with user-specified left and right contexts (`LW` and `RW`). Output includes a list of two data frames: a `BOW` (bag-of-words) data frame object and a `KWIC` (keyword in context) data frame object.

Note that generic noun phrases can be included as a search term (regex below), and can be specified in the query using `NPHR`.

``` r
clr_ref_nounphrase
## [1] "(?:(?:DET )?(?:ADJ )*)?(?:((NOUNX )+|PRON ))"
```

``` r
search4 <- 'NPHR BE (NEG)? VBN'

found_egs <- corpuslingr::clr_search_context(search=search4,corp=lingr_corpus,LW=15, RW = 15)
```

------------------------------------------------------------------------

### clr\_context\_kwic()

Access `KWIC` object:

``` r
found_egs %>%
  corpuslingr::clr_context_kwic(include=c('search', 'source'))%>% 
  DT::datatable(selection="none",class = 'cell-border stripe', rownames = FALSE,width="100%", escape=FALSE)
```

![](README-unnamed-chunk-18-1.png)

------------------------------------------------------------------------

### clr\_context\_bow()

A function for accessing/aggregating `BOW` object. The parameters `agg_var` and `content_only` can be used to specify how collocates are aggregated and whether only content words are included, respectively.

``` r
search5 <- "White House"

corpuslingr::clr_search_context(search=search5,corp=lingr_corpus, LW=20, RW=20)%>%
  corpuslingr::clr_context_bow(content_only = TRUE, agg_var = c('searchLemma', 'lemma'))%>%
  head()
##    searchLemma     lemma cofreq
## 1: WHITE HOUSE     TRUMP     14
## 2: WHITE HOUSE PRESIDENT      9
## 3: WHITE HOUSE     PRESS      7
## 4: WHITE HOUSE   SANDERS      6
## 5: WHITE HOUSE      FIRE      5
## 6: WHITE HOUSE  REPORTER      5
```

------------------------------------------------------------------------

### clr\_search\_keyphrases()

Function for extracting key phrases from each text comprising a corpus based on tf-idf weights. The methods and logic underlying this function are described in more detail [here](https://www.jtimm.net/blog/keyphrase-extraction-from-a-corpus-of-texts/).

The regex for key phrase search:

``` r
clr_ref_keyphrase
## [1] "(ADJ )*(NOUNX )+((PREP )(ADJ )*(NOUNX )+)?"
```

The user can specify the number of key phrases to extract, how to aggregate key phrases, how to output key phrases, and whether or not to use jitter to break ties among top n key phrases.

``` r
library(knitr)
lingr_corpus %>%
  corpuslingr::clr_search_keyphrases(n=5, 
                                     key_var ='lemma', 
                                     flatten=TRUE, 
                                     jitter=TRUE, 
                                     include = c('doc_id','search','source')) %>%
  slice(1:10) %>%
  kable(escape=FALSE, format = "html")
```

<table>
<thead>
<tr>
<th style="text-align:left;">
doc\_id
</th>
<th style="text-align:left;">
search
</th>
<th style="text-align:left;">
source
</th>
<th style="text-align:left;">
keyphrases
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
topic\_world
</td>
<td style="text-align:left;">
abcnews.go.com
</td>
<td style="text-align:left;">
Albright | Trump | Syria | strategy | woman
</td>
</tr>
<tr>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
topic\_nation
</td>
<td style="text-align:left;">
abcnews.go.com
</td>
<td style="text-align:left;">
body | Joseph Daniels | boy | TBI | parent
</td>
</tr>
<tr>
<td style="text-align:left;">
3
</td>
<td style="text-align:left;">
topic\_nation
</td>
<td style="text-align:left;">
abcnews.go.com
</td>
<td style="text-align:left;">
Chalarka | good Samaritan | man | police | incident
</td>
</tr>
<tr>
<td style="text-align:left;">
4
</td>
<td style="text-align:left;">
topic\_sports
</td>
<td style="text-align:left;">
bleacherreport.com
</td>
<td style="text-align:left;">
James | Zero Dark Thirty | season | game | Nance
</td>
</tr>
<tr>
<td style="text-align:left;">
5
</td>
<td style="text-align:left;">
topic\_nation
</td>
<td style="text-align:left;">
fortune.com
</td>
<td style="text-align:left;">
paper | child | woman | spousal wage gap | birth
</td>
</tr>
<tr>
<td style="text-align:left;">
6
</td>
<td style="text-align:left;">
topic\_world
</td>
<td style="text-align:left;">
fox4kc.com
</td>
<td style="text-align:left;">
Fedyaeva | RT | formalin | Thursday | Abdullov
</td>
</tr>
<tr>
<td style="text-align:left;">
7
</td>
<td style="text-align:left;">
topic\_nation
</td>
<td style="text-align:left;">
people.com
</td>
<td style="text-align:left;">
ABC | canola seed | overpass | driver | incident
</td>
</tr>
<tr>
<td style="text-align:left;">
8
</td>
<td style="text-align:left;">
topic\_world
</td>
<td style="text-align:left;">
bbc.com
</td>
<td style="text-align:left;">
Cambridge Analytica | Facebook | data | small number of people | app
</td>
</tr>
<tr>
<td style="text-align:left;">
9
</td>
<td style="text-align:left;">
topic\_sports
</td>
<td style="text-align:left;">
chicagotribune.com
</td>
<td style="text-align:left;">
Baez | seventh | Pirates | Cubs | Wrigley Field
</td>
</tr>
<tr>
<td style="text-align:left;">
10
</td>
<td style="text-align:left;">
topic\_sports
</td>
<td style="text-align:left;">
espn.com
</td>
<td style="text-align:left;">
Alabama | Trump | national title | Georgia | player
</td>
</tr>
</tbody>
</table>
