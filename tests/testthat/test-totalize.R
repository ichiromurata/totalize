factor_asis <- function(x){
	factor(x, levels=x)
}

test_that("example1 works", {
	test_mtx <- totalize(CO2, conc, c(Type, Treatment))
	crosstbl <- table(CO2$conc, interaction(CO2$Type, CO2$Treatment, lex.order=TRUE))
	conc_type <- table(CO2$conc, CO2$Type)
	conc_treat <- table(CO2$conc, CO2$Treatment)
	conc_all <- table(CO2$conc)
	type_treat <- table(interaction(CO2$Type, CO2$Treatment, lex.order=TRUE))
	type_all <- table(CO2$Type)
	treat_all <- table(CO2$Treatment)
	total <- nrow(CO2)
	all_col <- c(total, conc_all)
	type_col <- rbind(type_all, conc_type)
	treat_col <- rbind(treat_all, conc_treat)
	cross_col <- rbind(type_treat, crosstbl)
	ans_mtx <- cbind(all_col, type_col, treat_col[, 1], cross_col[, 1:2], treat_col[, 2], cross_col[, 3:4])
	dim_conc <- c("all_conc", unique(CO2$conc))
	dim_type <- factor_asis(c("all_Type", levels(CO2$Type)))
	dim_treat <- factor_asis(c("all_Treatment", levels(CO2$Treatment)))
	dimnames(ans_mtx) <- list(conc = dim_conc, `Type,Treatment` = levels(interaction(dim_type, dim_treat, sep="|", lex.order=TRUE)))
	
	expect_equal(test_mtx, ans_mtx)
})

test_that("example2 works", {
	test_mtx <- totalize(CO2, conc, c(Type, Treatment), uptake, FUN=mean)
	crosstbl <- stats::aggregate(CO2["uptake"], CO2[c("conc", "Type", "Treatment")], FUN=mean)
	conc_type <- stats::aggregate(CO2["uptake"], CO2[c("conc", "Type")], FUN=mean)
	conc_treat <- stats::aggregate(CO2["uptake"], CO2[c("conc", "Treatment")], FUN=mean)
	conc_all <- stats::aggregate(CO2["uptake"], CO2["conc"], FUN=mean)
	type_treat <- stats::aggregate(CO2["uptake"], CO2[c("Type", "Treatment")], FUN=mean)
	type_all <- stats::aggregate(CO2["uptake"], CO2["Type"], FUN=mean)
	treat_all <- stats::aggregate(CO2["uptake"], CO2["Treatment"], FUN=mean)
	total <- mean(CO2$uptake)
	all_col <- c(total, conc_all$uptake)
	type_col <- rbind(t(type_all$uptake), matrix(conc_type$uptake, nrow=7))
	treat_col <- rbind(t(treat_all$uptake), matrix(conc_treat$uptake, nrow=7))
	cross_col <- rbind(t(type_treat$uptake), matrix(crosstbl$uptake, nrow=7))
	ans_mtx <- cbind(all_col, treat_col, type_col[, 1], cross_col[, c(1, 3)], type_col[, 2], cross_col[, c(2, 4)])
	dim_conc <- c("all_conc", unique(CO2$conc))
	dim_type <- factor_asis(c("all_Type", levels(CO2$Type)))
	dim_treat <- factor_asis(c("all_Treatment", levels(CO2$Treatment)))
	dimnames(ans_mtx) <- list(conc = dim_conc, `Type,Treatment` = levels(interaction(dim_type, dim_treat, sep="|", lex.order=TRUE)))
	
	expect_equal(test_mtx, ans_mtx)
})

test_that("example3 works", {
	test_mtx <- totalize(esoph, agegp, c(alcgp, tobgp), ncases)
	crosstbl <- stats::aggregate(esoph["ncases"], esoph[c("agegp", "alcgp", "tobgp")], FUN=sum, drop=FALSE)
	agegp_alcgp <- stats::aggregate(esoph["ncases"], esoph[c("agegp", "alcgp")], FUN=sum, drop=FALSE)
	agegp_tobgp <- stats::aggregate(esoph["ncases"], esoph[c("agegp", "tobgp")], FUN=sum, drop=FALSE)
	agegp_all <- stats::aggregate(esoph["ncases"], esoph["agegp"], FUN=sum, drop=FALSE)
	alcgp_tobgp <- stats::aggregate(esoph["ncases"], esoph[c("alcgp", "tobgp")], FUN=sum, drop=FALSE)
	alcgp_all <- stats::aggregate(esoph["ncases"], esoph["alcgp"], FUN=sum, drop=FALSE)
	tobgp_all <- stats::aggregate(esoph["ncases"], esoph["tobgp"], FUN=sum, drop=FALSE)
	total <- sum(esoph$ncases)
	all_col <- c(total, agegp_all$ncases)
	alcgp_col <- rbind(t(alcgp_all$ncases), matrix(agegp_alcgp$ncases, nrow=6))
	tobgp_col <- rbind(t(tobgp_all$ncases), matrix(agegp_tobgp$ncases, nrow=6))
	cross_col <- rbind(t(alcgp_tobgp$ncases), matrix(crosstbl$ncases, nrow=6))
	ans_mtx <- cbind(all_col, tobgp_col, alcgp_col[, 1], cross_col[, c(1, 5, 9, 13)], alcgp_col[, 2], cross_col[, c(2, 6, 10, 14)], alcgp_col[, 3], cross_col[, c(3, 7, 11, 15)], alcgp_col[, 4], cross_col[, c(4, 8, 12, 16)])
	dim_agegp <- factor_asis(c("all_agegp", levels(esoph$agegp)))
	dim_alcgp <- factor_asis(c("all_alcgp", levels(esoph$alcgp)))
	dim_tobgp <- factor_asis(c("all_tobgp", levels(esoph$tobgp)))
	dimnames(ans_mtx) <- list(agegp = dim_agegp, `alcgp,tobgp` = levels(interaction(dim_alcgp, dim_tobgp, sep="|", lex.order=TRUE)))
	
	expect_equal(test_mtx, ans_mtx)
})

test_that("example4 works", {
	test_df <- totalize(esoph, agegp, c(alcgp, tobgp), ncases, asDF=TRUE, drop=TRUE)
	crosstbl <- stats::aggregate(esoph["ncases"], esoph[c("agegp", "alcgp", "tobgp")], FUN=sum)
	agegp_alcgp <- stats::aggregate(esoph["ncases"], esoph[c("agegp", "alcgp")], FUN=sum)
	agegp_tobgp <- stats::aggregate(esoph["ncases"], esoph[c("agegp", "tobgp")], FUN=sum)
	agegp_all <- stats::aggregate(esoph["ncases"], esoph["agegp"], FUN=sum)
	alcgp_tobgp <- stats::aggregate(esoph["ncases"], esoph[c("alcgp", "tobgp")], FUN=sum)
	alcgp_all <- stats::aggregate(esoph["ncases"], esoph["alcgp"], FUN=sum)
	tobgp_all <- stats::aggregate(esoph["ncases"], esoph["tobgp"], FUN=sum)
	total <- data.frame(agegp="all_agegp", alcgp="all_alcgp", tobgp="all_tobgp", ncases=sum(esoph$ncases))
	agegp_alcgp <- cbind(agegp_alcgp, tobgp="all_tobgp")
	agegp_tobgp <- cbind(agegp_tobgp, alcgp="all_alcgp")
	agegp_all <- cbind(agegp_all, alcgp="all_alcgp", tobgp="all_tobgp")
	alcgp_tobgp <- cbind(alcgp_tobgp, agegp="all_agegp")
	alcgp_all <- cbind(alcgp_all, agegp="all_agegp", tobgp="all_tobgp")
	tobgp_all <- cbind(tobgp_all, agegp="all_agegp", alcgp="all_alcgp")
	ans_df <- rbind(total, agegp_all, alcgp_all, tobgp_all, agegp_alcgp, agegp_tobgp, alcgp_tobgp, crosstbl)
	ans_df <- transform(ans_df, agegp = factor(agegp, levels=c("all_agegp", levels(esoph$agegp))), alcgp = ordered(alcgp, levels=c("all_alcgp", levels(esoph$alcgp))), tobgp = ordered(tobgp, levels=c("all_tobgp", levels(esoph$tobgp))))
	ans_df <- ans_df[order(ans_df$agegp, ans_df$alcgp, ans_df$tobgp), ]
	row.names(ans_df) <- NULL
	
	expect_equal(test_df, ans_df)
})

test_that("example5 works", {
	test_mtx <- totalize(penguins, species, island)
	crosstbl <- table(penguins$species, penguins$island)
	species_all <- table(penguins$species)
	island_all <- table(penguins$island)
	crosstbl[crosstbl == 0] <- NA
	species_all[species_all == 0] <- NA
	island_all[island_all == 0] <- NA
	total <- nrow(penguins)
	all_col <- c(total, species_all)
	cross_col <- rbind(island_all, crosstbl)
	ans_mtx <- cbind(all_col, cross_col)
	dim_species <- factor_asis(c("all_species", levels(penguins$species)))
	dim_island <- factor_asis(c("all_island", levels(penguins$island)))
	dimnames(ans_mtx) <- list(species = dim_species, island = dim_island)
	
	expect_equal(test_mtx, ans_mtx)
})

test_that("example6 works", {
	test_mtx <- totalize(penguins, species, island, body_mass, FUN=sum, na.rm=TRUE)
	crosstbl <- stats::aggregate(penguins["body_mass"], penguins[c("species", "island")], FUN=sum, na.rm=TRUE, drop=FALSE)
	species_all <- stats::aggregate(penguins["body_mass"], penguins["species"], FUN=sum, na.rm=TRUE, drop=FALSE)
	island_all <- stats::aggregate(penguins["body_mass"], penguins["island"], FUN=sum, na.rm=TRUE, drop=FALSE)
	total <- sum(penguins$body_mass, na.rm=TRUE)
	all_col <- c(total, species_all$body_mass)
	cross_col <- rbind(t(island_all$body_mass), matrix(crosstbl$body_mass, nrow=3))
	ans_mtx <- cbind(all_col, cross_col)
	dim_species <- factor_asis(c("all_species", levels(penguins$species)))
	dim_island <- factor_asis(c("all_island", levels(penguins$island)))
	dimnames(ans_mtx) <- list(species = dim_species, island = dim_island)

	expect_equal(test_mtx, ans_mtx)
})

test_that("1-column table", {
	test_mtx <- totalize(esoph, agegp, val=ncases)
	crosstbl <- stats::aggregate(esoph["ncases"], esoph["agegp"], FUN=sum, drop=FALSE)
	total <- sum(esoph$ncases)
	ans_mtx <- matrix(c(total, crosstbl$ncases), ncol=1)
	dimnames(ans_mtx) <- list(agegp = c("all_agegp", levels(esoph$agegp)), "ncases")

	expect_equal(test_mtx, ans_mtx)
})

test_that("weighted mean works (DF)", {
	CO2_Weight <- transform(CO2, weight=rnorm(nrow(CO2), 10, 1))
	CO2_Weight <- transform(CO2_Weight, uptake_w = uptake * weight)
	uptake_w_sum <- totalize(CO2_Weight, Type, Treatment, val=uptake_w, asDF=TRUE)
	weight_sum <- totalize(CO2_Weight, Type, Treatment, val=weight, asDF=TRUE)
	test_df <- transform(uptake_w_sum, uptake_mean = uptake_w_sum$uptake_w / weight_sum$weight)
	crosstbl <- stats::aggregate(CO2_Weight[c("uptake_w", "weight")], CO2[c("Type", "Treatment")], FUN=sum)
	type_all <- stats::aggregate(CO2_Weight[c("uptake_w", "weight")], CO2["Type"], FUN=sum)
	treat_all <- stats::aggregate(CO2_Weight[c("uptake_w", "weight")], CO2["Treatment"], FUN=sum)
	total <- data.frame(Type="all_Type", Treatment="all_Treatment", uptake_w=sum(CO2_Weight$uptake_w), weight=sum(CO2_Weight$weight))
	type_all <- cbind(type_all, Treatment="all_Treatment")
	treat_all <- cbind(treat_all, Type="all_Type")
	ans_df <- rbind(total, type_all, treat_all, crosstbl) |> transform(uptake_mean = uptake_w / weight)
	ans_df <- transform(ans_df, Type = factor(Type, levels=c("all_Type", levels(CO2$Type))), Treatment = factor(Treatment, levels=c("all_Treatment", levels(CO2$Treatment))))
	ans_df <- ans_df[order(ans_df$Type, ans_df$Treatment), c("Type", "Treatment", "uptake_w", "uptake_mean")]
	row.names(ans_df) <- NULL

	expect_equal(test_df, ans_df)
})

test_that("weighted mean works (Matrix)", {
	CO2_Weight <- transform(CO2, weight=rnorm(nrow(CO2), 10, 1))
	CO2_Weight <- transform(CO2_Weight, uptake_w = uptake * weight)
	uptake_w_sum <- totalize(CO2_Weight, Type, Treatment, val=uptake_w)
	weight_sum <- totalize(CO2_Weight, Type, Treatment, val=weight)
	test_mtx <- uptake_w_sum / weight_sum
	crosstbl <- stats::aggregate(CO2_Weight[c("uptake_w", "weight")], CO2[c("Type", "Treatment")], FUN=sum)
	type_all <- stats::aggregate(CO2_Weight[c("uptake_w", "weight")], CO2["Type"], FUN=sum)
	treat_all <- stats::aggregate(CO2_Weight[c("uptake_w", "weight")], CO2["Treatment"], FUN=sum)
	total <- data.frame(Type="all_Type", Treatment="all_Treatment", uptake_w=sum(CO2_Weight$uptake_w), weight=sum(CO2_Weight$weight))
	type_all <- cbind(type_all, Treatment="all_Treatment")
	treat_all <- cbind(treat_all, Type="all_Type")
	ans_df <- rbind(total, type_all, treat_all, crosstbl) |> transform(uptake = uptake_w / weight)
	ans_df <- transform(ans_df, Type = factor(Type, levels=c("all_Type", levels(CO2$Type))), Treatment = factor(Treatment, levels=c("all_Treatment", levels(CO2$Treatment))))
	ans_df <- ans_df[order(ans_df$Type, ans_df$Treatment), ]
	ans_mtx <- matrix(ans_df$uptake, nrow=nlevels(ans_df$Type), byrow=TRUE)
	dimnames(ans_mtx) <- list(Type = levels(ans_df$Type), Treatment = levels(ans_df$Treatment))
	
	expect_equal(test_mtx, ans_mtx)
})

test_that("validate NSE in function 1", {
	agegp <- 1
	ncases <- 1
	test_function <- function(x) {
		totalize(x, agegp, val=ncases)
	}
	test_mtx <- test_function(esoph)
	crosstbl <- stats::aggregate(esoph["ncases"], esoph["agegp"], FUN=sum, drop=FALSE)
	total <- sum(esoph$ncases)
	ans_mtx <- matrix(c(total, crosstbl$ncases), ncol=1)
	dimnames(ans_mtx) <- list(agegp = c("all_agegp", levels(esoph$agegp)), "ncases")

	expect_equal(test_mtx, ans_mtx)
})

test_that("validate NSE in function 2", {
	agegp <- 1
	ncases <- 1
	test_function <- function(x, ...) {
		totalize(x, ...)
	}
	test_mtx <- test_function(esoph, agegp, val=ncases)
	crosstbl <- stats::aggregate(esoph["ncases"], esoph["agegp"], FUN=sum, drop=FALSE)
	total <- sum(esoph$ncases)
	ans_mtx <- matrix(c(total, crosstbl$ncases), ncol=1)
	dimnames(ans_mtx) <- list(agegp = c("all_agegp", levels(esoph$agegp)), "ncases")

	expect_equal(test_mtx, ans_mtx)
})

