library(tidyverse) # data manipulation
library(arulesSequences) # run the sequence mining algorithm

df <- read.csv(file = 'input_data.csv')

# data cleaning -----------------------------------------------------------

df1 <- df %>% 
  group_by(customer.identifier) %>% 
  arrange(purchase.date) %>% 
  #Remove Instances where the same product appears repeatedly
  distinct(customer.identifier, product, .keep_all = TRUE) %>%
  #Create Item ID Within Customer ID
  mutate(item_id = row_number()) %>% 
  select(customer.identifier, purchase.date, item_id, product) %>% 
  ungroup() %>% 
  #Convert Everything to Factor
  mutate(across(.cols = c("customer.identifier", "product"), .f = as.factor))

df1 <- df1[order(df1$customer.identifier),] # descending order

# handle the special case where one person purchased multiple products on the same date  --------
df2 <- df1
# create unique id for each person-date pair
df2$unique<-paste0(as.character(df2$customer.identifier)," ", as.character(df2$purchase.date)) 
df2 <- df2 %>% 
  # if a person purchased multiple products on the same date, 
  # we need to merge these products into a basket like (A,B) on a single row
  # otherwise, cspade will throw an error 
  dplyr::group_by(unique) %>%
  dplyr::summarise(product = paste(product, collapse = ","))

df2$customer.identifier <- word(df2$unique, 1) # restore person id that was lost in the last step
df2$purchase.date <- word(df2$unique, 2)  # restore fill date that was lost in the last step

df2 <- df2 %>% 
  group_by(customer.identifier) %>% 
  arrange(purchase.date) %>% 
  mutate(item_id = row_number()) %>% #Create Item ID Within person ID
  select(customer.identifier, purchase.date, item_id, product) %>% 
  ungroup()

df2 <- df2 %>% arrange(customer.identifier)
  
save(df2,file="df2.Rda")

# c-spade pre-process -----------------------------------------------------

load("df2.Rda")

df2 %>% head(5) %>% knitr::kable()

sessions <-  as(df2 %>% transmute(items = product), "transactions")
transactionInfo(sessions)$sequenceID <- df2$customer.identifier
transactionInfo(sessions)$eventID <- df2$item_id
itemLabels(sessions) <- str_replace_all(itemLabels(sessions), "items=", "")
inspect(head(sessions,10))


# cspade ------------------------------------------------------------------

itemsets <- cspade(sessions, 
                   parameter = list(support = 0.001), 
                   control = list(verbose = FALSE))
inspect((itemsets))
df3 <- itemsets

# output all results
df3 <- as(df3, "data.frame") %>% as_tibble()
df3$pattern <- (str_count(df3$sequence, ",") + 1)
df3 <- df3[order(-df3$support),] # descending
write.csv(x=df3, file="all_results.csv", row.names=FALSE)

# output top results
c <- df3 %>% group_by(pattern) %>% slice_max(order_by = support, n = 20)
write.csv(x=c, file="top_results.csv", row.names=FALSE)


