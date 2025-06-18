# nwis_pull.R
# Copyright (c) 2025 University of Wisconsin–Madison
# Licensed under the MIT License. See LICENSE file for details.

#script uses the dataRetrieval package to ingest data from the USGS: https://doi-usgs.github.io/dataRetrieval/

nwis_data <- readNWISdata(siteNumbers = "04024000",       #USGS site number for St Louis River at Scanlon
                          parameterCd = "00060",          #selects discharge parameter to download in cubic feet per second
                          startDate = "1908-01-01") %>%   #earliest date to include in the data pull
  mutate(discharge_m3s = 0.02831685 * X_00060_00003)      #creating new calculated column for discharge in cubic meters per second

