corpuslingr: some corpus linguistics in r
-----------------------------------------

A library of functions that streamlines two sets of tasks useful to the corpus linguist:

-   aanotated corpus search of grammatical constructions and complex lexical patterns in context, and
-   detailed summary and aggregation of corpus search results.

BYU corpora. as model.

**Grammatical constructions and complex lexical patterns** are formalized here (in terms of an annotated corpus) as patterns comprised of:

-   different types of elements (eg, form, lemma, or part-of-speech),
-   contiguous and/or non-contiguous elements,
-   positionally fixed and/or free (ie, optional) elements, or
-   any combination thereof.

Under the hood, search is regex/tuple-based, akin to the `RegexpParser` function in Python's Natural Language Toolkit (NLTK).

Regex syntax is simplified (or, more accurately, supplemented) with an in-house "corpus querying language" modeled after the more intuitive and transparent syntax used in the online BYU suite of corpora. This allows for convenient specification of search patterns comprised of form, lemma, & pos, with all of the functionality of regex metacharacters and repetition quantifiers.

**Summary functions** allow users to:

-   aggregate search results by text & token frequency,
-   view search results in context (kwic),
-   create word embeddings/co-occurrence vectors for each search term, and
-   specify how search results are aggregated.

Importantly, both search and aggregation functions can be easily applied to multiple (ie, any number of) search queries.

Functions included in the library dovetail nicely with existing R packages geared towards text/corpus analysis (eg, `quanteda`, `spacyr`, `udpipe`, `coreNLP`, `qdap`). These packages are beasts (!); `corpuslingr` simply fills a few gaps with the needs of the corpus linguist in mind, enabling finer-grained, more qualitative analysis of language use and variation in context.

While still in development (ie, feedback!), the package should be useful to linguists and digital humanists interested in having [BYU corpora](https://corpus.byu.edu/)-like search functionality when working with (moderately-sized) personal corpora.

------------------------------------------------------------------------

Here, we walk through a simple workflow from corpus creation using `quicknews`, corpus annotation using the `cleanNLP` package, and annotated corpus search using `corpuslingr`.

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
topics <- c('nation','world', 'sports')

corpus <- lapply(topics, function (x) {
    quicknews::qnews_get_meta (language="en", country="us", type="topic", search=x)%>%
    quicknews::qnews_scrape_web (link_var='link')})%>%
  bind_rows() %>%
  mutate(doc_id = as.character(row_number())) #Add doc_id
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

This function prepares the annotated corpus for complex, tuple-based search. Tuples are created, taking the form `<token~lemma~pos>`; tuple onsets/offsets are also set.

Annotation output is homogenized, including column names. Naming conventions established in the `spacyr` package are adopted here.

Lastly, the function splits the corpus into a list of data frames by document. This is ultimately a search convenience.

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
## 1:     49      36185     6555     1539
```

-   **By genre:**

``` r
summary$genre
##          search n_docs textLength textType textSent
## 1: topic_nation     17      12722     3206      500
## 2:  topic_world     16      11148     2929      495
## 3: topic_sports     16      12315     2545      589
```

-   **By text:**

``` r
head(summary$text)
##    doc_id textLength textType textSent
## 1:      1        919      388       36
## 2:      2        679      348       33
## 3:      3        443      222       18
## 4:      4        599      279       27
## 5:      5        264      159       15
## 6:      6        286      166       15
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
</tbody>
</table>

------------------------------------------------------------------------

### clr\_search\_gramx()

Search for all instantiations of a particular lexical pattern/grammatical construction devoid of context. This function enables fairly quick search.

``` r
search1 <- "VERB (PRON)? (PREP| RP)"

lingr_corpus %>%
  corpuslingr::clr_search_gramx(search=search1)%>%
  slice(1:10)
## # A tibble: 10 x 4
##    doc_id token         tag    lemma      
##    <chr>  <chr>         <chr>  <chr>      
##  1 1      living in     VBG IN living in  
##  2 1      co-owned by   VBN IN co-own by  
##  3 1      Interested in VBD IN interest in
##  4 1      stay up       VB IN  stay up    
##  5 1      's because    VBZ IN be because 
##  6 1      replaced in   VBN IN replace in 
##  7 1      played out    VBD RP play out   
##  8 1      lived in      VBD IN live in    
##  9 1      tied to       VBN IN tie to     
## 10 1      appeared on   VBD IN appear on
```

------------------------------------------------------------------------

### clr\_get\_freq()

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
##                     token txtf docf
## 1:   INTERSTITIAL GALLERY    4    1
## 2:      PRESIDENTIAL RACE    2    1
## 3:         ESSENTIAL ROLE    1    1
## 4:          INITIAL ROUND    1    1
## 5:          INITIAL STAGE    1    1
## 6: PRESIDENTIAL CANDIDATE    1    1
```

------------------------------------------------------------------------

### clr\_search\_context()

A function that returns search terms with user-specified left and right contexts (`LW` and `RW`). Output includes a list of two data frames: a `BOW` (bag-of-words) data frame object and a `KWIC` (keyword in context) data frame object.

``` r
search3 <- 'NPHR (DO)? (NEG)? (THINK| BELIEVE )'

found_egs <- corpuslingr::clr_search_context(search=search3,corp=lingr_corpus,LW=15, RW = 15)
```

------------------------------------------------------------------------

### clr\_context\_kwic()

Access `KWIC` object:

``` r
found_egs %>%
  corpuslingr::clr_context_kwic()%>% #Add genre.
  select(doc_id,kwic)%>%
  DT::datatable(selection="none",class = 'cell-border stripe', rownames = FALSE,width="100%", escape=FALSE)
## PhantomJS not found. You can install it with webshot::install_phantomjs(). If it is installed, please make sure the phantomjs executable can be found via the PATH variable.
```

<!--html_preserve-->

<script type="application/json" data-for="htmlwidget-9e36688dab3f0b7796a7">{"x":{"filter":"none","data":[["1","1","3","3","6","13","13","13","13","13","16","16","16","16","17","19","19","20","20","23","23","23","25","26","34","37","39","41","41","41","41","44","44","45","45","45","46"],["appeared on \" This Week \" echoed the view that Pruitt faces problems . \" <mark> I think <\/mark> he 's in real trouble , \" Alabama Sen. Doug Jones told Stephanopoulos . \"","'s in real trouble , \" Alabama Sen. Doug Jones told Stephanopoulos . \" And <mark> I think <\/mark> it seems that he may be on his way out . \" \" The perception","Castellanos has in the past been critical of Trump . Last year , he said <mark> he believes <\/mark> \" we 're closer to impeachment now than we think . \"","Last year , he said he believes \" we 're closer to impeachment now than <mark> we think <\/mark> . \"","that was advertised on social media when he disappeared . According to the Trentonian , <mark> investigators believe <\/mark> Thompson tortured Diazx xx Delgado in an attempt to extract more money from him .","important to follow the process , which is to do a proper vetting , and <mark> I do n't think <\/mark> there should be shortcuts in that . But I do believe that the President needs","vetting , and I do n't think there should be shortcuts in that . But <mark> I do believe <\/mark> that the President needs somebody that he has confidence in to get this job done","difficulty of the task at hand for an incoming VA secretary . Read More \" <mark> I believe <\/mark> in Dr. Jackson 's values , \" Shulkin said . \" I think that 's","More \" I believe in Dr. Jackson 's values , \" Shulkin said . \" <mark> I think <\/mark> that 's important . I know that he cares a lot about veterans , and","that 's important . I know that he cares a lot about veterans , and <mark> I believe <\/mark> that he will work well with the President . \" But this is a big","summoned the assistance of the state attorney general 's office to investigate it . \" <mark> I think <\/mark> that the mayor along with the police chief [ of Sacramento ] did something in","said they encountered Clark while responding to a complaint about vehicle break-ins . Officers said <mark> they thought <\/mark> Clark had a gun when they shot him in his grandmother 's back yard ,","the police sergeant , credited Sacramento officers for their calm in high-stress situations . \" <mark> I think <\/mark> our officers have faced some very hostile crowds , \" he said . \" We","job . \" Les Simmons , a pastor from the south Sacramento area , said <mark> he believes <\/mark> the police department thus far has done a better job of handling protests than the","window . DeKalb said the teenager , who was missing some front teeth and who <mark> he thought <\/mark> was only 7 years old , was \" rattled to the bone . \" Maureen","celebrate the holiday referred to as \" Resurrection Sunday \" by Christians , marking what <mark> they believe <\/mark> occurred three days after Jesus was crucified on the cross . \" The important feast","of New Life Covenant Church gathered for four services to mark the occasion . \" <mark> We believe <\/mark> that he came to earth , died for our sins , \" said Pastor John","told reporters last month , according to CNN . \" It sounds to me like <mark> they believe <\/mark> it was Russia and I would certainly take that finding as fact . \" Trump","Putin about Russia 's interference in the 2016 US election . Trump said last year <mark> he believed <\/mark> Putin when he told him Russia did not interfere in the election , in contradiction","Bus catches fire in Jerusalem Washington ( CNN ) Senator Bernie Sanders said <mark> he does n't believe <\/mark> the official response from Israeli authorities , who say that deadly clashes in Gaza this","tens and tens of thousands of people who are engaged in a nonviolent protest . <mark> I believe <\/mark> now 15 or 20 people , Palestinians , have been killed and many , many","Palestinians , have been killed and many , many others have been wounded . So <mark> I think <\/mark> it 's a difficult situation , but my assessment is that Israel overreacted on that","the early findings of the inquiry . This theory suggests that an assassin , who <mark> Britain believes <\/mark> was working on behalf of the Russian government , walked up to the door of","Israeli military \" did what had to be done . \" He added , \" <mark> I think <\/mark> that all of our troops deserve a medal . \" President Recep Tayyip Erdogan of","2018 ? WE CURSE YOU , MERCILESS MMA GODS . THIS IS THE LAST TIME <mark> WE BELIEVE <\/mark> YOU AND YOUR EMPTY PROMISES . Bargaining OK , sorry we got a little carried","'ve been striving toward that . A national championship is the ultimate goal , when <mark> you think <\/mark> about it . We have guys that have been able to win conference championships before","had other offers , including the potential to compete for a starting job , but <mark> he thought <\/mark> the opportunity to play for the Giants -- and behind Manning -- would be a","Nets CAPTION Spoelstra explains last minute loss to Nets Spoelstra explains last minute loss to <mark> Nets CAPTION Dragic thinks <\/mark> the Heat will be ok after loss Dragic thinks the Heat will be ok after","explains last minute loss to Nets CAPTION Dragic thinks the Heat will be ok after <mark> loss Dragic thinks <\/mark> the Heat will be ok after loss CAPTION Banged up Wade thought he was fouled","ok after loss Dragic thinks the Heat will be ok after loss CAPTION Banged up <mark> Wade thought <\/mark> he was fouled on final play Banged up Wade thought he was fouled on final","after loss CAPTION Banged up Wade thought he was fouled on final play Banged up <mark> Wade thought <\/mark> he was fouled on final play CAPTION Erik Spoelstra on the meaning of clinching a","said . \" We do n't have to be the most talented team , but <mark> I think <\/mark> we 're together . \" Loyola ( 32 - 6 ) set a program record","the game because we know what they 're going to throw at us . And <mark> I think <\/mark> the way that he 's done that has really propelled us and helped us in","really young team , \" White Sox catcher Welington Castillo said . \" Aggressive and <mark> I think <\/mark> , it says a lot . We just go out and compete and have fun","postseason after reaching the American League Championship Series in the two previous seasons . \" <mark> I think <\/mark> it 's big , \" Blue Jays manager John Gibbons said . \" We won","not particularly want a day off . \" Any sports team , especially baseball , <mark> I think <\/mark> you just want to play , \" White Sox manager Rick Renteria said . \"","the adjustments he 's made at the plate when he 's swinging the bat . <mark> I think <\/mark> that 's going to be one of his strengths moving on . \" The Angels"]],"container":"<table class=\"cell-border stripe\">\n  <thead>\n    <tr>\n      <th>doc_id<\/th>\n      <th>kwic<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"order":[],"autoWidth":false,"orderClasses":false}},"evals":[],"jsHooks":[]}</script>
<!--/html_preserve-->

------------------------------------------------------------------------

### clr\_context\_bow()

A function for accessing `BOW` object. The parameters `agg_var` and `content_only` can be used to specify how collocates are aggregated and whether only content words are included, respectively.

``` r
search3 <- "White House"

corpuslingr::clr_search_context(search=search3,corp=lingr_corpus,LW=10, RW = 10)%>%
  corpuslingr::clr_context_bow(content_only=TRUE,agg_var=c('searchLemma','lemma','pos'))%>%
  head()
##    searchLemma       lemma   pos cofreq
## 1: WHITE HOUSE        YEAR  NOUN      5
## 2: WHITE HOUSE         EGG  NOUN      4
## 3: WHITE HOUSE       HOUSE PROPN      4
## 4: WHITE HOUSE       SOUTH PROPN      4
## 5: WHITE HOUSE       WHITE PROPN      4
## 6: WHITE HOUSE ASSOCIATION PROPN      3
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
Pruitt | condo | gift | lease | Christie
</td>
</tr>
<tr>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
pair | Trump Jr. | Vanessa | Marx x xa | kid
</td>
</tr>
<tr>
<td style="text-align:left;">
3
</td>
<td style="text-align:left;">
Trump | good legal help | Mueller | campaign | storm
</td>
</tr>
<tr>
<td style="text-align:left;">
4
</td>
<td style="text-align:left;">
Esty | Baker | office | Connecticut Post | Congresswoman Esty
</td>
</tr>
<tr>
<td style="text-align:left;">
5
</td>
<td style="text-align:left;">
Holland | Lillian Barnes | newspaper | couple | month
</td>
</tr>
<tr>
<td style="text-align:left;">
6
</td>
<td style="text-align:left;">
Diazx xx Delgado | Thompson | kidnapping | Trentonian | connection
</td>
</tr>
</tbody>
</table>
