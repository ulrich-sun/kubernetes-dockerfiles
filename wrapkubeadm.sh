#!/bin/bash
# Script pour initialiser Kubernetes avec des options personnalisées

kubeadm init --pod-network-cidr=192.168.0.0/16
