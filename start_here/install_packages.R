# install_packages.R
# Copyright (c) 2025 University of Wisconsin–Madison
# Licensed under the MIT License. See LICENSE file for details.

# a list required packages
package_list <- c("tidyverse", "dataRetrieval") 

# a list of required packages you already have installed on your machine
installed <- rownames(installed.packages()) 

# a list of required packages you do not have installed on your machine
to_install <- package_list[!package_list %in% installed]

# function to install all required packages missing on your machine
if (length(to_install) > 0) {    
  install.packages(to_install)
}

# load all required packages
lapply(package_list, library, character.only = TRUE)
