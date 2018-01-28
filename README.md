corpuslingr:
------------

Some r functions for (1) quick web scraping and (2) corpus seach of complex grammatical constructions.

High Level utility. Hypothetical workflows. Independently or in conjunction. Academic linguists and digital humanists.

``` r
library(tidyverse)
library(cleanNLP)
library(stringi)
library(corpuslingr) #devtools::install_github("jaytimm/corpuslingr")
library(corpusdatr) #devtools::install_github("jaytimm/corpusdatr")
```

Web scraping functions
----------------------

These functions .... There are other packages/means to scrape the web. The two included here are designed for quick/easy search of headline news. And creation of tif corpus-object. making subsequent annotation straightforward. 'Scrape news -&gt; annotate -&gt; search' in three or four steps.

Following grammatical constructions ~ day-to-day changes, eg.

### GetGoogleNewsMeta()

``` r
dailyMeta <- corpuslingr::GetGoogleNewsMeta (search="New Mexico",n=30)

head(dailyMeta['titles'])
##                                                                    titles
## 2   New Mexico holds hundreds of people in prison past their release date
## 3                        Colorado State comes up short against New Mexico
## 4     Stuck at the bottom: Why New Mexico fails to thrive | Education ...
## 5                     Breaking down lawmakers' bills on kids and families
## 6         New Mexico Senior care services no longer on the chopping block
## 7 New Mexico invests in young entrepreneurs to kickstart its sluggish ...
```

### GetWebTexts()

This function ... takes the output of GetGoogleNews() (or any table with links to websites) ... and returns a 'tif as corpus df' Text interchange formats.

``` r
nm_news <- dailyMeta %>% 
  corpuslingr::GetWebTexts(link_var='links') %>%
  mutate(txt=stringi::stri_enc_toutf8(txt))

head(nm_news)
##   doc_id
## 1   doc1
## 2   doc2
## 3   doc3
## 4   doc4
## 5   doc5
## 6   doc6
##                                                                                                            links
## 1 http://amarillo.com/wt-sports/sports/college-sports/2018-01-27/wt-stampede-buffs-maul-western-new-mexico-99-55
## 2                    http://krqe.com/2018/01/27/new-mexico-senior-care-services-no-longer-on-the-chopping-block/
## 3                                     http://krwg.org/post/dry-conditions-cramp-new-mexico-water-supply-forecast
## 4                                   http://krwg.org/post/new-mexico-texas-water-dispute-reaches-us-supreme-court
## 5                            http://nmindepth.com/2018/01/28/breaking-down-lawmakers-bills-on-kids-and-families/
## 6                http://www.koaa.com/story/37367417/new-mexico-holds-hundreds-of-inmates-past-their-release-date
##                                      source
## 1                              Amarillo.com
## 2                              KRQE News 13
## 3                                      KRWG
## 4                                      KRWG
## 5                       New Mexico In Depth
## 6 KOAA.com Colorado Springs and Pueblo News
##                                                            titles
## 1               WT stampede: Buffs maul Western New Mexico, 99-55
## 2 New Mexico Senior care services no longer on the chopping block
## 3           Dry conditions cramp New Mexico water supply forecast
## 4                                                      New Mexico
## 5             Breaking down lawmakers' bills on kids and families
## 6    New Mexico holds hundreds of inmates past their release date
##                        pubdates       date
## 1 Sun, 28 Jan 2018 04:12:07 GMT 2018-01-28
## 2 Sun, 28 Jan 2018 05:55:00 GMT 2018-01-28
## 3 Sat, 27 Jan 2018 21:47:29 GMT 2018-01-27
## 4 Sun, 28 Jan 2018 15:46:07 GMT 2018-01-28
## 5 Sun, 28 Jan 2018 09:37:12 GMT 2018-01-28
## 6 Sun, 28 Jan 2018 16:29:00 GMT 2018-01-28
##                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                txt
## 1                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     WT stampede: Buffs maul Western New Mexico, 99-55 Impact box   WT 99, Western NM 55 Records: No. 11-ranked West Texas A&M improves to 19-2 overall and 9-2 in the Lone Star Conference. Western New Mexico drops to 3-17, 0-11. Impact: West Texas moves to 30-1 in its last 31 home games. Next Up: Showdown time with first place UT Permian-Basin visiting West Texas A&M at 7:30 p.m. Tuesday. One sign of a good team regardless of the sport is doing the expected. West Texas was a very good team Saturday afternoon. Struggling Western New Mexico rolled into the First United Bank Center and the No. 11-ranked Buffs took care of business using an early 11-0 run as the catalyst for a lopsided 99-55 Lone Star Conference victory before 1,118 fans The win moved WT to 19-2 overall and sets up an LSC showdown Tuesday at the FUB with first-place University of Texas-Permian Basin. Western New Mexico departed the FUB still looking for win number one in the LSC dropping to 0-11. "It was one of those things where they don't have a win in conference and it was close for a little bit there," said West Texas coach Tom Brown. "What we did was do what we were supposed to do. We broke their will in the first half and that was good for us. We were able to get a lot of guys in." The Buffs faced little drama in this one as Western New Mexico plays the same up-tempo style of play. Except for the opening few minutes when the game was tied at seven, this one was all WT with all 11 Buff players scoring and grabbing a rebound, four finding double figures scoring led by Drew Evans' 23 points, and a total of 65 3-pointers attempted by both teams.in his nine WT used an 11-0 run midway through the first half to build a cushion resulting in a 44-21 halftime lead. Any question of a Western NM comeback was put to rest with 12:31 remaining in the first half when the Buffs moved the 23-point to 31 when senior guard David Chavlovich and sophomore Drew Evans combined on a highlight reel dunk for 63-32 lead. Chavlovich dribbled out past the 3-point arc on the wing then quickly lofted a back door pass to the 6-foot-3 Evans, who hammered home the dunk. Evans had his most productive game in LSC play this year going 8-of-11 from the floor, and making three steals. "As a coach I probably enjoy a good box out or rebounds more than a dunk, but Drew played well for us and that's good to see," Brown said. "He needs to get a few more rebounds for us. Everybody had a rebound and scored so that's good for us." Joining Evans in double figures for the Buffs were junior forward Ryan Quaid with 15, guard Jordan Evans added 12 and Chavlovich chipped in 12. Freshman Gaige Prim grabbed a team-high nine rebounds and scored four points in 13 minutes of action. Another highlight for the fans and the Buffs players was the nine points scored by freshman Sterling White of Happy in his nine minutes of play. The nine points included a dunk much celebrated with loud applause from the fans and smiles from the WT players on the bench. Western NM never found its offense shooting 16-of-65 from the floor (24.6 percent) and had one highlight in 6-f0ot-9 junior post Jon-Reese Wooden producing a double-double with 10 points and 12 rebounds. All in all, WT enjoyed this one and that meant simply winning a game it was supposed to according to season records. "To see Ster do that and the whole bench play like that is fun for us all," Quaid said. "Western New Mexico did not have a good record in conference and that's our job to have a game like this. Coaches are preaching to us to take care of business. It's not about how much we can beat this time by it's more about is this performance going to be good enough to beat the a Commerce, to be a UTPB, and to beat an in-region top team. That's what it's about. It's that point of the season." WT 99, WNM 55 Western New Mexico (3-17, 0-11): Latrell Spivey 0-0 0-0 0, CJ Vanbeekum 2-8 1-6 7, Jordan Enriquez 4-13 2-2 10, Willie McCray 0-9 4-6 4, Hane Vaughnwilson 2-11 1-2 5, Davis Wade 1-6 0-1 2, Jon-Reese Woodson 3-8 4-11 10, Alex Gonzalez 3-7 0-0 8, Eddie Giron 1-3 0-0 2, O'Shayne Reid 0-0 0-0 0. Totals 16-65 20-33 55. West Texas A&M (19-2, 9-2): David Chavlovich 4-10 0-0 12, CJ Jennings 1-7 0-0 2, Jordan Evans 5-10 0-1 13, Gach Gach 1-6 -0-0 3, Ryan Quaid 6-8 3-6 15, Drew Evans 8-11 5-5 23, Jordan Collins 2-6 2-2 7, Rylan Gerber 2-4 0-0 4, Gaige Prim 2-4 0-3 4, Wyatt Wheatly 2-5 -0-0 5, Sterling White 3-4 2-3 9. Totals 36-75 12-20 99. Western New Mexico;21;34-55 West Texas A&M;44;55-99 3-point goals: WNM: 3-23 (Vanbeekum 1-6, Gonzalez 2-6). WT: 15-42 (Chavlovich 4-9, Evans 3-8, Gach 1-4, Evans 2-5, Collins 1-3, Gerber 2-4, Wheatly 1-4, White 1-1). Rebounds: WNM: 50 (Woodson 12). WT: 51 (Prim 9). Steals: WNM 5 (McCray 3). WT: 11 (D. Evans 3). Blocked shots: WNM: 2 (Vanbeekum 1, Copper 1). WT: 6 (Prim 4). Turnovers: WNM 19 (Spivey 5). WT: 10 (Jennings 3). Total Fouls: WNM: 23. WT: 28. Fouled out: Jennings. Technicals: Prim. Officials: George Washington, Thomas Northcutt, John Schoepf. Attendance: 1,118. Lone Star Conference 
## 2                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           Click to share on Pinterest (Opens in new window) SANTA FE, N.M. (KRQE) - After concerns about a major disruption of senior services for tens of thousands of elderly New Mexicans. The state has changed its tune. The governor's administration had planned to cancel a contract that could have halted payments immediately to service providers, like Meals on Wheels and Homemaker Services, affecting more than 70,000 thousand seniors statewide. Democratic lawmakers say critical services that New Mexico seniors rely on are no longer at risk. "I'm very grateful that the governor decided to rescind this original decision and that the aging alternative services department did the right thing by taking care of our seniors," said Sen. Howie Morales (D-Silver City). The New Mexico Department of Aging and Long-Term Services works with the Non-Metro Area Agency on Aging," or "Triple A," Triple A reimburses dozens of providers like Meals on Wheels, Respite Care, Homemaker Services, and senior transportation services on behalf of the state. It's a contract Gov. Susana Martinez' administration planned to end after allegations of billing and reimbursement issues. "We were given very little information, which is why myself and Rep. Armstrong stood strong with our position because there wasn't a clear reason why this change was occurring," Morales said. Morales said the group is crucial, distributing $20 million in funding to 65 different senior service providers in every single county outside Bernalillo. "They depend on it with their life, and I think the opportunity to keep these services intact is extremely vital to ensure we can take care of our most vulnerable population in our state," Morales said. The contract does end in June, but Sen. Morales is hopeful they can renew the current contract or make adjustments to have other options up for discussion. New 13 reached out to the Governor's Office to find out what sparked the change of heart. We're told the Aging and Long-Term Services Department will release a statement on Monday. Share, Print or Email 
## 3                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              Dry conditions cramp New Mexico water supply forecast By News Editor And Partners . 18 hours ago   ALBUQUERQUE, N.M. (AP) - New Mexico's water resources could feel the pinch later this year thanks to dismal snowpack and a strengthening weather pattern in the Pacific Ocean that typically brings drier weather. The National Weather Service in Albuquerque issued an  update Friday on the water supply outlook. Senior hydrologist Royce Fontenot says drought has expanded across New Mexico in recent weeks. Severe conditions now cover 60 percent of the state. He said some areas, particularly in the eastern plains, have not seen any moisture for the last 100 days or so. He also said snowpack levels for all basins are well below normal and that will affect water supplies going forward. Forecasters estimate New Mexico would need as much as 270 percent of normal precipitation in some areas to recover by the spring. 
## 4                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  New Mexico - Texas Water Dispute Reaches The U.S. Supreme Court By sarah tory-high country news . 55 minutes ago Tweet Share Google+ Email Credit Elephant Butte Dam / Sarah Tory-High Country News   Southern New Mexico's Mesilla Valley is like an island: a fertile patchwork of farm fields and groves of pecan trees surrounded by the brown Chihuahuan Desert.    For Mesilla Valley farmers, the metaphor rings true in other ways as well. Though they live in New Mexico, the residents of the roughly 90,000-acre-area are caught between their own state and Texas. The Rio Grande water they depend on is not technically New Mexico's water, but rather part of the water that goes to Texas under the Rio Grande Compact, a treaty ensuring that Texas, New Mexico and Colorado get their fair share of the river. New Mexico's delivery obligation to Texas hinges on collecting enough water in Elephant Butte Reservoir, 90 miles from the Texas border and the neighboring Mesilla Valley. Unfortunately, that leaves the farmers downriver in a complicated no-man's-land of interstate water management. "We cringe when we hear, 'Not one more drop to Texas,' because that means not one more drop for us," says Samantha Barncastle, the lawyer for the Elephant Butte Irrigation District, which manages and delivers irrigation water to Mesilla Valley farmers.  After more than a decade of back-and-forth between New Mexico and Texas, the fight has finally reached the Supreme Court. The first round of oral arguments took place on Jan. 8, with a final decision expected by early spring. For the farmers, the conflict has only heightened their sense of isolation from their own state - and made the costs of poor water management in a hotter and drier West more obvious than ever. Built in 1916 by the Bureau of Reclamation, Elephant Butte Dam made a large-scale agricultural economy possible in New Mexico's dry south. But disputes between states over the river continued, especially during times of drought.   The latest stems from a 2014 lawsuit filed by the state of Texas, claiming that by allowing farmers in southern New Mexico to pump groundwater, New Mexico was depleting the water destined for Texas under the Rio Grande Compact. Farmers in the Mesilla Valley receive a yearly allocation of 36 inches of water per acre from the reservoir, as long as flows in the Rio Grande are sufficient. But in the 1950s, a severe drought curtailed that allotment. To supplement irrigation supplies, the Bureau of Reclamation encouraged local farmers to pump groundwater. "Everyone did," recalls Robert Faubion, a fourth-generation local farmer. When the current drought began in 2003, farmers came to rely more on their groundwater wells, sometimes receiving almost 80 percent of their yearly irrigation needs from the aquifer. (The region's towns and cities, including Las Cruces, rely 100 percent on groundwater.) According to the U.S. Geological Survey Mesilla Basin Monitoring Program, between 2003 and 2005 the Mesilla Valley aquifer declined by up to 5 feet and held steady until 2011, when it began dropping sharply again. In some places, groundwater levels fell by 18 feet. As the situation worsened, the Elephant Butte Irrigation District and its longtime rival in Texas, the El Paso County Water Improvement District, agreed that the time had come to resolve their grievances. So the two agencies settled on an "operating agreement" in 2008, which required New Mexico to relinquish some of its Rio Grande water to Texas in exchange for Texas ceasing its complaints about groundwater pumping. The signing coincided with Valentine's Day. "We had sort of a love fest," says Gary Esslinger, the treasurer and manager of the Elephant Butte Irrigation District. The love lasted until 2011, when, in a surprise move, then-New Mexico Attorney General Gary King sued the irrigation district and the El Paso County Water Improvement District No. 1 as well as the Bureau of Reclamation, arguing that the deal gave away too much of New Mexico's water. The decision to sue one of its own irrigation districts was, to Barncastle, "incredibly strange." In 2014, Texas fired back with its own lawsuit against New Mexico, bringing us to today's scenario: If the Supreme Court rules against New Mexico, the state budget will take a hit. New Mexico could owe billions of dollars in damages - on top of the $15 million already spent on legal fees - and potentially have to find additional sources of water to send to Texas, as a way to make up for its groundwater pumping. According to Barncastle, the case is motivating stakeholders in southern New Mexico to work on a framework for better groundwater management. The impacts of climate change are adding yet another layer of uncertainty, since no one knows how weather patterns might affect water scarcity in the future. Regardless, the outcome will have major implications, says southern New Mexico Sen. Joe Cervantes. Most of the state's population and industry is located along the riparian corridor. "If the health of the Rio Grande is threatened, then all of those communities are put at risk," Cervantes warned. This story was originally published at High Country News (hcn.org) on 1/23/18   
## 5                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          Subscribe to 2018 Legislative Session Andrés Leighton for Searchlight New Mexico Estrella Becerra, pre-K coordinator for the Gadsden Independent School District, watches Matthew Gonzalez color at Anthony Elementary's "On Track" pre-K in Anthony, New Mexico. The state pre-K program serves about 8,400 children through public schools and private child care centers. New Mexico ranks 49th in child well-being. Wonder what the state's lawmakers are doing about it? We looked at 2,586 legislative ideas on kids and families so you don't have to. Here's what we learned: Lawmakers proposed more than double the number of bills, memorials and resolutions during the Richardson administration than during the Martinez administration. The database shows lawmakers proposed 1,749 legislative initiatives under Democrat Gov. Bill Richardson and 837 initiatives under Republican Gov. Susana Martinez. Does that mean the Richardson administration did more for kids than the Martinez administration? Not necessarily. The total volume of all bills proposed in the eight years under Richardson was bigger: nearly 16,000 compared with slightly more than 9,000. The Martinez count is one year short because the last session of her tenure has just begun. It can be argued that the Legislature has been more effective - or at least more efficient - over the past seven years. The Legislature has gotten about 19 percent of initiatives on kids passed under Martinez, with her signature. About 15 percent of such initiatives passed on Richardson's watch. Inflating the bill volume in the Richardson years were hundreds of one-paragraph funding requests for small-time projects. In the years when New Mexico was cash-flush, these bills - critics would call them pork - would die during the session but then found their way into a secondary budget bill, the "HB2 Jr." For example, the 2008 "junior" budget bill included $43,000 for a youth holiday in Bernalillo; $8,000 for an Albuquerque teen drug treatment program; and $27,000 for a Roswell science fair for kids, among dozens of other line items. There have been no such "junior" bills under Martinez, who has spent most of her tenure climbing out of a recessionary budget hole. Yeah, but what about politics? This article is part of a year-long reporting project centered on child-wellbeing in New Mexico, produced by Searchlight New Mexico, a nonprofit, nonpartisan media organization that seeks to empower New Mexicans to demand honest and effective public policy. Politically, advocates argue Richardson had a more ambitious agenda related to the well-being of kids. And indeed, more sweeping changes did occur, including the creation of what is now the Public Education Department, the beginning of state-funded preschool and the formation of a Children's Cabinet. Furthermore, under Richardson, lawmakers and voters agreed to fund a multi-year raise for teachers with money from the Land Grant Permanent Fund. Martinez - who called Richardson's initiatives "irresponsible spending during prosperous times" in her most recent "State of the State" address - began with her own ambitious agenda to improve the quality of New Mexico public schools. It delivered mixed legislative results. Martinez achieved most of her education agenda - including high-stakes testing, teacher evaluations and Common Core standards - administratively. She won legislative reforms such as the introduction of school grades and some educational appropriations but couldn't get lawmakers to agree on ending "social promotion," her proposal to hold back third-graders who can't read. "Martinez had a Democratic Senate for her entire tenure and a Democratic House for all but two years of it," said Fred Nathan, executive director of Think New Mexico, a Santa Fe-based think tank. "With divided government, there is less likelihood that bills will both pass and be signed, which discourages some legislators from introducing them in the first place." Unsurprisingly, bipartisan legislative actions have a better chance of passing than either all-Democrat or all-Republican efforts. The bad news? Less than 3 percent of bills, etc., were bipartisan. Just 73 of 2,586 legislative actions had bipartisan support. Bipartisan actions were slightly more likely to pass the Legislature and be signed by the governor than actions sponsored by only one party. Bipartisan actions were passed at a rate of 20 percent, or 15 of 73. Compare that with Democratic ideas, 16 percent of which passed - 334 of 2,026 - or Republican, 14 percent of which passed, or 68 of 476. Democrats have controlled far more seats in the Legislature than Republicans over the past 15 years, which in part explains the bigger volume of Democratic proposals. Here's what the database says about what successful and failed initiatives had in common: Initiatives for kids that were successful - and bipartisan - were often voluntary, research-based, solutions-oriented and targeted to the neediest population. That's when legislators crossed party lines. Proposals that were mandatory, universal, unrooted in research and regarded as punitive to kids were likely to drive lawmakers into their political corners and fail. Also likely to fail: proposals that would fundamentally alter the status quo. That's unsurprising, given New Mexico's "traditionalist" political culture - an academic label for regions where decisionmakers seek "to maintain the existing order and the status quo," says Lonna Atkeson, a political science professor at University of New Mexico. "It's hard to move forward, especially when you are poor." Subscribe for New Mexico In Depth stories and news direct to your inbox ___________________________________________________________________ New Mexico In Depth thanks our members and sponsors. New Mexico In Depth is funded by donations from organizations and individuals who support our mission. Please consider contributing by becoming a member or making a one-time donation . 
## 6 New Mexico holds hundreds of inmates past their release date Posted: Updated: ALBUQUERQUE, N.M. (AP) -  Joleen Valencia resisted the temptation to count her days to freedom, knowing that tracking the time only worsened the anxiety of serving a two-year drug-trafficking sentence inside a New Mexico prison. After her sentence started in the spring of 2015, she wanted nothing more than to return to her family's home amid mesas on a reservation north of Albuquerque and stay clean after recovering from a heroin addiction. Especially after her mother died and granddaughter had been born. But rather than agonize, she kept busy, working daily dishwashing shifts to earn 10 cents an hour and eventually enough "good time" for a new parole date: July 13, 2016. "They would tell you, don't count your days, because it's going to make it hard," said Valencia, 50. But she couldn't resist as her parole date neared, making it all the more frustrating when the day came and went. For three more months, Valencia remained incarcerated, one of more than 1,000 inmates identified in New Mexico Corrections Department documents as serving what's known as "in-house parole." An expensive and long-running problem, it routinely has resulted in corrections officials holding inmates for all or part of their parole terms - often because they are unable to find or afford suitable housing outside prison. Sometimes, missing paperwork or administrative backlogs also can rob them of the freedom they've earned. ___ This report is part of the CJ Project, an initiative to broaden the news coverage of criminal justice issues affecting New Mexico's diverse communities, created by the Asian American Journalists Association with funding from the W.K. Kellogg Foundation. For more information: http://www.aaja.org/cj-project ___ The problem of in-house parole isn't unique to New Mexico. Numerous states have histories of holding inmates past their expected parole dates, with some responding to the issue with reforms. But in New Mexico, the problem persists despite efforts to address it. In an email, Mahesh Sita, a corrections spokesman, said reducing the number of release-eligible inmates - the department's term for those on in-house parole - is a priority, despite figures showing a struggle to overcome the problem. A review of state data obtained through public records requests found there were 165 inmates on in-house parole at the start of the fiscal year beginning July 1, amounting to slightly more than the average monthly total since January 2014. Overall, an analysis of the data found the state spent an estimated $10.6 million to incarcerate the thousand inmates who found themselves in the most recent fiscal year on in-house parole - a status some on the list had for years. "Imagine someone sitting there all those years thinking about that date," said Sheila Lewis, a defense attorney in Santa Fe and former director of the New Mexico Women's Justice Project. "I think it's psychologically cruel to tell somebody that if you follow all the rules and you don't lose any of your good time, you'll be out in time for your son's graduation from high school and they look forward to it," she said. "And they miss it." More than three years' worth of state documents showed the primary driving factor of in-house parole has been a shortage of housing and resources for felons, who must arrange for a place to live as a condition of their release on parole. Their limited options include trying to pursue a coveted spot often paid for by a charity or the state at a residential treatment program. They can also apply for a bed at one of the state's privately operated halfway houses, which frequently require security deposits or other payment up front. An average of three-dozen inmates approved for release by the parole board each month over a three-year period ending in mid-2017 remained incarcerated because they were awaiting a bed in a residential treatment program or halfway house. Women, who comprised just more than 10 percent of the prison population, faced tougher odds in winning a timely release, with officials holding them on in-house parole at two and a half times the rate of men in the recent fiscal year. Officials attributed this, in part, to a surge in women's incarceration rates overall and fewer community-based housing options for them as they prepare to re-enter society. But state documents and studies also show that other factors beyond housing have further complicated the problem, including administrative backlogs and incomplete parole files. In the most extreme cases, offenders can spend their entire parole term behind bars, going from prisons directly to neighborhoods without the services or supervision that experts say can help with transitioning back into society. The Corrections Department in the past has acknowledged this can pose a public safety problem. "Simply put, it is not in the interest of public safety," the department said in a 2016 blog for lawmakers. Numerous inmates, like Valencia, saw their release dates come and go, often because prison caseworkers and parole officers, who are woefully understaffed, failed to prepare their parole plans for the parole board to review or fell behind in doing so. The parole board, which operates independently of the Corrections Department, reviews inmates' appeals for release each month. "They get scratched from the docket when we're missing paperwork," said Joann Martinez, the parole board's executive director. "If we don't have that for the parole board, the case can't move forward." Long-lasting solutions have been elusive, though the state has invested in more housing for parolees. Recently, for example, the Corrections Department contracted with charities to add more beds for inmates in re-entry programs, adding 30 for women in Los Lunas, south of Albuquerque. The Corrections Department also seemed to become more diligent about penalizing private prison corporations, which records show housed roughly half of New Mexico's 7,000 inmates last year. In July 2016, documents exchanged between CoreCivic and the state showed the multi-billion dollar corporation was fined $19,150 for keeping 15 women, including Valencia, inside the Northwestern New Mexico Correctional Facility beyond their release date. Valencia's last day as a prisoner finally came Oct. 17, 2016. She's now serving her final months of parole in Albuquerque, while preparing to spend more time again with her family at San Felipe Pueblo once her parole ends. Valencia for years felt too ashamed of her addiction, and the depths she would go for it, to face her family and own children. Now, she hopes the chance to be more involved in their lives again will help her overcome the grief and frustration that's lingered since prison and her time on in-house parole. "It's messed me up but it's still not going to take me down that road of destructive behavior," she said. WEATHER
```

Corpus preparation
------------------

Also, PrepText(). Although, I think it may not work on TIF. Hyphenated words and any excessive spacing in texts. Upstream solution.

Using the ... `cleanNLP` package.

``` r
cleanNLP::cnlp_init_udpipe(model_name="english",feature_flag = FALSE, parser = "none") 
## Loading required namespace: udpipe
#cnlp_init_corenlp(language="en",anno_level = 1L)
ann_corpus <- cleanNLP::cnlp_annotate(nm_news$txt, as_strings = TRUE) 
```

### SetSearchCorpus()

This function performs some cleaning ... It will ... any/all annotation types in theory. Output, however, homogenizes column names to make things easier downstream. Naming conventions established in the `spacyr` package are adopted here. The function performs two or three general tasks. Eliminates spaces. Annotation form varies depending on the annotator, as different folks have different

Adds tuples and their chraracter onsets/offsets. A fairly crude corpus querying language

Lastly, the function splits corpus into a list of dataframes by doc\_id. This facilitates ... any easy solution to ...

``` r
lingr_corpus <- ann_corpus$token %>%
  SetSearchCorpus(doc_var='id', 
                  token_var='word', 
                  lemma_var='lemma', 
                  tag_var='pos', 
                  pos_var='upos',
                  sentence_var='sid',
                  NER_as_tag = FALSE)
```

### GetDocDesc()

``` r
corpuslingr::GetDocDesc(lingr_corpus)$corpus
##    n_docs textLength textType textSent
## 1:     20      12335     2835      742
```

``` r
head(corpuslingr::GetDocDesc(lingr_corpus)$text)
##    doc_id textLength textType textSent
## 1:  text1        958      348       55
## 2: text10        543      256       35
## 3: text11        182      106       11
## 4: text12        474      200       21
## 5: text13        529      247       36
## 6: text14        993      398       61
```

Search function and aggregate functions.
----------------------------------------

We also need to discuss special search terms, eg, `keyPhrase` and `nounPhrase`.

### An in-house corpus querying language (CQL)

Should be 'copy and paste' at his point. See 'Corpus design' post. Tuples and complex corpus search.?

### SimpleSearch()

``` r
search1 <- "<_Vx> <up!>"

lingr_corpus %>%
  corpuslingr::SimpleSearch(search=search1)
##     doc_id         token     tag       lemma
##  1:  text1      sets up  VBZ RP      set up 
##  2: text10     shake up   VB RP    shake up 
##  3: text12      step up   VB IN     step up 
##  4: text13  climbing up  VBG RP   climbe up 
##  5: text13      woke up  VBD RP     wake up 
##  6: text14      stay up   VB IN     stay up 
##  7: text14    teamed up  VBN RP     team up 
##  8: text15   setting up  VBG RP      set up 
##  9: text16      make up   VB RP     make up 
## 10: text16   venture up  VBP RP  venture up 
## 11: text17     comes up  VBZ RP     come up 
## 12: text20        is up  VBZ JJ       be up 
## 13: text20   partner up   VB RP  partner up 
## 14: text20 partnered up  VBD RP  partner up 
## 15: text20   clamber up   VB RP  clamber up 
## 16: text20   growing up  VBG RP     grow up 
## 17: text20      grow up   VB RB     grow up 
## 18:  text4      make up   VB RP     make up 
## 19:  text9      grow up   VB RP     grow up 
## 20:  text9   growing up  VBG RP     grow up
```

### GetContexts()

``` r
search4 <- '<all!> <> <of!>'
corpuslingr::GetContexts(search=search4,corp=lingr_corpus,LW=5, RW = 5)%>%
  corpuslingr::GetKWIC()
##    doc_id       lemma
## 1: text14 all four of
## 2: text19   all or of
## 3: text20 all sort of
## 4:  text6   all or of
##                                                                                              kwic
## 1:                            Burns came out on in <mark> all four of </mark> her events on the ,
## 2: corrections officials holding inmates for <mark> all or of </mark> their terms - often because
## 3:            The draws Native vendors and <mark> all sorts of </mark> visitors from far and wide
## 4: corrections officials holding inmates for <mark> all or of </mark> their terms - often because
```

``` r
nounPhrase
## [1] "(?:(?:<_DT> )?(?:<_Jx> )*)?(?:((<_Nx> )+|<_PRP> ))"
```

### GetSearchFreqs()

``` r
lingr_corpus %>%
  corpuslingr::SimpleSearch(search=search1)%>%
  corpuslingr::GetSearchFreqs(aggBy = 'lemma')
##           lemma txtf docf
##  1:    GROW UP     4    2
##  2:    MAKE UP     2    2
##  3: PARTNER UP     2    1
##  4:     SET UP     2    2
##  5:      BE UP     1    1
##  6: CLAMBER UP     1    1
##  7:  CLIMBE UP     1    1
##  8:    COME UP     1    1
##  9:   SHAKE UP     1    1
## 10:    STAY UP     1    1
## 11:    STEP UP     1    1
## 12:    TEAM UP     1    1
## 13: VENTURE UP     1    1
## 14:    WAKE UP     1    1
```

### GetKWIC()

``` r
search2 <- "<_Jx> <and!> <_Jx>"

corpuslingr::GetContexts(search=search2,corp=lingr_corpus,LW=5, RW = 5)%>%
  corpuslingr::GetKWIC()
##     doc_id                lemma
##  1: text14     third and fourth
##  2: text15     warmer and drier
##  3: text15     early and active
##  4: text19   expensive and long
##  5: text19    overall and fewer
##  6: text20    more and populous
##  7: text20   varied and diverse
##  8: text20         far and wide
##  9: text20    bigger and bigger
## 10:  text5 honest and effective
## 11:  text6   expensive and long
## 12:  text6    overall and fewer
## 13:  text9  economic and social
## 14:  text9   economic and early
##                                                                                                    kwic
##  1:                 1:00.30 ) finished second , <mark> third and fourth </mark> , respectively , at the
##  2:               through early , so continued <mark> warmer and drier </mark> than normal , " Fontenot
##  3:                 We are preparing for an <mark> early and active </mark> and bringing some and crews
##  4:                                 " in- . " An <mark> expensive and long </mark> - , it routinely has
##  5:                       a in women 's rates <mark> overall and fewer </mark> - based options for them
##  6:               young brains draining away to <mark> more and populous </mark> markets . But there 's
##  7:              these human collisions with a <mark> varied and diverse </mark> of people that can add
##  8:                             all sorts of visitors from <mark> far and wide </mark> . The big is the
##  9:                          to , you know , <mark> bigger and bigger </mark> places ? Alonso Estrada :
## 10: empower New Mexicans to demand <mark> honest and effective </mark> public . Politically , advocates
## 11:                                 " in- . " An <mark> expensive and long </mark> - , it routinely has
## 12:                       a in women 's rates <mark> overall and fewer </mark> - based options for them
## 13:                            and , and of the <mark> economic and social </mark> well - of families .
## 14:                    , nonpartisan Coming Monday : <mark> Economic and early </mark> go in ; shows of
```

### GetBOW()

Vector space model, or word embedding

### GetKeyphrases()

The package has one 'specialty' function... most of this is described more thoroughly in this [post]().

``` r
keyPhrase
## [1] "(<_JJ> )*(<_N[A-Z]{1,10}> )+((<_IN> )(<_JJ> )*(<_N[A-Z]{1,10}> )+)?"
```

``` r
lingr_corpus %>%
  #SimpleSearch() %>% add doc_var ~makes it more generic. key_var
  GetKeyPhrases(n=5, key_var ='lemma', flatten=TRUE,jitter=TRUE)
##     doc_id
##  1:  text1
##  2: text10
##  3: text11
##  4: text12
##  5: text13
##  6: text14
##  7: text15
##  8: text16
##  9: text17
## 10: text18
## 11: text19
## 12:  text2
## 13: text20
## 14:  text3
## 15:  text4
## 16:  text5
## 17:  text6
## 18:  text7
## 19:  text8
## 20:  text9
##                                                                                        keyphrases
##  1:                                        West Texas | western New Mexico | Evans | Buffs | WNm 
##  2:                                           Dunn | Libertarians | Libertarian | party | Senate 
##  3:                                      Families Department | Youth | glitch | Medicaid | child 
##  4:    dollar to New Mexico | New Mexico House | democratic lawmaker | productions | Night Shift 
##  5:                      McKenzie Jamieson | dinosaur | Yakima | light | West Valley High School 
##  6:                                        event | Lobos | Aggy | NEW MEXICO Saturday | Palomino 
##  7:                                              La | Thursday | condition | Pajarito | Fontenot 
##  8:                                  northern New Mexico | Romero | Brooks | ATV | lucrative run 
##  9:                                              Colorado State | point | Rams | Jackson | Paige 
## 10:                                              point | New Mexico State | UMKC | Scripps | Inc 
## 11:                                 inmate | Valencia | document | corrections Department | date 
## 12:                                          Morale | Long | Services | meals on wheels | senior 
## 13:                        Paul Solman | Richard Berry | Kyle Guin | Lee Francis | Gary Oppedahl 
## 14: area | New Mexico in recent week | Forecaster | News Editor | dry condition cramp New Mexico 
## 15:            Texas | Mesilla Valley | farmer | Elephant Butte Irrigation District | Rio Grande 
## 16:                                               Richardson | Martinez | lawmaker | bills | kid 
## 17:                                 inmate | Valencia | corrections Department | July | document 
## 18:                                     visit | MST Jan | DISEASECONTROL SAYS | KILLED | Seventy 
## 19:        police | NW New Mexico David Lynch January | northbound lane | belt | SAN JUAN COUNTY 
## 20:                                       child | Minnesota | ranking | Casey Foundation | teens
```

?Reference corpus.
~Perhaps using SOTU.

Multi-term search
-----------------

``` r
#multi-search <- c("")
```

Corpus workflow
---------------

``` r
search4 <- "<_xNP> (<wish&> |<hope&> |<believe&> )"
```
