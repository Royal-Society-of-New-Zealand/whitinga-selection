# whitinga-selection: whitinga-selection-excellence
# Authors: Amy Marshall, Jason Gush
# whitinga-selection.r 2021-05-03 10:39:21Z

#excellence threshold to be determined by the panel 
whitinga_selection_excellence <- function(dataframe, ma = 5, pa = 3, ff = 15, fe = 30, threshold = 4.0){
    # exlude applicants with scores below threshold
    dataframe <- filter(dataframe, Score >= threshold)
    
    # draw Maori fellows, i.e. Ethnicity is flagged as Maori or Maori/Pacific Nations
    maori_fellows <- dataframe %>% filter(str_detect(Ethnicity, "Ma")) %>% slice_sample(n = ma) %>% mutate(ballot = "M\u101ori")
    
    # exclude already drawn fellows from the pool
    pool <- dataframe %>% anti_join(maori_fellows, by = c("Gender", "Ethnicity", "id"))
    
    # draw Pacific Nations fellows, i.e. Ethnicity is flagged as Pacific Nations or Maori/Pacific Nations
    pacific_fellows <- pool %>% filter(str_detect(Ethnicity, "Pa")) %>% slice_sample(n = pa) %>% mutate(ballot = "Pacific")
    
    fellows <- bind_rows(maori_fellows, pacific_fellows)
    pool <- pool %>% anti_join(fellows, by = c("Gender", "Ethnicity", "id"))
    
    # determine how many more female fellows are needed
    count_female = fellows %>% filter(Gender == "F") %>% nrow()
    female_fellows_to_select = ff - count_female	
    
    # randomly sort remaining applicant pool
    shuffled_rows <- sample(nrow(pool))
    pool_sorted <- pool[shuffled_rows,]
    
    # select top sorted female and gender diverse applicants until the minimum target
    # of female fellows  has been drawn
    priv_pool <- pool_sorted %>% filter(Gender == "F" | Gender == "GD") 
    head_counter = female_fellows_to_select
    females_drawn = 0
    
    while (females_drawn < female_fellows_to_select && nrow(fellows) + head_counter < fe) {
        new_fellows <- priv_pool %>% slice_head(n = head_counter) %>% mutate(ballot = "Pool")
        females_drawn <- new_fellows %>% filter(Gender == "F") %>% nrow()
        # if the slice is too small, i.e., as one or more gender diverse fellows were drawn
        # in slice, increase the slice size by one and redraw
        head_counter = head_counter + 1
    }
    
    fellows <- bind_rows(fellows, new_fellows)
    
    pool_sorted <- pool_sorted %>% anti_join(new_fellows, by = c("Gender", "Ethnicity", "id"))
    
    # draw from the top of the sort (now largely/exclusively male or non-reponse) all remaining fellows
    fellows_still_to_draw = fe - nrow(fellows)
    new_new_fellows <- pool_sorted %>% slice_head(n = fellows_still_to_draw) %>% mutate(ballot = "Pool")
    
    fellows <- bind_rows(fellows, new_new_fellows)
    unchosen_applicant_list <<- pool_sorted %>% anti_join(fellows, by = c("Gender", "Ethnicity", "id"))
    
    return(fellows)
}
