My technical blogs

# Project description
This is for sharing my technical stuffs using Jekyll

## Prerequisites
Simply using Docker for development work - also meant composing and testing posts before committing to Github

## Installation

- Checkout codebase from https://github.com/nhantran/nhantran.github.io.git
```bash
git clone https://github.com/nhantran/nhantran.github.io.git myblogs
```

- Run following command to create Docker image:
```bash
cd myblogs
docker build -t myblogs .
```

- Start Docker container for hosting this blogs project
```bash
docker run -d --name blog -v myblogs:/root/myblogs -p 4000:4000 -t myblogs 
```

- Preview the work at localhost:4000