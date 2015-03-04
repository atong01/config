#!/bin/bash

#Written By Alex Tong January 28, 2015

#This script sets up passwordless-ssh capability on a remote machine from
#Alex Tong's Macbook Pro 2013

mkdir -p ~/.ssh
cat id_rsa.pub >> ~/.ssh/authorized_keys
