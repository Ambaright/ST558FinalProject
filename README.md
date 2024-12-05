# ST558FinalProject

Having an error with the Docker stuff getting pushed to the repo, specifically with some aspect of the docker image that was saved. Here is the code for the Dockerfile:

FROM rstudio/plumber

RUN apt-get update -qq && apt-get install -y libssl-dev libcurl4-gnutls-dev libpng-dev pandoc

RUN R -e "install.packages(c('tidyverse','tidymodels','ranger'))"

COPY myAPI.R myAPI.R
COPY diabetes_binary_health_indicators_BRFSS2015.csv diabetes_binary_health_indicators_BRFSS2015.csv

EXPOSE 8000

ENTRYPOINT ["R", "-e", \
"pr <- plumber::plumb('myAPI.R'); pr$run(host='0.0.0.0', port=8000)"]
