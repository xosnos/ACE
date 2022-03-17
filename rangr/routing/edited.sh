#! /bin/bash
sudo nginx -t
sudo systemctl restart nginx
sudo systemctl restart gunicorn
