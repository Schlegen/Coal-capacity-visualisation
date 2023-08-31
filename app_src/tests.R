#library(testthat)

setwd(box::file())
source("server.R")

#Tests are un MW

#ARGENTINA 
test_that("Test Argentina 0", {
  country_ISO <- "ARG"
  expected_value <- NA
  year <- 0
  
  query_result <- country_capacities(year)
  query_result <- query_result$coal_capacity[query_result$ISO3 == country_ISO][1]
  expect_equal(is.na(query_result), TRUE)
})

test_that("Test Argentina 2000", {
  country_ISO <- "ARG"
  expected_value <- 375
  year <- 2000
  
  query_result <- country_capacities(year)
  query_result <- query_result$coal_capacity[query_result$ISO3 == country_ISO][1]
  expect_equal(query_result, expected_value)
})

test_that("Test Argentina 2022", {
  country_ISO <- "ARG"
  expected_value <- 495
  year <- 2022
  
  query_result <- country_capacities(year)
  query_result <- query_result$coal_capacity[query_result$ISO3 == country_ISO][1]
  expect_equal(query_result, expected_value)
})


#SLOVENIA
test_that("Test Slovenia 2022", {
  country_ISO <- "SVN"
  expected_value <- 1069
  year <- 2022
  
  query_result <- country_capacities(year)
  query_result <- query_result$coal_capacity[query_result$ISO3 == country_ISO][1]
  expect_equal(query_result, expected_value)
})

test_that("Test Slovenia 2017", {
  country_ISO <- "SVN"
  expected_value <- 1469
  year <- 2017
  
  query_result <- country_capacities(year)
  query_result <- query_result$coal_capacity[query_result$ISO3 == country_ISO][1]
  expect_equal(query_result, expected_value)
})

test_that("Test Slovenia 2013", {
  country_ISO <- "SVN"
  expected_value <- 944
  year <- 2013
  
  query_result <- country_capacities(year)
  query_result <- query_result$coal_capacity[query_result$ISO3 == country_ISO][1]
  expect_equal(query_result, expected_value)
})

test_that("Test Slovenia 2008", {
  country_ISO <- "SVN"
  expected_value <- 1004
  year <- 2008
  
  query_result <- country_capacities(year)
  query_result <- query_result$coal_capacity[query_result$ISO3 == country_ISO][1]
  expect_equal(query_result, expected_value)
})

test_that("Test Slovenia 1972", {
  country_ISO <- "SVN"
  expected_value <- 609
  year <- 1972
  
  query_result <- country_capacities(year)
  query_result <- query_result$coal_capacity[query_result$ISO3 == country_ISO][1]
  expect_equal(query_result, expected_value)
})


