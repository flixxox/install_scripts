#!/bin/bash

INSTALL_DIR=${HOME}/local

curl -sSL https://install.python-poetry.org | POETRY_HOME=${INSTALL_DIR} python3 -

BASHRC_PATH="export PATH=${INSTALL_DIR}/bin:\$PATH"

if ! grep -q "${BASHRC_PATH}" "${HOME}/.bashrc"; then
    echo -e "\n${BASHRC_PATH}" >> ${HOME}/.bashrc
fi