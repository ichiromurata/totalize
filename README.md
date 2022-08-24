
<!-- README.md is generated from README.Rmd. Please edit that file -->

# totalize

<!-- badges: start -->
<!-- badges: end -->

[Japanese README is here.](README-ja.md)

Aggregate values with its group total and put into matrix tables

## Installation

You can install `totalize` from GitHub.

``` r
devtools::install_github("ichiromurata/totalize")
```

## How this works

Summarising data can be acted by `table()`,

``` r
table(interaction(datasets::CO2$Type, datasets::CO2$Treatment))
#> 
#>      Quebec.nonchilled Mississippi.nonchilled         Quebec.chilled 
#>                     21                     21                     21 
#>    Mississippi.chilled 
#>                     21
```

or `by()`,

``` r
by(datasets::CO2$uptake, datasets::CO2[c("Type", "Treatment")], sum)
#> Type: Quebec
#> Treatment: nonchilled
#> [1] 742
#> ------------------------------------------------------------ 
#> Type: Mississippi
#> Treatment: nonchilled
#> [1] 545
#> ------------------------------------------------------------ 
#> Type: Quebec
#> Treatment: chilled
#> [1] 666.8
#> ------------------------------------------------------------ 
#> Type: Mississippi
#> Treatment: chilled
#> [1] 332.1
```

or `stats::aggregate()`.

``` r
stats::aggregate(datasets::CO2["uptake"], datasets::CO2[c("Type", "Treatment")], sum)
#>          Type  Treatment uptake
#> 1      Quebec nonchilled  742.0
#> 2 Mississippi nonchilled  545.0
#> 3      Quebec    chilled  666.8
#> 4 Mississippi    chilled  332.1
```

But if you need subtotals and total (total “Type”, total “Treatment” and
both summed in examples above), you have to calculate them through
several steps, since it involves multiple count of the same data
essentially and can’t be done by one method execution.

`totalize` rolls up these operations.

``` r
library(totalize)
totalize(datasets::CO2, "uptake", c("Type", "Treatment"), sum) |> toDF()
#>          Type  Treatment uptake
#> 1         all        all 2285.9
#> 2      Quebec        all 1408.8
#> 3 Mississippi        all  877.1
#> 4         all nonchilled 1287.0
#> 5      Quebec nonchilled  742.0
#> 6 Mississippi nonchilled  545.0
#> 7         all    chilled  998.9
#> 8      Quebec    chilled  666.8
#> 9 Mississippi    chilled  332.1
```

Further, it provides matrix representation.

``` r
totalize(datasets::CO2, "uptake", c("Type", "Treatment"), sum) |> tomatrix(1)
#>              Treatment
#> Type             all nonchilled chilled
#>   all         2285.9       1287   998.9
#>   Quebec      1408.8        742   666.8
#>   Mississippi  877.1        545   332.1
```

3 or more variables can be put into a (2d) matrix.

``` r
totalize(datasets::CO2, "uptake", c("Type", "Treatment", "conc"), sum) |> tomatrix(1)
#>              Treatment,conc
#> Type          all|all nonchilled|all chilled|all all|95 nonchilled|95
#>   all          2285.9           1287       998.9  147.1          79.7
#>   Quebec       1408.8            742       666.8   84.4          45.8
#>   Mississippi   877.1            545       332.1   62.7          33.9
#>              Treatment,conc
#> Type          chilled|95 all|175 nonchilled|175 chilled|175 all|250
#>   all               67.4   267.4          150.7       116.7   346.5
#>   Quebec            38.6   162.5           90.1        72.4   215.6
#>   Mississippi       28.8   104.9           60.6        44.3   130.9
#>              Treatment,conc
#> Type          nonchilled|250 chilled|250 all|350 nonchilled|350 chilled|350
#>   all                  194.8       151.7   368.0          210.8       157.2
#>   Quebec               112.2       103.4   228.5          121.1       107.4
#>   Mississippi           82.6        48.3   139.5           89.7        49.8
#>              Treatment,conc
#> Type          all|500 nonchilled|500 chilled|500 all|675 nonchilled|675
#>   all           370.5          210.6       159.9   383.4          216.1
#>   Quebec        228.8          118.8       110.0   237.0          124.5
#>   Mississippi   141.7           91.8        49.9   146.4           91.6
#>              Treatment,conc
#> Type          chilled|675 all|1000 nonchilled|1000 chilled|1000
#>   all               167.3      403           224.3        178.7
#>   Quebec            112.5      252           129.5        122.5
#>   Mississippi        54.8      151            94.8         56.2

totalize(datasets::CO2, "uptake", c("Type", "Treatment", "conc"), sum) |> tomatrix(c(1, 3))
#>                   Treatment
#> Type,conc             all nonchilled chilled
#>   all|all          2285.9     1287.0   998.9
#>   Quebec|all       1408.8      742.0   666.8
#>   Mississippi|all   877.1      545.0   332.1
#>   all|95            147.1       79.7    67.4
#>   Quebec|95          84.4       45.8    38.6
#>   Mississippi|95     62.7       33.9    28.8
#>   all|175           267.4      150.7   116.7
#>   Quebec|175        162.5       90.1    72.4
#>   Mississippi|175   104.9       60.6    44.3
#>   all|250           346.5      194.8   151.7
#>   Quebec|250        215.6      112.2   103.4
#>   Mississippi|250   130.9       82.6    48.3
#>   all|350           368.0      210.8   157.2
#>   Quebec|350        228.5      121.1   107.4
#>   Mississippi|350   139.5       89.7    49.8
#>   all|500           370.5      210.6   159.9
#>   Quebec|500        228.8      118.8   110.0
#>   Mississippi|500   141.7       91.8    49.9
#>   all|675           383.4      216.1   167.3
#>   Quebec|675        237.0      124.5   112.5
#>   Mississippi|675   146.4       91.6    54.8
#>   all|1000          403.0      224.3   178.7
#>   Quebec|1000       252.0      129.5   122.5
#>   Mississippi|1000  151.0       94.8    56.2
```

Would you like to ignore NAs? Pass `na.rm=TRUE` to the arguments.

``` r
# Missing values turn the totals into NA
within(datasets::CO2, uptake[c(1, 10)] <- NA) |>
    totalize("uptake", c("Type", "Treatment", "conc"), sum) |> tomatrix(1)
#>              Treatment,conc
#> Type          all|all nonchilled|all chilled|all all|95 nonchilled|95
#>   all              NA             NA       998.9     NA            NA
#>   Quebec           NA             NA       666.8     NA            NA
#>   Mississippi   877.1            545       332.1   62.7          33.9
#>              Treatment,conc
#> Type          chilled|95 all|175 nonchilled|175 chilled|175 all|250
#>   all               67.4   267.4          150.7       116.7      NA
#>   Quebec            38.6   162.5           90.1        72.4      NA
#>   Mississippi       28.8   104.9           60.6        44.3   130.9
#>              Treatment,conc
#> Type          nonchilled|250 chilled|250 all|350 nonchilled|350 chilled|350
#>   all                     NA       151.7   368.0          210.8       157.2
#>   Quebec                  NA       103.4   228.5          121.1       107.4
#>   Mississippi           82.6        48.3   139.5           89.7        49.8
#>              Treatment,conc
#> Type          all|500 nonchilled|500 chilled|500 all|675 nonchilled|675
#>   all           370.5          210.6       159.9   383.4          216.1
#>   Quebec        228.8          118.8       110.0   237.0          124.5
#>   Mississippi   141.7           91.8        49.9   146.4           91.6
#>              Treatment,conc
#> Type          chilled|675 all|1000 nonchilled|1000 chilled|1000
#>   all               167.3      403           224.3        178.7
#>   Quebec            112.5      252           129.5        122.5
#>   Mississippi        54.8      151            94.8         56.2

# Ignoring NAs
within(datasets::CO2, uptake[c(1, 10)] <- NA) |>
    totalize("uptake", c("Type", "Treatment", "conc"), sum, na.rm=TRUE) |> tomatrix(1)
#>              Treatment,conc
#> Type          all|all nonchilled|all chilled|all all|95 nonchilled|95
#>   all          2232.8         1233.9       998.9  131.1          63.7
#>   Quebec       1355.7          688.9       666.8   68.4          29.8
#>   Mississippi   877.1          545.0       332.1   62.7          33.9
#>              Treatment,conc
#> Type          chilled|95 all|175 nonchilled|175 chilled|175 all|250
#>   all               67.4   267.4          150.7       116.7   309.4
#>   Quebec            38.6   162.5           90.1        72.4   178.5
#>   Mississippi       28.8   104.9           60.6        44.3   130.9
#>              Treatment,conc
#> Type          nonchilled|250 chilled|250 all|350 nonchilled|350 chilled|350
#>   all                  157.7       151.7   368.0          210.8       157.2
#>   Quebec                75.1       103.4   228.5          121.1       107.4
#>   Mississippi           82.6        48.3   139.5           89.7        49.8
#>              Treatment,conc
#> Type          all|500 nonchilled|500 chilled|500 all|675 nonchilled|675
#>   all           370.5          210.6       159.9   383.4          216.1
#>   Quebec        228.8          118.8       110.0   237.0          124.5
#>   Mississippi   141.7           91.8        49.9   146.4           91.6
#>              Treatment,conc
#> Type          chilled|675 all|1000 nonchilled|1000 chilled|1000
#>   all               167.3      403           224.3        178.7
#>   Quebec            112.5      252           129.5        122.5
#>   Mississippi        54.8      151            94.8         56.2
```

## Rounding numbers

This package includes a rounding method which rounds half [away from
zero](https://en.wikipedia.org/wiki/Rounding#Round_half_away_from_zero).

There are some difficulties when rounding floating point numbers. See
the help page of the method `awayfromzero()`.

Rounding can be chained by pipe operator `|>`.

``` r
totalize(datasets::CO2, "uptake", c("Type", "Treatment", "conc"), mean) |>
    tomatrix(c(2, 3)) |> awayfromzero(1)
#>                  Type
#> Treatment,conc     all Quebec Mississippi
#>   all|all         27.2   33.5        20.9
#>   nonchilled|all  30.6   35.3        26.0
#>   chilled|all     23.8   31.8        15.8
#>   all|95          12.3   14.1        10.5
#>   nonchilled|95   13.3   15.3        11.3
#>   chilled|95      11.2   12.9         9.6
#>   all|175         22.3   27.1        17.5
#>   nonchilled|175  25.1   30.0        20.2
#>   chilled|175     19.5   24.1        14.8
#>   all|250         28.9   35.9        21.8
#>   nonchilled|250  32.5   37.4        27.5
#>   chilled|250     25.3   34.5        16.1
#>   all|350         30.7   38.1        23.3
#>   nonchilled|350  35.1   40.4        29.9
#>   chilled|350     26.2   35.8        16.6
#>   all|500         30.9   38.1        23.6
#>   nonchilled|500  35.1   39.6        30.6
#>   chilled|500     26.7   36.7        16.6
#>   all|675         32.0   39.5        24.4
#>   nonchilled|675  36.0   41.5        30.5
#>   chilled|675     27.9   37.5        18.3
#>   all|1000        33.6   42.0        25.2
#>   nonchilled|1000 37.4   43.2        31.6
#>   chilled|1000    29.8   40.8        18.7
```
