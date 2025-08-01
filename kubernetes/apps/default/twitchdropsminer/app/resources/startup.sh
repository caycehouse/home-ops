#!/bin/sh
cp /TwitchDropsMiner/cookies.jar.import /TwitchDropsMiner/cookies.jar
cp /TwitchDropsMiner/settings.json.import /TwitchDropsMiner/settings.json
python -u main.py -vvv
