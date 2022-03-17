# ACE

### Backend Setup
`ssh -i eecs441.pem ubuntu@34.70.39.80`
Connects to the server

Database is called rangrdb. Has tables `users` and `shots`

`users` table looks like:

| username(varchar 255)| user_id (int) |
| -------------        |:-------------:|
| testuser             | 1             |


`shots` table looks like:

|user_id (int)  | launch_angle (decimal)| launch_speed (decimal)| hang_time (decimal)| distance (decimal)| shot_id (int) | time (timestamp)             |
|:-------------:|:---------------------:|:---------------------:|:------------------:|:-----------------:|:-------------:|:----------------------------:|
|      1        |                  14.1 |                  26.5 |                4.8 |             151.6 |             1 | 2022-03-17 06:38:00.942947   |
