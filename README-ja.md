
<!-- README.md is generated from README.Rmd. Please edit that file -->

# totalize

<!-- badges: start -->
<!-- badges: end -->

集計表を作成し、小計・合計を計算するパッケージ

## インストール

次のコマンドでGitHubからインストールできます。

``` r
devtools::install_github("ichiromurata/totalize")
```

# 概要

Rにはデータを集計する様々な関数があります。

`datasets::CO2`のデータを例に取りましょう。データ数のカウントは`table()`で行えます。

``` r
table(interaction(datasets::CO2$Type, datasets::CO2$Treatment))
#> 
#>      Quebec.nonchilled Mississippi.nonchilled         Quebec.chilled    Mississippi.chilled 
#>                     21                     21                     21                     21
```

値の足し上げは`by()`や、

``` r
by(datasets::CO2$uptake, datasets::CO2[c("Type", "Treatment")], sum)
#> Type: Quebec
#> Treatment: nonchilled
#> [1] 742
#> ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ 
#> Type: Mississippi
#> Treatment: nonchilled
#> [1] 545
#> ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ 
#> Type: Quebec
#> Treatment: chilled
#> [1] 666.8
#> ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ 
#> Type: Mississippi
#> Treatment: chilled
#> [1] 332.1
```

`stats::aggregate()`を使うことができます。

``` r
stats::aggregate(datasets::CO2["uptake"], datasets::CO2[c("Type", "Treatment")], sum)
#>          Type  Treatment uptake
#> 1      Quebec nonchilled  742.0
#> 2 Mississippi nonchilled  545.0
#> 3      Quebec    chilled  666.8
#> 4 Mississippi    chilled  332.1
```

しかしこれらを使って小計や合計（上の例では“Type”計、“Treatment”計、合計）を並べた表を
作るには、何回かに分けてそれらを別々に算出し、表を結合する必要があります。

1つのデータレコードを小計と合計に同時に足さなければいけないため、
上のようなコマンドを1回実行するだけではすべてを算出できません。

`totalize`はこれをまとめて行います。

``` r
library(totalize)
totalize(datasets::CO2, c(Type, Treatment), val=uptake, asDF=TRUE)
#>          Type  Treatment uptake
#> 1         all        all 2285.9
#> 2         all nonchilled 1287.0
#> 3         all    chilled  998.9
#> 4      Quebec        all 1408.8
#> 5      Quebec nonchilled  742.0
#> 6      Quebec    chilled  666.8
#> 7 Mississippi        all  877.1
#> 8 Mississippi nonchilled  545.0
#> 9 Mississippi    chilled  332.1
```

さらに、2次元の集計表に展開することができます。

``` r
totalize(datasets::CO2, row=Type, col=Treatment, val=uptake)
#>              Treatment
#> Type             all nonchilled chilled
#>   all         2285.9       1287   998.9
#>   Quebec      1408.8        742   666.8
#>   Mississippi  877.1        545   332.1
```

3つ以上の変数があっても、集計表に展開できます。

``` r
totalize(datasets::CO2, row=Type, col=c(Treatment, conc), val=uptake)
#>              Treatment,conc
#> Type          all|all all|95 all|175 all|250 all|350 all|500 all|675 all|1000 nonchilled|all nonchilled|95 nonchilled|175 nonchilled|250 nonchilled|350 nonchilled|500 nonchilled|675 nonchilled|1000 chilled|all chilled|95 chilled|175 chilled|250 chilled|350 chilled|500 chilled|675 chilled|1000
#>   all          2285.9  147.1   267.4   346.5   368.0   370.5   383.4      403           1287          79.7          150.7          194.8          210.8          210.6          216.1           224.3       998.9       67.4       116.7       151.7       157.2       159.9       167.3        178.7
#>   Quebec       1408.8   84.4   162.5   215.6   228.5   228.8   237.0      252            742          45.8           90.1          112.2          121.1          118.8          124.5           129.5       666.8       38.6        72.4       103.4       107.4       110.0       112.5        122.5
#>   Mississippi   877.1   62.7   104.9   130.9   139.5   141.7   146.4      151            545          33.9           60.6           82.6           89.7           91.8           91.6            94.8       332.1       28.8        44.3        48.3        49.8        49.9        54.8         56.2

totalize(datasets::CO2, row=c(Type, conc), col=Treatment, val=uptake)
#>                   Treatment
#> Type,conc             all nonchilled chilled
#>   all|all          2285.9     1287.0   998.9
#>   all|95            147.1       79.7    67.4
#>   all|175           267.4      150.7   116.7
#>   all|250           346.5      194.8   151.7
#>   all|350           368.0      210.8   157.2
#>   all|500           370.5      210.6   159.9
#>   all|675           383.4      216.1   167.3
#>   all|1000          403.0      224.3   178.7
#>   Quebec|all       1408.8      742.0   666.8
#>   Quebec|95          84.4       45.8    38.6
#>   Quebec|175        162.5       90.1    72.4
#>   Quebec|250        215.6      112.2   103.4
#>   Quebec|350        228.5      121.1   107.4
#>   Quebec|500        228.8      118.8   110.0
#>   Quebec|675        237.0      124.5   112.5
#>   Quebec|1000       252.0      129.5   122.5
#>   Mississippi|all   877.1      545.0   332.1
#>   Mississippi|95     62.7       33.9    28.8
#>   Mississippi|175   104.9       60.6    44.3
#>   Mississippi|250   130.9       82.6    48.3
#>   Mississippi|350   139.5       89.7    49.8
#>   Mississippi|500   141.7       91.8    49.9
#>   Mississippi|675   146.4       91.6    54.8
#>   Mississippi|1000  151.0       94.8    56.2
```

`FUN=sum`などの場合は`na.rm=TRUE`を引数に追加すると、データ中のNAを無視できます。

``` r
# Missing values turn the totals into NA
transform(datasets::CO2, uptake_na=replace(uptake, c(1, 10), NA)) |>
    totalize(row=Type, col=c(Treatment, conc), val=uptake_na)
#>              Treatment,conc
#> Type          all|all all|95 all|175 all|250 all|350 all|500 all|675 all|1000 nonchilled|all nonchilled|95 nonchilled|175 nonchilled|250 nonchilled|350 nonchilled|500 nonchilled|675 nonchilled|1000 chilled|all chilled|95 chilled|175 chilled|250 chilled|350 chilled|500 chilled|675 chilled|1000
#>   all              NA     NA   267.4      NA   368.0   370.5   383.4      403             NA            NA          150.7             NA          210.8          210.6          216.1           224.3       998.9       67.4       116.7       151.7       157.2       159.9       167.3        178.7
#>   Quebec           NA     NA   162.5      NA   228.5   228.8   237.0      252             NA            NA           90.1             NA          121.1          118.8          124.5           129.5       666.8       38.6        72.4       103.4       107.4       110.0       112.5        122.5
#>   Mississippi   877.1   62.7   104.9   130.9   139.5   141.7   146.4      151            545          33.9           60.6           82.6           89.7           91.8           91.6            94.8       332.1       28.8        44.3        48.3        49.8        49.9        54.8         56.2

# Ignoring NAs
transform(datasets::CO2, uptake_na=replace(uptake, c(1, 10), NA)) |>
    totalize(row=Type, col=c(Treatment, conc), val=uptake_na, na.rm=TRUE)
#>              Treatment,conc
#> Type          all|all all|95 all|175 all|250 all|350 all|500 all|675 all|1000 nonchilled|all nonchilled|95 nonchilled|175 nonchilled|250 nonchilled|350 nonchilled|500 nonchilled|675 nonchilled|1000 chilled|all chilled|95 chilled|175 chilled|250 chilled|350 chilled|500 chilled|675 chilled|1000
#>   all          2232.8  131.1   267.4   309.4   368.0   370.5   383.4      403         1233.9          63.7          150.7          157.7          210.8          210.6          216.1           224.3       998.9       67.4       116.7       151.7       157.2       159.9       167.3        178.7
#>   Quebec       1355.7   68.4   162.5   178.5   228.5   228.8   237.0      252          688.9          29.8           90.1           75.1          121.1          118.8          124.5           129.5       666.8       38.6        72.4       103.4       107.4       110.0       112.5        122.5
#>   Mississippi   877.1   62.7   104.9   130.9   139.5   141.7   146.4      151          545.0          33.9           60.6           82.6           89.7           91.8           91.6            94.8       332.1       28.8        44.3        48.3        49.8        49.9        54.8         56.2
```

## 1行（1列）のみの表

`totailze`は1列のみの表も作成できます。

``` r
totalize(datasets::CO2, row=c(Type, Treatment), val=uptake)
#>                         
#> Type,Treatment           uptake
#>   all|all                2285.9
#>   all|nonchilled         1287.0
#>   all|chilled             998.9
#>   Quebec|all             1408.8
#>   Quebec|nonchilled       742.0
#>   Quebec|chilled          666.8
#>   Mississippi|all         877.1
#>   Mississippi|nonchilled  545.0
#>   Mississippi|chilled     332.1
```

1行のみの表を作る場合は、上の表を転置`t()`してください。

``` r
totalize(datasets::CO2, row=c(Type, Treatment), val=uptake) |> t()
#>         Type,Treatment
#>          all|all all|nonchilled all|chilled Quebec|all Quebec|nonchilled Quebec|chilled Mississippi|all Mississippi|nonchilled Mississippi|chilled
#>   uptake  2285.9           1287       998.9     1408.8               742          666.8           877.1                    545               332.1
```

# 四捨五入について

このパッケージでは四捨五入をする関数`awayfromzero()`を提供しています。

Rの`round()`関数は四捨五入ではなく偶数丸めを行います。四捨五入の関数はbase
Rには含まれていません。

ただし、浮動小数点数の丸めには気を付けるべき点があります。
`awayfromzero()`のヘルプページを参照してください。

四捨五入はパイプ演算子`|>`で結んで実行できます。

``` r
totalize(datasets::CO2, row=c(Treatment, conc), col=Type, val=uptake, FUN=mean) |>
    awayfromzero(1)
#>                  Type
#> Treatment,conc     all Quebec Mississippi
#>   all|all         27.2   33.5        20.9
#>   all|95          12.3   14.1        10.5
#>   all|175         22.3   27.1        17.5
#>   all|250         28.9   35.9        21.8
#>   all|350         30.7   38.1        23.3
#>   all|500         30.9   38.1        23.6
#>   all|675         32.0   39.5        24.4
#>   all|1000        33.6   42.0        25.2
#>   nonchilled|all  30.6   35.3        26.0
#>   nonchilled|95   13.3   15.3        11.3
#>   nonchilled|175  25.1   30.0        20.2
#>   nonchilled|250  32.5   37.4        27.5
#>   nonchilled|350  35.1   40.4        29.9
#>   nonchilled|500  35.1   39.6        30.6
#>   nonchilled|675  36.0   41.5        30.5
#>   nonchilled|1000 37.4   43.2        31.6
#>   chilled|all     23.8   31.8        15.8
#>   chilled|95      11.2   12.9         9.6
#>   chilled|175     19.5   24.1        14.8
#>   chilled|250     25.3   34.5        16.1
#>   chilled|350     26.2   35.8        16.6
#>   chilled|500     26.7   36.7        16.6
#>   chilled|675     27.9   37.5        18.3
#>   chilled|1000    29.8   40.8        18.7
```
