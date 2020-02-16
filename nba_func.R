br_link <- "https://www.basketball-reference.com"

# get players' href
br_href <- function(player) {
  initial <- strsplit(player, " ")[[1]][2] %>% # get the starting letter of players' initials
    substr(., 1, 1) %>%
    tolower() %>%
    paste0(br_link, "/players/", .) %>%
    read_html()
  past <- initial %>%
    html_nodes(xpath = sprintf("//table/tbody/tr/th[1]/a[text()='%s']",
                               player))
  
  # active players are in bold text
  if (length(past) == 0) {
    initial %>%
      html_nodes(xpath = sprintf("//table/tbody/tr/th[1]/strong/
        a[text()='%s']",
                                 player)) %>% html_attr("href") %>% paste0(br_link, .)
  } else {
    past %>% html_attr("href") %>% paste0(br_link, .)
  }
}

# get players' season stats
br_getstats <- function(player) {
  read_html(br_href(player)) %>%
    html_nodes("table") %>% html_table() %>% as.data.frame() %>%
    select(c(1, 2, 3, 6, 8, 10, 11, 13, 14, 21, 24, 25, 26, 27, 28, 30)) %>%
    rename(
      `FG%` = "FG.",
      `3PA` = "X3PA",
      `3P%` = "X3P.",
      `FT%` = "FT."
    ) %>% distinct(Season, .keep_all = T) %>% drop_na("Age") %>% subset(grepl('^\\d+$', .$G)) %>%
    remove_rownames() %>% column_to_rownames(var = "Season")
}

# get players' image
br_getimage <- function(player) {
  read_html(br_href(player)) %>%
    html_nodes("img") %>% `[`(2) %>% html_attr("src")
}

# get players' career summary stats
br_getcareer <- function(player) {
  summary <-
    read_html(br_href(player)) %>% html_nodes(xpath = "//div[@class='stats_pullout']") %>%
    html_text() %>% str_extract_all(pattern = "\\(?[0-9,.]+\\)?") %>% unlist()
  if ("2019" %in% summary) {
    summary %>% `[`(c(6, 8, 10, 21)) %>% data.frame(row.names = c("PTS", "TRB", "AST", "PER")) %>% `names<-`(NULL)
  } else {
    summary %>% `[`(c(2, 3, 4, 10)) %>% data.frame(row.names = c("PTS", "TRB", "AST", "PER")) %>% `names<-`(NULL)
  }
}

# calulating fantasy score
f_formula <- function(x) {
  points <-
    mean(x$PTS) + mean(1.2 * x$TRB) + mean(1.5 * x$AST) + mean(3 * x$STL, na.rm = T) + mean(3 * x$BLK, na.rm = T) - mean(x$TOV, na.rm = T)
  return(round(points, 2))
}