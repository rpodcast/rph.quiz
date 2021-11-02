FROM rocker/r-ver:4.1.0
RUN apt-get update && apt-get install -y  git-core libcurl4-openssl-dev libgit2-dev libicu-dev libsasl2-dev libssl-dev libxml2-dev make pandoc pandoc-citeproc && rm -rf /var/lib/apt/lists/*
RUN echo "options(repos = c(CRAN = 'https://cran.rstudio.com/'), download.file.method = 'libcurl', Ncpus = 4)" >> /usr/local/lib/R/etc/Rprofile.site
RUN R -e 'install.packages("remotes")'
RUN Rscript -e 'remotes::install_version("magrittr",upgrade="never", version = "2.0.1")'
RUN Rscript -e 'remotes::install_version("tibble",upgrade="never", version = "3.1.5")'
RUN Rscript -e 'remotes::install_version("shiny",upgrade="never", version = "1.7.1")'
RUN Rscript -e 'remotes::install_version("config",upgrade="never", version = "0.3.1")'
RUN Rscript -e 'remotes::install_version("whereami",upgrade="never", version = "0.1.9")'
RUN Rscript -e 'remotes::install_version("thematic",upgrade="never", version = "0.1.2.1")'
RUN Rscript -e 'remotes::install_version("shinyWidgets",upgrade="never", version = "0.6.2")'
RUN Rscript -e 'remotes::install_version("shinyjs",upgrade="never", version = "2.0.0")'
RUN Rscript -e 'remotes::install_version("mongolite",upgrade="never", version = "2.3.1")'
RUN Rscript -e 'remotes::install_version("golem",upgrade="never", version = "0.3.1")'
RUN Rscript -e 'remotes::install_version("dplyr",upgrade="never", version = "1.0.7")'
RUN Rscript -e 'remotes::install_github("rstudio/bslib@bea8ee5253b8daeee8300e1d5d4988cdd6161026")'
RUN Rscript -e 'remotes::install_github("JohnCoene/firebase@52a1d94704095296e0e209a5762bc776efdad89b")'
RUN mkdir /build_zone
ADD . /build_zone
WORKDIR /build_zone

# copy cert file
RUN mkdir /deploy_files
RUN cp /build_zone/deploy_files/ca-certificate.crt /deploy_files/ca-certificate.crt
RUN cp /build_zone/firebase.rds /deploy_files/firebase.rds
RUN rm /build_zone/.Rprofile
RUN rm -rf /build_zone/renv

RUN R -e 'remotes::install_local(upgrade="never")'
RUN rm -rf /build_zone

EXPOSE 80
CMD R -e "options('shiny.port'=80,shiny.host='0.0.0.0',golem.app.prod = TRUE);rph.quiz::run_app(with_mongo = TRUE)"
