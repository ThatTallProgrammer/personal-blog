$data_dir = "$PSScriptRoot/v001"

docker run -it --rm -p 8080:8080 -v ${data_dir}:/usr/local/structurizr structurizr/structurizr local