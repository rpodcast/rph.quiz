## Development workflow

### Pre-reqs

The development process for this application requires the following to be set up:
* A local (or container) version of MongoDB installed and available. This could be installed directly on your development machine, or running as a docker container. If interested in the container version, see the service entry in the `.devcontainer/docker-compose.yml` file.
* Ability to build the application as a Docker container. The build file instructions are contained in the `Dockerfile` file in the root of the repository.
* If using a hosted version of MongoDB in the cloud (for instance Digital Ocean), add any necessary files for authentication such as certificates in the `deploy_files` directory at the root of the repo. In this case, the file is called `ca-certificate.crt`.
* Create both a `.Renviron` and `.env` files that host specific environment variables that will be used to connect to MongoDB. See the corresponding `.Renviron.example` and `.env.example` for the expected syntax.
* Set up an account on Docker Hub and create a Docker Hub repo to host your container image. In this example, the repo is called `rpodcast/rphquizplay`
* If using Digital Ocean to host the application, you will need an account on that service.

### In-app Development 

* Iterate on the application in dev mode. The easiest way is to execute the `run_dev.R` script in this sub directory. Note that you should set the following to ensure dev mode:

```r
options(golem.app.prod = FALSE) # TRUE = production mode, FALSE = development mode
Sys.setenv("GOLEM_CONFIG_ACTIVE" = "dev")
```

* Ensure all package dependencies are recorded in `DESCRIPTION` by running `usethis::use_package("name_of_package")` or `usethis::use_dev_package("name_of_package")` as appropriate.
* Create the Docker file using the function in `03_deploy.R` if the file is not present
* Edit the `Dockerfile` to add the following snippet before the installation of the app package:

```
# copy cert file
RUN mkdir /deploy_files
RUN cp /build_zone/deploy_files/ca-certificate.crt /deploy_files/ca-certificate.crt
RUN rm /build_zone/.Rprofile
RUN rm -rf /build_zone/renv
```

* Build the app container image with the Dockerfile: `docker build -t rphquiz .` where `rphquiz` is the name of the image (can be any string)
* Run a container based on the app image locally as if it was a production version of the container:

```
docker run --env-file=.env -p 5557:80 --name rphlocal rphquiz
```

Where `rphlocal` is a name for the running container (can be any string)

* In your local web browser, visit `localhost:5557`
* If the application has any errors, go back to a terminal and run the following to access the console output in the logs: `docker logs rphlocal`
* Once app is working as expected, make a new tag that is the same as the repo / image name from Docker Hub: `docker tag rphquiz rpodcast/rphquizplay`
* Authenticate to Docker Hub from the command line by running `docker login` and entering your Docker Hub user ID and password at the prompts
* Push the container image to Docker Hub: `docker push rpodcast/rphquizplay`
* If deploying to Digital Ocean apps, use the procedure outlined in https://hosting.analythium.io/how-to-host-shiny-apps-on-the-digitalocean-app-platform/ 