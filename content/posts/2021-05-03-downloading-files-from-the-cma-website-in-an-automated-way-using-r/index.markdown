---
title: Downloading files from the CMA website in an automated way using R
author: ''
date: '2021-05-03'
slug: []
categories: []
tags:
  - rvest
  - scraping
  - r
  - cma
description: ''
keywords: []
toc: true
---

This post is slightly specific to my work. The Competition and Markets Authority ("CMA") will often publish documents at various points during its cases. I was prompted to write this short piece of code to automate the downloading of these documents when the CMA published 80+ responses from stakeholders to a particular set of working papers.

The code uses the [`rvest`](https://rvest.tidyverse.org/) package to scrape the CMA's website and the `utils` package to download the files.

```
rm(list = ls())

library(rvest)
library(magrittr)
library(utils)

setwd("C:\\Users\\james\\Documents\\Online Platforms Final Report and Appendices")                                         

# -----------------------------------------------------------------------------

# Step 1: Get HTML code
webpage_html <- read_html("https://www.gov.uk/cma-cases/online-platforms-and-digital-advertising-market-study")              

# Step 2: Find relevant part of HTML code
section_html <- webpage_html %>%
  html_node("ul:nth-child(10)") %>%
  html_nodes("a")

# Step 3: Find links in HTML
links <- section_html %>%
  html_attr("href")

## Step 4: Extract document names from webpage text
doc_names <- section_html %>%
  html_text("href")
doc_names <- paste0(doc_names, ".pdf")
doc_names <- gsub(":", "", doc_names)

# Step 5: Download files from links to working directory  
for (i in seq_along(links)) {
  download.file(links[i], doc_names[i], mode = "wb")
}
```

I explain the code below.

## Step 1: Get HTML code

Websites are written in a language called HTML. To view the HTML of any website, you can simply right click and select 'Inspect' (or press `Ctrl`+`Shift`+`I`). 

All [`read_html()`](https://xml2.r-lib.org/reference/read_xml.html) is doing is going to the address inputted and retrieving the HTML of that webpage.

The file it downloads is an XML file. You can play around with it. You will see that it is a list of length 2 (because all HTML pages are made up of two sections: a head and a body).




```r
webpage_html <- read_html("https://www.gov.uk/cma-cases/online-platforms-and-digital-advertising-market-study")  

webpage_html
```

```
## {html_document}
## <html lang="en">
## [1] <head>\n<meta http-equiv="Content-Type" content="text/html; charset=utf-8 ...
## [2] <body>\n    <script>document.body.className = ((document.body.className)  ...
```

The content of webpages are found in the second element of the list (i.e. in the body section). 


```r
xml_child(webpage_html, 2)
```

```
## {html_node}
## <body>
##  [1] <script>document.body.className = ((document.body.className) ? document. ...
##  [2] <div id="global-cookie-message" class="gem-c-cookie-banner govuk-clearfi ...
##  [3] <div id="skiplink-container">\n      <div>\n        <a href="#content" c ...
##  [4] <header role="banner" id="global-header" class=""><div class="header-wra ...
##  [5] <div id="user-satisfaction-survey-container"></div>
##  [6] <div id="global-header-bar"></div>
##  [7] <div id="global-bar" class="global-bar dont-print" data-module="global-b ...
##  [8] <div id="wrapper" class="direction-ltr">\n\n        \n<div class="gem-c- ...
##  [9] <footer class="group js-footer" id="footer" role="contentinfo"><div clas ...
## [10] <div id="global-app-error" class="app-error hidden"></div>
## [11] <script src="https://www.gov.uk/assets/static/header-footer-only-2159177 ...
## [12] <script>if (typeof window.GOVUK === 'undefined') document.body.className ...
## [13] <script src="/assets/government-frontend/application-ad747abfe1bc91b2a7c ...
## [14] <script type="application/ld+json">\n  {\n  "@context": "http://schema.o ...
## [15] <script type="application/ld+json">\n  {\n  "@context": "http://schema.o ...
```

## Step 2: Find relevant part of HTML code

The next step is finding the documents we want to download within those 15 lines of code. But first let's take a step back.

</br>
<style>
div.blue { border-left: 6px solid #002e63; background-color:#eef3fa; padding-left: 30px; padding-right: 20px; padding-top: 0.5px; padding-bottom: 30px}
</style>
<div class = "blue">
### HTML elements/attributes and CSS selectors

HTML pages are made up of **elements**. These elements will typically include an opening tag and a closing tag. If you inspect the HTML of this text (do it!), you will see that it is a paragraph, denoted by an opening tag `<p>` and a closing tag `</p>`.


```r
<p>
  HTML pages are made up of <strong>elements</strong>. These elements will typically include an opening tag and a closing tag. If you inspect the HTML of this text (do it!), you will see that it is a paragraph, denoted by an opening tag <code>&lt;p&gt;</code> and a closing tag <code>&lt;/p&gt;</code>.
</p>
```

There are many other types of elements. For example, headers (`<h1>`, `<h2>`, `<h3>` etc..), links (`<a>`), lists (`<ul>`, `<ol>`, `<li>`), images (`<img>`), dividers (`div`) and many more...

Tags can have **attributes**. The most common attributes are `id` and `class`. These two attributes can be used for example to style the element (e.g. a particular format/colour/style can be defined for elements with a particular `id` or `class`). This is done using Cascading Style Sheets ("CSS"), a language used to define the presentation of HTML documents (HTML- content structure and semantics; CSS- content style and layout).

In CSS, **selectors** can be used to select the HTML elements that you want to style. Similarly, they can be used to identify HTML elements that you want to scrape... The four most important selectors are (the following is taken directly from the `rvest` package's website):

- `p`: selects all `<p>` elements.
- `.title`: selects all elements with `class` "title".
- `p.special`: selects all `<p>` elements with `class` "special".
- `#title`: selects the element with the `id` attribute that equals "title".

This is by no means a complete introduction to HTML, CSS and webpages, but there are plenty of resources out there. If you are interested in learning how to scrape beyond this simple CMA example, this little tutorial isn't going to cut it! You could start with the `rvest` package's own introduction to [HTML and scraping basics](https://rvest.tidyverse.org/articles/rvest.html), but even this is likely to be limited. The [MDN Web Docs](https://developer.mozilla.org/en-US/docs/Web/HTML) produced by Mozilla (the company behind the Firefox web browser) are a good resource for getting familiar with HTML and CSS. In terms of scraping specifically though, I think the best way of learning is to work through some sort of textbook. I personally used Ryan Mitchell's Web Scraping with Python (though if you intend to use R, maybe a different textbook would be best!).
</div>

Anyway- back to the scraping. Let's take it line by line. [`html_node()`](https://rvest.tidyverse.org/reference/html_nodes.html) in this case looks for the first unordered list, `<ul>`, that is also the tenth **child** of its parent (an element's children are the elements nested within it- e.g. `<head>` and `<body>` are children of `<html>`). 


```r
section_html <- webpage_html %>%
  html_node("ul:nth-child(10)")

section_html
```

```
## {html_node}
## <ul>
##  [1] <li>\n    <p><span id="attachment_4c64e01e-e52c-4643-9c5a-9f889954d767"  ...
##  [2] <li>\n    <p><span id="attachment_74c305e9-1fd3-41ad-aecf-142547e6b3dd"  ...
##  [3] <li>\n    <p><span id="attachment_351aee2b-6f3d-410e-8e22-85e67faa7a85"  ...
##  [4] <li>\n    <p><span id="attachment_4efe00e1-895e-44fb-ba9f-6a9f3f153857"  ...
##  [5] <li>\n    <p><span id="attachment_cff0b30b-3ba9-4ce6-8e51-85246ae4d92c"  ...
##  [6] <li>\n    <p><span id="attachment_664caa11-5507-46f1-86f4-f1c01a914d83"  ...
##  [7] <li>\n    <p><span id="attachment_d695ac7f-8fff-4b34-9168-d7ce82ebea32"  ...
##  [8] <li>\n    <p><span id="attachment_1420a80d-abeb-4c05-b657-4238b3ffbd8e"  ...
##  [9] <li>\n    <p><span id="attachment_fe640b1a-ca45-48fe-8ec3-241c5d4db2c7"  ...
## [10] <li>\n    <p><span id="attachment_a8d6b91b-e0c7-49c3-8c21-e9d6c711ddbb"  ...
## [11] <li>\n    <p><span id="attachment_d966df6a-95eb-4d7c-b2b1-645a15596e7e"  ...
## [12] <li>\n    <p><span id="attachment_30c3ea1a-13e8-418c-874d-6f897433bb7f"  ...
## [13] <li>\n    <p><span id="attachment_72b942db-272d-4339-a7ec-0995f70e5942"  ...
## [14] <li>\n    <p><span id="attachment_baad26ee-2b29-428d-b7ee-35d248b60c3b"  ...
## [15] <li>\n    <p><span id="attachment_01c05e86-63b2-46cc-b05c-d801f54eb172"  ...
## [16] <li>\n    <p><span id="attachment_98f89a40-0603-42a7-9c2c-85373964b416"  ...
## [17] <li>\n    <p><span id="attachment_892ae18a-5b6c-41c4-93a9-4ac7da88eb4a"  ...
## [18] <li>\n    <p><span id="attachment_76eb511b-d496-44a1-8746-0ecc6484b333"  ...
## [19] <li>\n    <p><span id="attachment_d719eab9-a706-48ab-8421-34946c976655"  ...
## [20] <li>\n    <p><span id="attachment_f08e83c9-7c34-47e0-9ec8-f31b442eb04e"  ...
## ...
```

Let's also view the full HTML code by converting the list to character strings and concatenating them together. If you scroll to the right below, you will see the links to the pdfs and the text that appears on the CMA's website: 'Final report (1.7.20)', 'Appendix A: the legal framework (1.7.20)', Appendix B: summary of responses to our interim report consultation (1.7.20)' etc. 


```r
cat(as.character(section_html))
```

```
## <ul>
## <li>
##     <p><span id="attachment_4c64e01e-e52c-4643-9c5a-9f889954d767" class="attachment-inline"><a href="https://assets.publishing.service.gov.uk/media/5fa557668fa8f5788db46efc/Final_report_Digital_ALT_TEXT.pdf">Final report</a></span> (1.7.20)</p>
##   </li>
##   <li>
##     <p><span id="attachment_74c305e9-1fd3-41ad-aecf-142547e6b3dd" class="attachment-inline"><a href="https://assets.publishing.service.gov.uk/media/5fe494e98fa8f56aed3d5e94/Appendix_A_-_The_legal_framework_v2_-_WEB_-.pdf">Appendix A: the legal framework</a></span> (1.7.20)</p>
##   </li>
##   <li>
##     <p><span id="attachment_351aee2b-6f3d-410e-8e22-85e67faa7a85" class="attachment-inline"><a href="https://assets.publishing.service.gov.uk/media/5efb1c5e3a6f4023c52b800b/Appendix_B_-_Summary_of_responses_to_our_consultation_v.2.pdf">Appendix B: summary of responses to our interim report consultation</a></span> (1.7.20)</p>
##   </li>
##   <li>
##     <p><span id="attachment_4efe00e1-895e-44fb-ba9f-6a9f3f153857" class="attachment-inline"><a href="https://assets.publishing.service.gov.uk/media/5fe49506e90e0712011cb4ea/Appendix_C_-_Market_Outcomes_v.12_WEB_-.pdf">Appendix C: market outcomes</a></span> (1.7.20)</p>
##   </li>
##   <li>
##     <p><span id="attachment_cff0b30b-3ba9-4ce6-8e51-85246ae4d92c" class="attachment-inline"><a href="https://assets.publishing.service.gov.uk/media/5fe4951c8fa8f56af8e88105/Appendix_D_Profitability_of_Google_and_Facebook_non-confidential_WEB.pdf">Appendix D: profitability of Google and Facebook </a></span> (1.7.20)</p>
##   </li>
##   <li>
##     <p><span id="attachment_664caa11-5507-46f1-86f4-f1c01a914d83" class="attachment-inline"><a href="https://assets.publishing.service.gov.uk/media/5fe49531d3bf7f089e48dec9/Appendix_E_Ecosystems_v.2_WEB.pdf">Appendix E: ecosystems of Google and Facebook </a></span> (1.7.20)</p>
##   </li>
##   <li>
##     <p><span id="attachment_d695ac7f-8fff-4b34-9168-d7ce82ebea32" class="attachment-inline"><a href="https://assets.publishing.service.gov.uk/media/5fe495438fa8f56af97b1e6c/Appendix_F_-_role_of_data_in_digital_advertising_v.4_WEB.pdf">Appendix F: the role of data in digital advertising </a></span> (1.7.20)</p>
##   </li>
##   <li>
##     <p><span id="attachment_1420a80d-abeb-4c05-b657-4238b3ffbd8e" class="attachment-inline"><a href="https://assets.publishing.service.gov.uk/media/5fe49554e90e0711ffe07d05/Appendix_G_-_Tracking_and_PETS_v.16_non-confidential_WEB.pdf">Appendix G: the role of tracking in digital advertising </a></span> (1.7.20)</p>
##   </li>
##   <li>
##     <p><span id="attachment_fe640b1a-ca45-48fe-8ec3-241c5d4db2c7" class="attachment-inline"><a href="https://assets.publishing.service.gov.uk/media/5fe4956ad3bf7f089e48deca/Appendix_H_-_search_defaults_v.6_WEB.pdf">Appendix H: default positions in search</a></span> (1.7.20)</p>
##   </li>
##   <li>
##     <p><span id="attachment_a8d6b91b-e0c7-49c3-8c21-e9d6c711ddbb" class="attachment-inline"><a href="https://assets.publishing.service.gov.uk/media/5fe4957c8fa8f56aeff87c12/Appendix_I_-_search_quality_v.3_WEB_.pdf">Appendix I: search quality and economies of scale</a></span> (1.7.20)</p>
##   </li>
##   <li>
##     <p><span id="attachment_d966df6a-95eb-4d7c-b2b1-645a15596e7e" class="attachment-inline"><a href="https://assets.publishing.service.gov.uk/media/5efb1dd2d3bf7f7699160dd6/Appendix_J_-_Facebook_Platform_and_API_access_v4.pdf">Appendix J: Facebook Platform and API access</a></span> (1.7.20)</p>
##   </li>
##   <li>
##     <p><span id="attachment_30c3ea1a-13e8-418c-874d-6f897433bb7f" class="attachment-inline"><a href="https://assets.publishing.service.gov.uk/media/5fe49595d3bf7f089f9998ce/Appendix_K_-_consumer_controls_over_platforms__data_collection_WEB.pdf">Appendix K: consumer controls over platforms’ data collection</a></span> (1.7.20)</p>
##   </li>
##   <li>
##     <p><span id="attachment_72b942db-272d-4339-a7ec-0995f70e5942" class="attachment-inline"><a href="https://assets.publishing.service.gov.uk/media/5efb1e07e90e075c5d587c0b/Appendix_L_-_Overview_of_Academic_Research_and_Consumer_Surveys__v3_.pdf">Appendix L: summary of research on consumers’ attitudes and behaviour</a></span> (1.7.20)</p>
##   </li>
##   <li>
##     <p><span id="attachment_baad26ee-2b29-428d-b7ee-35d248b60c3b" class="attachment-inline"><a href="https://assets.publishing.service.gov.uk/media/5fe495c28fa8f56afaf406d4/Appendix_M_-_intermediation_in_open_display_advertising_WEB.pdf">Appendix M: intermediation in open display advertising </a></span> (1.7.20)</p>
##   </li>
##   <li>
##     <p><span id="attachment_01c05e86-63b2-46cc-b05c-d801f54eb172" class="attachment-inline"><a href="https://assets.publishing.service.gov.uk/media/5fe495d3e90e071205803985/Appendix_N__-_understanding_advertiser_demand_for_digital_advertising_WEB.pdf">Appendix N: understanding advertiser demand for digital advertising</a></span> (1.7.20)</p>
##   </li>
##   <li>
##     <p><span id="attachment_98f89a40-0603-42a7-9c2c-85373964b416" class="attachment-inline"><a href="https://assets.publishing.service.gov.uk/media/5fe495ede90e071205803986/Appendix_O_-_measurement_issues_in_digital_advertising_WEB.pdf">Appendix O: measurement issues in digital advertising </a></span> (1.7.20)</p>
##   </li>
##   <li>
##     <p><span id="attachment_892ae18a-5b6c-41c4-93a9-4ac7da88eb4a" class="attachment-inline"><a href="https://assets.publishing.service.gov.uk/media/5fe496018fa8f56af2a85fea/Appendix_P_-_specialised_search_v.8_WEB.pdf">Appendix P: specialised search</a></span> (1.7.20)</p>
##   </li>
##   <li>
##     <p><span id="attachment_76eb511b-d496-44a1-8746-0ecc6484b333" class="attachment-inline"><a href="https://assets.publishing.service.gov.uk/media/5fe49614e90e0711ffe07d06/Appendix_Q_on_exploitation_of_market_power_in_search_and_display_v.5_Redacted_WEB.pdf">Appendix Q: exploitation of market power </a></span> (1.7.20)</p>
##   </li>
##   <li>
##     <p><span id="attachment_d719eab9-a706-48ab-8421-34946c976655" class="attachment-inline"><a href="https://assets.publishing.service.gov.uk/media/5fe49625e90e071207e10eff/Appendix_R_-_fees_in_the_adtech_stack_WEB.pdf">Appendix R: fees in the adtech stack </a></span> (1.7.20)</p>
##   </li>
##   <li>
##     <p><span id="attachment_f08e83c9-7c34-47e0-9ec8-f31b442eb04e" class="attachment-inline"><a href="https://assets.publishing.service.gov.uk/media/5efb22fbd3bf7f768fdcdfae/Appendix_S_-_the_relationship_between_large_digital_platforms_and_publishers.pdf">Appendix S: the relationship between large digital platforms and publishers</a></span> (1.7.20)</p>
##   </li>
##   <li>
##     <p><span id="attachment_b881abd1-390b-4cbb-8a36-a5b36e09ec4d" class="attachment-inline"><a href="https://assets.publishing.service.gov.uk/media/5efb4d513a6f4023cf12fc8b/Appendix_T_-_Principles_for_evaluating_data_remedies.pdf">Appendix T: our approach to assessing data remedies</a></span> (1.7.20)</p>
##   </li>
##   <li>
##     <p><span id="attachment_44963982-2770-45e7-9a14-ce4d6a82855b" class="attachment-inline"><a href="https://assets.publishing.service.gov.uk/media/5efb5fab3a6f4023d242ed4f/Appendix_U_-_The_Code_v.6.pdf">Appendix U: supporting evidence for the code of conduct</a></span> (1.7.20)</p>
##   </li>
##   <li>
##     <p><span id="attachment_c7e0a166-0359-4198-9a06-0fb17a3c078e" class="attachment-inline"><a href="https://assets.publishing.service.gov.uk/media/5fe36a18d3bf7f08a02c87f6/Appendix_V__-__assessment_of_pro-competition_interventions_in_general_search_1.7.20.pdf">Appendix V: assessment of pro-competition interventions in general search</a></span> (1.7.20)</p>
##   </li>
##   <li>
##     <p><span id="attachment_87ebfa4f-e39f-49bb-b5c9-a43b816a8ff9" class="attachment-inline"><a href="https://assets.publishing.service.gov.uk/media/5fe36a378fa8f56af53c5d68/Appendix_W_-_assessment_of_pro-competition_interventions_in_social_media_1.7.20.pdf">Appendix W: assessment of pro-competition interventions in social media</a></span> (1.7.20)</p>
##   </li>
##   <li>
##     <p><span id="attachment_f7d19d8d-9bcf-4724-a724-de1bf489962e" class="attachment-inline"><a href="https://assets.publishing.service.gov.uk/media/5fe36a658fa8f56af0ac66f2/Appendix_X__-__assessment_of_pro-competition_interventions_to_enable_consumer_choice_over_personalised_advertising_1.7.20.pdf">Appendix X: assessment of pro-competition interventions to enable consumer choice over personalised advertising</a></span> (1.7.20)</p>
##   </li>
##   <li>
##     <p><span id="attachment_6f492f61-b712-46a3-b9e0-f19ce93c2ce1" class="attachment-inline"><a href="https://assets.publishing.service.gov.uk/media/5fe36ab9d3bf7f0898e0776c/Appendix_Y_-_choice_architecture_and_Fairness_by_Design_1.7.20.pdf">Appendix Y: choice architecture and Fairness by Design</a></span> (1.7.20)</p>
##   </li>
##   <li>
##     <p><span id="attachment_5fd6ea5e-5393-4e5a-b7e3-bd23319cf204" class="attachment-inline"><a href="https://assets.publishing.service.gov.uk/media/5efc3f7ae90e075c5aeb9947/Appendix_Z_-_Data_related_interventions_in_digital_advertising_markets.pdf">Appendix Z: assessment of potential data-related interventions in digital advertising markets</a></span> (1.7.20)</p>
##   </li>
##   <li>
##     <p><span id="attachment_26c02dfe-e79f-43d7-8417-08ba306ab6da" class="attachment-inline"><a href="https://assets.publishing.service.gov.uk/media/5efc3f5de90e075c4fa0ac0a/Appendix_ZA_-_Separation_remedies_AD_TECH_SEPARATION_ONLY_v.6.pdf">Appendix ZA: assessment of potential pro-competition interventions to address market power in open display advertising</a></span> (1.7.20)</p>
##   </li>
##   <li>
##     <p><span id="attachment_a8a33a66-c626-4454-93b5-a483c9688c59" class="attachment-inline"><a href="https://assets.publishing.service.gov.uk/media/5efc5cad3a6f4023d3b7a866/Final_Report_Glossary.pdf">Glossary</a></span> (1.7.20)</p>
##   </li>
##   <li>
## <span id="attachment_6330a610-8aad-427a-8456-95e94c89bdd6" class="attachment-inline"><a href="https://assets.publishing.service.gov.uk/media/5efb3fded3bf7f769d2695af/Digital_Advertising_Services_Research.pdf">Qualitative research report prepared by Jigsaw Research</a></span> (1.7.20)</li>
##   <li>
##     <p>Press release: <a href="https://www.gov.uk/government/news/new-regime-needed-to-take-on-tech-giants">New regime needed to take on tech giants</a> (1.7.20)</p>
##   </li>
##   <li>
## <span id="attachment_d11e0063-9cea-4c6a-b5fc-bba0e93b0dfa" class="attachment-inline"><a href="https://assets.publishing.service.gov.uk/media/5f6df85be90e0747c22710b2/CMA_Online_Platforms_and_Digital_Advertising_market_study_presentation__web_.pdf">Presentation slides: summary of final report</a></span> (1.10.20)</li>
## </ul>
```

It might be worth taking another step back though. How do you go about finding the CSS selector for a particular section you might want to scrape? `ul:nth-child(10)` is somewhat specific and doesn't appear directly in the HTML code anywhere. Although this is true, it is possible to get the information from inspecting the webpage (`Ctrl`+`Shift`+`I`), clicking on the specific part of the webpage you are interested in and working out yourself how to uniquely identify it. In the case of downloading files from the CMA website, `ul:nth-child(x)` will usually do the job (provided they don't change the structure of their webpages). For scraping more generally, there will be other ways of identifying the part(s) of the webpage that you want (i.e. not necessarily by referencing the element and whether it is the nth child- see for example the four bullet points in the 'HTML elements/attributes and CSS selectors' section).

Although you can work it out yourself, a much simpler way to find the right CSS selector for basic scraping tasks is to use a helpful tool called CSS SelectorGadget.

</br>
<style>
div.blue { border-left: 6px solid #002e63; background-color:#eef3fa; padding-left: 30px; padding-right: 20px; padding-top: 0.5px; padding-bottom: 30px}
</style>
<div class = "blue">
### CSS SelectorGadget

SelectorGadget is a tool that helps you find the relevant CSS selector for the part of the webpage you want to scrape. You can either save the bookmark at [selectorgadget.com](https://selectorgadget.com/) or download the Chrome extension. Once you launch it, all you need to do is click on the webpage element you want to scrape. It will turn green and the tool will generate a minimal CSS selector for the element (and will highlight in yellow everything else that is matched by the selector). If the CSS selector also matches elements you are not interested in, simply click on elements you don't want to scrape. They will turn red and the tool will generate a more specific CSS selector (this is how we end up with something like `ul:nth-child(10)`).

</div>

Back to the code- ultimately, we want a list of links to the various pdfs. Links are denoted by the `<a>` tag. We thus search for this tag within the HTML code above.


```r
section_html <- section_html %>%
  html_nodes("a")

section_html
```

```
## {xml_nodeset (32)}
##  [1] <a href="https://assets.publishing.service.gov.uk/media/5fa557668fa8f578 ...
##  [2] <a href="https://assets.publishing.service.gov.uk/media/5fe494e98fa8f56a ...
##  [3] <a href="https://assets.publishing.service.gov.uk/media/5efb1c5e3a6f4023 ...
##  [4] <a href="https://assets.publishing.service.gov.uk/media/5fe49506e90e0712 ...
##  [5] <a href="https://assets.publishing.service.gov.uk/media/5fe4951c8fa8f56a ...
##  [6] <a href="https://assets.publishing.service.gov.uk/media/5fe49531d3bf7f08 ...
##  [7] <a href="https://assets.publishing.service.gov.uk/media/5fe495438fa8f56a ...
##  [8] <a href="https://assets.publishing.service.gov.uk/media/5fe49554e90e0711 ...
##  [9] <a href="https://assets.publishing.service.gov.uk/media/5fe4956ad3bf7f08 ...
## [10] <a href="https://assets.publishing.service.gov.uk/media/5fe4957c8fa8f56a ...
## [11] <a href="https://assets.publishing.service.gov.uk/media/5efb1dd2d3bf7f76 ...
## [12] <a href="https://assets.publishing.service.gov.uk/media/5fe49595d3bf7f08 ...
## [13] <a href="https://assets.publishing.service.gov.uk/media/5efb1e07e90e075c ...
## [14] <a href="https://assets.publishing.service.gov.uk/media/5fe495c28fa8f56a ...
## [15] <a href="https://assets.publishing.service.gov.uk/media/5fe495d3e90e0712 ...
## [16] <a href="https://assets.publishing.service.gov.uk/media/5fe495ede90e0712 ...
## [17] <a href="https://assets.publishing.service.gov.uk/media/5fe496018fa8f56a ...
## [18] <a href="https://assets.publishing.service.gov.uk/media/5fe49614e90e0711 ...
## [19] <a href="https://assets.publishing.service.gov.uk/media/5fe49625e90e0712 ...
## [20] <a href="https://assets.publishing.service.gov.uk/media/5efb22fbd3bf7f76 ...
## ...
```

## Step 3: Find links in HTML

If you look at the code above, you will notice that the value of each link's `href` attribute is an address to a pdf. These can all be extracted using [`html_attr()`](https://rvest.tidyverse.org/reference/html_attr.html).


```r
links <- section_html %>%
  html_attr("href")

links
```

```
##  [1] "https://assets.publishing.service.gov.uk/media/5fa557668fa8f5788db46efc/Final_report_Digital_ALT_TEXT.pdf"                                                                                            
##  [2] "https://assets.publishing.service.gov.uk/media/5fe494e98fa8f56aed3d5e94/Appendix_A_-_The_legal_framework_v2_-_WEB_-.pdf"                                                                              
##  [3] "https://assets.publishing.service.gov.uk/media/5efb1c5e3a6f4023c52b800b/Appendix_B_-_Summary_of_responses_to_our_consultation_v.2.pdf"                                                                
##  [4] "https://assets.publishing.service.gov.uk/media/5fe49506e90e0712011cb4ea/Appendix_C_-_Market_Outcomes_v.12_WEB_-.pdf"                                                                                  
##  [5] "https://assets.publishing.service.gov.uk/media/5fe4951c8fa8f56af8e88105/Appendix_D_Profitability_of_Google_and_Facebook_non-confidential_WEB.pdf"                                                     
##  [6] "https://assets.publishing.service.gov.uk/media/5fe49531d3bf7f089e48dec9/Appendix_E_Ecosystems_v.2_WEB.pdf"                                                                                            
##  [7] "https://assets.publishing.service.gov.uk/media/5fe495438fa8f56af97b1e6c/Appendix_F_-_role_of_data_in_digital_advertising_v.4_WEB.pdf"                                                                 
##  [8] "https://assets.publishing.service.gov.uk/media/5fe49554e90e0711ffe07d05/Appendix_G_-_Tracking_and_PETS_v.16_non-confidential_WEB.pdf"                                                                 
##  [9] "https://assets.publishing.service.gov.uk/media/5fe4956ad3bf7f089e48deca/Appendix_H_-_search_defaults_v.6_WEB.pdf"                                                                                     
## [10] "https://assets.publishing.service.gov.uk/media/5fe4957c8fa8f56aeff87c12/Appendix_I_-_search_quality_v.3_WEB_.pdf"                                                                                     
## [11] "https://assets.publishing.service.gov.uk/media/5efb1dd2d3bf7f7699160dd6/Appendix_J_-_Facebook_Platform_and_API_access_v4.pdf"                                                                         
## [12] "https://assets.publishing.service.gov.uk/media/5fe49595d3bf7f089f9998ce/Appendix_K_-_consumer_controls_over_platforms__data_collection_WEB.pdf"                                                       
## [13] "https://assets.publishing.service.gov.uk/media/5efb1e07e90e075c5d587c0b/Appendix_L_-_Overview_of_Academic_Research_and_Consumer_Surveys__v3_.pdf"                                                     
## [14] "https://assets.publishing.service.gov.uk/media/5fe495c28fa8f56afaf406d4/Appendix_M_-_intermediation_in_open_display_advertising_WEB.pdf"                                                              
## [15] "https://assets.publishing.service.gov.uk/media/5fe495d3e90e071205803985/Appendix_N__-_understanding_advertiser_demand_for_digital_advertising_WEB.pdf"                                                
## [16] "https://assets.publishing.service.gov.uk/media/5fe495ede90e071205803986/Appendix_O_-_measurement_issues_in_digital_advertising_WEB.pdf"                                                               
## [17] "https://assets.publishing.service.gov.uk/media/5fe496018fa8f56af2a85fea/Appendix_P_-_specialised_search_v.8_WEB.pdf"                                                                                  
## [18] "https://assets.publishing.service.gov.uk/media/5fe49614e90e0711ffe07d06/Appendix_Q_on_exploitation_of_market_power_in_search_and_display_v.5_Redacted_WEB.pdf"                                        
## [19] "https://assets.publishing.service.gov.uk/media/5fe49625e90e071207e10eff/Appendix_R_-_fees_in_the_adtech_stack_WEB.pdf"                                                                                
## [20] "https://assets.publishing.service.gov.uk/media/5efb22fbd3bf7f768fdcdfae/Appendix_S_-_the_relationship_between_large_digital_platforms_and_publishers.pdf"                                             
## [21] "https://assets.publishing.service.gov.uk/media/5efb4d513a6f4023cf12fc8b/Appendix_T_-_Principles_for_evaluating_data_remedies.pdf"                                                                     
## [22] "https://assets.publishing.service.gov.uk/media/5efb5fab3a6f4023d242ed4f/Appendix_U_-_The_Code_v.6.pdf"                                                                                                
## [23] "https://assets.publishing.service.gov.uk/media/5fe36a18d3bf7f08a02c87f6/Appendix_V__-__assessment_of_pro-competition_interventions_in_general_search_1.7.20.pdf"                                      
## [24] "https://assets.publishing.service.gov.uk/media/5fe36a378fa8f56af53c5d68/Appendix_W_-_assessment_of_pro-competition_interventions_in_social_media_1.7.20.pdf"                                          
## [25] "https://assets.publishing.service.gov.uk/media/5fe36a658fa8f56af0ac66f2/Appendix_X__-__assessment_of_pro-competition_interventions_to_enable_consumer_choice_over_personalised_advertising_1.7.20.pdf"
## [26] "https://assets.publishing.service.gov.uk/media/5fe36ab9d3bf7f0898e0776c/Appendix_Y_-_choice_architecture_and_Fairness_by_Design_1.7.20.pdf"                                                           
## [27] "https://assets.publishing.service.gov.uk/media/5efc3f7ae90e075c5aeb9947/Appendix_Z_-_Data_related_interventions_in_digital_advertising_markets.pdf"                                                   
## [28] "https://assets.publishing.service.gov.uk/media/5efc3f5de90e075c4fa0ac0a/Appendix_ZA_-_Separation_remedies_AD_TECH_SEPARATION_ONLY_v.6.pdf"                                                            
## [29] "https://assets.publishing.service.gov.uk/media/5efc5cad3a6f4023d3b7a866/Final_Report_Glossary.pdf"                                                                                                    
## [30] "https://assets.publishing.service.gov.uk/media/5efb3fded3bf7f769d2695af/Digital_Advertising_Services_Research.pdf"                                                                                    
## [31] "https://www.gov.uk/government/news/new-regime-needed-to-take-on-tech-giants"                                                                                                                          
## [32] "https://assets.publishing.service.gov.uk/media/5f6df85be90e0747c22710b2/CMA_Online_Platforms_and_Digital_Advertising_market_study_presentation__web_.pdf"
```

## Step 4: Extract document names from webpage text

In order to name the documents, we can use the text from the CMA's website. This can be extracted using [`html_text()`](https://rvest.tidyverse.org/reference/html_text.html). We then append the ".pdf" file extension and remove the colon (which isn't a valid character for a file name).


```r
doc_names <- section_html %>%
  html_text("href")
doc_names <- paste0(doc_names, ".pdf")
doc_names <- gsub(":", "", doc_names)

doc_names
```

```
##  [1] "Final report.pdf"                                                                                                         
##  [2] "Appendix A the legal framework.pdf"                                                                                       
##  [3] "Appendix B summary of responses to our interim report consultation.pdf"                                                   
##  [4] "Appendix C market outcomes.pdf"                                                                                           
##  [5] "Appendix D profitability of Google and Facebook .pdf"                                                                     
##  [6] "Appendix E ecosystems of Google and Facebook .pdf"                                                                        
##  [7] "Appendix F the role of data in digital advertising .pdf"                                                                  
##  [8] "Appendix G the role of tracking in digital advertising .pdf"                                                              
##  [9] "Appendix H default positions in search.pdf"                                                                               
## [10] "Appendix I search quality and economies of scale.pdf"                                                                     
## [11] "Appendix J Facebook Platform and API access.pdf"                                                                          
## [12] "Appendix K consumer controls over platforms’ data collection.pdf"                                                         
## [13] "Appendix L summary of research on consumers’ attitudes and behaviour.pdf"                                                 
## [14] "Appendix M intermediation in open display advertising .pdf"                                                               
## [15] "Appendix N understanding advertiser demand for digital advertising.pdf"                                                   
## [16] "Appendix O measurement issues in digital advertising .pdf"                                                                
## [17] "Appendix P specialised search.pdf"                                                                                        
## [18] "Appendix Q exploitation of market power .pdf"                                                                             
## [19] "Appendix R fees in the adtech stack .pdf"                                                                                 
## [20] "Appendix S the relationship between large digital platforms and publishers.pdf"                                           
## [21] "Appendix T our approach to assessing data remedies.pdf"                                                                   
## [22] "Appendix U supporting evidence for the code of conduct.pdf"                                                               
## [23] "Appendix V assessment of pro-competition interventions in general search.pdf"                                             
## [24] "Appendix W assessment of pro-competition interventions in social media.pdf"                                               
## [25] "Appendix X assessment of pro-competition interventions to enable consumer choice over personalised advertising.pdf"       
## [26] "Appendix Y choice architecture and Fairness by Design.pdf"                                                                
## [27] "Appendix Z assessment of potential data-related interventions in digital advertising markets.pdf"                         
## [28] "Appendix ZA assessment of potential pro-competition interventions to address market power in open display advertising.pdf"
## [29] "Glossary.pdf"                                                                                                             
## [30] "Qualitative research report prepared by Jigsaw Research.pdf"                                                              
## [31] "New regime needed to take on tech giants.pdf"                                                                             
## [32] "Presentation slides summary of final report.pdf"
```

## Step 5: Download files from links to working directory 

The final step is simply to download all the files using `download.file()` from the `utils` package. The first argument is the url to download from (Step 3) and the second is the name you want to give the file (Step 4). Remember to set your working directory up front, as that is where the documents will get saved.

```
for (i in seq_along(links)) {
  download.file(links[i], doc_names[i], mode = "wb")
}
```

## Final remarks

That should be enough information to run and understand the code. One thing to bear in mind though is that webpages get edited. As such, the CSS selector that identifies what you want one day may not do so the next. For example, if the CMA adds another set of pdfs to the case page, `ul:nth-child(10)` will no longer be the right CSS selector. Rather, it might now be `ul:nth-child(11)`.

And one final point. The code above is not actually my original code. It has been amended slightly to download the Final Report and all the various appendices of the CMA's [Market Study into Online Platforms and Digital Advertising](https://www.gov.uk/cma-cases/online-platforms-and-digital-advertising-market-study). To amend the code to download a different set of documents, only two lines have to be tweaked:

- The link to the CMA's case page (the first line in step 1)
- The particular section of the case page (the second line of step 2)
