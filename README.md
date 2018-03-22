corpuslingr
===========

The main function of this library is to enable complex search of an annotated corpus akin to search functionality made available via `RegexpParser` in Python's Natural Language Toolkit (NLTK). While regex-based, search syntax has been simplified, and modeled after the more intuitive syntax used in the online BYU suite of corpora.

Summary functions allow users to aggregate search results by text & token frequency, view search results in context (kwic), and create word embeddings/co-occurrence vectors for each search term. Functions also allow users to specify how search results are aggregated. Importantly, search and aggregation functions can be easily applied to multiple (ie, any number of) search queries.

The collection of functions presented here is ideal for usage-based linguists and digital humanists interested in fine-grained search of moderately-sized corpora.

``` r
library(tidyverse)
library(cleanNLP)
library(corpuslingr) #devtools::install_github("jaytimm/corpuslingr")
library(quicknews) #devtools::install_github("jaytimm/quicknews")
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
## 1:     69      53095     8813     2273
```

By genre:

``` r
summary$genre
##           search n_docs textLength textType textSent
## 1:  topic_nation     17      15024     3578      631
## 2:   topic_world     18      12982     3392      539
## 3:  topic_sports     18      14870     3235      732
## 4: topic_science     16      10219     2751      487
```

By text:

``` r
head(summary$text)
##    doc_id textLength textType textSent
## 1:      1       1186      554       41
## 2:      2        723      282       30
## 3:      3        579      274       28
## 4:      4       1270      522       53
## 5:      5        358      183       19
## 6:      6        938      415       46
```

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
*break*
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
Wildcard
</td>
<td style="text-align:left;">
-   </td>
    <td style="text-align:left;">
    ANYTHING
    </td>
    </tr>
    <tr>
    <td style="text-align:left;">
    Indeterminate length search w brackets and min/max
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
    Noun phrase search - POS w regex
    </td>
    <td style="text-align:left;">
    (?:(?:DET )?(?:ADJ )\*)?(?:((NOUNX )+|PRON ))
    </td>
    <td style="text-align:left;">
    Bill Clinton, he, the red kite
    </td>
    </tr>
    <tr>
    <td style="text-align:left;">
    Key phrase search - POS w regex
    </td>
    <td style="text-align:left;">
    (ADJ )*(NOUNX )+((PREP )(ADJ )*(NOUNX )+)?
    </td>
    <td style="text-align:left;">
    flowers in bloom, very purple couch
    </td>
    </tr>
    </tbody>
    </table>

### clr\_search\_gramx()

Search for all instantiaions of a particular lexical pattern/grammatical construction devoid of context. This function enables fairly quick search.

``` r
search1 <- "VERB (PRON)? PREP| RP"

lingr_corpus %>%
  corpuslingr::clr_search_gramx(search=search1)%>%
  slice(1:10)
## # A tibble: 10 x 4
##    doc_id token              tag    lemma            
##    <chr>  <chr>              <chr>  <chr>            
##  1 1      vote on            VB IN  vote on          
##  2 1      vote on            VB IN  vote on          
##  3 1      evening after      VBG IN evening after    
##  4 1      debated throughout VBD IN debate throughout
##  5 1      look like          VB IN  look like        
##  6 1      lamenting that     VBG IN lament that      
##  7 1      's in              VBZ IN be in            
##  8 1      speculated that    VBD IN speculate that   
##  9 1      vote on            VB IN  vote on          
## 10 1      visit by           VB IN  visit by
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
## 1:   PRESIDENTIAL ELECTION    5    5
## 2:          CELESTIAL BODY    2    1
## 3:    POTENTIAL EXEMPTIONS    2    2
## 4: PRESIDENTIAL MEMORANDUM    2    2
## 5: CONFIDENTIAL STRATEGIES    1    1
## 6:    INITIAL NEGOTIATIONS    1    1
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
  kable(escape=FALSE, format = "html")
```

<table>
<thead>
<tr>
<th style="text-align:left;">
doc\_id
</th>
<th style="text-align:left;">
kwic
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
11
</td>
<td style="text-align:left;">
a campaign surrogate . " <mark> You do n't believe </mark> that surrogates from the Trump
</td>
</tr>
<tr>
<td style="text-align:left;">
11
</td>
<td style="text-align:left;">
Sessions replied . " And <mark> I do n't believe </mark> it happened . " That
</td>
</tr>
<tr>
<td style="text-align:left;">
13
</td>
<td style="text-align:left;">
gun . Eighty-four percent of <mark> Republicans believe </mark> people on the  "
</td>
</tr>
<tr>
<td style="text-align:left;">
16
</td>
<td style="text-align:left;">
before fatally shooting Clark . <mark> The gun officers thought </mark> Clark had in his hand
</td>
</tr>
<tr>
<td style="text-align:left;">
16
</td>
<td style="text-align:left;">
Police Department said the man <mark> they believed </mark> was breaking windows was the
</td>
</tr>
<tr>
<td style="text-align:left;">
16
</td>
<td style="text-align:left;">
produced by the Bee . <mark> She believes </mark> another suspect was smashing windows
</td>
</tr>
<tr>
<td style="text-align:left;">
16
</td>
<td style="text-align:left;">
they are resisting or if <mark> police think </mark> a weapon is present ,
</td>
</tr>
<tr>
<td style="text-align:left;">
19
</td>
<td style="text-align:left;">
" certainly right . " <mark> I think </mark> the comparison with 1936 is
</td>
</tr>
<tr>
<td style="text-align:left;">
22
</td>
<td style="text-align:left;">
approach is closer to how <mark> Trump thought </mark> the job would be than
</td>
</tr>
<tr>
<td style="text-align:left;">
22
</td>
<td style="text-align:left;">
we might stipulate , because <mark> he thinks </mark> it will yield the best
</td>
</tr>
<tr>
<td style="text-align:left;">
22
</td>
<td style="text-align:left;">
I know , some of <mark> you believe </mark> it 's because Putin is
</td>
</tr>
<tr>
<td style="text-align:left;">
22
</td>
<td style="text-align:left;">
made a nefarious deal . <mark> I do n't think </mark> Trump 's motives matter here
</td>
</tr>
<tr>
<td style="text-align:left;">
23
</td>
<td style="text-align:left;">
I have not participated , <mark> I think </mark> it 's in the country
</td>
</tr>
<tr>
<td style="text-align:left;">
26
</td>
<td style="text-align:left;">
. Mr. Olmert contended that <mark> Mr. Barak believed </mark> Mr. Olmert would soon have
</td>
</tr>
<tr>
<td style="text-align:left;">
3
</td>
<td style="text-align:left;">
Orange County Register . " <mark> I think </mark> they were spot-on , that
</td>
</tr>
</tbody>
</table>
### clr\_context\_bow()

A function for accessing `BOW` object. The parameters `agg_var` and `content_only` can be used to ....

``` r
search3 <- "White House"

corpuslingr::clr_search_context(search=search3,corp=lingr_corpus,LW=10, RW = 10)%>%
  corpuslingr::clr_context_bow(content_only=TRUE,agg_var=c('searchLemma','lemma'))%>%
  head()
##    searchLemma      lemma cofreq
## 1: WHITE HOUSE        SAY      8
## 2: WHITE HOUSE   OFFICIAL      4
## 3: WHITE HOUSE      MARCH      3
## 4: WHITE HOUSE      TRUMP      3
## 5: WHITE HOUSE        AIM      2
## 6: WHITE HOUSE ALLEGATION      2
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
  kable(escape=FALSE, format = "html")
```

<table>
<thead>
<tr>
<th style="text-align:left;">
doc\_id
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
omnibus | bill | Democrats | Trump | lawmaker
</td>
</tr>
<tr>
<td style="text-align:left;">
10
</td>
<td style="text-align:left;">
teacher | percent | school | school shootings | public school
</td>
</tr>
<tr>
<td style="text-align:left;">
11
</td>
<td style="text-align:left;">
Mr. Sessions | Mr. McCabe | investigation | Mr. Trump | Mr. Mueller
</td>
</tr>
<tr>
<td style="text-align:left;">
12
</td>
<td style="text-align:left;">
Mr. Paddock | Mandalay Bay | clip | video | complete picture to date
</td>
</tr>
<tr>
<td style="text-align:left;">
13
</td>
<td style="text-align:left;">
url | id | text | mobile\_url | gun
</td>
</tr>
<tr>
<td style="text-align:left;">
14
</td>
<td style="text-align:left;">
China | European Union | tariff | global trade war | Lighthizer
</td>
</tr>
</tbody>
</table>
