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

Including text metadata in the `meta` parameter enables access to (and aggregation by) text characteristics included in metadata in the process of corpus search.

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
## [1] "<against~against~IN> <him~he~PRP> <in~in~IN> <the~the~DT> <deaths~death~NNS>"
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
## 1:     64      44982     7920     2048
```

-   **By genre:**

``` r
summary$genre
##           search n_docs textLength textType textSent
## 1:  topic_nation     20      12060     3034      610
## 2:  topic_sports     15       9319     2264      483
## 3:   topic_world     16      14535     3558      658
## 4: topic_science     13       9068     2491      385
```

-   **By text:**

``` r
head(summary$text)
##    doc_id textLength textType textSent
## 1:      1        712      311       38
## 2:      2        190      131       10
## 3:      3       1198      457       56
## 4:      4        150       98        8
## 5:      5        370      191       22
## 6:      6        686      333       33
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

Search for all instantiations of a particular lexical pattern/grammatical construction devoid of context. This function enables fairly quick search. By setting `include_meta = TRUE`, search results can be viewed with text metadata.

``` r
search1 <- "ADJ and (ADV)? ADJ"

lingr_corpus %>%
  corpuslingr::clr_search_gramx(search=search1, include_meta=TRUE)%>%
  select(doc_id, source, token, tag)%>% 
  slice(1:15)
## # A tibble: 15 x 4
##    doc_id source                        token                   tag       
##    <chr>  <chr>                         <chr>                   <chr>     
##  1 3      en.brinkwire.com              German and French       JJ CC JJ  
##  2 3      en.brinkwire.com              military and civilian   JJ CC JJ  
##  3 5      fox6now.com                   used and uncapped       JJ CC JJ  
##  4 7      mmajunkie.com                 willing and able        JJ CC JJ  
##  5 9      profootballtalk.nbcsports.com second and final        JJ CC JJ  
##  6 9      profootballtalk.nbcsports.com more and more clear     JJR CC RB~
##  7 10     arabnews.com                  cognitive and emotional JJ CC JJ  
##  8 11     cantonrep.com                 digital and print       JJ CC JJ  
##  9 13     espn.com                      official and unofficial JJ CC JJ  
## 10 15     foxnews.com                   daily and multiple      JJ CC JJ  
## 11 19     latimes.com                   secure and less vulner~ JJ CC RBR~
## 12 19     latimes.com                   secure and cheap        JJ CC JJ  
## 13 19     latimes.com                   difficult and time-con~ JJ CC JJ  
## 14 25     timesfreepress.com            armed and dangerous     JJ CC JJ  
## 15 27     businessmirror.com.ph         productive and less pr~ JJ CC RBR~
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
##           lemma txtf docf
## 1:      GO INTO    4    3
## 2:   CRASH INTO    3    1
## 3:    COME INTO    2    2
## 4:     GET INTO    2    2
## 5: RELEASE INTO    2    1
## 6:  SPLASH INTO    2    1
```

Setting `include_meta = TRUE` facilitates aggregation by variable(s) included in metadata:

``` r
search3 <- "SHOT~NOUN| BALL~NOUN| PLAY~VERB"

lingr_corpus %>%
  corpuslingr::clr_search_gramx(search=search3, include_meta=TRUE)%>%
  corpuslingr::clr_get_freq(agg_var = c('search','token','tag'), toupper=TRUE)%>%
  slice(1:15)
## # A tibble: 15 x 5
##    search        token   tag    txtf  docf
##    <chr>         <chr>   <chr> <int> <int>
##  1 topic_sports  PLAY    VB       10     5
##  2 topic_sports  BALL    NN        6     3
##  3 topic_sports  SHOT    NN        6     2
##  4 topic_sports  PLAYING VBG       5     4
##  5 topic_sports  SHOTS   NNS       5     1
##  6 topic_nation  SHOT    NN        4     1
##  7 topic_nation  PLAYING VBG       2     1
##  8 topic_nation  SHOTS   NNS       2     1
##  9 topic_sports  PLAY    VBP       2     1
## 10 topic_sports  PLAYED  VBN       2     2
## 11 topic_sports  PLAYS   VBZ       2     2
## 12 topic_nation  PLAY    VB        1     1
## 13 topic_nation  PLAYS   VBZ       1     1
## 14 topic_science BALL    NN        1     1
## 15 topic_sports  PLAYED  VBD       1     1
```

------------------------------------------------------------------------

### clr\_search\_context()

A function that returns search terms with user-specified left and right contexts (`LW` and `RW`). Output includes a list of two data frames: a `BOW` (bag-of-words) data frame object and a `KWIC` (keyword in context) data frame object.

Note that generic noun phrases can be include as a search term (regex below), and can be specified in the query using `NPHR`.

``` r
clr_ref_nounphrase
## [1] "(?:(?:DET )?(?:ADJ )*)?(?:((NOUNX )+|PRON ))"
```

``` r
search4 <- 'NPHR BE (NEG)? VBN'

found_egs <- corpuslingr::clr_search_context(search=search4,corp=lingr_corpus,LW=15, RW = 15, include_meta = TRUE)
```

------------------------------------------------------------------------

### clr\_context\_kwic()

Access `KWIC` object:

``` r
found_egs %>%
  corpuslingr::clr_context_kwic(include=c('search', 'source'))%>% #Add genre.
  DT::datatable(selection="none",class = 'cell-border stripe', rownames = FALSE,width="100%", escape=FALSE)
## PhantomJS not found. You can install it with webshot::install_phantomjs(). If it is installed, please make sure the phantomjs executable can be found via the PATH variable.
```

<!--html_preserve-->

<script type="application/json" data-for="htmlwidget-c7004c3dd7d2b13cb827">{"x":{"filter":"none","data":[["topic_nation","topic_nation","topic_nation","topic_sports","topic_sports","topic_world","topic_world","topic_world","topic_world","topic_world","topic_nation","topic_nation","topic_world","topic_world","topic_world","topic_world","topic_world","topic_science","topic_science","topic_science","topic_science","topic_nation","topic_nation","topic_nation","topic_nation","topic_science","topic_science","topic_science","topic_science","topic_science","topic_science","topic_science","topic_science","topic_sports","topic_nation","topic_nation","topic_nation","topic_nation","topic_nation","topic_nation","topic_nation","topic_nation","topic_nation","topic_nation","topic_nation","topic_nation","topic_world","topic_world","topic_world","topic_world","topic_world","topic_world","topic_world","topic_world","topic_world","topic_sports","topic_sports","topic_sports","topic_sports","topic_sports","topic_sports","topic_sports","topic_nation","topic_nation","topic_nation","topic_nation","topic_nation","topic_nation","topic_nation","topic_science","topic_science","topic_science","topic_world","topic_world","topic_world","topic_world","topic_nation","topic_nation","topic_nation","topic_nation","topic_nation","topic_nation","topic_nation","topic_nation","topic_nation","topic_science","topic_science","topic_science","topic_science","topic_science","topic_science","topic_science","topic_nation","topic_nation","topic_nation","topic_nation","topic_nation","topic_sports","topic_sports","topic_sports","topic_sports","topic_sports","topic_sports","topic_sports","topic_sports","topic_sports","topic_science","topic_science","topic_science","topic_science","topic_science","topic_nation","topic_nation","topic_nation","topic_nation","topic_nation","topic_nation","topic_nation","topic_world","topic_world","topic_world","topic_world","topic_world","topic_world","topic_world","topic_world","topic_world","topic_world","topic_world","topic_world","topic_world","topic_world","topic_science","topic_science","topic_science","topic_nation","topic_nation","topic_nation","topic_sports","topic_sports","topic_nation","topic_nation","topic_nation","topic_nation","topic_nation","topic_nation","topic_nation","topic_sports","topic_sports","topic_world","topic_world","topic_world","topic_world","topic_world","topic_world","topic_world","topic_world","topic_world","topic_world","topic_world","topic_world","topic_world","topic_world","topic_world","topic_world","topic_world"],["abcnews.go.com","abcnews.go.com","abcnews.go.com","bleacherreport.com","bleacherreport.com","en.brinkwire.com","en.brinkwire.com","en.brinkwire.com","en.brinkwire.com","en.brinkwire.com","fox13now.com","fox13now.com","fox6now.com","fox6now.com","fox6now.com","fox6now.com","fox6now.com","indianexpress.com","indianexpress.com","indianexpress.com","indianexpress.com","money.cnn.com","money.cnn.com","money.cnn.com","money.cnn.com","arabnews.com","arabnews.com","arabnews.com","arabnews.com","cantonrep.com","cantonrep.com","cantonrep.com","easternmirrornagaland.com","espn.com","foxnews.com","foxnews.com","foxnews.com","foxnews.com","foxnews.com","foxnews.com","foxnews.com","foxnews.com","foxnews.com","foxnews.com","foxnews.com","foxnews.com","latimes.com","latimes.com","latimes.com","latimes.com","latimes.com","newindianexpress.com","newindianexpress.com","newindianexpress.com","newindianexpress.com","nj.com","nj.com","nj.com","nj.com","nj.com","nj.com","nj.com","nola.com","timesfreepress.com","timesfreepress.com","timesfreepress.com","timesfreepress.com","timesfreepress.com","timesfreepress.com","businessmirror.com.ph","businessmirror.com.ph","businessmirror.com.ph","forward.com","forward.com","in.reuters.com","in.reuters.com","nypost.com","nypost.com","nypost.com","nypost.com","nypost.com","nypost.com","nypost.com","nypost.com","nypost.com","qrius.com","qrius.com","spaceflightnow.com","spaceflightnow.com","spaceflightnow.com","spaceflightnow.com","spaceflightnow.com","cbsnews.com","cbsnews.com","cbsnews.com","cbsnews.com","cnn.com","express.co.uk","express.co.uk","express.co.uk","foxsports.com","foxsports.com","foxsports.com","foxsports.com","foxsports.com","foxsports.com","morningticker.com","morningticker.com","morningticker.com","morningticker.com","morningticker.com","npr.org","npr.org","nytimes.com","nytimes.com","nytimes.com","nytimes.com","nytimes.com","nytimes.com","nytimes.com","nytimes.com","nytimes.com","nytimes.com","nytimes.com","nytimes.com","pbs.org","pbs.org","pbs.org","reuters.com","reuters.com","reuters.com","reuters.com","space.com","space.com","thetalkingdemocrat.com","washingtonpost.com","washingtonpost.com","washingtonpost.com","washingtonpost.com","washingtonpost.com","washingtonpost.com","washingtonpost.com","washingtonpost.com","washingtonpost.com","washingtonpost.com","washingtonpost.com","washingtonpost.com","washingtonpost.com","washingtonpost.com","washingtonpost.com","washingtonpost.com","washingtonpost.com","washingtonpost.com","washingtonpost.com","washingtonpost.com","washingtonpost.com","washingtonpost.com","washingtonpost.com","washingtonpost.com","washingtonpost.com","washingtonpost.com","washingtonpost.com","washingtonpost.com","washingtonpost.com","washingtonpost.com","washingtonpost.com"],["caring for the dogs while the in-laws were out of town . The case against <mark> them was dismissed <\/mark> at the request of prosecutors after an expert determined an air conditioner at the kennel","'s attorney said a graph created by authorities that accurately showed electrical usage dropping inside <mark> the kennel was n't turned <\/mark> over to his client before trial . Montoya said he learned of the chart 's","trial . Steven Dichter , an attorney representing Trombi , declined to comment on why <mark> the ruling was reversed <\/mark> . Follow Jacques Billeaud at twitter.com/jacquesbilleaud . His work can be found athttps://bit.ly/2GGWEPO . 0",", the wife of Atlanta Falcons quarterback Matt Ryan , announced Sunday the couple 's <mark> twin boys were cleared <\/mark> to go home after more than a month in the neonatal intensive care unit at","intensive care unit at Northside Hospital in Atlanta . Ryan made an Instagram post explaining <mark> she was placed <\/mark> on bed rest Jan . 9 . She gave birth to the brothers , Marshall","busy modernizing its army , experts told DW . The US , Russia , and <mark> China are considered <\/mark> the world 's strongest nations when it comes to military power , with the US","' ' We do n't always know where the target is ' This point of <mark> view is echoed <\/mark> by Russian journalist and military analyst Pavel Felgenhauer , who warns that real-life conflicts depend","Confederations Cup , \" he told DW . \" You never know the result until <mark> the game is played <\/mark> . \" Felgenhauer notes that Russia is lacking in many areas of modern military technology","n't always know where the target is . \" No more German and French satellites <mark> These problems were exacerbated <\/mark> by the 2014 Crimean crisis , according to the analyst . In the years leading","market economy , but the main goal for any enterprise on Soviet territory , whether <mark> it was designated <\/mark> as military or civilian , was to be ready to produce military goods and equipment","Email WEST VALLEY CITY , Utah -- Police confirm <mark> a male suspect was killed <\/mark> in an officer-involved shooting in West Valley City Sunday . The incident occurred in the","first heard report of the incident around 3:40 p.m . West Valley City PD confirmed <mark> a male suspect was killed <\/mark> , but no further details about the events leading up to the shooting were immediately","Email CARBONDALE , Pa . A home on Spring St. in Carbondale , <mark> Pennsylvania was declared <\/mark> \" unfit for human habitation \" after police were called out for a fight between","Spring St. in Carbondale , Pennsylvania was declared \" unfit for human habitation \" after <mark> police were called <\/mark> out for a fight between a woman and her boyfriend . Police said they were","were called out for a fight between a woman and her boyfriend . Police said <mark> they were called <\/mark> as a result of a fight between Emily Delamarter and her boyfriend , Joshua Freitas","aback by the level and degree of filth in the home . Court documents show <mark> the apartment was covered <\/mark> in garbage and old food . It smelled of mold that appeared to come from","something like that had to happen , \" added a neighbor . Both Delmarter and <mark> Freitas were taken <\/mark> to jail on child endangerment and drug charges . Police said the children were under","it finally splashed into the ocean . Tiangong - 2 continues to be operational . <mark> This lab was launched <\/mark> the same year the Chinese lost control of the now-downed space station . ISRO is","enough to destroy a spacecraft 1 in 1 trillion : Probability of an individual on <mark> Earth being hit <\/mark> by falling debris ( Aerospace Corporation ) The solutions In May , it will be","release a smaller satellite that will recapture space junk with a harpoon . Passivation : <mark> Satellite explosions are reduced <\/mark> by deactivating various systems Design for demise : Designing with material that burn up on","Designing with material that burn up on re-entry Deorbiting systems : Under international guidelines , <mark> satellites are brought <\/mark> down within 25 years after mission life Design for servicing : Grips or handles can","Facebook is about to tell users if their <mark> data was shared <\/mark> with Cambridge Analytica Our Terms of Service and Privacy Policy have changed . By continuing","Contact Us Closed Captioning Site Map > Most stock quote data provided by BATS . <mark> Market indices are shown <\/mark> in real time , except for the DJIA , which is delayed by two minutes","for use to S&P Opco , LLC and CNN . Standard & Poor 's and <mark> S&P are registered <\/mark> trademarks of Standard & Poor 's Financial Services LLC and Dow Jones is a registered","News Network . A Time Warner Company . All Rights Reserved . Terms under which <mark> this service is provided <\/mark> to you . Privacy Policy .","used archival data from the Chandra X-ray Observatory , a telescope orbiting earth . Their <mark> findings were published <\/mark> in Nature magazine last Wednesday . April 05 , 2018 23:14 45678 TAMPA , USA","no evidence of new neurons are being created past the age of 13 . While <mark> neither study is seen <\/mark> as providing the definitive last word , the research is being closely watched as the","neurons \" in the hippocampi of people older than 18 , he told AFP when <mark> the study was published <\/mark> . They did find some in children between birth and one year , \" and","and a few at seven and 13 years of age , \" he said . <mark> That study was described <\/mark> by experts as \" sobering , \" because it indicated the human hippocampus is largely","everyone in the excitement of aviation and exploration . \" Being the first woman in <mark> the post is added <\/mark> honor because the science and tech fields are lacking in women and people of color","herself ( in me ) , \" she said . \" So many jobs of <mark> the future are tied <\/mark> to technology . It 's not just important , it 's a necessity \" to","visitors a year - as it begins a seven-year , $ 1 billion renovation . <mark> The federal government is expected <\/mark> to pay for three-quarters of the cost of the project , leaving the museum to","will stay there for up to six months from an earlier planned two-week trip . <mark> The move is seen <\/mark> as to quickly end the dependency over Russian Soyuz flights to ferry astronauts to the","putt on the 12 hole during the final round . David Cannon / Getty Images <mark> He was met <\/mark> with polite applause on the first tee . The throaty cheer was for McIlroy ,","for the return of \" Last Man Standing , \" the Tim Allen comedy that <mark> many suspect was canceled <\/mark> because of pro-conservative content . In fact , it can be argued that much of",". \" \" The Washington Post is far more fiction than fact . Story after <mark> story is made <\/mark> up garbage -- more like a poorly written novel than good reporting . Always quoting","Jeff Bezos . The Washington Post is far more fiction than fact . Story after <mark> story is made <\/mark> up garbage - more like a poorly written novel than good reporting . Always quoting","as Trump pointed out in his tweet Sunday . \" This portrait of Kelly 's <mark> trajectory is based <\/mark> on interviews with 16 administration officials , outside advisers and presidential confidants , many of","George said . Four men in her group rushed the suspect . One of her <mark> friends was stabbed <\/mark> in the stomach and two in their arms , she said . The suspect stabbed",", was killed by lightning over the weekend . ( Facebook ) A 23 - <mark> year-old woman was killed <\/mark> by lightning at a Florida mud bog over the weekend and four other people were","woman was killed by lightning at a Florida mud bog over the weekend and four <mark> other people were hurt <\/mark> , Fox 30 reported . The lightning strike killing Kourtney Lambert , 23 , reportedly","Email A man in <mark> Florida was hit <\/mark> and killed by a high speed Brightline train on Sunday , police said . (","speed Brightline train on Sunday , police said . ( Brightline ) A man in <mark> Florida was hit <\/mark> and killed by a high-speed train on Sunday - the fourth person to die since","train struck a pedestrian approximately 100 feet south of the Southeast 4th Street crossing . <mark> The male was pronounced <\/mark> deceased at the scene , \" the Delray Police Department tweeted , adding that they","train struck a pedestrian approximately 100 feet south of the Southeast 4th Street crossing . <mark> The male was pronounced <\/mark> deceased at the scene by DBPD . Any witnesses are urged to call DBPD Det","4th Street crossing . The male was pronounced deceased at the scene by DBPD . <mark> Any witnesses are urged <\/mark> to call DBPD Det . Joseph Hart 243-7800 . Delray Beach Police ( @DelrayBeachPD )","worldwide - one-tenth the number that Facebook has - but has gained popularity because its <mark> messages are said <\/mark> to be secure and less vulnerable to hackers . It offers instant messaging as well","Iranian security and intelligence agencies arrested some Telegram users , citing national security reasons . <mark> Iranian hard-liners are believed <\/mark> to have been considering a permanent block for months , opening a new rift with","the Middle East , to find good news from any disaster . \" Others said <mark> the ban was destined <\/mark> to fail - just like a nominal ban on satellite dishes , to keep out","Iranian apps that are advertised by the regime . It 's another example of how <mark> top politicians are not trusted <\/mark> either . The theocracy ruling Iran is facing a legitimacy crisis . \" The blockage","primarily through Telegram , where they offer after-sale services and answer questions . \" If <mark> Telegram is filtered <\/mark> , access to our clients will become difficult and time-consuming and we may lose many","in Kalahandi district covering a distance of about 13 km without engine.The incident occurred as <mark> skid brakes were not applied <\/mark> at Titlagarh railway station where the engine is detached and a new diesel engine attached","without engine.The incident occurred as skid brakes were not applied at Titlagarh railway station where <mark> the engine is detached <\/mark> and a new diesel engine attached for reversal . The coaches continued to move as",", railway staff brought those to stationary by putting blocks on track . Later , <mark> an engine was attached <\/mark> to the train which left Kesinga at 12.35 am and reached Puri at 1.30 pm","Piyush Goyal should take remedial action to address the lapses . Meanwhile , inquiry into <mark> the incident was started <\/mark> by a team of Sambalpur Railway Division comprising Head of Civil Pradeep Nagar , Head","Beckham , most notably from the Rams . In response , Beckham 's camp let <mark> it be known <\/mark> that he does not plan to take the field again without a long-term contract ,","or Michael Strahan with the Giants in 2007 -- heated up . If Beckham 's <mark> feelings are hurt <\/mark> over a sense that he is not wanted or valued by the Giants -- he","2007 -- heated up . If Beckham 's feelings are hurt over a sense that <mark> he is not wanted <\/mark> or valued by the Giants -- he reportedly told Rams players he would like to","by Shurmur and general manager Dave Gettleman , but he scuffed it in March when <mark> he was seen <\/mark> in a viral video with a woman later identified as a French model and what","acknowledged getting to the bottom of the video . Shurmur , quarterback Eli Manning and <mark> safety Landon Collins are expected <\/mark> to address the media on Monday . It is unknown how long Beckham will stay","Giants facility during the voluntary program given he wo n't practice due to health . <mark> He s kipped <\/mark> all voluntary options last offseason . Ryan Dunleavy may be reached at rdunleavy@njadvancemedia.com . Follow","cases would have been a tailor-made double play ball ending the inning . But shortstop <mark> J.P. Crawford was shifted <\/mark> to the right side of the bag and while he reached the ball , he","msimoneaux@nola.com , NOLA.com The Times-Picayune A Florida woman is facing drug charges after <mark> she was found <\/mark> in possession of marijuana and cocaine during a traffic stop in Fort Pierce last month","friend in East Ridge shooting April 8th , 2018 by Staff Report in Breaking News <mark> This story was updated <\/mark> April 8 , 2018 , at 8 p.m. with more information . The front of","April 8 , 2018 , at 8 p.m. with more information . The front of <mark> the home is shown <\/mark> where two people were shot and killed early Sunday , April 8 , 2018 ,","8 p.m. with more information . The front of the home is shown where two <mark> people were shot <\/mark> and killed early Sunday , April 8 , 2018 , in East Ridge . The","early Sunday , April 8 , 2018 , in East Ridge . The front of <mark> the home is shown <\/mark> where ... Photo by Rosana Hughes / Times Free Press . Casey Lawhorn Casey Lawhorn","according to a news release , but he fled the scene before police arrived . <mark> He was believed <\/mark> to have been in Dade County at the time , driving a gold 2002 Ford","108 pounds . Anyone who sees him or the vehicle should call police immediately . <mark> He is considered <\/mark> to be armed and dangerous . Contact staff writer Rosana Hughes at rhughes@timesfreepress.com or 423-757-6327","brains and reasoning power that have elevated us from the beasts of the field . <mark> The horse was domesticated <\/mark> around 3,000 BC , and we quickly learned not to be run over by a","at some recent events . In January an official message from the state government of <mark> Hawaii was sent <\/mark> over television , radio , and cell phones informing the public that \" Ballistic Missile",". Seek Immediate Shelter . This Is Not a Drill . \" Thirty-eight minutes later <mark> it was announced <\/mark> that the message was a mistake . The governor of the state apologized for the","JERUSALEM ( JTA ) - A Palestinian man attempting to stab an Israeli man at <mark> a West Bank gas station was shot <\/mark> in the head by an armed civilian who witnessed the attack . The assailant ,","assaila nt ran after the Israeli man brandishing a screwdriver . Three people who witnessed <mark> the attack were treated <\/mark> for shock , according to reports . Share This :","3 billion euros a year . The minimum , the CFDT says , is that <mark> work conditions be dealt <\/mark> with in a new collective bargaining round which should conclude before anything happens to hiring","time of a wider protests against social welfare reforms . Widespread public anger led to <mark> the rail reform being pulled <\/mark> and ultimately the government 's downfall . ( $ 1 = 0.8143 euros ) Sud","teen girl to keep her as his 'pet ' : cops MENDOCINO , Calif . <mark> A body was recovered <\/mark> Saturday in the vicinity where an SUV plunged off a Northern California cliff last month","the age and identity could not immediately be determined , said Lt. Shannon Barney . <mark> An autopsy is planned <\/mark> Tuesday to determine a cause of death . While authorities said they believe the body","could take weeks . Jennifer and Sarah HartFacebook Sarah and Jennifer Hart and their six <mark> adopted children were believed <\/mark> to be in the family 's SUV when it plunged off a cliff last month","in the family 's SUV when it plunged off a cliff last month . Five <mark> bodies were found <\/mark> March 26 near Mendocino , a few days after Washington state authorities began investigating the","\" Devonte , a black boy who is still missing , drew national attention after <mark> he was photographed <\/mark> in tears while hugging a white police officer during a 2014 protest . The discovery","off ' This de Blasio administration official set one heckuva bad example for the teens <mark> she was hired <\/mark> to keep out of jail . Reagan Stevens , a deputy director in the Mayor",", a deputy director in the Mayor 's Office of Criminal Justice , and two <mark> young men were arrested <\/mark> for illegal weapons possession while sitting in a double-parked car near the scene of a","that killed 17 students and staffers at a Parkland , Fla. , high school . <mark> Stevens was arrested <\/mark> around 10:25 p.m. near the corner of 177th Street and 106th Avenue along with driver","were each charged with two counts of criminal possession of a weapon - one for <mark> the gun being loaded <\/mark> , another for its illegally obscured serial number - because no one admitted owning the",", salamanders , snails , and aquatic invertebrates like amphipods , gastropods , ostracods and <mark> daphnia were used <\/mark> to produce offspring in microgravity . The current experiment , however , may give insights","the ISS will be thawed out by the crew members and then chemically activated before <mark> they are used <\/mark> to fertilise an egg . The entire experiment will be video recorded in order to","to ensure the rocket is ready for InSight 's 34 - day launch period . <mark> Liftoff is scheduled <\/mark> for May 5 during a two-hour launch window opening at 4:05 a.m. PDT ( 7:05",", and ULA and NASA agreed to launch InSight from Vandenberg . Fewer Atlas 5 <mark> missions are scheduled <\/mark> from Vandenberg , so officials wanted to reduce the workload at ULA 's busier launch","antennas . \" In essence , it will take the vital signs of Mars - <mark> it s pulse <\/mark> , temperature and much more , \" said Thomas Zurbuchen , head of NASA 's","record on Earth has eroded away , but Mars may still hold clues about how <mark> it was born <\/mark> , accreted rock and dust , and formed a hot , high-pressure mantle and core","instrument forced a delay until the next Mars launch opportunity this year . InSight 's <mark> primary mission is expected <\/mark> to last more than a Martian year - or nearly two Earth years - through","50th floor . \" pic.twitter.com/J3in1jDmlH - Jonathan Miller ( @jhmill ) April 7 , 2018 <mark> Fire sprinklers were not required <\/mark> in New York City high-rises when Trump Tower was completed in 1983 . Subsequent updates","April 7 , 2018 Fire sprinklers were not required in New York City high-rises when <mark> Trump Tower was completed <\/mark> in 1983 . Subsequent updates to the building code required commercial skyscrapers to install the","the building code required commercial skyscrapers to install the sprinklers retroactively , but owners of <mark> older residential high-rises are not required <\/mark> to install sprinklers unless the building undergoes major renovations . Some fire-safety advocates pushed for","unless the building undergoes major renovations . Some fire-safety advocates pushed for a requirement that <mark> older apartment buildings be retrofitted <\/mark> with sprinklers when New York City passed a law requiring them in new residential high-rises",", the commander of the brigade . \" This is an unfortunate event , and <mark> we are saddened <\/mark> by the loss of our fellow soldiers . We ask that everyone respect the privacy","'s actions have caused at least one fight for the weekend to be cancelled as <mark> Michael Chiesa was cut <\/mark> by the broken glass . The NYPD released a warrant for McGregor 's arrest before","June 14 . GETTY Conor McGregor faces three counts of assault and one count of <mark> criminal mischief Cena is expected <\/mark> to show up at WrestleMania 34 this Sunday despite the fact he is not booked","mischief Cena is expected to show up at WrestleMania 34 this Sunday despite the fact <mark> he is not booked <\/mark> to wrestle . The Champ has challenged Undertaker to a match but The Deadman has","and its 7 - 2 start matched the franchise best accomplished four previous times . <mark> Arizona manager Torey Lovullo was ejected <\/mark> by plate umpire Tim Timmons in the second inning . Lovullo was arguing a called","forecast for Monday is n't much better , but the show must go on . <mark> The Indians are scheduled <\/mark> to play home games in each of the next seven days . Article continues below","caused him to spend two months on the disabled list last year . Francona said <mark> Chisenhall is expected <\/mark> to miss about four to six weeks . To replace Chisenhall on the roster ,","on Sunday . \" He 's going to get a chance to play , and <mark> he 's played <\/mark> here before and helped us win before , \" Francona said . \" So it","win his eighth Cup Series race at Texas or end his career-long winless streak . <mark> Johnson was caught <\/mark> up in an incident involving seven cars coming off the backstretch on the first lap","not immediately returned . Sheriff 's spokeswoman Nancy Crowley tells the San Francisco Chronicle that <mark> Smith was booked <\/mark> Friday for violating a condition of his electronic monitoring while on bail . Article continues",", 2018 by Dan Taylor Leave a Comment Due to a little-known 1992 law , <mark> SpaceX was forced <\/mark> to shut down their live broadcast of a Falcon 9 launch nine minutes after liftoff","SpaceX launch of a Falcon 9 rocket to bring 10 Iridium satellites into orbit . <mark> The feed was cut <\/mark> just under 10 minutes after liftoff , as SpaceX did not have the requisite permission","reliability , the second stage has redundant igniter systems . Like the first stage , <mark> the second stage is made <\/mark> from a high-strength aluminum-lithium alloy . The interstage is a composite structure that connects the","( RP - 1 ) propellant . After ignition , a hold-before-release system ensures that <mark> all engines are verified <\/mark> for full-thrust performance before the rocket is released for flight . Then , with thrust","ignition , a hold-before-release system ensures that all engines are verified for full-thrust performance before <mark> the rocket is released <\/mark> for flight . Then , with thrust greater than five 747s at full power ,","via the FBI , but according Murphy , this law would streamline the process . <mark> The first published data is expected <\/mark> next month . Currently , New Jersey is ranked as having the third-toughest gun laws","streamline the process . The first published data is expected next month . Currently , <mark> New Jersey is ranked <\/mark> as having the third-toughest gun laws in the nation , behind California and Connecticut ,","lives in Pompano Beach , Fla. , and was among Mr. Deason 's friends whose <mark> data was collected <\/mark> . \" If you sign up for anything and it is n't immediately obvious how","The questionnaire used to collect data for Cambridge Analytica was not actually on Facebook . <mark> It was hosted <\/mark> by a company called Qualtrics , which provides a platform for online surveys . It","brunch preferences reveal their inner Disney princess . Facebook has said that people who took <mark> the quiz were told <\/mark> that their data would be used only for academic purposes , claiming that it and","their data would be used only for academic purposes , claiming that it and its <mark> users were misled <\/mark> by Cambridge Analytica and the researcher it hired , Aleksandr Kogan , a 28 -","'s terms of service that was reviewed by The Times . Photo Jim Symbouras 's <mark> profile data was collected <\/mark> dozens of times after Facebook friends of his were directed to the online survey .","elections , then contacted him for a job after Ronald Reagan 's 1980 election . <mark> Mr. Bolton was named <\/mark> assistant administrator of the United States Agency for International Development , where M. Peter McPherson","named Dick Cheney , a member of a committee investigating the Iran-contra affair . When <mark> the elder George Bush was elected <\/mark> , Mr. Baker named Mr. Bolton assistant secretary of state for international organizations . Mr.","I never found him to be in any way tricky or underhanded . \" When <mark> Mr. Bush was re-elected <\/mark> , Mr. Cheney pressed Ms. Rice , the incoming secretary , to give Mr. Bolton","BERLIN - Six men suspected of plotting a possible attack on the Berlin half-marathon on <mark> Sunday were detained <\/mark> by the police amid heightened security in Germany a day after a truck attack in","target civilians , the authorities remained on raised alert . In Berlin , roughly 630 <mark> officers were deployed <\/mark> along the marathon route . The authorities said the six detained men had shown a","statement . Advertisement Continue reading the main story No further information about the detainees ' <mark> identities was given <\/mark> . The police said their initial investigation had turned up no explosives in the suspects","support keeping American troops in Syria , including top American military officials , argue that <mark> they are needed <\/mark> to protect those gains . Highlighting the internal debate in Washington , at virtually the",": Once a month , a civics class in Northern Ireland breaks new ground . <mark> Visiting students are bussed <\/mark> across town from St. Mary 's and St. Cecilia 's , which are Catholic schools","struggle over keeping Northern Ireland within the United Kingdom or unifying it with Ireland . <mark> Society was split <\/mark> between Protestant , pro-United Kingdom loyalists and paramilitaries on the one hand and Catholic pro-Irish","provisional Irish Republican Army , or IRA. Between 1969 and 1998 , more than 3500 <mark> people were killed <\/mark> . Today Londonderry 's stark murals memorialize that history and the Foyle River still divides","Lula to a helicopter and then a jet at a Sao Paulo airport , where <mark> he was flown <\/mark> to the southern city of Curitiba to begin serving his sentence . He spent the","corruption probe have served their sentences . Lula will not be allowed to interact with <mark> others being held <\/mark> in the building , including his former finance minister Antonio Palocci . \" His spirit","world 's top oil exporter , would head to Spain later in the week . <mark> He is set <\/mark> to meet French President Emmanual Macron on Tuesday . On the agenda for his two-day",". A tourism project between Paris and Riyadh is likely to be announced , but <mark> he is not expected <\/mark> to clinch any mega-deals . Activists were planning protests on Sunday . Macron is under","particular shape . It 's the easiest of all to visualize , since only three <mark> stars are needed <\/mark> to form it . In addition to two constellations that are officially recognized as triangles","triangle configuration , although it is only temporary since one of the three points on <mark> the triangle is marked <\/mark> not by a star , but a planet . Facing east-southeast this week at around","other forces outside the force of gravity , which could give clues as to what <mark> it is made <\/mark> of . Scientists consider that only 4 % of the universe is common matter ,","to say what she wants . [ Trump confidant Roger Stone ca n't stop claiming <mark> he was poisoned <\/mark> by polonium ] Former New York governor Eliot Spitzer , who was a guest on",", she announced that she was taking a week-long vacation , which Fox News told <mark> The Washington Post was preplanned <\/mark> . Ingraham is scheduled to return to her show Monday . Hogg has rejected that","taking a week-long vacation , which Fox News told The Washington Post was preplanned . <mark> Ingraham is scheduled <\/mark> to return to her show Monday . Hogg has rejected that apology , calling Ingraham","a goal and an assist . Feb. 26 : Columbus 5 , Washington 1 : <mark> This ugly loss was decided <\/mark> within the first 20 minutes and was a lowlight of the most difficult stretch of","a lot of confidence in Braden , \" Trotz said at the time . \" <mark> He 's been <\/mark> a good goaltender for a long time . Yeah , I have confidence in him","say the GMC Yukon LX was intentionally driven off the scenic Pacific Coast Highway . <mark> The vehicle was found <\/mark> upside down and partially submerged at the bottom of the cliff , and authorities recovered","County that evening , according to the California Highway Patrol . The family 's 2003 <mark> GMC Yukon LX was found <\/mark> at the bottom of the cliff in nearby Westport , Calif . , two days","reach them . The agency tried a second time on March 26 , the day <mark> the SUV was found <\/mark> , and again the next day . Since the crash , a troubling narrative of","she lost her temper and bent the girl over a bathtub and spanked her . <mark> She was convicted <\/mark> of misdemeanor domestic assault and received a 90 - day suspended jail sentence after the","told The Washington Post . Devonte captured the world 's attention in 2014 , when <mark> he was photographed <\/mark> sobbing in the arms of a white police officer in Portland , where people had","Policy , said on NBC News 's \" Meet the Press . \" \" But <mark> we 're clear-eyed <\/mark> about this . We 're moving forward on a measured way with tariffs , with","impact on our economy . And the president has said - sectors like agriculture , <mark> he 's prepared <\/mark> to defend , \" Mnuchin said . [ How Trump risked a trade war with","hand . Asked if he hurt himself , he simply said : \" No , <mark> it 's padded <\/mark> . \" JUDGE THIS Judge 's franchise record of 14 straight home games with an","Bundy has pitched well in two starts , getting no-decisions vs. Minnesota and Houston . <mark> He 's allowed <\/mark> just one run in 13 innings , striking out 15 . Yankees : After a","Europe German van driver had run-ins with police , suicidal thoughts Flowers and <mark> candles are pictured <\/mark> at the place in Muenster , Germany , Sunday , April 8 , 2018 where","to a neighbor last month , German prosecutors said Sunday . The man , whose <mark> name was not released <\/mark> , killed two people and injured 20 others Saturday afternoon by crashing into those drinking","thoroughly . Prosecutors said he had expressed suicidal plans by email to a neighbor . <mark> Police were told <\/mark> about the email and went to the man 's Muenster home but he was not","fraud , a hit-and-run and domestic conflicts with his family , but Adomeit said that <mark> all charges were dismissed <\/mark> . Authorities have identified the two victims killed by the van crash as a 51","the northeast , and a 65 - year-old man from nearby Borken county . Their <mark> names were not released <\/mark> , as is customary in Germany . Early Sunday , all three bodies were taken","were not released , as is customary in Germany . Early Sunday , all three <mark> bodies were taken <\/mark> from the crash scene in front of the well-known Kiepenkerl pub . The silver-grey van","scene in front of the well-known Kiepenkerl pub . The silver-grey van that crashed into <mark> the crowd was hauled <\/mark> away hours later , after explosives experts had thoroughly checked it . Inside the van","gas bottles and canisters containing gasoline and bio-ethanol , but did not know yet why <mark> they were stored <\/mark> there . \" We are now focusing our investigations on getting a comprehensive picture of","voters in Sunday 's election . Orban began a brief speech to cheering supporters after <mark> preliminary results were announced <\/mark> with a clear message : \" We won . \" He also told the crowd","still open to accommodate long lines of people waiting to cast ballots . Most of <mark> the queues were made <\/mark> up of \" transfer voters , \" people such as college students or workers who","in line by the scheduled 7 p.m. closing time had been able to vote . <mark> Preliminary results are expected <\/mark> after 11 p.m . Prime Minister Viktor Orban is seeking his third consecutive term and","everyone waiting in line by the scheduled 7 p.m. closing time finished casting ballots . <mark> Preliminary results are expected <\/mark> after 11 p.m. ___ 4:15 p.m . Experts say the large turnout in Hungary 's","Jobbik breakthrough can be expected in the election . \" Prime Minister Viktor Orban 's <mark> Fidesz party is expected <\/mark> to win the majority of the 199 parliamentary seats , with Vona 's Jobbik and","stance , says it 's a \" misunderstanding \" that his frequently harsh criticism of <mark> Brussels was directed <\/mark> at the whole of the European Union . He says \" the EU is not","Kim Jong Un is willing to discuss the denuclearization of the Korean Peninsula . \" <mark> The official was n't authorized <\/mark> to be quoted by name and demanded anonymity . The meeting could occur as early","would say when or how the contact took place , nor in what location . <mark> The officials were n't authorized <\/mark> to comment by name and demanded anonymity . Previously , former Secretary of State Rex","where the meeting will place or whether a location has been determined , nor has <mark> an exact date been set <\/mark> . Initially , the White House said it expected the meeting to take place by"]],"container":"<table class=\"cell-border stripe\">\n  <thead>\n    <tr>\n      <th>search<\/th>\n      <th>source<\/th>\n      <th>kwic<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"order":[],"autoWidth":false,"orderClasses":false}},"evals":[],"jsHooks":[]}</script>
<!--/html_preserve-->

------------------------------------------------------------------------

### clr\_context\_bow()

A function for accessing/aggregating `BOW` object. The parameters `agg_var` and `content_only` can be used to specify how collocates are aggregated and whether only content words are included, respectively.

``` r
search5 <- "White House"

corpuslingr::clr_search_context(search=search5,corp=lingr_corpus, LW=20, RW=20)%>%
  corpuslingr::clr_context_bow(content_only = TRUE, agg_var = c('searchLemma', 'lemma'))%>%
  head()
##    searchLemma     lemma cofreq
## 1: WHITE HOUSE     TRUMP      6
## 2: WHITE HOUSE     KELLY      5
## 3: WHITE HOUSE      POST      3
## 4: WHITE HOUSE PRESIDENT      3
## 5: WHITE HOUSE       SAY      3
## 6: WHITE HOUSE    SUNDAY      3
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
Arpaio | attorney | dog | kennel | Austin Flake
</td>
</tr>
<tr>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
birth | wife of Atlanta Falcons quarterback Matt Ryan | rest Jan | further light | past few month
</td>
</tr>
<tr>
<td style="text-align:left;">
3
</td>
<td style="text-align:left;">
Russia | DW | Felgenhauer | Soviet Union | US
</td>
</tr>
<tr>
<td style="text-align:left;">
4
</td>
<td style="text-align:left;">
male suspect | incident | news | scene | West Valley City PD
</td>
</tr>
<tr>
<td style="text-align:left;">
5
</td>
<td style="text-align:left;">
police | baby | street | boyfriend | old food
</td>
</tr>
<tr>
<td style="text-align:left;">
6
</td>
<td style="text-align:left;">
ISRO | China | space station | control | reusable launch vehicle
</td>
</tr>
</tbody>
</table>
