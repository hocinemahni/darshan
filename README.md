# Darshan + MPI (Docker)

[![CI](https://github.com/hocinemahni/darshan/actions/workflows/ci.yml/badge.svg)](https://github.com/hocinemahni/darshan/actions/workflows/ci.yml)
![Darshan](https://img.shields.io/badge/Darshan-3.4.3-blue)
![Ubuntu](https://img.shields.io/badge/Ubuntu-22.04-orange)

Docker environment to build and run **Darshan** (runtime + utilities) with **OpenMPI** on Ubuntu 22.04.  
Includes a small **MPI-IO example** (`my_mpi_io.c`) to generate Darshan logs and test I/O instrumentation.

---

## About (EN)

This repository provides a Docker image that installs and compiles Darshan together with OpenMPI on Ubuntu 22.04. It also includes a small MPI-IO example to generate Darshan logs and test I/O instrumentation. Useful for HPC research, teaching, and I/O characterization workflows.

## À propos (FR)

Ce dépôt fournit une image Docker qui installe et compile Darshan (runtime + utilitaires) avec OpenMPI sur Ubuntu 22.04. Il contient un petit exemple MPI-IO pour générer des logs Darshan et valider l’instrumentation I/O. Utile pour la recherche HPC, l’enseignement et l’analyse des E/S.

---

## Contents

- Ubuntu 22.04
- OpenMPI (`mpicc`, `mpirun`)
- Darshan (runtime + utilitaires) depuis le dépôt officiel
- Exemple `my_mpi_io.c`
- Logs Darshan écrits dans `/tmp` (montable sur l’hôte)

Par défaut la build utilise `DARSHAN_TAG=darshan-3.4.3` (modifiable via `--build-arg`).

---

## Build


```bash
# Depuis la racine du repo
docker build -t darshan-mpi:3.4.3 \
  -f darshan_Dockerfile \
  --build-arg DARSHAN_TAG=darshan-3.4.3 .
