#' @export


build_work_sectorISIC4 <- function(CensusData){
        
        CensusData     <- harmonizeIBGE:::check_prepared_to_harmonize(CensusData)
        metadata <- harmonizeIBGE:::get_metadata(CensusData)
        sulfix   <- harmonizeIBGE:::find_sulfixforOccSectors(CensusData)
        
        just_created_vars_list_existedBefore <- exists(x = "just_created_vars", where = .GlobalEnv)
        
        
        crosswalk_location <- system.file("extdata",
                                          "crosswalk_sector_isic4.csv",
                                          package = "harmonizeIBGE")
        
        varList_location <- system.file("extdata",
                                        "varList_sector.csv",
                                        package = "harmonizeIBGE")
        
        crosswalk <- read.csv2(crosswalk_location, stringsAsFactors = F) %>%
                filter(classification == sulfix) %>%
                select(sector_code, sectorISIC4) %>%
                as.data.table()
        
        varList   <- read.csv2(varList_location, stringsAsFactors = F)
        
        if(metadata$type != "pnadc"){
                varName <- varList %>%
                        filter(data == metadata$type & year == metadata$year) %>%
                        .$var_sector
        }else{
                varName <- varList %>%
                        filter(data == metadata$type) %>%
                        .$var_sector
        }
        
        harmonizeIBGE:::check_necessary_vars(CensusData, varName)
        
        age_just_created = F
        check_vars <- harmonizeIBGE:::check_var_existence(CensusData, c("age"))
        if(length(check_vars) > 0){
                CensusData <- eval(parse(text = paste0("build_demographics_age_",metadata$year,"(CensusData)")))
                age_just_created = T
                gc();Sys.sleep(.5);gc()
        }
        
        econActivity_just_created = F
        check_vars <- harmonizeIBGE:::check_var_existence(CensusData, c("econActivity"))
        if(length(check_vars) > 0){
                CensusData <- eval(parse(text = paste0("build_work_econActivity_", metadata$year,"(CensusData)")))
                econActivity_just_created = T
                gc();Sys.sleep(.5);gc()
        }
        
        occupationalStatus_just_created = F
        check_vars <- harmonizeIBGE:::check_var_existence(CensusData, c("occupationalStatus"))
        if(length(check_vars) > 0){
                CensusData <- eval(parse(text = paste0("build_work_occupationalStatus_", metadata$year,"(CensusData)")))
                occupationalStatus_just_created = T
                gc();Sys.sleep(.5);gc()
        }
        
        CensusData[ , sector_code := CensusData[[varName]] ]
        
        setkey(CensusData, "sector_code")
        setkey(crosswalk, "sector_code")
        
        # efficient join using CensusData.table sintax:
        CensusData = CensusData[crosswalk, sectorISIC4 := sectorISIC4] # this causes loss of the metadata
        
        CensusData = harmonizeIBGE:::set_metadata(CensusData, metadata) #recovering metadata...
        
        gc(); Sys.sleep(.3);gc()
        
        CensusData <- CensusData %>%
                select(-sectorISIC4, everything(), sectorISIC4, -sector_code)
        
        CensusData[sectorISIC4 == 0, sectorISIC4 := NA]
        
        CensusData[is.na(occupationalStatus) | occupationalStatus == 0, sectorISIC4 := NA]
        CensusData[is.na(econActivity)       | econActivity == 0      , sectorISIC4 := NA]
        
        CensusData[ occupationalStatus == 1 & is.na(sectorISIC4), sectorISIC4 := 999]
        CensusData[ age < 10, sectorISIC4 := NA]
        
        gc();Sys.sleep(.5);gc()
        
        #if(just_created_vars_list_existedBefore == F){
        #        CensusData <- harmonizeIBGE:::erase_just_created_vars(CensusData)
        #}
        
        if(age_just_created == T){
                CensusData[ ,age := NULL]
        }
        
        if(econActivity_just_created == T){
                CensusData[ ,econActivity := NULL]
        }
        
        if(occupationalStatus_just_created == T){
                CensusData[ , occupationalStatus := NULL]
        } 
        
        gc();Sys.sleep(.5);gc()
        
        CensusData
}

