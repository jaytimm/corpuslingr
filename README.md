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
## 1:     67      50694     8550     2249
```

By genre:

``` r
summary$genre
##           search n_docs textLength textType textSent
## 1:  topic_nation     15      10750     2658      483
## 2:   topic_world     17      10452     2892      459
## 3:  topic_sports     19      18596     3806      914
## 4: topic_science     16      10896     2926      520
```

By text:

``` r
head(summary$text)
##    doc_id textLength textType textSent
## 1:      1        780      336       48
## 2:      2        462      228       22
## 3:      3       1567      566       63
## 4:      4        579      274       28
## 5:      5       1270      522       53
## 6:      6        567      291       23
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
##                    token txtf docf
## 1:          MARTIAL ARTS    3    1
## 2: PRESIDENTIAL ELECTION    3    3
## 3:        CELESTIAL BODY    2    1
## 4:          INITIAL PLAN    2    1
## 5:    ESSENTIAL SUPPLIES    1    1
## 6:      INITIAL RESPONSE    1    1
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
  kable(escape=FALSE, format = "markdown")
```

<table style="width:100%;">
<colgroup>
<col width="7%" />
<col width="92%" />
</colgroup>
<thead>
<tr class="header">
<th align="left">doc_id</th>
<th align="left">kwic</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left">1</td>
<td align="left">the network , explaining that <mark> he believed </mark> Fox News had become a</td>
</tr>
<tr class="even">
<td align="left">1</td>
<td align="left">branches of government and said <mark> he believed </mark> Fox News was knowingly causing</td>
</tr>
<tr class="odd">
<td align="left">1</td>
<td align="left">the fire , tweeting that <mark> she thought </mark> Smith 's comments were &quot;</td>
</tr>
<tr class="even">
<td align="left">10</td>
<td align="left">&quot; It 's remarkable . <mark> I do n't think </mark> it 's ever occurred in</td>
</tr>
<tr class="odd">
<td align="left">12</td>
<td align="left">reading the main story &quot; <mark> You do n't believe </mark> that surrogates from the Trump</td>
</tr>
<tr class="even">
<td align="left">12</td>
<td align="left">Sessions replied . &quot; And <mark> I do n't believe </mark> it happened . &quot; That</td>
</tr>
<tr class="odd">
<td align="left">13</td>
<td align="left">We have argued , and <mark> I think </mark> successfully , that the European</td>
</tr>
<tr class="even">
<td align="left">13</td>
<td align="left">We have argued , and <mark> I think </mark> successfully , that the European</td>
</tr>
<tr class="odd">
<td align="left">15</td>
<td align="left">before fatally shooting Clark . <mark> The gun officers thought </mark> Clark had in his hand</td>
</tr>
<tr class="even">
<td align="left">15</td>
<td align="left">Police Department said the man <mark> they believed </mark> was breaking windows was the</td>
</tr>
<tr class="odd">
<td align="left">15</td>
<td align="left">produced by the Bee . <mark> She believes </mark> another suspect was smashing windows</td>
</tr>
<tr class="even">
<td align="left">15</td>
<td align="left">they are resisting or if <mark> police think </mark> a weapon is present ,</td>
</tr>
<tr class="odd">
<td align="left">16</td>
<td align="left">the venues , yes , <mark> I think </mark> the comparison with 1936 is</td>
</tr>
<tr class="even">
<td align="left">16</td>
<td align="left">is certainly right . &quot; <mark> I think </mark> it is an emetic prospect</td>
</tr>
<tr class="odd">
<td align="left">16</td>
<td align="left">beyond common sense . And <mark> we do not think </mark> British war veterans - including</td>
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
##    searchLemma          lemma cofreq
## 1: WHITE HOUSE     ALLEGATION      2
## 2: WHITE HOUSE          TRUMP      2
## 3: WHITE HOUSE           WEEK      2
## 4: WHITE HOUSE         ACCORD      1
## 5: WHITE HOUSE ADMINISTRATION      1
## 6: WHITE HOUSE         AFFAIR      1
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
network | Peters | note | comment | CNN
</td>
</tr>
<tr>
<td style="text-align:left;">
10
</td>
<td style="text-align:left;">
Daniels | Avenatti | Cohen | last week | CNN
</td>
</tr>
<tr>
<td style="text-align:left;">
11
</td>
<td style="text-align:left;">
suspect | Border Protection | pound of cocaine | airline worker | pound
</td>
</tr>
<tr>
<td style="text-align:left;">
12
</td>
<td style="text-align:left;">
Mr. Sessions | Mr. Trump | Mr. Mueller | Mr. McCabe | Russians
</td>
</tr>
<tr>
<td style="text-align:left;">
13
</td>
<td style="text-align:left;">
European Union | United States | tariff | steel | aluminum
</td>
</tr>
<tr>
<td style="text-align:left;">
14
</td>
<td style="text-align:left;">
Mr. Paddock | Mandalay Bay | clip | video | frame
</td>
</tr>
</tbody>
</table>
