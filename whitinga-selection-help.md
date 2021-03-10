# Whitinga Fellowship selection algorithm

## Description

Simple R function to randomly draw fellows from an applicant pool while satisfying, or exceeding, a given set of diversity targets.

## Usage

whitinga_selection(dataframe, ma = 5, pa = 3, ff = 15, fe = 30)

## Arguments

*dataframe* a dataframe of applicants structured as id, Gender coded as c("M", "F", "GD", "NR"), Ethnicity coded as c("ma", "pa", "ma/pa", "pool")  
*ma*        the target minimum draw for Māori fellows  
*pa*        the target minimum draw for Pacific Nation fellows  
*ff*        the target minimum draw for female fellows  
*fe*        the total number of fellows to draw

## Details

The *whitinga_selection* function makes extensive use the dplyr library's slice and filter functions to draw fellows from the different applicant groups.  
Some degree of sense is required of inputs; under plausible real-world applicant populations, it is guarenteed to satisfy Māori and Pasific Nation targets, and unless ma+pa is set high and/or GD population large and a very very unlucky draws, the female fellow target.  

## Value

A dataframe of fe selected Fellows having columns: Gender, Ethnicity, id, and ballot (i.e. group in which the fellow was selected).

## Example

    # Create synthetic population
    
    require(tidyr)
    demo_population <-uncount(data.frame(Gender = rep(c("M", "F", "GD", "NR"), times=4), Ethnicity = rep(c("Ma", "Pa", "Ma/Pa", "Pool"), each=4), Count = c(9,15,3,0,3,3,0,3,3,3,3,0,411,408,3,24)), weights = Count, .id = "id")
    
    # Simulate selection
    require(dplyr)
    require(stringr)
    
    set.seed(0)
    example_selection <- whitinga_selection(demo_population)
    xtabs(~Gender + Ethnicity, example_selection)
    
    #       Ethnicity
    # Gender Ma Ma/Pa Pa Pool
    #     F   3     1  1   13
    #     GD  0     1  0    0
    #     M   2     0  1    6
    #     NR  0     0  0    2
