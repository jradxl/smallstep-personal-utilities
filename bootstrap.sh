#!/bin/bash

source .env

step ca bootstrap --ca-url=${CA_URL} --fingerprint=${CA_FINGERPRINT}

