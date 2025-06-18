# SLRE-signals
This repository contains helpful R scripts that pulls public water quality, nutrients, discharge, and phytoplankton data from the St. Louis River Estuary (SLRE) and performs analysis and creates visualizations.
These data and visualizations support the National Estuarine Research Reserve Science Collaborative funded project "Building a collaborative monitoring strategy for a changing St. Louis Estuary" which you can read more about here: https://nerrssciencecollaborative.org/project/Ramage22
Several scripts support visualizations that are used in the project's recommendation report: https://minds.wisconsin.edu/handle/1793/95360

It is the intent to build upon these data synthesis as more public data in the SLRE is collected and publically available.
If you are interested in collaborating and/or requesting public data be added please reach out.

Contributors
Hannah Nicklay – Lead Analyst & Author
hannah.nicklay@wisc.edu 
Peter Birschbach - Analyst

License
All code in this repository was developed under federal funding and is released under the MIT License to support transparency and reuse in environmental research.

Data used in the analyses are sourced from publicly funded programs (e.g., NOAA, EPA, USGS), and are in the public domain unless otherwise noted. Users are encouraged to cite original data providers in downstream use.

Repository Structure
├── start_here/             
│   ├── download_packages.R   # A single script that gets you set up with the needed R packages to run all scripts
│   ├── SWMP_data_download.R  # Instruction on downloading data from the Centralized Data Management Office (CDMO)s
├── data_wrangling/           # scripts that pull data from public sources and formats them for use in other scripts\
│   ├── NWIS.R                # Ingests Water Level data from the Duluth Tidal Station (NOAA Tides and Currents)
│   ├── EPA_WATERQUALITY.R    # Ingests historic SLRE water quality data
│   ├── SWMP_data.R
├── visualizations/           # scripts that summarize and visualize data
├── analysis/                 # scripts that perform statistical analysis
│   ├── SWMP_trends.R         # performs Mann-Kendall trend analysis on SWMP data
