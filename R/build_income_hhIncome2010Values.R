#' Builds a synthetic variable for education attainment - 2010
#' @param data.frame
#' @value data.frame
#' @export


build_income_hhIncome2010Values <- function(CensusData){

        CensusData <- harmonizeIBGE:::check_prepared_to_harmonize(CensusData)
        

        metadata <- harmonizeIBGE:::get_metadata(CensusData)
        
        if(metadata$year == 1960){
                return(CensusData)
        }
        
        idhh_just_created = F
        check_vars <- harmonizeIBGE:::check_var_existence(CensusData, c("idhh"))
        if(length(check_vars) > 0){
                CensusData <- eval(parse(text = paste0("build_identification_idhh_", metadata$year, "(CensusData)")))
                idhh_just_created = T
                gc();Sys.sleep(.5);gc()
        }
        
        hhType_just_created = F
        check_vars <- harmonizeIBGE:::check_var_existence(CensusData, c("hhType"))
        if(length(check_vars) > 0){
                CensusData <- build_household_hhType(CensusData)
                hhType_just_created = T
                gc();Sys.sleep(.5);gc()
        }
        
        nonrelative_just_created = F
        check_vars <- harmonizeIBGE:::check_var_existence(CensusData, c("nonrelative"))
        if(length(check_vars) > 0){
                CensusData <- eval(parse(text = paste0("build_demographics_nonrelative_", metadata$year, "(CensusData)")))
                nonrelative_just_created = T
                gc();Sys.sleep(.5);gc()
        }
        
        totalIncome2010Values_just_created = F
        check_vars <- harmonizeIBGE:::check_var_existence(CensusData, c("totalIncome2010Values"))
        if(length(check_vars) > 0){
                CensusData <- build_income_totalIncome2010Values(CensusData)
                hhIncome2010Values_just_created = T
                gc();Sys.sleep(.5);gc()
        }

        # Copying the income information
        CensusData[ , totalIncome2010Values_tmp := totalIncome2010Values]
        gc();Sys.sleep(.3);gc()
        
        # Just members of the household will have valid values
        CensusData[, totalIncome2010Values_tmp := totalIncome2010Values_tmp*as.numeric(!nonrelative)]
        gc();Sys.sleep(.3);gc()
        
        # Once the incomes will be summed inside the household, we need to replace NAs by zero
        CensusData[is.na(totalIncome2010Values), totalIncome2010Values_tmp := 0]
        gc();Sys.sleep(.3);gc()
        
        # Calculating the total household income
        CensusData[, hhIncome2010Values := sum(totalIncome2010Values_tmp), by=idhh]
        gc();Sys.sleep(.3);gc()
        
        # Non-relatives will be NAs:
        CensusData[nonrelative == 1, hhIncome2010Values := NA]
        gc();Sys.sleep(.3);gc()
        
        # Collective households will be NAs:
        # 0 "private permanent" 
        # 1 "private improvised" 
        # 2 "collective dwelling"
        CensusData[hhType == 2, hhIncome2010Values := NA]

        gc()
        
        CensusData[, totalIncome2010Values_tmp := NULL]
        gc();Sys.sleep(.3);gc()
        

        if(idhh_just_created == T){
                CensusData[, idhh := NULL] 
                gc();Sys.sleep(.1);gc()
        }
        
        if(hhType_just_created == T){
                CensusData[, hhType := NULL] 
                gc();Sys.sleep(.1);gc()
        }
        
        if(nonrelative_just_created == T){
                CensusData[, nonrelative := NULL] 
                gc();Sys.sleep(.1);gc()
        }
        
        if(totalIncome2010Values_just_created == T){
                CensusData[, totalIncome2010Values := NULL] 
                gc();Sys.sleep(.1);gc()
        }
        
        
        gc();Sys.sleep(.3);gc()
        CensusData
}
