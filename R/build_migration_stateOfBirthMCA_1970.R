#' Harmonize a set of education variables all at once
#' @param data.frame
#' @value data.frame
#' @export

build_migration_stateOfBirthMCA_1970 <- function(CensusData){
        
        if(!is.data.frame(CensusData)){
                stop("'CensusData' is not a data.frame")
        }
        
        check_vars <- harmonizeIBGE:::check_var_existence(CensusData, c("v030"))
        if(length(check_vars) > 0){
                stop("The following variables are missing from the data: ",
                     paste(check_vars, collapse = ", "))
        }
        
        if(!is.data.table(CensusData)){
                CensusData = as.data.table(CensusData)
        }
        
        metadata    <- harmonizeIBGE:::get_metadata(CensusData)
        
        bornInBrazil_just_created = F
        check_vars <- harmonizeIBGE:::check_var_existence(CensusData, c("bornInBrazil"))
        if(length(check_vars) > 0){
                CensusData <- build_migration_bornInBrazil_1970(CensusData)
                bornInBrazil_just_created = T
        }
        
        data("crosswalk_states_tmp")
        crosswalk_states_tmp =  crosswalk_states_tmp %>%
                filter(year == 1970 & variable == "state_of_birth") %>%
                select(original_code, semi_harmonized_code) %>%
                rename(v030            = original_code,
                       stateOfBirthMCA = semi_harmonized_code) %>%
                as.data.table() %>%
                setkey("v030")
        
        setkey(CensusData, "v030")
        
        CensusData[crosswalk_states_tmp, stateOfBirthMCA := stateOfBirthMCA]
        
        gc(); Sys.sleep(.5);gc()
        
        ## Foreigns  = 999
        CensusData[ bornInBrazil == 0, stateOfBirthMCA := 999]
        
        if(bornInBrazil_just_created == T){
                CensusData[ , bornInBrazil := NULL]
        }
        
        CensusData <- harmonizeIBGE:::set_metadata(Data = CensusData, metadata = metadata) 
        
        gc()
        CensusData
}


